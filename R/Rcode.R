library(tidyverse)
#setwd = 
wd <- "C:/Users/olivi/Desktop/NavSensorRecorder"
path <- "C:/Users/olivi/Desktop/NavSensorRecorder/20210827_150115"


dirs <- list.dirs(wd)
for(i in 1:length(dirs)) {
  files <- list.files(dirs[i])
  
}
files <- list.files(path)

read_gnss <- function(files){
  
  # [1] "TimestampGNSS [ns]" " UTC time [ms]"     " Lat [deg]"         " Lon [deg]"        
  # [5] " Height [m]"        " Speed [m/s]"       " Heading [deg]"     " Hor Acc [m]"      
  # [9] " Vert Acc [m]"      " Speed Acc [m/s]"   " Heading Acc [deg]"
  read_delim(file.path(path,files[grepl("GNSS.csv", files)]), delim= ";") %>%
    set_names("timestamp", "timestampUTC", "lat", "lng", "height", "speed", 
              "heading", "y_acc", "z_acc", "x_acc", "heading_acc") %>%
    mutate(
      timestamp = as.character(timestamp),
      timestampUTC = as.POSIXct((timestampUTC+0.1)/1000, origin = "1970-01-01")
    )
}





folder_path <-  "C:/Users/olivi/Desktop/NavSensorRecorder/20210902_144419"
files <- list.files(folder_path)

df <- read_delim(file.path(path,files[grepl("GNSS.csv", files)]), delim= ";") %>%
  set_names("timestamp", "timestampUTC", "lat", "lng", "height", "speed", 
            "heading", "y_acc", "z_acc", "x_acc", "heading_acc") %>%
  mutate(
    timestamp = as.character(timestamp),
    timestampUTC = as.POSIXct((timestampUTC+0.1)/1000, origin = "1970-01-01")
  )

write.csv(df, file=file.path(wd, '20210902_144419_new.csv'))


