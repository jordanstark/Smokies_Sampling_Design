# Script to stratify points sampled from across park
# and choose sampling points in Cosby based on stratification 
# Mar 2020
# Jordan Stark

#### setup ####
# packages
library(sf)
library(raster)

# paths
GISlib  <- "C:/Users/Jordan/Desktop/Smokies trips/March_2020_Smokies/SensorLocationPlan/"

# import data
ETRrast <- raster(paste(GISlib,"ETRzip/ETRzip.gri",sep=""))

stdcrs <- crs(ETRrast)

# Import and transform trails and roads (for mapping only)
trails <- st_read(paste(GISlib,"GRSM_TRAILS/GRSM_TRAILS.shp",sep=""))
roads  <- st_read(paste(GISlib,"GRSM_ROAD_CENTERLINES/GRSM_ROAD_CENTERLINES.shp",sep=""))
trails <- st_transform(trails,stdcrs)
roads  <- st_transform(roads,stdcrs)

# Import and transform watershed data amd buffer
allbuffer  <- st_read(paste(GISlib,"SampleBufferFeb2020_3/SampleBufferFeb2020_3.shp",sep=""))
watersheds <- st_read(paste(GISlib,"GRSM_WATERSHEDS/GRSM_WATERSHEDS.shp",sep=""))
cosby      <- st_union(watersheds[watersheds$Name=="Cosby Creek",])

allbuffer <- st_transform(allbuffer,stdcrs)
cosby     <- st_transform(cosby,stdcrs)

cosbybuf <- st_intersection(allbuffer,cosby)

# Make 100m grid within buffer area
cosby_allpts <- st_intersection(cosbybuf,
                                st_make_grid(cosbybuf,
                                             cellsize=100,what="centers")) 

# extract ETR of potential points
cosby_ETR <- crop(ETRrast,cosbybuf)
cosby_allpts$ETR <- extract(cosby_ETR,cosby_allpts)

cosby_allpts$ptID <- 1:length(cosby_allpts$ETR)

pt_dist <- as.matrix(dist(st_coordinates(cosby_allpts)))


NearestPts <- function(ID,distmat) {
  pt_dists <- distmat[ID,]
  pt_dists <- sort(pt_dists)
  as.numeric(names(pt_dists[1:25]))
}


table(cosby_allpts$ETR)

#### sample sites ####
set.seed(5653504)
cosby_allpts$include <- F


cosbySplit <- split(cosby_allpts,cosby_allpts$ETR)

for(i in 1:length(cosbySplit)) {
  dat <- cosbySplit[[i]]
  
  samps <- sample.int(length(dat$ETR),
                      size = 1)
  dat$include[samps] <- T
  
  cosbySplit[[i]] <- dat
}

cosby_sites1 <- do.call(rbind,cosbySplit)
cosby_include1 <- cosby_sites1[cosby_sites1$include==T,]

for(i in 1:27) {
  ID <- cosby_include1$ptID[i]
  ETR <- cosby_include1$ETR[i]
  nearPts <- NearestPts(ID,pt_dist)
  cosby_sites1[which(cosby_sites1$ptID %in% nearPts & cosby_sites1$ETR==ETR),] <- NA
}

table(cosby_sites1$ETR) #min number left is 4


cosbySplit <- split(cosby_sites1,cosby_sites1$ETR)

for(i in 1:length(cosbySplit)) {
  dat <- cosbySplit[[i]]

  samps <- sample.int(length(dat$ETR),
                        size = 1)
  dat$include[samps] <- T
  
  cosbySplit[[i]] <- dat
}

cosby_sites2 <- do.call(rbind,cosbySplit)
cosby_include2 <- cosby_sites2[cosby_sites2$include==T,]

for(i in 1:54) {
  ID <- cosby_include2$ptID[i]
  ETR <- cosby_include2$ETR[i]
  nearPts <- NearestPts(ID,pt_dist)
  cosby_sites2[which(cosby_sites2$ptID %in% nearPts & cosby_sites2$ETR==ETR),] <- NA
}

table(cosby_sites2$ETR) # min number left is one

cosbySplit <- split(cosby_sites2,cosby_sites2$ETR)

for(i in 1:length(cosbySplit)) {
  dat <- cosbySplit[[i]]
  
  samps <- sample.int(length(dat$ETR),
                      size = 1)
  dat$include[samps] <- T
  
  cosbySplit[[i]] <- dat
}

cosby_sites3 <- do.call(rbind,cosbySplit)
cosby_include3 <- cosby_sites3[cosby_sites3$include==T,]

finalsites <- rbind(cosby_include1,cosby_include2,cosby_include3)
finalsites$ETR <- factor(finalsites$ETR)

st_write(finalsites,paste(GISlib,"Cosby_SampleSites",sep=""),driver="ESRI Shapefile")
write.csv(finalsites,"E:/GIS_SensorStratification/Cosby_SampleSites.csv")



#### plotting ####
library(tmap)
library(tmaptools)

tmap_mode("view")

EVI_Area    <- raster(paste(GISlib,"EVI_Summary/EVI_Summary.gri",sep=""),
                      band=1)
parkbound <- st_read(paste(GISlib,"GRSM_BOUNDARY_POLYGON/GRSM_BOUNDARY_POLYGON.shp",sep=""))

parkbound <- st_transform(parkbound,stdcrs)
parkbound[,2:21] <- NULL # don't need attrs just the points
parkbound <- parkbound[parkbound$OBJECTID<18,]

tm_shape(cosby,is.master=T) +
  tm_polygons(alpha=0.1,border.col="blue") +
tm_shape(finalsites) +
  tm_dots(col="ETR",size=0.2) +
tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") 


tm_shape(cosby_ETR)+
  tm_raster(style="cat",palette="Set3",stretch.palette=F)




tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") +
tm_shape(EVI_Area) +
  tm_raster(n=5) +
tm_shape(cosby) +
  tm_polygons(alpha=0.4,border.col="blue") +
tm_shape(parkbound) +
  tm_polygons(alpha=0.05,border.col="blue")




