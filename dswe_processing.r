# dswe_processing.r
# Author: Mollie Gaines
# Last Edited: 4/17/2020
# Purpose: process INWM tifs to get rasters across entire southeast with 5 bands: 
#          Band 1: high confidence water count
#          Band 2: any water count
#          Band 3: land count
#          Band 4: cloud count
#          Band 5: (high water count / (land count + all water count)) * 100
# Usage: runs based on specific file strucutre, no input required, outputs 
# Example Input: Q:/My Drive/Research/DSWE_SE/Bulk Order 1060486/Dynamic Surface Water Extent
# Example Output: Q:/My Drive/Research/data/DSWE_SE/2017/FALL/LC08_CU_019013_20171118_20181203_C01_V01_INWM.tif

library(raster)
library(stringr)
library(doParallel)
library(itertools)

# set.seed(42)
# r1 <- raster(matrix(sample(c(NA, 0:4, 9), 100, rep=T), nrow=10))
# r2 <- raster(matrix(sample(c(NA, 0:4, 9), 100, rep=T), nrow=10))
# r3 <- raster(matrix(sample(c(NA, 0:4, 9), 100, rep=T), nrow=10))
# r4 <- raster(matrix(sample(c(NA, 0:4, 9), 100, rep=T), nrow=10))
# s <- stack(r1, r2, r3, r4)
# s_v <- values(s)


myf <- function(x){
    # check for all na
    if(all(is.na(x))) return(c(NA, NA, NA, NA, NA))

    # set a temporary raster stack without NA's
    tmp <- x[!is.na(x)]

    #get all high conf. water (1)
    n_1 <- as.integer(sum(as.numeric(tmp==1 & !is.na(tmp))))

    #get all water (1-4)
    n_water <- as.integer(sum(as.numeric(tmp<9 & tmp>0 & !is.na(tmp))))

    #get all non-water (non-water and not cloud/cloud shadow --> land)
    n_0 <- as.integer(sum(as.numeric(tmp==0 & !is.na(tmp))))

    #get all cloud (9)
    n_9 <- as.integer(sum(as.numeric(tmp==9 & !is.na(tmp))))

    #get fraction of high conf. water vs all other water and land
    p_1 <- ifelse(
        sum(as.numeric(tmp<9 & !is.na(tmp))) == 0,
        as.integer(0),
        as.integer(round((sum(tmp[tmp == 1], na.rm=T) / sum(as.numeric(tmp<9 & !is.na(tmp))) * 100),0))
    )
    
    # get fraction of water values among not-missing data
    # water_n <- (sum(tmp[tmp > 0], na.rm=T) / sum(!is.na(tmp))) * 100

    # water_n <- ifelse(
    #     (sum(as.numeric(tmp<9 & !is.na(tmp))) == 0 
    #       | is.na(sum(as.numeric(tmp<9 & !is.na(tmp))))), 
    #       0, 
    #       sum(as.numeric((tmp<9 & tmp>0) & !is.na(tmp))) / sum(as.numeric(tmp<9 & !is.na(tmp)))
    # )

    # total_n <- sum(!is.na(tmp)) # perhaps you'd want to return this too, the # of good vals

    return(c(n_1, n_water, n_0, n_9, p_1))

}

# water_composite_v <- apply(s_v, 1, myf)
# water_composite_s <- stack(s, r1)
# values(water_composite_s) <- t(water_composite_v)
# names(water_composite_s) <- c("Count 1", "All water", "Count 0", "Count 9", "Percent 1")
# plot(s)
# plot(water_composite_s)


# lst <- list.files("../data/DSWE_SE/2018/Fall", full.names = T, pattern = '\\.tif')[1:5]
# small_stack <- raster::stack(lst)

# small_stack_vals <- raster::values(small_stack)
# small_stack_comp <- apply(small_stack_vals, 1, myf)
# small_comp <- small_stack
# raster::values(small_comp) <- t(small_stack_comp)
# names(small_comp) <- c("Count 1", "All water", "Count 0", "Count 9", "Percent 1")
# #plot(small_stack)
# plot(small_comp)

