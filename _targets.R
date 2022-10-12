library(targets)
library(tarchetypes)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse", "bookdown", "sf"))

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
source("R/pavement_data.R")
source("R/figures.R")
source("R/join_points_and_segments.R")
source("R/build_linknode_tables.R")
source("R/join_segments_data.R")
source("R/acc_data.R")

bounding_box <- "data/provo_bb.geojson"
network_folder <- "data/provo_bikes"


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
  tar_target(acc_data,make_acc_pavement_data("data/pavement_data/process_acceleration")),
  
  # this target is a sf object of all the ride points we took.
  tar_target(all_points_sf, make_point_sf(ride_data)),
  # get a table that has the link associated with every ride point
  tar_target(ride_point_links, get_links_of_points(linknodes$links, all_points_sf, 
                                                   distance = 25))
)



# Targets necessary to build the book / article
book_targets <- list(
)



# run all targets
list(
  data_targets, 
  book_targets
)
