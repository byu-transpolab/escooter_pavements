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
source("R/build_linknode_tables.R")
source("R/join_segments_data.R")


bounding_box <- "data/provo_bb.geojson"
network_folder <- "data/provo_bikes"


# Targets necessary to build your data and run your model
data_targets <- list(
  
  # targets to make the provo bike shapefile and geojsons -------
  tar_target(gdb, download_gdb("data/MM_NetworkDataset_06032021.gdb"), 
             format = "file"),
  tar_target(bb,  st_read(bounding_box)),
  tar_target(linknodes, extract_roads(bb, gdb)),
  tar_target(write, write_linknodes(linknodes, network_folder,26912), 
             format = "file"),
  
  # targets to make pavement data ---------
  tar_target(links_pavements, make_link_pavement_data("data/pavement_data/")),
  
  tar_target(all_points_sf, make_point_sf(links_pavements))
)



# Targets necessary to build the book / article
book_targets <- list(
)



# run all targets
list(
  data_targets, 
  book_targets
)
