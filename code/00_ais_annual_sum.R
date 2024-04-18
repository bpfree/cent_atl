############################
### 0. Download AIS data ###
############################

# Clear environment
rm(list = ls())

# Calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               lubridate,
               parallel,
               plyr,
               purrr,
               reshape2,
               stringr,
               terra,
               tidyr)

#####################################
#####################################

# parameters
ais_crs <- "EPSG:3857"

call_area_crs <- "ESRI:102008"

#####################################
#####################################

fishery_dir <- "ais_vtc_2016/ais_vtc_2016/"

raster_dir <- "data/b_intermediate_data"

# fishery_function <- function(fishery_dir, call_area){
#   # load the fishery raster data
#   fishery_raster <- terra::rast(file.path(data_dir, fishery_dir, "w001001.adf"))
#   
#   # limit fishery raster data to the study region
#   raster <- terra::crop(x = fishery_raster,
#                         # crop using study region
#                         y = call_area,
#                         # mask using study region (T = True)
#                         mask = T,
#                         extend = T)
# }

#####################################
#####################################

# set data directory
data_dir <- "data/a_raw_data"

draft_call_area <- sf::st_read(dsn = file.path(data_dir, "Draft_Call_Area_CRM/Draft Call Area (3 NM - CRM).shp")) %>%
  sf::st_transform(x = ., crs = ais_crs)
sf::st_crs(draft_call_area)

ais_2015 <- terra::rast(file.path(data_dir, "ais_vtc_2015/ca_ais_vtc_2015.tif")) # EPSG:3857
ais_2016 <- terra::rast(file.path(data_dir, "ais_vtc_2016/ais_vtc_2016/w001001.adf"))
terra::crs(ais_2016) <- crs(ais_crs)

ais_2017 <- terra::rast(file.path(data_dir, "ais_vtc_2017/ais_vtc_2017/w001001.adf"))
terra::crs(ais_2017) <- crs(ais_crs)

ais_2018 <- terra::rast(file.path(data_dir, "ais_vtc_2018/ais_vtc_2018/w001001.adf")) %>%
  terra::project(x = .,
                 y = crs(ais_crs))
plot(ais_2018)

ais_2019 <- terra::rast(file.path(data_dir, "ais_vtc_2019/ais_vtc_2019/w001001.adf")) %>%
  terra::project(x = .,
                 y = crs(ais_crs))
ais_2020 <- terra::rast(file.path(data_dir, "AISVesselTransitCounts2020/AISVesselTransitCounts2020.tif")) %>%
  terra::project(x = .,
                 y = crs(ais_crs))
ais_2021 <- terra::rast(file.path(data_dir, "AISVesselTransitCounts2021/AISVTC2021Atlantic.tif"))
ais_2022 <- terra::rast(file.path(data_dir, "AISVesselTransitCounts2022/AISVTC2022Atlantic.tif"))


ca_ais_2015 <- ais_2015 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2016 <- ais_2016 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2017 <- ais_2017 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2018 <- ais_2018 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2019 <- ais_2019 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2020 <- ais_2020 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2021 <- ais_2021 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

ca_ais_2022 <- ais_2022 %>%
  terra::crop(x = .,
              y = draft_call_area,
              mask = T,
              extend = T)

dim(ca_ais_2015) # 8363 x 5845
dim(ca_ais_2016) # 8363 x 5845
dim(ca_ais_2017) # 8363 x 5845
dim(ca_ais_2018) # 8020 x 5606
dim(ca_ais_2019) # 8020 x 5606
dim(ca_ais_2020) # 9272 x 6481
dim(ca_ais_2021) # 8363 x 5846
dim(ca_ais_2022) # 8363 x 5846

terra::minmax(ca_ais_2015)
terra::minmax(ca_ais_2016)
terra::minmax(ca_ais_2017)
terra::minmax(ca_ais_2018)
terra::minmax(ca_ais_2019)
terra::minmax(ca_ais_2020)
terra::minmax(ca_ais_2021)
terra::minmax(ca_ais_2022)

# dim(ca_ais_2018) <- dim(ca_ais_2015)
# dim(ca_ais_2019) <- dim(ca_ais_2015)
# dim(ca_ais_2020) <- dim(ca_ais_2015)
# dim(ca_ais_2021) <- dim(ca_ais_2015)
# dim(ca_ais_2022) <- dim(ca_ais_2015)

# ca_ais_2021 <- terra::extend(x = ca_ais_2021,
#                               y = ca_ais_2016)

