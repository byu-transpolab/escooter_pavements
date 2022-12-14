# This is where you write functions that can be called from 
# _targets
# 

#' search and find gnss and acc metric
#' 
#' @param acc_data_set path to the place where acc  data is stored
#' @param points_sf path to the place for gnss data is stored
#' 

Search_acc_metric <- function(points_sf,acc_data_set){
  
  # filter out folders that are not in the range of the acceleration data
  range_points <- points_sf  %>% 
    #sample_frac(size = .01) %>%
    filter(folder %in% acc_data_set$folder)
  
  # add column for acc metric 
  range_points$metric <- NA

  
  
  #iterate through each row in range_points to find metric for timestamp
  range_points$metric <- unlist(apply(range_points,FUN = interpolate_acc, MARGIN =1, acc_set_data = acc_data_set))
  
  


  
  
  #make_points_gnss(gnss_metric)
    
 
  
range_points
  
}

#' search and find gnss and acc metric
#' 
#' 
#'    
#'    
interpolate_acc <- function(range_gnss,acc_set_data){
  #browser()
  #find folder
  sample<- acc_set_data %>%
    filter(acc_set_data$folder %in% range_gnss$folder)
  
  #get row number of closest match
  j <- which.min(abs(sample$timestamp - range_gnss$timestamp))
  
  #If j is the last row then there is no j+1
  
  if(j == nrow(sample)){
    ym1<- sample$metric[j-1]
    y0 <- sample$metric[j]
    yaverage <- (ym1 + y0) /2
    range_gnss$metric <- yaverage
  }else if( j == 1) { #if J is first there is no j-1
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
  range_gnss$metric
}


