#' Put all of the points into one big map for us to look at
#' 
#' @param links_pavements A list of the rides and the data that was collected.
#' 
#' 
#' 
make_point_sf <- function(links_pavements){
  
  lapply(links_pavements, function(x){
    if(nrow(x$gnss) > 0){
      x$gnss %>%
        select(timestamp,timestampUTC, lat, lng, folder) %>%
        st_as_sf(coords = c("lng", "lat"), crs = 4326)
    }
  }) %>%
    bind_rows()
  
}


make_point_map <- function(all_points_sf, leaflet = FALSE){
  
  if(leaflet){
    leaflet(all_points_sf) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircles()
  }
  
  
  
}

