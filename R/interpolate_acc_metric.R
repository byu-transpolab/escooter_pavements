# This is where you write functions that can be called from 
# _targets
# 

#' search and find gnss and acc metric
#' 
#' @param acc_data_set path to the place where acc  data is stored
#' @param points_sf path to the place for gnss data is stored
#' 

Search_acc_metric <- function(points_sf,acc_data_set){
  
  #filter out timestamps that are not in the range of the acceleration data
  range_points <- points_sf # %>% filter(timestamp > min(acc_data_set$timestamp), 
  #timestamp < max(acc_data_set$timestamp))
  
  
  range_points$metric <- NA
#' search and find gnss and acc metric
#' 
#' 
#'    
#'    
  interpolate_acc <- function(range_gnss,acc_set_data){
    browser()
    #find folder
    sample<- acc_set_data %>%
      filter(acc_set_data$folder == range_gnss$folder)
    
    #get row number of closest match
    j <- which.min(abs(sample$timestamp - range$timestamp))
    if(j == nrow(sample)){
      ym1<- sample$metric[j-1]
      y0 <- sample$metric[j]
      yaverage <- (ym1 + y0) /2
      range_gnss$metric <- yaverage
    } else if( j == 1) {
      y0 <- sample$metric[j]
      yp1 <- sample$metric[j+1]
      yaverage <- (y0+yp1) /2
      ranges_gnss$metric <- yaverage
    } else {
      ym1 <- sample$metric[j-1]
      y0  <- sample$metric[j]
      yp1 <- sample$metric[j + 1]
      yaverage <- (ym1 + y0 + yp1) / 3
      range_gnss$metric <- yaverage
    }
  }
  #lapply 
  gnss_metric <- apply(range_points,interpolate_acc, margin=1, acc_set_dat = acc_data_set)
  
  #Margin = 1
  #tapply
  #rowwwise and mutate
  


  
  
  
  #gnss_metric <- lapply(range_points, FUN = interpolate_acc ,acc_data_set)
  
  
  
  #loop through gnss_points
  #for(i in 1:nrow(range_points)) {
    
    # match the folders
    #true_false_check <- acc_data_set$folder == range_points$folder[i]
    #if(all(true_false_check == False)) {
     # next
    #} else {
    #acc_data_set_filter <- filter(acc_data_set, acc_data_set$folder == range_points$folder[i])
    
    # find row which is a closest match for gnss point
    #j <- which.min(abs(acc_data_set_filter$timestamp - range_points$timestamp[i]))
    
    #if(abs(acc_data_set$timestamp[j] - range_points$timestamp[i]) > 1e4){
      #next
    #}
    
    # linear interpolate for acc metric
    # we already found the nearest row j to each point i. Let's get the measure
    # at j, j-1, and j+1
    #ym1 <- acc_data_set_filter$metric[j - 1]
    #y0  <- acc_data_set_filter$metric[j]
    #yp1 <- acc_data_set_filter$metric[j + 1]
    
    # ideally, we might want to figure out which side i is from j, but that
    # costs us computation time. other options:
    # linear interp of ym1, yp1
    # yinterp = (range_points$timestamp[i] - acc_data_set$timestamp[j-1]) * 
    #  ((yp1 - ym1)/(acc_data_set$timestamp[j+1] - acc_data_set$timestamp[j-1]))
    # just use y0
    #yinterp = y0
    # average of ym1, y0, yp1
    #yinterp = (ym1 + y0 + yp1)/3
    

   # range_points$metric[i] <- yinterp
    
  

  
}