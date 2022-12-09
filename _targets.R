library(targets)
library(tarchetypes)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse", "bookdown", "sf", "lubridate", "purrr","viridis"))

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
source("R/pavement_data.R")
source("R/figures.R")
source("R/join_points_and_segments.R")
source("R/build_linknode_tables.R")
source("R/join_segments_data.R")
source("R/acc_data.R")
source("R/Interpolate_acc_metric.R")
source("R/rider_times.R")

bounding_box <- "data/provo_bb.geojson"
network_folder <- "data/provo_bikes"

# Start and End Times are given along with Rider Name
starttime <- c("2021-10-30 9:13:00","2021-11-04 11:23:00","2021-11-05 14:37:00","2021-11-06 8:32:00","2021-11-13 6:40:00","2021-11-16 11:24:00","2021-11-18 11:27:00","2021-11-20 8:03:00","2021-11-30 11:36:00","2021-12-04 8:27:00","2021-12-07 11:28:00","2022-01-15 19:08:00","2022-01-16 17:36:00","2022-05-16 17:55:00","2022-05-21 08:00:00", "2022-05-27 07:44:00","2022-05-28 07:31:00","2022-05-28 08:50:00","2022-06-03 07:44:00", "2022-06-04 08:46:00")
endtime <- c("2021-10-30 10:31:00","2021-11-04 11:39:00","2021-11-05 15:06:00","2021-11-06 11:00:00","2021-11-13 10:42:00","2021-11-16 12:13:00","2021-11-18 12:12:00","2021-11-20 9:59:00","2021-11-30 12:06:00","2021-12-04 9:47:00","2021-12-07 16:27:00","2022-01-15 19:10:00","2022-01-16 17:41:00","2022-05-16 18:31:00","2022-05-21 08:53:00", "2022-05-27 11:10:00", "2022-05-28 08:48:00", "2022-05-28 10:45:00","2022-06-03 11:08:00", "2022-06-04 10:27:00")
rname <- as.character(c("Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Nicole & Dylan","Dylan & Liv","Nicole & Dylan","Nicole & Dylan","Dylan & Liv","Nicole & Dylan","Nicole & Dylan","Stephen","Stephen","Jonathon & Nicole","Jonathon","Jonathon","Jonathon","Nicole","Nicole","Jonathon"))

#tar_option_set(debug = "ride_data")

# Targets necessary to build your data and run your model
data_targets <- list(
  
  # targets to make the provo bike shapefile and geojsons ========
  # This downloads a geodatabase extracted from UDOT
  tar_target(gdb, download_gdb("data/MM_NetworkDataset_06032021.gdb"), 
             format = "file"),
  # this is a bounding box so we can just get network links in Provo
  tar_target(bb,  st_read(bounding_box)),
  # this reads the GDB, extracts links in the bounding box, and processes them
  # into a link / node list. 
  tar_target(linknodes, extract_roads(bb, gdb)),
  # this writes outs the link node list into a folder and some other 
  # files for further work
  tar_target(write, write_linknodes(linknodes, "data/r5",26912), 
             format = "file"),
  
  # this downloads a java application that converts link / node
  # tables (in the files we just wrote into an OSM pbf file.
  tar_target(lib, "lib/links2osm-1.0-SNAPSHOT.jar", format = "file"),
  tar_target(osmpbf, write_osmpbf(lib, write)),
  
  # targets to make pavement data =========================
  # this reads all of the scooter data we collected 
  tar_target(ride_data, make_link_pavement_data("data/pavement_data/")),
  # this reads all the acc data processed by Dr. Mazeo
  tar_target(acc_list,make_acc_pavement_data("data/process_acceleration")),
  #this combines the acc_data into one list
  tar_target(acc_data, combine_acc(acc_list)),
  
  # this target is a sf object of all the ride points we took.
  tar_target(all_points_sf, make_point_sf(ride_data)),
  #this target interpolates the ACC data with the GNSS
  tar_target(all_points_gnss, Search_acc_metric(all_points_sf,acc_data)),
  # get a table that has the link associated with every ride point

  tar_target(ride_point_links, get_links_of_points(linknodes$links, all_points_gnss,distance = 25)),
  
  # merge all_points_sf and rider_chart 
  tar_target(rider_chart, make_ridertibble(starttime,endtime,rname)),
  tar_target(rider_times, rider_merge(rider_chart,ride_point_links))

)



# Targets necessary to build the book / article
book_targets <- list(
)



# run all targets
list(
  data_targets, 
  book_targets
)
