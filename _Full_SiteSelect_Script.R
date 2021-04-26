# Clean site selection script
# All scripts generated and run in Spring 2020
# Clean script compiled in Sept 2020
# Jordan Stark

#####################################
############### Setup ###############
setwd("E:/GIS_SensorStratification/Clean_process")

# pathways
GISlib <- "E:/GIS_SensorStratification/Clean_process/GISlib/"
out_path <- "E:/GIS_SensorStratification/Clean_process/Outputs/"

# raw inputs
  # GRSM_Watersheds.shp - downloaded 19Feb20 from GRSM database
  # GRSM_ROAD_CENTERLINES.shp - Downloaded from GRSM database 29Aug19
  # GRSM_TRAILS.shp - Downloaded from GRSM database 29Aug19
  # GRSM_BOUNDARY_POLYGON.shp - Downloaded 4Mar20 from GRSM database
  # elev.gri - 10m DEM of area around park, downloaded 13Nov19 from GRSM database in four parts (mgrsm10dem files) and combined

# intermediate products
  # Elev_park.gri - elevation aggregated to 30m and cropped to park
  # tci.gri - TCI
  # Rad_Rasters/ - folder with daily radiation index
  # CroppedRadStack.gri - shape file with daily radiation index layers cropped to park
  # Totrad.gri - Annual radiation index
  # rastersample_250m.shp - Sample of 250m grid across park for TCI, Elevation and Totrad
  # ETRzip.gri - stratification zones
  # Sample_Buffer.shp - areas from which to select points
  

# outputs
  # Sample sites in .csv files (in out_path) and shape files (in GISlib)

#####################################



########################################
############### Packages ###############
library(rstudioapi) # allows 'jobrunscript' command

# Packages loaded in individual scripts

## GIS packages
  # sf - for point selection, buffers
  # raster
  # sp - for TCI script only
  # topmodel - for TCI calculation
  # rgdal - for irradiance calculation
  # rgeos - for irradiance calculation
  # solartime - for irradiance calculation

########################################




############################################
############### full scripts ###############
# Scripts that are used to generate intermediate outputs are commented out
    # uncomment to generate output
    # note that you need to wait to run the next intermediate script until the last one is done
# importEnv=T allows paths to be set from this script
# working directory needs to contain all scripts
# all scripts run in <5 min unless time noted


#jobRunScript("TCI_calc.R",importEnv=T)
  # generates TCI layer file and Elev_park
  # this takes ~15m to run
  # requires elev.gri
  # output is tci.gri

#jobRunScript("Irradiance_calc.R",importEnv=T)
  # generates daily irradiance rasters
  # takes ~6 hours to run
  # requires elev.gri, tci.gri (for cropping) 
  # also requires folder "Rad_Rasters/" in GISlib (empty)
  # output is Rad_Rasters/ folder and CroppedRadStack.gri

#jobRunScript("Calc_totrad.R",importEnv=T)
  # generates annual radiation index
  # requires CroppedRadStack.gri
  # output is Totrad.gri

#jobRunScript("Park_250m_points.R",importEnv=T)
  # Samples park at 250m resolution for elevation, TCI and annual radiation
  # takes ~15 minutes to run
  # requires elev.gri, tci.gri, Totrad.gri, GRSM_BOUNDARY_POLYGON.shp
  # output is rastersample_250m2.shp in GISlib

#jobRunScript("ETR_raster.R",importEnv=T)
  # stratifies park by elevation, log(TCI) and annual radiation
  # stratification is equal area
  # requires Elev_park.gri, tci.gri, Totrad.gri and rastersample_250m2.shp
  # output is ETRzip.gri and ETRzip_stack.gri in GISlib
    # _stack has each stratification zone as a separate layer

#jobRunScript("SiteBuffers.R",importEnv=T)
  # Creates buffers for useable sites
    # criteria are 25 to 150m from trails
    # and <5km from parking
  # requires GRSM_ROAD_CENTERLINES.shp and GRSM_TRAILS.shp
  # output is SampleBuffer.shp

jobRunScript("BigCrSites.R",importEnv=T)
  # chooses 81 stratified sites in the Big Creek watershed
  # requires ETRrast, SampleBuffer, GRSM_Watersheds
  # outputs BigCr_SampleSites.shp and BigCr_SampleSites.csv

jobRunScript("CosbySites.R",importEnv=T)
  # chooses 81 stratified sites in the Cosby watershed
  # requires ETRrast, SampleBuffer, GRSM_Watersheds
  # outputs Cosby_SampleSites.shp and Cosby_SampleSites.csv

# ** note I am getting slightly different sites than I did in March. 
## I suspect this is because while I did use set.seed in the site choosing scripts
## I did not in the point sampling script
## I do have the original 250m point sample saved as a separate file

############################################