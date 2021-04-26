# Create raster of ETR zip codes
# Mar 2020 

#### setup ####
# Libraries
library(raster)
library(sf)

# paths
GISlib <- GISlib


# import GIS data and make a stack
Elev   <- raster(paste(GISlib,"Elev_park.gri",sep=""))
TCI    <- raster(paste(GISlib,"tci.gri",sep=""))
Totrad <- raster(paste(GISlib,"Totrad.gri",sep=""))

lTCI   <- log(TCI)
extent(Totrad)   <- alignExtent(Totrad,lTCI)

zipstack <- stack(Elev,lTCI,Totrad)
names(zipstack) <- c("Elev","lTCI","Totrad")

# import points sampled across park at 250m
parksites <- st_read(paste(GISlib,"rastersample_250m2/rastersample_250m2.shp",sep=""))

stdcrs <- crs(parksites)

#### define strata ####
parksites$class.E <- cut(parksites$Elev,
                         include.lowest=T,
                         labels=c("e1","e2","e3"),
                         breaks=quantile(parksites$Elev,probs=c(0,0.333,0.666,1)))

parksites_ESplit <- split(parksites,parksites$class.E)

for(i in 1:length(parksites_ESplit)){
  dat <- parksites_ESplit[[i]]
  dat$class.T <- cut(dat$log_TCI,
                     include.lowest=T,
                     labels=c("t1","t2","t3"),
                     breaks=quantile(dat$log_TCI,
                                     probs=c(0,0.333,0.666,1),
                                     na.rm=T))
  dat$class.ET <- interaction(dat$class.E,
                              dat$class.T)
  parksites_ESplit[[i]] <- dat
}

parksites_ETBind  <- do.call(rbind,parksites_ESplit)
parksites_ETSplit <- split(parksites_ETBind,parksites_ETBind$class.ET)

for(i in 1:length(parksites_ETSplit)) {
  dat <- parksites_ETSplit[[i]]
  dat$class.R <- cut(dat$Totrad,
                     include.lowest=T,
                     labels=c("r1","r2","r3"),
                     breaks=quantile(dat$Totrad,
                                     probs=c(0,0.333,0.666,1),
                                     na.rm=T))
  dat$class.ETR <- interaction(dat$class.ET,
                               dat$class.R)
  parksites_ETSplit[[i]] <- dat
}

park_all <- do.call(rbind,parksites_ETSplit)

summary(park_all$class.ETR)


#### extract boundaries ####
strat_bounds <- data.frame(class_E = rep(c("e1","e2","e3"),each=9),
                           class_lT = rep(c("t1","t2","t3"),each=3,3),
                           class_R = rep(c("r1","r2","r3"),9))
strat_bounds$strat_name <- paste(strat_bounds$class_E,strat_bounds$class_lT,strat_bounds$class_R,sep=".")
strat_bounds$E_min <- NA
strat_bounds$E_max <- NA
strat_bounds$lT_min <- NA
strat_bounds$lT_max <- NA
strat_bounds$R_min <- NA
strat_bounds$R_max <- NA

for(i in 1:length(strat_bounds$strat_name)) {
  stratname <- strat_bounds$strat_name[i]
  stratdat <- park_all[as.character(park_all$class.ETR) == stratname,]
  strat_bounds$E_min[i]  <- min(stratdat$Elev,na.rm=T)
  strat_bounds$E_max[i]  <- max(stratdat$Elev,na.rm=T)
  strat_bounds$lT_min[i] <- min(stratdat$log_TCI,na.rm=T)
  strat_bounds$lT_max[i] <- max(stratdat$log_TCI,na.rm=T)
  strat_bounds$R_min[i]  <- min(stratdat$Totrad,na.rm=T)
  strat_bounds$R_max[i]  <- max(stratdat$Totrad,na.rm=T)
}

#adjust bounds to min and max of raster layers since extremes missed in 250m sample
strat_bounds$E_min[strat_bounds$class_E=="e1"] <- min(Elev[],na.rm=T)
strat_bounds$E_max[strat_bounds$class_E=="e3"] <- max(Elev[],na.rm=T)
strat_bounds$lT_min[strat_bounds$class_lT=="t1"] <- min(lTCI[],na.rm=T)
strat_bounds$lT_max[strat_bounds$class_lT=="t3"] <- max(lTCI[],na.rm=T)
strat_bounds$R_min[strat_bounds$class_R=="r1"] <- min(Totrad[],na.rm=T)
strat_bounds$R_max[strat_bounds$class_R=="r3"] <- max(Totrad[],na.rm=T)

#write.csv(strat_bounds,"E:/GIS_Sensorstratification/strata_boundaries.csv")


#### assign pixels from rasters to categories
ETRstack <- stack()

for(i in 1:27){
  E <- zipstack[["Elev"]]
  lT <- zipstack[["lTCI"]]
  R <- zipstack[["Totrad"]]
  name <- strat_bounds$strat_name[i]
  
  Emin <- strat_bounds$E_min[i]
  Emax <- strat_bounds$E_max[i]
  E[!(E[]>Emin & E[]<Emax)] <- NA
  
  lT <- mask(lT,E)
  
  lTmin <- strat_bounds$lT_min[i]
  lTmax <- strat_bounds$lT_max[i]
  lT[!(lT[]>lTmin & lT[]<lTmax)] <- NA
  
  R <- mask(R,lT)
  
  Rmin <- strat_bounds$R_min[i]
  Rmax <- strat_bounds$R_max[i]
  R[!(R[]>Rmin & R[]<Rmax)] <- NA
  
  R[!is.na(R)] <- i
  names(R) <- name
  ETRstack <- stack(ETRstack,R)
}

ETRrast <- merge(ETRstack)

writeRaster(ETRrast,paste(GISlib,"ETRzip",sep=""))
writeRaster(ETRstack,paste(GISlib,"ETRzip_stack",sep=""))

