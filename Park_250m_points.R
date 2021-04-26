# Script to sample rasters across the park at 250m resolution
# Mar 2020
# Jordan Stark

#### setup ####
   # Libraries
      library(raster)
      library(sf)
   
   # paths
      GISlib <- GISlib
   
   
   # import GIS data
      Elev <- raster(paste(GISlib,"Elevation/elev.gri",sep=""))
      TCI  <- raster(paste(GISlib,"tci.gri",sep=""))
      Totrad      <- raster(paste(GISlib,"Totrad.gri",sep=""))
      
      stdcrs <- crs(TCI)
   

   
   # import park location data
      parkbound <- st_read(paste(GISlib,"GRSM_BOUNDARY_POLYGON/GRSM_BOUNDARY_POLYGON.shp",sep=""))
      
      parkbound <- st_transform(parkbound,stdcrs)
      parkbound[,2:21] <- NULL # don't need attrs just the points
      parkbound <- parkbound[parkbound$OBJECTID<18,]  # just the main park, not AT and external roads
      
      

#### sampling frequencies ####
   # create 250m sampling grid of points inside park
      allpts <- st_intersection(parkbound,
                                st_make_grid(parkbound,
                                             cellsize=250,
                                             what="centers"))
         #make_grid is for elev to avoid sampling sites that are very far from park in 'parkbound' -maybe on the AT?
      
      
   # extract each GIS layer for each point
      allpts$TCI       <- extract(TCI,allpts)
      allpts$Elev      <- extract(Elev,allpts)
      allpts$Totrad    <- extract(Totrad,allpts)

   # log transform TCI
      allpts$log.TCI <- log(allpts$TCI)

      st_write(allpts,paste(GISlib,"rastersample_250m2",sep=""),driver="ESRI Shapefile")
   
