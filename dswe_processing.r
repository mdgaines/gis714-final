###########################################################################################
###########################################################################################
## This script contains several routines to preprocess the DWSE dataset ###################
## Edited by: Vini                                                      ################### 
## Date: Oct, 2019                                                      ###################
## Edited by: Mollie (for my uses)                                      ###################
## Date: Feb 2020
###########################################################################################

# load spatial packages
library(raster)
library(rgdal)
library(rgeos)

# turn off factors
options(stringsAsFactors = FALSE)
setwd('Q:/My Drive/Research/scripts')


###### Single layer extraction routine   ##################################################
###### Extract in the same year/month folder   ############################################

#inputs
path_tar = 'G:/My Drive/Vini Perin - PhD CGA/datasets/DWSE/1995_2002' #folder with .tar files
path_extract =  file.path(path_tar,'extract_test') #folder to store single

#conditions for path extract 
if (!dir.exists(path_extract)){
     dir.create(path_extract) 
    }  else {
}

#create a list of .tar files from path_tar
list_tar <- list.files(path_tar, full.names = TRUE, pattern = '\\.tar')

ind = 1 #index to count number of images processed

#apply for loop in list_tar
for (i in list_tar[1:20]){
    #get date, month
    date = as.Date(unlist(strsplit(unlist(strsplit(i,'/'))[7],'_'))[4],'%Y%m%d')
    year = strftime(date, "%Y")
    month = strftime(date, "%m")
    tile = unlist(strsplit(unlist(strsplit(i,'/'))[7],'_'))[3]

    #extract dir
    extract_dir = file.path(path_extract,tile)

    #separate by tile
    if (!dir.exists(extract_dir)){
        dir.create(extract_dir)
    } else {
    } 

    #retrive layer name
    filename = paste(sub('\\SW.tar$', '',basename(i)),'INWM.tif', sep ='') #INWM layer
    
    #separate by year_month
    extract_dir_ym = file.path(extract_dir, paste(year,month,sep = '_'))

    if (!dir.exists(extract_dir_ym)){
        dir.create(extract_dir_ym)
    } else {
    }

    #apply untar function again
    img_untar <- untar(i, files = filename, exdir = extract_dir_ym)

    #print a message once the image is complete.
    print(sprintf("Image %s is completed. Image number %s of %s ", filename, ind, length(list_tar)))

    #add index
    ind = ind + 1

#print a reasonable message!
print(sprintf('All images in %s were processed. Go do something with it!',path_tar))
}   

###########################################################################################
###########################################################################################
###########################################################################################

###### Add scenes for each ARD tile from 1995 to 2019   ###################################
###### Parallel processing is necessary   #################################################

###########################################################################################
# This script "mosaic" scenes using parallel processing in windows#########################
# Edited by: Vini                                       ###################################
###########################################################################################

#Function that are we going to parallel process!
#select most confident water pixel
#This is a pixel-based approach! 
#If we have overlapping scenes, than it selects the most confident water pixel classification.
water_pixel <- function(x){
  # fill anything that isn't 0, 1, 2, 3, or 4 with NA
  tmp <- rep(NA, length(x))
  tmp[x %in% 0:4] <- x[x %in% 0:4]
  # check for all na
  if(all(is.na(tmp))) return(NA)
  # cjeck for all 0
  if(all(sum(tmp, na.rm =T) == 0)) return(0)
  # get maximum value in tmp
  max_water_conf <- min(tmp[tmp>0], na.rm=T)

  return(max_water_conf)
}

#Load libraries
library(raster)
library(doParallel) #for parallel using foreach
library(itertools) #for isplitRows in foreach
library(BLR) #maybe we do not need this

#First create a list of raster stacks so we can parallel several at one time!
path = 'Q:/My Drive/Vini Perin - PhD CGA/datasets/DWSE/INWM_layer' #path with the images already divided into folder/tiles
mosaic_f = 'Q:/My Drive/Vini Perin - PhD CGA/datasets/DWSE/mosaic_tiles'

#get different tiles
tiles <- list.dirs(path = path , full.names = F, recursive = F)

#seetings for our pararrel processing
ncores <- 8 #Max cores that I have available!
cl <- makePSOCKcluster(ncores) #PSOCK for windows
registerDoParallel(cl)

#read each month in a for loop
for (i in tiles[2:5]){
    #get the months in each tile
    months = list.dirs(file.path(path,i),full.names = F, recursive = F)

    #get the files from each tile and each month
    for(x in months){
        #path for each tile and each month
        tile_path = file.path(path,i,x)

        #list files in tile_path
        list_ <-  list.files(tile_path ,full.names = T, pattern = '\\.tif')

        #stack rasters
        s <- stack(list_ )

        #get values
        s_v <- raster::values(s)
        #print message before start process
        print(sprintf('Processing %s and %s',i,x))

        #parallel each tiles
        max_water <- foreach(m=isplitRows(s_v, chunks=ncores),
                             .combine='c',
                             .multicombine =T)  %dopar% {
                              apply(m,1,water_pixel)
                             }
        #save monthly mosaic
        composite <- subset(s, 1)
        raster::values(composite) <- t(max_water)
        names(composite) <- c("MaxWaterConfidence")

        #save mosaic
        file_name = paste(i, '_', x,'.tif', sep='')
        #write raster
        writeRaster(composite, filename = file.path(mosaic_f,file_name),format="GTiff", overwrite=TRUE)
        #print nice message
        print(sprintf('File %s was created and saved at %s',file_name,mosaic_f))
    }

stopCluster(cl)
}

###########################################################################################
###########################################################################################
###########################################################################################

# FUNCTIONS UNDER CONSTRUCTIONS !!! THESE ARE GENERAL IDEAS! ##############################

