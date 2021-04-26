# Script to stratify points sampled from across park
# and choose sampling points in Big Creek based on stratification 
# Mar 2020
# Jordan Stark

#### setup ####
# packages
library(sf)
library(raster)

# paths
GISlib  <- "E:/GIS_SensorStratification/GIS/"

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
BigCr      <- st_union(watersheds[watersheds$Name=="Big Creek" & watersheds$States=="NC",])

allbuffer <- st_transform(allbuffer,stdcrs)
BigCr     <- st_transform(BigCr,stdcrs)

BigCrbuf <- st_intersection(allbuffer,BigCr)


# Make 100m grid within buffer area
BigCr_allpts <- st_intersection(BigCrbuf,
                                st_make_grid(BigCrbuf,
                                             cellsize=100,what="centers")) 

# extract ETR of potential points
BigCr_ETR <- crop(ETRrast,BigCrbuf)
BigCr_allpts$ETR <- extract(BigCr_ETR,BigCr_allpts)

BigCr_allpts$ptID <- 1:length(BigCr_allpts$ETR)

pt_dist <- as.matrix(dist(st_coordinates(BigCr_allpts)))


NearestPts <- function(ID,distmat) {
  pt_dists <- distmat[ID,]
  pt_dists <- sort(pt_dists)
  as.numeric(names(pt_dists[1:25]))
}


table(BigCr_allpts$ETR)

#### sample sites ####
set.seed(345925)
BigCr_allpts$include <- F


BigCrSplit <- split(BigCr_allpts,BigCr_allpts$ETR)

for(i in 1:length(BigCrSplit)) {
  dat <- BigCrSplit[[i]]
  
  samps <- sample.int(length(dat$ETR),
                      size = 1)
  dat$include[samps] <- T
  
  BigCrSplit[[i]] <- dat
}

BigCr_sites1 <- do.call(rbind,BigCrSplit)
BigCr_include1 <- BigCr_sites1[BigCr_sites1$include==T,]

for(i in 1:27) {
  ID <- BigCr_include1$ptID[i]
  ETR <- BigCr_include1$ETR[i]
  nearPts <- NearestPts(ID,pt_dist)
  BigCr_sites1[which(BigCr_sites1$ptID %in% nearPts & BigCr_sites1$ETR==ETR),] <- NA
}

table(BigCr_sites1$ETR) #min number left is 11


BigCrSplit <- split(BigCr_sites1,BigCr_sites1$ETR)

for(i in 1:length(BigCrSplit)) {
  dat <- BigCrSplit[[i]]

  samps <- sample.int(length(dat$ETR),
                        size = 1)
  dat$include[samps] <- T
  
  BigCrSplit[[i]] <- dat
}

BigCr_sites2 <- do.call(rbind,BigCrSplit)
BigCr_include2 <- BigCr_sites2[BigCr_sites2$include==T,]

for(i in 1:54) {
  ID <- BigCr_include2$ptID[i]
  ETR <- BigCr_include2$ETR[i]
  nearPts <- NearestPts(ID,pt_dist)
  BigCr_sites2[which(BigCr_sites2$ptID %in% nearPts & BigCr_sites2$ETR==ETR),] <- NA
}

table(BigCr_sites2$ETR) # min number left is 9

BigCrSplit <- split(BigCr_sites2,BigCr_sites2$ETR)

for(i in 1:length(BigCrSplit)) {
  dat <- BigCrSplit[[i]]
  
  samps <- sample.int(length(dat$ETR),
                      size = 1)
  dat$include[samps] <- T
  
  BigCrSplit[[i]] <- dat
}

BigCr_sites3 <- do.call(rbind,BigCrSplit)
BigCr_include3 <- BigCr_sites3[BigCr_sites3$include==T,]

finalsites <- rbind(BigCr_include1,BigCr_include2,BigCr_include3)
finalsites$ETR <- factor(finalsites$ETR)

st_write(finalsites,paste(GISlib,"BigCr_SampleSites",sep=""),driver="ESRI Shapefile")
write.csv(finalsites,"E:/GIS_SensorStratification/BigCr_SampleSites.csv")



#### plotting ####
library(tmap)
library(tmaptools)

tmap_mode("view")

tm_shape(BigCr,is.master=T) +
  tm_polygons(alpha=0.1,border.col="blue") +
tm_shape(finalsites) +
  tm_dots(col="ETR",size=0.2,id="ptID") +
tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") 


tm_shape(BigCr_ETR)+
  tm_raster(style="cat",palette="Set3",stretch.palette=F)




tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") +
tm_shape(EVI_Area) +
  tm_raster(n=5) +
tm_shape(BigCr) +
  tm_polygons(alpha=0.4,border.col="blue") +
tm_shape(parkbound) +
  tm_polygons(alpha=0.05,border.col="blue")




