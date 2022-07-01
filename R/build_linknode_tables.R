#' Download the WFRC MM database from AGRC
#'
#' @details 
#' The Utah AGRC multimodal network database is available at 
#'   https://gis.utah.gov/data/transportation/street-network-analysis/#MultimodalNetwork
#'   
#' For this research we downloaded the information from that file in August 2020.
#' The file we downloaded is available on Box, but is not committed to the 
#' repository for space reasons. This file contains code to download the archived 
#' AGRC network, extract it. 
#' 
#' This function requires the user to have the `7z` command line utility installed
#' and available on the PATH.
#' 
#' @importFrom stringr str_c
download_gdb <- function(filegdb){
  if(!file.exists(filegdb)) {
    zippedgdb <- "data/agrc_network.zip"
    if(!file.exists(zippedgdb)) {
      download.file("https://byu.box.com/shared/static/o2sc6ozzb0j62n3u5gdw2uakj8pfhrvr.zip",
                    zippedgdb)
    }
    system2("7z", c("e", zippedgdb, stringr::str_c("-o", filegdb)) )
    file.remove("data/agrc_network.zip")
  } else {
    message("File is already available")
  }
  
  return(filegdb)
}

#' Extract the roadway links and associated nodes from the WFRC network 
#' based on a bounding box
#' 
#' @param bb An object of class `sf` defining a study area.
#' @param gdb_path A path to the WFRC MM database
#' 
#' @return A list with two objects:
#'   - `links` An object of class `sf` with the link shapes and line attributes
#'   - `nodes` An object of class `sf` with the node shapes
#' 
#' @details
#' The algorithm works as follows:
#'   - extract junctions from geodatabase and filter to junctions in `bb`
#'   - extract links from gdb and filter to links in `bb`
#'   - Identify coordinates for ending and starting points of links
#'   - Determine which junctions are closes
#' 
#' @importFrom sf st_read st_transform st_filter
#' @importFrom dplyr mutate row_number
#' 
#' @examples
#' leaflet() |>
#'   addPolylines(data = mylinks) |>
#'   addCircleMarkers(data = mynodes, color = "black")
#' 
extract_roads <- function(bb, gdb_path){
  
  # to see the layers in the database
  # st_layers(gdb_path)
  
  # get nodes from the dataset
  nodes <- sf::st_read(gdb_path, layer = "NetworkDataset_ND_Junctions") |>
    sf::st_transform(4326) |>
    # create a node id
    dplyr::mutate(id = dplyr::row_number()) |>
    sf::st_filter(sf::st_buffer(bb, 1000))
    
  # get bike / ped / auto linkes
  links <- sf::st_read(gdb_path, layer = "BikePedAuto") |>
    sf::st_transform(4326) |>
    dplyr::filter(BikeNetwork == "Y") |>
    sf::st_cast("MULTILINESTRING") |> 
    sf::st_filter(bb) |> 
    
    dplyr::transmute(
      link_id = dplyr::row_number(), 
      aadt = ifelse(AADT == 0, NA, AADT),
      # the "oneway" field can take three values
      oneway = dplyr::case_when(
        Oneway == "B" ~ 0,  # link goes in both directions
        Oneway == "TF" ~ 1, # link goes in drawn order
        Oneway == "" ~ 2    # link goes against drawn order!
      ),
      type = dplyr::case_when(
        AutoNetwork == "N" & PedNetwork == "Y" ~ "footway",
        CartoCode == "3 US Highways, Unseparated" ~ "trunk",
        CartoCode %in% c("5 Major State Highways, Unseparated",
                         "6 Other State Highways (Institutional)") ~ "primary",
        CartoCode == "8 Major Local Roads, Paved" ~ "secondary",
        CartoCode == "10 Other Federal Aid Eligible Local Roads" ~ "tertiary",
        CartoCode == "11 Other Local, Neighborhood, Rural Roads" ~ "residential"
      ),
      length = Length_Miles,
      speed = Speed, 
      bikelane_l = ifelse(BIKE_L == "", "none", BIKE_L),
      bikelane_r = ifelse(BIKE_R == "", "none", BIKE_R),
    ) 

  # Node identification =======
  # The links don't have any node information on them. So let's extract the
  # first and last points from each polyline. This actually extracts all of them
  link_points <- links |>
    dplyr::select(link_id) |>
    sf::st_cast("POINT") # WARNING: will generate n points for each point.
  
  # now we get the first point of each feature and find the nearest node
  start_nodes <- link_points |> 
    dplyr::group_by(link_id) |> dplyr::slice(1) |>
    sf::st_join(nodes, join = sf::st_nearest_feature) |>
    dplyr::rename(a = id)
  
  # and do the same for the last n() point of each feature
  end_nodes <- link_points |> 
    dplyr::group_by(link_id) |> dplyr::slice(dplyr::n()) |>
    sf::st_join(nodes, join = sf::st_nearest_feature) |>
    dplyr::rename(b = id)
  
  # put the node id's onto the links dataset in the forward direction
  mylinks <- links |>
    dplyr::left_join(start_nodes |> sf::st_set_geometry(NULL), by = "link_id") |>
    dplyr::left_join(end_nodes   |> sf::st_set_geometry(NULL), by = "link_id")  |>
    dplyr::mutate(link_id = as.character(link_id))
  
  
  # If the link goes against the drawn order, replace a and b and reverse the order
  my_backwards_links <- mylinks |>
    dplyr::filter(oneway == "2") |>
    sf::st_reverse() |>
    dplyr::mutate(
      new_a = a,
      new_b = b,
      a = new_b,
      b = new_a,
      bikelane = bikelane_l
    )  |>
    dplyr::select(link_id, a, b, aadt, speed, length, bikelane, type)
    
    
  # If the link is a two-way link, create another link in the reverse direction
  my_reverse_links <- mylinks |>
    dplyr::filter(oneway == "0") |>
    sf::st_reverse() |>
    dplyr::mutate(
      link_id = stringr::str_c(link_id, "_1", sep = ""),
      new_a = a,
      new_b = b,
      a = new_b,
      b = new_a,
      bikelane = bikelane_l,
      aadt = aadt / 2
    ) |>
    dplyr::select(link_id, a, b, aadt, speed, length, bikelane, type)
  
  # forward direction of two-way links
  my_forward_links <- mylinks |>
    dplyr::filter(oneway == "0") |>
    dplyr::transmute(link_id, a, b, aadt = aadt / 2, speed, length, 
                      bikelane = bikelane_r, type)
  
  # standard one-way link directions
  my_normal_links <- mylinks |>
    dplyr::filter(oneway == "1") |>
    dplyr::transmute(link_id, a, b, aadt, speed, length, bikelane = bikelane_r, type)
  
  # remove any nodes that are not part of link endpoints
  mynodes <- nodes |> 
    dplyr::filter(id %in% mylinks$a | id %in% mylinks$b)
  
 
  # Return list of links and nodes ============
  list(
    links = dplyr::bind_rows(my_reverse_links, my_backwards_links, 
                             my_forward_links, my_normal_links) |> 
      dplyr::mutate(id = dplyr::row_number()),
    nodes = mynodes
  )
  
}



