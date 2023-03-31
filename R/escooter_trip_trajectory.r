library(tidyverse)
library(sf)
library(lubridate)


# Download raw data file =================================
gps_points <- "data/october_2019_gpspoints.json"
if (!file.exists(gps_points)) {
  box <- null  # redacted private data link
  download.file(box, gps_points)
}

# Turn zagster points into a spatial object ==============
paths <- jsonlite::fromJSON(gps_points)
df <- paths$datasets$data$allData
m <- df[[1]]
colnames(m) <- paths$datasets$data$fields[[1]]$name

# make into a data frame
df2 <- as_tibble(m) %>%
  mutate(
    location_lat = as.numeric(location_lat),
    location_lon = as.numeric(location_lon),
  ) %>% 
  filter(location_lat > 40.2, location_lat < 40.3)

# add a unique ID to each observation
df2$ID <- seq.int(nrow(df2))

# get the time as an actual time object
df2$time <- as.POSIXct(lubridate::as_datetime(df2$created_at, format = "%m/%d/%y %H:%M", tz = ""))

# project from lat/long into EPSG 3566 NAD83 / Utah Central (ftUS)
projected <- st_as_sf(df2, coords = c("location_lon", "location_lat"), crs = 4326)
projected <- st_transform(projected, 3566)

write_rds(projected, "data/projected_points.rds")


sf::st_write(projected, "fmm/escooter_data/trips.shp")
sf::st_write(projected, "fmm/escooter_data/trips_points.csv", layer_options = "GEOMETRY=AS_XY")
readr::write_csv( projected |> sf::st_set_geometry(projected$geometry), 
                 file.path("fmm/escooter_data/trips_points.csv"))
