### calculate yearly radiation input
### from doy rasters
# Jordan Stark, 25Feb20

# paths
GISlib <- GISlib

# libraries
library(raster)


# read in cropped raster stack
#radstack <- stack(list.files(paste(GISlib,"Rad_Rasters/",sep=""),full.names=T))
radstack <- stack(paste(GISlib,"CroppedRadStack.gri",sep=""))

# calculate and save totrad

totrad <- sum(radstack)
writeRaster(totrad,paste(GISlib,"Totrad",sep=""))