# get list of ARD tile names (all start with 0) in the study area
tiles <- read.csv("../data/DSWE_SE/tiles.csv", stringsAsFactors = F)[,1]
tiles <- str_pad(as.character(tiles), 6, pad = "0")

years <- rev(list.files("../data/DSWE_SE/raw_tifs", full.names=T))
for(fldr in years[3]){
    yr_szn <- c()
    if(file.exists(file.path(fldr,"Fall"))){
        yr_szn <- append(yr_szn, file.path(fldr,"Fall"))
    }
    if(file.exists(file.path(fldr,"Spring"))){
        yr_szn <- append(yr_szn, file.path(fldr,"Spring"))
    }
    if(file.exists(file.path(fldr,"Summer"))){
        yr_szn <- append(yr_szn, file.path(fldr,"Summer"))
    }
    if(file.exists(file.path(fldr,"Winter"))){
        yr_szn <- append(yr_szn, file.path(fldr,"Winter"))
    }
    print(yr_szn)
    for(sub_fldr in yr_szn){
        # check if processed_tif folders exist, if not, make them
        out_fldr <- file.path("../data/DSWE_SE/processed_tifs",basename(fldr),paste("tiles_",basename(sub_fldr),sep=""))
        if(!file.exists(out_fldr)){
            if(!file.exists(dirname(out_fldr))){
                dir.create(dirname(out_fldr))
            }
            dir.create(out_fldr)
        }

        # get list of tif files in folder (will build this out later, but going one at a time for now)
        fls <- list.files(sub_fldr, full.names = T, pattern = '\\.tif')

        # set up parallel processing
        ncores <- detectCores() - 1
        cl <- makePSOCKcluster(ncores)
        registerDoParallel(cl)

        # build composite rasters by tile
        i <- 1
        for(t in tiles){
            # generate file name of processed composite raster
            fl_name <- file.path(out_fldr, paste(t,"_composite.tif", sep=""))

            # if processed composite raster doesn't exist, make it
            if(!file.exists(fl_name)){

                # get all tif files that have the tile name in their file name
                rstr_lst <- fls[grep(paste("_",t,"_",sep=""), fls, ignore.case = FALSE, perl = FALSE, fixed = TRUE)]
                print(paste0(length(rstr_lst), " rasters for tile ", t))

                # read in rasters
                lst_stack <- raster::stack(rstr_lst)
                # get raster values as matrix
                stack_vals <- raster::values(lst_stack)
                
                # process rasters to get counts of high conf. water, all water, land, cloud, and 
                #    percent of high conf. water, using parallel processing
                print("Beginning composite.")
                composite_vals <- foreach(m=isplitRows(stack_vals, chunks=ncores),
                                        .combine=c,
                                        .multicombine=T) %dopar% {
                                            apply(m,1,myf)
                                        }
                print("Composite complete.")
                rm(stack_vals)   # remove stack_vals matrix to free up memory

                # convert parallel output vector to matrix with columns for each raster of interest
                comp_mat <- matrix(composite_vals, ncol=5, byrow=T)
                comp <- subset(lst_stack, 1:5)   # prep raster space for composite (comp)

                rm(lst_stack)   # remove lst_stack RasterStack to free up memory

                # set comp_mat values to raster with each column as a raster band
                raster::values(comp) <- comp_mat
                names(comp) <- c("Count 1", "All water", "Count 0", "Count 9", "Percent 1")
            
                rm(comp_mat)   # remove comp_mat matrix to free up memory
        
                # write raster to tiles folder
                writeRaster(comp, filename = fl_name, format="GTiff",overwrite=T)
                print(paste0("Raster ", basename(fl_name), " written successfully, ", round(i/90*100,1), "% completed."))

                rm(comp)   # remove comp RasterStack to free up memory
            } 
            
            else {print(paste(basename(fl_name), "already exists."))}
            
            i <- i + 1

        }
        stopCluster(cl)

        print(paste(out_fldr, "complete."))

    }
}

    