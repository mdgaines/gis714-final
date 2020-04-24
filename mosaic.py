# mosaic.py
# Authors: Mollie Gaines and Vini Perin
# Purpose: merge all DSWE tiff tiles together to make a large raster of DSWE

# env installed with rasterio glob2 numpy and pylint (for vs code)

import glob
from osgeo import gdal
import time, os


def mosaic(rstr_lst,out_path):
    ''' Takes a list of raster files and merges them together '''

    print("--- starting mosaic ---")

    vrt_options = gdal.BuildVRTOptions(resampleAlg='nearest',addAlpha=True,xRes =30,yRes=30)
    
    #create the VRT with the raster list
    temp_vrt = gdal.BuildVRT('temp.vrt', rstr_lst, options=vrt_options)

    #we need to specify the translation option before,
    # here we add Gtiff and COMPRESS; to deal with big rasters and compression, the final output will have
    # 4gb
    #we can set other commands as well
    translateoptions = gdal.TranslateOptions(gdal.ParseCommandLine(("-of Gtiff -co COMPRESS=LZW")))

    #time it
    start_time = time.time()
    #apply gdalTranslate and then save the raster
    gdal.Translate(out_path, temp_vrt, options= translateoptions)
    #print a message as soon as it is over!
    print("--- {0} merged in {1} minutes ---".format(os.path.basename(out_path),round((time.time() - start_time)/60,2)))



baseDirPath = "G:/My Drive/Research/data/DSWE_SE/processed_tifs"
yrs_dir = [ name for name in os.listdir(baseDirPath) if os.path.isdir(os.path.join(baseDirPath, name)) ]
for yr in yrs_dir:
    szn_dir = [ name for name in os.listdir(os.path.join(baseDirPath,yr)) if os.path.isdir(os.path.join(baseDirPath, yr, name)) ]
    for szn in szn_dir: 

        path = os.path.join(baseDirPath,yr,(yr+szn[5:]+"_m1.tif"))
        if not os.path.exists(path):
            lst_rasters = sorted(glob.glob(os.path.join(baseDirPath,yr,szn) + "/*.tif"))
            
            lst_1 = lst_rasters[:45]
            mosaic(lst_1,path)
        else:
            print("{0} already exists.".format(path))

        path = os.path.join(baseDirPath,yr,(yr+szn[5:]+"_m2.tif"))
        if not os.path.exists(path):
            lst_2 = lst_rasters[45:]
            mosaic(lst_2,path)
        else:
            print("{0} already exists.".format(path))
        
        print("{0} {1} merging completed.".format(yr, szn))
        
    print("All seasons for {0} merged.".format(yr))
    
print("--- End merging. ---")
        



# #List rasters
# #I was sorting then to try make it in batch
# lst_rasters = sorted(glob.glob('G:\\My Drive\\Research\\data\\DSWE_SE\\2018\\Fall\\tiles/*.tif'))[45:90]

# #this is useful
# #https://gdal.org/python/osgeo.gdal-module.html#BuildVRTOptions
# #https://gis.stackexchange.com/questions/291508/using-config-flag-with-the-python-gdal-gdal-translate
# #https://gis.stackexchange.com/questions/299059/osgeo-gdal-translate-how-to-set-compression-on-gdal-gtiff-driver

# vrt_options = gdal.BuildVRTOptions(resampleAlg='nearest',addAlpha=True,xRes =30,yRes=30)

# #create the VRT with the raster list,
# #when having the all 90 rasters, it should be a file of about 250kb
# my_vrt = gdal.BuildVRT('part2.vrt',lst_rasters, options=vrt_options)

# #we need to specify the translation option before,
# # here we add Gtiff and COMPRESS; to deal with big rasters and compression, the final output will have
# # 4gb
# #we can set other commands as well
# translateoptions = gdal.TranslateOptions(gdal.ParseCommandLine(("-of Gtiff -co COMPRESS=LZW")))


# #time it
# start_time = time.time()
# #apply gdalTranslate and then save the raster
# gdal.Translate('batch2.tif', my_vrt, options= translateoptions)
# #print a message as soon as it is over!
# print("--- %s seconds ---" % (time.time() - start_time))