plot(ca_ais_2021)
dim(ca_ais_2021)

terra::minmax(ca_ais_2021)[2]

ca_ais_2015 <- terra::extend(x = ca_ais_2015,
                             y = ca_ais_2021)
ca_ais_2016 <- terra::extend(x = ca_ais_2016,
                             y = ca_ais_2021)
ca_ais_2017 <- terra::extend(x = ca_ais_2017,
                             y = ca_ais_2021)

terra::minmax(ca_ais_2018)
ca_ais_2018 <- terra::resample(x = ca_ais_2018,
                               y = ca_ais_2021,
                               method = "near")
terra::minmax(ca_ais_2018)

terra::minmax(ca_ais_2019)
ca_ais_2019 <- terra::resample(x = ca_ais_2019,
                               y = ca_ais_2021,
                               method = "near")
terra::minmax(ca_ais_2019)

terra::minmax(ca_ais_2020)
ca_ais_2020 <- terra::resample(x = ca_ais_2020,
                               y = ca_ais_2021,
                               method = "near")
terra::minmax(ca_ais_2020)

dim(ca_ais_2015) # 8363 x 5846
dim(ca_ais_2016) # 8363 x 5846
dim(ca_ais_2017) # 8363 x 5846
dim(ca_ais_2018) # 8363 x 5846
dim(ca_ais_2019) # 8363 x 5846
dim(ca_ais_2020) # 8363 x 5846
dim(ca_ais_2021) # 8363 x 5846
dim(ca_ais_2022) # 8363 x 5846

res(ca_ais_2015) # 100 x 100
res(ca_ais_2016) # 100 x 100
res(ca_ais_2017) # 100 x 100
res(ca_ais_2018) # 100 x 100
res(ca_ais_2019) # 100 x 100
res(ca_ais_2020) # 100 x 100
res(ca_ais_2021) # 100 x 100
res(ca_ais_2022) # 100 x 100

ext(ca_ais_2015) # -8738033.1873, -8153433.1873, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2016) # -8738033.1873, -8153433.1873, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2017) # -8738033.1873, -8153433.1873, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2018) # -8738098.56193315, -8153480.09228914, 3912775.26144865, 4749136.32576278 (xmin, xmax, ymin, ymax)
ext(ca_ais_2019) # -8738098.56193315, -8153480.09228914, 3912775.26144865, 4749136.32576278 (xmin, xmax, ymin, ymax)
ext(ca_ais_2020) # -8738113.15748747, -8153522.2285258, 3912752.16782283, 4749093.33328073 (xmin, xmax, ymin, ymax)
ext(ca_ais_2021) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2022) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)

ext(ca_ais_2015) <- ext(ca_ais_2021)
ext(ca_ais_2016) <- ext(ca_ais_2021)
ext(ca_ais_2017) <- ext(ca_ais_2021)
ext(ca_ais_2018) <- ext(ca_ais_2021)
ext(ca_ais_2019) <- ext(ca_ais_2021)
ext(ca_ais_2020) <- ext(ca_ais_2021)

ext(ca_ais_2015) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2016) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2017) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2018) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2019) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2020) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2021) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)
ext(ca_ais_2022) # -8738069.7374, -8153469.7374, 3912778.3932, 4749078.3932 (xmin, xmax, ymin, ymax)

cat(crs(ca_ais_2015))
cat(crs(ca_ais_2016))
cat(crs(ca_ais_2017))
cat(crs(ca_ais_2018))
cat(crs(ca_ais_2019))
cat(crs(ca_ais_2020))
cat(crs(ca_ais_2021))
cat(crs(ca_ais_2022))

plot(ca_ais_2015)
plot(ca_ais_2016)
plot(ca_ais_2017)
plot(ca_ais_2018)
plot(ca_ais_2019)
plot(ca_ais_2020)
plot(ca_ais_2021)
plot(ca_ais_2022)

ca_ais_sum <- c(ca_ais_2015,
                ca_ais_2016,
                ca_ais_2017,
                ca_ais_2018,
                ca_ais_2019,
                ca_ais_2020,
                ca_ais_2021,
                ca_ais_2022) %>%
  terra::app(fun = "sum", na.rm = T)

plot(ca_ais_sum)

terra::minmax(ca_ais_sum)[1]
terra::minmax(ca_ais_sum)[2]

terra::writeRaster(x = ca_ais_sum, filename = file.path(raster_dir, "ca_ais_2015_2022.grd"))
