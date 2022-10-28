# This is where you write functions that can be called from 
# _targets
# 

#' search and find gnss and acc metric
#' 
#' @param acc_data path to the place where acc  data is stored
#' @param points_sf path to the place for gnss data is stored
#' 

Search_acc_metric <- function(points_sf,acc_list){
  
  gnss_metric <- lapply(points_sf, function(points_sf,acc_list){
    loop_gnss_metric(points_sf,acc_lists)
  })
}
  
#' search and find gnss and acc metric
#' 
#' @param acc_data path to the place where acc  data is stored
#' @param points_sf path to the place for gnss data is stored
#'    
#'    
loop_gnss_metric <- function(points_sf,acc_data){
  
  #filter out timestamps that are not in the range of the acceleration data
  range_points <- points_sf %>% filter(timestamp > min(acc_data$timestamp), 
                                       timestamp < max(acc_data$timestamp))
  

  range_points$metric <- NA
  
  #loop through gnss_points
  for(i in 1:nrow(range_points)) {
    
    # find row which is a closest match for gnss point
    j <- which.min(abs(acc_data$timestamp - range_points$timestamp[i]))
    
    #if(abs(acc_data$timestamp[j] - range_points$timestamp[i]) > 1e4){
      #next
    #}
    
    # linear interpolate for acc metric
    # we already found the nearest row j to each point i. Let's get the measure
    # at j, j-1, and j+1
    ym1 <- acc_data$metric[j - 1]
    y0  <- acc_data$metric[j]
    yp1 <- acc_data$metric[j + 1]
    
    # ideally, we might want to figure out which side i is from j, but that
    # costs us computation time. other options:
    # linear interp of ym1, yp1
    # yinterp = (range_points$timestamp[i] - acc_data$timestamp[j-1]) * 
    #  ((yp1 - ym1)/(acc_data$timestamp[j+1] - acc_data$timestamp[j-1]))
    # just use y0
    #yinterp = y0
    # average of ym1, y0, yp1
    yinterp = (ym1 + y0 + yp1)/3
    

    range_points$metric[i] <- yinterp
    
  }
  
}