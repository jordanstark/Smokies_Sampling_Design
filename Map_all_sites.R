# Check distribution of other variables and correlation across park and sampling sites
# Mar 2020 

#### setup ####
# Libraries
library(raster)
library(sf)
library(ggplot2)
library(tmap)
library(tmaptools)

# paths
GISlib <- "E:/GIS_SensorStratification/GIS/"


# import points sampled across park at 250m
parksites <- st_read(paste(GISlib,"rastersample_250m/rastersample_250m.shp",sep=""))
cosbysites <- st_read(paste(GISlib,"Cosby_SampleSites/Cosby_SampleSites.shp",sep=""))
BigCrsites <- st_read(paste(GISlib,"BigCr_SampleSites/BigCr_SampleSites.shp",sep=""))
stdcrs <- crs(parksites)

# import GIS data to add
max_CC <- raster(paste(GISlib,"Max_Canopy_Cover/Max_Canopy_Cover.gri",sep=""))
Elev   <- raster(paste(GISlib,"Elev_park/Elev_park.gri",sep=""))
TCI    <- raster(paste(GISlib,"TCI/tci.gri",sep=""))
lTCI   <- log(TCI)
Totrad <- raster(paste(GISlib,"Totrad/Totrad.gri",sep=""))
strdist <- raster(paste(GISlib,"streamdist",sep=""))
lstrdist <- log(strdist)

# import trails and roads for planning
trails <- st_read(paste(GISlib,"GRSM_TRAILS/GRSM_TRAILS.shp",sep=""))
roads  <- st_read(paste(GISlib,"GRSM_ROAD_CENTERLINES/GRSM_ROAD_CENTERLINES.shp",sep=""))
trails <- st_transform(trails,stdcrs)
roads  <- st_transform(roads,stdcrs)


# extract other GIS data to parksites and cosbysites
parksites$max_CC   <- extract(max_CC,parksites)

cosbysites$max_CC  <- extract(max_CC,cosbysites)
cosbysites$Elev    <- extract(Elev,cosbysites)
cosbysites$lTCI    <- extract(lTCI,cosbysites)
cosbysites$Totrad  <- extract(Totrad,cosbysites)
cosbysites$strdist <- extract(strdist,cosbysites)

BigCrsites$max_CC  <- extract(max_CC,BigCrsites)
BigCrsites$Elev    <- extract(Elev,BigCrsites)
BigCrsites$lTCI    <- extract(lTCI,BigCrsites)
BigCrsites$Totrad  <- extract(Totrad,BigCrsites)
BigCrsites$strdist <- extract(strdist,BigCrsites)


#### evaluate sites for distrib of log(strdist) and EVI area

ggplot(parksites, aes(x=Elev,y=max_CC)) +
  geom_point(aes(alpha=0.05)) +
  geom_point(data=cosbysites,aes(x=Elev,y=max_CC),color="red",size=4) +
  geom_point(data=BigCrsites,aes(x=Elev,y=max_CC),color="blue",size=4)


ggplot(parksites, aes(x=Elev,y=strdist)) +
  geom_point(aes(alpha=0.05)) +
  geom_point(data=cosbysites,aes(x=Elev,y=strdist),color="red",size=4) +
  geom_point(data=BigCrsites,aes(x=Elev,y=strdist),color="blue",size=4)


#### ID trails etc

tmap_mode("view")

tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
  tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") 




tm_shape(cosbysites) +
  tm_dots(col="ETR",size=0.2,id="ptID") +
tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") 

tm_shape(BigCr,is.master=T) +
  tm_polygons(alpha=0.1,border.col="blue")

tm_shape(BigCrsites) +
  tm_dots(col="ETR",size=0.2,id="ptID") +
  tm_shape(trails) +
  tm_lines(col="black",lty=2,id="TRAILNAME") +
  tm_shape(roads) +
  tm_lines(col="red",id="RDLABEL") 


tm_shape(SOM) +
  tm_polygons()








