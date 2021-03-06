## scripts for data processing for paper 1

---

`untar.ipynb` decompresses .tar files containing the interperated and masked (INWM) DSWE product. Puts .tif files into folders by year and season.

`dswe_processing.r` processes the decompressed .tif files and aggregates by ARD Tile (total of 90 in the study area). Calculates 5 bands based on DSWE classifications: 
          Band 1: high confidence water count
          Band 2: any water count
          Band 3: land count
          Band 4: cloud count
          Band 5: (high water count / (land count + all water count)) * 100

`mosaic.py` merges 45 ARD tiles from the year-season to generate 2 raster files per year-season

`gridmet2.js` Google Earth Engine script to get standardized anomaly maximum temperature data for each season in 2018.

`cld_GEE.js` Google Earth Engine script to get percent of land cover types in each 8-digit HUC

`lmm.r` reads all csv files and compiles them into one csv and runs 2 linear mixed models and finds the marginal and conditional R^2 values for each model (disclaimer, this is not very cleanly written and will not be my final script when I scale up this project, but it got the job done quickly)

---

`error_files.txt` contains error messages from the decompression in untar.ipynb

---

## DSWE Naming Conventions
**LXSS_US_HHHVVV_YYYYMMDD_yyyymmdd_CCC_VVV_PACKAGE.tar**

(e.g., LC08_CU_006006_20160715_20171205_C01_V01_SW.tar)

|   |   |
| - | ------- |
| L | Landsat |
| X | Sensor (“C” = OLI / TIRS, “E” = ETM+, “T” = TM) |
| SS | Satellite (“08” = Landsat 8, “07” = Landsat 7, “05” = Landsat 5, “04” = Landsat 4) |
| US | Regional grid of the U.S. (“CU” = CONUS, “AK” = Alaska, “HI” = Hawaii)| 
| HHH | Horizontal tile number
| VVV | Vertical tile number
| YYYY | Acquisition year
| MM | Acquisition month
| DD | Acquisition day
| yyyy | ARD tile Production year
| mm | ARD tile Production month
| dd | ARD tile Production day
| CCC | Level 1 Collection number (“C01”, “C02”, etc.)
| VVV | Analysis Ready Data (ARD) Version number (“V01”, “V02”, etc.)
| PACKAGE | Data package (“SW” = Dynamic Surface Water Extent package)
