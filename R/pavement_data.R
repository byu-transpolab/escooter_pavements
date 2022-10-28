# This is where you write functions that can be called from 
# _targets
# 

#' read all nav recorder data
#' 
#' @param data path to the place where data is stored
#' 
make_link_pavement_data <- function(data){
  
   pavement_sets <- dir(data)
   
   pavement_data <- lapply(pavement_sets, function(set){
     read_scooter_recorder(file.path(data, set))
   })
  
}

#' read nav recorder data
#' 
#' @param path path to one collection set
#' @details 
#' 
read_scooter_recorder <- function(path){
  files <- list.files(path, full.names = TRUE)
  
  # read GNSS files
  gnss <- read_gnss(files[grepl("GNSS.csv", files)])
  
  
  # TODO: read other files, and add them to output lists
  #acc <- read_acc(files[grepl("Acc.csv", files)])
  
  list(
    "gnss" = gnss
  )
}


# TODO: write other functions to read other files and clean them up.

#' Read the gnss file from the scooter path
read_gnss <- function(file){
  
  # [1] "TimestampGNSS [ns]" " UTC time [ms]"     " Lat [deg]"         " Lon [deg]"        
  # [5] " Height [m]"        " Speed [m/s]"       " Heading [deg]"     " Hor Acc [m]"      
  # [9] " Vert Acc [m]"      " Speed Acc [m/s]"   " Heading Acc [deg]"
  gnss <- read_delim(file, delim= ";", col_types = list(
    `TimestampGNSS [ns]` = col_character()
  )) %>%
    set_names("timestamp", "timestampUTC", "lat", "lng", "height", "speed", 
              "heading", "y_acc", "z_acc", "x_acc", "heading_acc")
  
  if(nrow(gnss) == 0){
    warning(str_c("GNSS", file, "contains no information"))
  } else {
    gnss <- gnss %>%
    mutate(
      timestamp = as.numeric(timestamp),
      timestampUTC = as.POSIXct((timestampUTC+0.1)/1000, origin = "1970-01-01")
    )
  }
  
  gnss
}

#' Plot the gnss data from one path
plot_gnss <- function(gnss, leaflet = FALSE){
  sf <- st_as_sf(gnss, coords = c("lng", "lat"), crs = 4326) 
  
  if(leaflet){
    pal <- colorNumeric("reds", gnss$speed)
    leaflet(sf) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addCircleMarkers(color = "red")
    
  }  else {
    
    ggplot(sf, aes(color = speed)) +
      annotation_map_tile("cartodark", zoom = 12) + 
      geom_sf()
    
  }
    
}
