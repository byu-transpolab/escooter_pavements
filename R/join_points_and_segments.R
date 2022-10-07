#' Buffer the links to try and join ride data
#' 
#' @param links A sf with links
#' @param all_points_sf A sf with scooter ride points
#' @param distance Radius of buffer (in feet)
#' 
#' @return A points sf with the link identified
#' 
get_links_of_points <- function(links, all_points_sf, distance = -25) {
  
  #links <- sample_frac(links, 0.02)
  
  
  # buffer the links  ==== 
  buffer <- links %>%
    st_transform(2281) %>% # central utah USFT
    st_buffer(dist = distance, singleSide = TRUE)
  
  # spatial join the points to the buffers
  points <- all_points_sf %>%
    #sample_frac(0.1) %>%
    st_transform(2281) %>% # central utah US FT
    st_join(buffer %>% select(link_id))
  
  # cleanup === 
  # What do you do with points that map to multiple links?
  # what is the right buffer distance?
  # Maybe need to exclude points that map to more than two links?
  # two because forward and backward links are on top of each other.
  # 
  # What if we 
  
  
  points
}