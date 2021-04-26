# Script to stratify points sampled from across park
# and choose sampling points in Big Creek based on stratification 
# Mar 2020
# Jordan Stark

#### setup ####
# packages
library(sf)
library(raster)

# paths
GISlib  <- GISlib

# import data
ETRrast <- raster(paste(GISlib,"ETRzip.gri",sep=""))

stdcrs <- crs(ETRrast)

# Import and transform watershed data amd buffer
allbuffer  <- st_read(paste(GISlib,"SampleBuffer/SampleBuffer.shp",sep=""))
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
write.csv(finalsites,paste(out_path,"BigCr_SampleSites.csv",sep=""),row.names=F)


