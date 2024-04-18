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
               tidyr)

#####################################
#####################################

# set directories
## download directory
download_dir <- "data/a_raw_data"

#####################################
#####################################

# parameters
## years for the first URL path
start_year_1 <- 2015
end_year_1 <- 2017

## years for the second URL path
start_year_2 <- 2018
end_year_2 <- 2022

#####################################
#####################################

### Note: adapted from Nick McMillan's code: https://github.com/NPR-investigations/rices-whale-speed-analysis/blob/main/analysis/1-download-marinecadastre-data.qmd

### AIS data hosting site: https://marinecadastre.gov/ais/

# Given a year, the function creates a vector for all the zip files to download
generate_ais_url1 = function(start_year, end_year){
  
  ## list dates for time frame of interest
  dates <- seq(from = stringr::str_glue("{start_year_1}"),
               to = stringr::str_glue("{end_year_1}"),
               by = 1)
  
  urls <- stringr::str_glue("https://marinecadastre.gov/downloads/data/ais/ais{dates}/VesselTransitCounts{dates}.zip")
  return(urls)
}

generate_ais_url2 = function(start_year, end_year){
  
  ## list dates for time frame of interest
  dates <- seq(from = stringr::str_glue("{start_year_2}"),
               to = stringr::str_glue("{end_year_2}"),
               by = 1)
  
  urls <- stringr::str_glue("https://marinecadastre.gov/downloads/data/ais/ais{dates}/AISVesselTransitCounts{dates}.zip")
  return(urls)
}

urls1 <- generate_ais_url1(start_year_1, end_year_1)
urls2 <- generate_ais_url2(start_year_2, end_year_2)

#####################################
#####################################

# Define the path where the files will be saved
dest_path <- file.path(download_dir)

# Check if the directory exists, if not, create it
if (!dir.exists(dest_path)) {
  dir.create(dest_path, recursive = TRUE)
}

#####################################

# Function to download and save a file
download_save <- function(url, dest_path) {
  # Extract filename from the URL
  file_name <- basename(url)
  
  # Combine destination path and filename
  dest_file <- file.path(dest_path, file_name)
  
  # Attempt to download the file
  tryCatch({
    options(timeout=100000)
    
    download.file(url = url,
                  # place the downloaded file in correct data directory location
                  destfile = dest_file,
                  method = "auto",
                  mode = "wb")
    message("Downloaded: ", url)
  }, error = function(e) {
    message("Failed to download: ", url)
  })
}

#####################################

# Apply the function to each URL
# lapply(urls, fun = download_save, dest_path = dest_path)

# run parallel function to each URL
## set up the cluster
cl <- makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create (use all possible cores available)
                  type = 'PSOCK')

## run the parallel function over the urls
work1 <- parallel::parLapply(cl = cl, X = urls1, fun = download_save, dest_path = dest_path)
work2 <- parallel::parLapply(cl = cl, X = urls2, fun = download_save, dest_path = dest_path)

## stop the cluster
parallel::stopCluster(cl = cl)

#####################################
#####################################

# List all zip files in the directory
zip_files <- list.files(path = dest_path, pattern = "*.zip")
zip_files

zip_time <- Sys.time()

# Loop through each file
for(zip_file in zip_files){
  
  start2 <- Sys.time()
  
  # Generate full paths to zip and unzip locations
  zip_path <- file.path(dest_path, zip_file)
  
  new_path <- file.path(dest_path, gsub(pattern = ".zip", replacement = "", x = zip_file))
  
  # Unzip the file
  unzip(zipfile = zip_path,
        # keep in same location
        exdir = new_path) #unzip_path
  
  # Delete the zipped file
  file.remove(zip_path)
}

#print how long it takes to loop through dates
print(paste("Takes", Sys.time() - zip_time, units(Sys.time() - zip_time), "to complete unzipping data", sep = " "))

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