###########################################################################################
###########################################################################################
###########################################################################################

######-- Function to mosaic list of rasters --##############
######-- This function takes around 45s per mosaic! --######
mosaic_IWNM <- function(path_rasters, extract_dir,...){
    #path to rasters and mosaic folder 
    path_rasters = path_rasters
    extract_dir = extract_dir

    #create a list/matrix with all possible dates
    #this part list the layer names! Including the date
    list_all_dates = list.files(path_rasters, pattern = '\\.tif')

    #THIS IS PROBLEMATIC
    #get unique dates
    #ncol = 8, because the name is divided into 8 parts after we apply strsplit
    dates = unique(matrix(unlist(strsplit(list_all_dates,'_')),ncol=8,byrow=TRUE)[,4])

    for (x in dates){

        #create a list of raster files based on x > date in dates!
        pattern = paste('.*',x ,'.*\\.tif', sep = '')

        #list_rasters based on pattern
        list_rasters <- list.files(path_rasters, full.names = TRUE, pattern = pattern)

        #crete an empty raster
        mergeResImg = raster()
        for (i in list_rasters){
            img = raster(i)
            if (abs(mergeResImg@data@min) == abs(mergeResImg@data@max)) {
                mergeResImg = img
            }
            else {
                mergeResImg = merge(mergeResImg, img)
            }
        }

        names = paste(x,'.tif', sep = '')
        writeRaster(mergeResImg, names, extract_dir, overwrite = T) #extract_dir. There might be a problem with this.
        print(sprintf('Images from %s is done!',x))

    }
}


#Final objective: create a monthly mosaic, including all tiles.
#Steps: 1) mosaic and clamp all monthly data for one tile
#       2) put all monthly tiles together, here we apply mosaic again
#       3) save monthly entire area mosaic
#
#For step #1: mosaic and clamp all scenes for one month and one tile
#giving the path for different tiles
test_path = 'Q:/My Drive/Vini Perin - PhD CGA/datasets/DWSE/test_polygon2/single'
tiles <- list.dirs(path = test_path , full.names = F, recursive = F)

#read each month in a for loop
for (i in tiles){
    #get the months in each tile
    months = list.dirs(file.path(test_path,i),full.names = F, recursive = F)

    #get the files from each tile and each month
    for(x in months){
        #path for each tile and each month
        tile_path = file.path(test_path,i,x)

        #list files in tile_path
        list_ <-  list.files(tile_path ,full.names = T, pattern = '\\.tif')

        #retrieve files from list_
        print(sprintf('Processing %s and %s',i,x))
        r <- lapply(list_ , raster) #files to raster. Here we create a list of all files available
        for(z in 1:length(r)){r[[z]] <- clamp(r[[z]],lower = 1, upper = 4, useValues = F)} #here we clamp to the values to have only numbers that we are interested
        r <- do.call(mosaic, c(r, fun = max)) #mosaic all scenes for one tile and one month, overlap will retrieve the max value

        #save all tiles, for a each month in one folder
        #create folder mosaic if does not exist
        mosaic_f = file.path(test_path,'mosaic')

        #condition to create
        if (!dir.exists(mosaic_f)){
        dir.create(mosaic_f)
        print('mosaic folder was created.')
        } else {   
        }
        
        #write r.tif
        file_name = paste(i, '_', x,'.tif', sep='')
        #save
        writeRaster(r, filename = file.path(mosaic_f,file_name),format="GTiff", overwrite=TRUE)

        #print a reasonable message
        print(sprintf('File %s was created and saved at %s',file_name,mosaic_f))

        
    }
    
}

####### There may be problems with this function ####################
####### Untar and stack files  in folder directory ##################
####### This function is to stack all layers from one image! ########
####### we may still need to work on this!! #########################

untar_and_stack_all <- function(path_tar,...){
    path_tar = path_tar
    path_untar = paste(path_tar, 'untar', sep = '')
    path_stack = paste(path_tar, 'stack', sep = '')

    #condition to create untar folder
    if (!dir.exists(path_untar)){
    dir.create(path_untar)
    } else {
        print("Untar folder already exists!")
    }

    #condition to create save folder
    if (!dir.exists(path_stack)){
    dir.create(path_stack)
    } else {
        print("Stack folder already exists!")
    }

    #create a list of .tar files
    list_tar <- list.files(path_tar, full.names = TRUE, pattern = '\\.tar')

    #create a loop into the list_tar

    for (i in list_tar){
        
        #name of extract directory > DWSE ou landsat scene image name!
        folder = gsub('.tar','',strsplit(i,'/')[[1]][7])

        #create extract directory 
        extract_dir = file.path(path_untar,folder) #warning messages when there is already the unzipped files

        if (!dir.exists(extract_dir)){
        dir.create(extract_dir)
        } else {
            print("Extract directory already exists!")
        } 

        #Apply untar function  
        img_untar <- untar(i, list = FALSE, exdir = extract_dir)

        #list .tif files in extract_dir!
        list_tif <- list.files(extract_dir, full.names = TRUE, pattern = '\\.tif')

        #create a raster stack with .tifs
        raster_s <- stack(list_tif)

        #rename .tifs using shorter names
        #this problematic when applying the rasterWrite - it does not save the stack the layer names
        raster_s <- setNames(raster_s,c('DIAG','INTR','INWM','MASK','SHADE','SLOPE'))
        #save the raster stack
        writeRaster(raster_s, file.path(path_stack,paste(folder,'.tif',sep='')), format="GTiff",options="INTERLEAVE=BAND", overwrite=TRUE)

        #print a message once the image is complete.
        print(sprintf("Image %s is completed.", folder))
    }
}