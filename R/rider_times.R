#library(tidyverse)
#library(lubridate)
#library(purrr)
# Make Timestamps Equation
make_timestamps <- function(start, end){
  ##browser() 
   # How many seconds within the time is given through this difftime function
  length <- as.numeric(difftime(end, start, units = "secs"))
  # Times is created as an empty list
  timestampUTC <- c()
  # Start loop at 1
  timestampUTC[1] <- start
  # Loop for creating new rows for each second
  for(i in 1:length + 1){
    timestampUTC[i] <- timestampUTC[i - 1] + 1
  }
  # Times are converted to datetimes
  as_datetime(timestampUTC)
}

# Make Rider Tibble Function
make_ridertibble <- function(start,end,name_r){
  
  # Start and End Times are given along with Rider Name
  start_time <- as_datetime(start)
  end_time <- as_datetime(end)
 # rname <- as.character(c("Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Dylan & Liv","Nicole & Dylan","Nicole & Dylan","Dylan & Liv","Nicole & Dylan","Nicole & Dylan","Stephen","Stephen","Jonathon & Nicole","Jonathon","Jonathon","Jonathon","Nicole","Nicole","Jonathon"))
  
  
  # Tibble is created
  ridertib <- tibble(starttime,
                     endtime,
                     rider = c(rname))
  # Rider is assigned to each second
  ridertib %>% 
    mutate(timestampUTC = map2(starttime, endtime, make_timestamps)) %>% 
    unnest(timestampUTC)
}


# A short tibble is created for rider and their times
#rider_chart <- make_ridertibble(stime,etime,rname)
#rider_chart


#merge rider tibble with all_points_sf
rider_merge<- function(chart_rider,all_points){
  join <- full_join(chart_rider,all_points, by="timestampUTC")
}
