# This is where you write functions that can be called from 
# _targets
# 
# 

#' Summarize a mean value
#' 
#' @param dataset A data frame or tibble with an `x` variable.
summ <- function(dataset) {
  summarize(dataset, mean_x = mean(x))
}


#' read nav recorder data
#' 
#' @param path path to one collection set
#' @details 
#' 
read_scooter_recorder <- function(path){
  files <- list.files(path, full.names = TRUE)
  
  gnss <- read_gnss(files[3])
}


read_gnss <- function(file){
  
  # [1] "TimestampGNSS [ns]" " UTC time [ms]"     " Lat [deg]"         " Lon [deg]"        
  # [5] " Height [m]"        " Speed [m/s]"       " Heading [deg]"     " Hor Acc [m]"      
  # [9] " Vert Acc [m]"      " Speed Acc [m/s]"   " Heading Acc [deg]"
  read_delim(files[grepl("GNSS.csv", files)], delim= ";") %>%
    set_names("timestamp", "timestampUTC", "lat", "lng", "height", "speed", 
              "heading", "y_acc", "z_acc", "x_acc", "heading_acc") %>%
    mutate(
      timestamp = as.character(timestamp),
      timestampUTC = as.POSIXct((timestampUTC+0.1)/1000, origin = "1970-01-01")
    )
}

plot_gnss <- function(gnss){
  sf <- st_as_sf(gnss, coords = c("lng", "lat"), crs = 4326) 
    
  pal <- colorNumeric("reds", gnss$speed)
  leaflet(sf) %>%
    addProviderTiles(providers$CartoDB.DarkMatter) %>%
    addCircleMarkers(color = "red")
    
  ggplot(sf, aes(color = speed)) +
    annotation_map_tile("cartodark", zoom = 2) + 
    geom_sf()
    
}