#' Write link and node sets to CSV files
#' 
#' @param linknodes A list with two SF objects named `links` and `nodes`
#' @param folder Where the files will be written.
#' @param epsg output crs for shapefile
#' 
#' @details 
#' Writes out three files in the target folder:
#'   - `network.geojson` A map for visualization
#'   - `links.csv` A CSV file of all the links with attributes
#'   - `nodes.csv` A CSV file of all the nodes with coordinates
#' 
#' 
write_linknodes <- function(linknodes, folder, epsg){
  
  # check if folder exists
  if(!dir.exists(folder)) dir.create(folder)
  
  # write links as a geojson for mapping
  sf::st_write(linknodes$links, file.path(folder, "network.geojson"), 
               delete_dsn = TRUE)
  
  #write links as a shapefile for mapping
  sf::st_write(
    sf::st_transform(linknodes$links,epsg),
    file.path(folder, "network.shp"), 
               delete_dsn = TRUE,)
  
  # write links as CSV file
  readr::write_csv(linknodes$links |> sf::st_set_geometry(NULL), 
                   file.path(folder, "links.csv"))
  

  
  # write nodes file
  linknodes$nodes |>
    dplyr::mutate(
      x = sf::st_coordinates(SHAPE)[, 1],
      y = sf::st_coordinates(SHAPE)[, 2]
    ) |>
    sf::st_set_geometry(NULL) |>
    readr::write_csv(file.path(folder, "nodes.csv"))
  
  # if there is a centroid frame, write it out also
  if(!is.null(linknodes$centroids)) {
    linknodes$nodes |>
      dplyr::mutate(
        x = sf::st_coordinates(SHAPE)[, 1],
        y = sf::st_coordinates(SHAPE)[, 2]
      ) |>
      sf::st_set_geometry(NULL) |>
      readr::write_csv(file.path(folder, "centroids.csv"))
  }
  
  file.path(folder, "network.geojson")
}



