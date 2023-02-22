

library(reticulate)
library(zeallot)
use_condaenv("sigproc")
scipy <- import("scipy", convert = TRUE)
scipy$amin(c(1,3,5,7))
argparse <- import("argparse", convert = TRUE)
np <- import("numpy", convert = TRUE)
plt <- import ("matplotlib", convert = TRUE)
subprocess <- import ("subprocess", convert = TRUE)

#' read all nav recorder data
#' 
#' @param accdata path to the place where data is stored
#' 


make_acc_data <- function(accdata){
  acc_pavement_sets <- dir(accdata)
  
  acc_pavement_data <- lapply(acc_pavement_sets, function(set){
    read_acc_recorder(file.path(accdata, set))
  })
  
}

#' read nav recorder acc data
#' 
#' @param accpath path to one collection set
#' @details 
#' 
read_acc_recorder <- function(accpath){
  acc_files <- list.files(accpath, full.names = TRUE)
  acc <- calibrate_acc(acc_files[grepl("Acc.csv", acc_files)])
  
  list(
    "acc" = acc
  )
}

#'Implement Dr. Mazzeo's Process
#'
#'@param file file to porcess
#'@details
#'

calibrate_acc <- function(file) {
  acc <- read_delim(file, delim  = ";", skip = 2)%>%
    set_names("timestamp", "accX", "accY","accZ")
  #Correct error where ; is in the accZ column 
  acc$accZ <- as.numeric(gsub(";", acc$accZ, replacement = ""))
    
  # Get the average time difference of the data set
  avg_time_diff <- (acc$timestamp[length(acc$timestamp)] - acc$timestamp[1]) / (length(acc$timestamp))
  # Estimate the Sampling frequency (HZ)
  fs <- 1 /(avg_time_diff * 10**-9)
  
  #Process the means of the accelerations
  
  x_mean <- mean(acc$accX)
  y_mean <- mean(acc$accY)
  z_mean <- mean(acc$accZ)
  
  #Process the standard deviations
  
  x_sd <- sd(acc$accX)
  y_sd <- sd(acc$accY)
  z_sd <- sd(acc$accZ)
  
  x_dev <- acc$accX - x_mean
  y_dev <- acc$accY - y_mean
  z_dev <- acc$accZ - z_mean
  
  # Calculate Total Deviation
  total_dev = sqrt(x_dev**2 + y_dev**2 + z_dev**2)
  
  
  if(length(acc$timestamp) > 500){
    c(b,a) %<-% scipy$signal$butter(5, 0.001)
    filtered_total_dev <- scipy$signal$filtfilt(b,a,total_dev,padlen = as.integer(500))
    
    acc <- acc %>%
      mutate(
        timestamp = as.numeric(acc$timestamp),
        folder = as.numeric(gsub("_",".",substr(file, 21, 35))),
        metric = as.numeric(filtered_total_dev))
    
    }
}


