### calculate yearly radiation input
### from doy rasters
# Jordan Stark, 25Feb20

# paths
GISlib <- "E:/GIS_SensorStratification/GIS/"

# libraries
library(raster)

# import data
filenames <- list.files(path = paste(GISlib,"Rad_Rasters/",sep=""), 
                        pattern = "\\.gri$",
                        full.names=T)
radstack <- stack(filenames,quick=T) #quick=T does not check extents, ok here since all were created with same function and template

# crop to smaller size to allow calculation
#TCI  <- raster(paste(GISlib,"TCI/tci.gri",sep=""))
#radstack <- crop(radstack,TCI)
#writeRaster(radstack,paste(GISlib,"CroppedRadStack/CroppedRadStack",sep=""))

# read in cropped raster stack
radstack <- stack(paste(GISlib,"CroppedRadStack/CroppedRadStack.gri",sep=""))

# calculate and save totrad

totrad <- sum(radstack)
writeRaster(totrad,paste(GISlib,"Totrad/Totrad",sep=""))

