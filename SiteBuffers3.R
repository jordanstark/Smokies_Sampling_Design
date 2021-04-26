# Script to generate road and trail buffers for sampling in GRSM
# with smaller trail buffers
# March 2020

#libraries
library(sf)

#data sources
roadPath <- "E:/GIS_SensorStratification/GIS/GRSM_ROAD_CENTERLINES/GRSM_ROAD_CENTERLINES.shp"
trailPath <- "E:/GIS_SensorStratification/GIS/GRSM_TRAILS/GRSM_TRAILS.shp"

# import data
roads <- st_read(roadPath)
trails <- st_read(trailPath)

# transform crs and make one shape
trails <- st_transform(trails,st_crs(roads))
rm_trails <- c("Tritt Cemetery Access Trail") #trails that won't work
trails <- trails[!(as.character(trails$TRAILNAME) %in% rm_trails),]

trails <- st_union(trails)
parking <- roads[roads$ASSETCODE=="Parking Area",]
parking <- st_union(parking)

# calculate buffers
parkingbuf <- st_buffer(parking,dist=5000)

useable_trails <- st_intersection(parkingbuf,trails)

trailbuf_min   <- st_buffer(useable_trails,dist=25)
trailbuf_max   <- st_buffer(useable_trails,dist=150)

fullbuf <- st_difference(trailbuf_max,trailbuf_min)


st_write(obj=fullbuf,dsn="E:/GIS_SensorStratification/GIS/SampleBufferFeb2020_3",driver="ESRI SHAPEFILE")
