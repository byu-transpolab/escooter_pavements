# This is where you write functions that can be called from 
# _targets
# 

#' read processed acceleration data
#' 
#' @param acc_data path to the place where data is stored
#' 
make_acc_pavement_data <- function(acc_data){
  
  acc_sets <- dir(acc_data)
  
  acc__data <- lapply(acc_sets, function(set){
 +
      read_acc_scooter_recorder(file.path(acc_data, set))
  })
  
}

#' read nav recorder data
#' 
#' @param path path to one collection set
#' @details 
#' 
read_acc_scooter_recorder <- function(path){
  #files <- list.files(path, full.names = TRUE)
  
  # read ACC files
  acc <- read_acc(path[grepl("proccessed.csv", path)])
  
  

  
  list(
    "acc" = acc
  )
}


#' Read the acc file from the scooter path
read_acc <- function(file){
  
  # [1] "TimestampAcc [ns]" " Metric "
  acc <- read_delim(file, delim= ";", col_types = list(
    `TimestampAcc [ns]` = col_character()
  )) %>%
    set_names("timestamp", "metric")
  
  if(nrow(acc) == 0){
    warning(str_c("acc", file, "contains no information"))
  } else {
    acc <- acc %>%
      mutate(
        timestamp = as.numeric(timestamp),
        #timestamp = as.POSIXct((timestamp+0.1)/1000, origin = "1970-01-01")
      )
  }
  
  acc
}


