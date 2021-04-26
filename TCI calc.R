# code to generate TCI from DEM
# Jordan Stark
# Feb 2020

# libraries
library(raster)
library(sp)
library(topmodel)

# data location
DEMPath <- "E:/GIS_SensorStratification/GIS/Elevation/Elev.gri"

# import data
DEM <- raster(DEMPath)
extent <- extent(220000,320000,3920000,3970000)
DEM <- crop(DEM,extent)
DEM <- aggregate(DEM,fact=3) # convert to 30m resolution

# calculate - based on code from upslope.area in dynatopmodel; 'sinkfill' needed to avoid large 'NA' areas near streams
matrix <- raster::as.matrix(DEM)
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # degree used in examples (min slope)
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 68761 before
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 45950 before
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 29027 before
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 19433 before
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 9837 before
matrix <- sinkfill(matrix,res=xres(DEM),degree=0.1) # run again due to 'sink removal not complete' message
                                                    # 1996 before

topidx <- topidx(matrix,res=xres(DEM))
TCI    <- setValues(DEM,topidx$atb)


writeRaster(TCI,"E:/GIS_SensorStratification/GIS/TCI/TCI")
writeRaster(TCI,"E:/GIS_SensorStratification/GIS/TCI/TCI.tif")
