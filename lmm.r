#lmm.r
# linear mixed effects models for 714 project (lol it's due so soon :[] )

library(lme4)
library(MuMIn)

##### IMPORT DATA #####

## Surface Water Data
dswe <- read.csv("G:/My Drive/Research/data/DSWE_SE/hucStats_18.csv", stringsAsFactors = F)


## Climate Data
fall_max_temp <- read.csv("G:/My Drive/Research/data/ClimateData/fall18_maxTemp_anomoly.csv", stringsAsFactors = F)
spring_max_temp <- read.csv("G:/My Drive/Research/data/ClimateData/spring18_maxTemp_anomoly.csv", stringsAsFactors = F)
summer_max_temp <- read.csv("G:/My Drive/Research/data/ClimateData/summer18_maxTemp_anomoly.csv", stringsAsFactors = F)
winter_max_temp <- read.csv("G:/My Drive/Research/data/ClimateData/winter18_maxTemp_anomoly.csv", stringsAsFactors = F)

fall_min_temp <- read.csv("G:/My Drive/Research/data/ClimateData/fall18_minTemp_anomoly.csv", stringsAsFactors = F)
spring_min_temp <- read.csv("G:/My Drive/Research/data/ClimateData/spring18_minTemp_anomoly.csv", stringsAsFactors = F)
summer_min_temp <- read.csv("G:/My Drive/Research/data/ClimateData/summer18_minTemp_anomoly.csv", stringsAsFactors = F)
winter_min_temp <- read.csv("G:/My Drive/Research/data/ClimateData/winter18_minTemp_anomoly.csv", stringsAsFactors = F)

fall_Precip <- read.csv("G:/My Drive/Research/data/ClimateData/fall18_Pr_anomoly.csv", stringsAsFactors = F)
spring_Precip <- read.csv("G:/My Drive/Research/data/ClimateData/spring18_Pr_anomoly.csv", stringsAsFactors = F)
summer_Precip <- read.csv("G:/My Drive/Research/data/ClimateData/summer18_Pr_anomoly.csv", stringsAsFactors = F)
winter_Precip <- read.csv("G:/My Drive/Research/data/ClimateData/winter18_Pr_anomoly.csv", stringsAsFactors = F)


## Anthropogenic Data
# Landcover data
ag17 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_agro17_sum.csv", stringsAsFactors = F)
ag17$ag17_pAg <- (ag17$sum / (30 * 100)) / ag17$areasqkm
ag18 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_agro18_sum.csv", stringsAsFactors = F)
ag18$ag18_pAg <- (ag18$sum / (30 * 100)) / ag18$areasqkm
ag19 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_agro19_sum.csv", stringsAsFactors = F)
ag19$ag19_pAg <- (ag19$sum / (30 * 100)) / ag19$areasqkm

int17 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_intense17_sum.csv", stringsAsFactors = F)
int17$int17_pInt <- (int17$sum / (30 * 100)) / int17$areasqkm
int18 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_intense18_sum.csv", stringsAsFactors = F)
int18$int18_pInt <- (int18$sum / (30 * 100)) / int18$areasqkm
int19 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_intense19_sum.csv", stringsAsFactors = F)
int19$int19_pInt <- (int19$sum / (30 * 100)) / int19$areasqkm

nat17 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_natural17_sum.csv", stringsAsFactors = F)
nat17$nat17_pNat <- (nat17$sum / (30 * 100)) / nat17$areasqkm
nat18 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_natural18_sum.csv", stringsAsFactors = F)
nat18$nat18_pNat <- (nat18$sum / (30 * 100)) / nat18$areasqkm
nat19 <- read.csv("G:/My Drive/Research/data/LandCover/CDL_natural19_sum.csv", stringsAsFactors = F)
nat19$nat19_pNat <- (nat19$sum / (30 * 100)) / nat19$areasqkm

landcover <- ag17[c("huc8","ag17_pAg")]
landcover <- merge(landcover, ag18[c("huc8","ag18_pAg")], by = "huc8")
landcover <- merge(landcover, ag19[c("huc8","ag19_pAg")], by = "huc8")

landcover$f_pAg <- landcover$ag18_pAg
landcover$sp_pAg <- landcover$ag18_pAg * 0.8 + landcover$ag17_pAg * 0.2
landcover$su_pAg <- landcover$ag18_pAg * 0.9 + landcover$ag17_pAg * 0.1
landcover$w_pAg <- landcover$ag18_pAg * 0.2 + landcover$ag19_pAg * 0.8


landcover <- merge(landcover, int17[c("huc8","int17_pInt")], by = "huc8")
landcover <- merge(landcover, int18[c("huc8","int18_pInt")], by = "huc8")
landcover <- merge(landcover, int19[c("huc8","int19_pInt")], by = "huc8")

landcover$f_pInt <- landcover$int18_pInt
landcover$sp_pInt <- landcover$int18_pInt * 0.8 + landcover$int17_pInt * 0.2
landcover$su_pInt <- landcover$int18_pInt * 0.9 + landcover$int17_pInt * 0.1
landcover$w_pInt <- landcover$int18_pInt * 0.2 + landcover$int19_pInt * 0.8


landcover <- merge(landcover, nat17[c("huc8","nat17_pNat")], by = "huc8")
landcover <- merge(landcover, nat18[c("huc8","nat18_pNat")], by = "huc8")
landcover <- merge(landcover, nat19[c("huc8","nat19_pNat")], by = "huc8")

landcover$f_pNat <- landcover$nat18_pNat
landcover$sp_pNat <- landcover$nat18_pNat * 0.8 + landcover$nat17_pNat * 0.2
landcover$su_pNat <- landcover$nat18_pNat * 0.9 + landcover$nat17_pNat * 0.1
landcover$w_pNat <- landcover$nat18_pNat * 0.2 + landcover$nat19_pNat * 0.8

# Population
pop <- read.csv("G:/My Drive/Research/data/population/landscan_17_18.csv", stringsAsFactors = F)

pop$f_pPop <- (pop$lsat_18_sum * 0.9 + pop$lsat_17_sum * 0.1) / pop$areasqkm
pop$sp_pPop <- (pop$lsat_18_sum * 0.7 + pop$lsat_17_sum * 0.3) / pop$areasqkm
pop$su_pPop <- (pop$lsat_18_sum * 0.8 + pop$lsat_17_sum * 0.2) / pop$areasqkm
pop$w_pPop <- pop$lsat_18_sum / pop$areasqkm


##### GET ALL DATA INTO ONE FILE #####
all_data <- dswe[c("huc8","areasqkm","name","Fall18_m1_f18_m1_sum", "Fall18_m2_f18_m1_sum",
                    "Sp18_m1_sp18_m1_sum","Sp18_m2_sp18_m2_sum", "Su18_m1_su18_m1_sum",
                    "Su18_m2_su18_m2_sum","W18_m1_su18_m2_sum","W18_m2_w18_m2_sum")]

## Get percent water per HUC for each season
all_data[is.na(all_data)] <- 0

# Fall
all_data$f_pWater <- ((all_data$Fall18_m1_f18_m1_sum + all_data$Fall18_m2_f18_m1_sum) / (30 * 100)) / all_data$areasqkm
all_data$Fall18_m1_f18_m1_sum <- NULL
all_data$Fall18_m2_f18_m1_sum <- NULL

# Spring
all_data$sp_pWater <- ((all_data$Sp18_m1_sp18_m1_sum + all_data$Sp18_m2_sp18_m2_sum) / (30 * 100)) / all_data$areasqkm
all_data$Sp18_m1_sp18_m1_sum <- NULL
all_data$Sp18_m2_sp18_m2_sum <- NULL

# Summer
all_data$su_pWater <- ((all_data$Su18_m1_su18_m1_sum + all_data$Su18_m2_su18_m2_sum) / (30 * 100)) / all_data$areasqkm
all_data$Su18_m1_su18_m1_sum <- NULL
all_data$Su18_m2_su18_m2_sum <- NULL

# Winter
all_data$w_pWater <- ((all_data$W18_m1_su18_m2_sum + all_data$W18_m2_w18_m2_sum) / (30 * 100)) / all_data$areasqkm
all_data$W18_m1_su18_m2_sum <- NULL
all_data$W18_m2_w18_m2_sum <- NULL

## Get Standardized Weather Anomalies for each season
# Max Temp
all_data <- merge(all_data, fall_max_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "f_MxTemp"
all_data <- merge(all_data, spring_max_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "sp_MxTemp"
all_data <- merge(all_data, summer_max_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "su_MxTemp"
all_data <- merge(all_data, winter_max_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "w_MxTemp"

# Min Temp
all_data <- merge(all_data, fall_min_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "f_MnTemp"
all_data <- merge(all_data, spring_min_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "sp_MnTemp"
all_data <- merge(all_data, summer_min_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "su_MnTemp"
all_data <- merge(all_data, winter_min_temp[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "w_MnTemp"

# Precip
all_data <- merge(all_data, fall_Precip[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "f_Pr"
all_data <- merge(all_data, spring_Precip[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "sp_Pr"
all_data <- merge(all_data, summer_Precip[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "su_Pr"
all_data <- merge(all_data, winter_Precip[c("mean","huc8")], by = "huc8")
names(all_data)[length(names(all_data))] <- "w_Pr"

## Get percent landcover per season
# Agriculture
all_data <- merge(all_data, landcover[c("f_pAg","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("sp_pAg","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("su_pAg","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("w_pAg","huc8")], by = "huc8")

# Intensive
all_data <- merge(all_data, landcover[c("f_pInt","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("sp_pInt","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("su_pInt","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("w_pInt","huc8")], by = "huc8")

# Natural
all_data <- merge(all_data, landcover[c("f_pNat","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("sp_pNat","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("su_pNat","huc8")], by = "huc8")
all_data <- merge(all_data, landcover[c("w_pNat","huc8")], by = "huc8")

## Get population density per season
all_data <- merge(all_data, pop[c("f_pPop","huc8")], by = "huc8")
all_data <- merge(all_data, pop[c("sp_pPop","huc8")], by = "huc8")
all_data <- merge(all_data, pop[c("su_pPop","huc8")], by = "huc8")
all_data <- merge(all_data, pop[c("w_pPop","huc8")], by = "huc8")

##### RUN LINEAR MIXED MODELS #####

# HUCs are Random Effects
# All others are Fixed Effects (for this 1 year model)
# Response variable is mean % dswe over all seasons

all_data$mean_pWater <- (all_data$f_pWater + all_data$sp_pWater + all_data$su_pWater + all_data$w_pWater) / 4

# Model 1 has only Climate Data
model1 <- lmer(log(mean_pWater) ~ f_MxTemp + sp_MxTemp + su_MxTemp + w_MxTemp +
                                 f_MnTemp + sp_MnTemp + su_MnTemp + w_MnTemp +
                                 f_Pr + sp_Pr + su_Pr + w_Pr +
                                 (1|huc8), data = all_data)

# Model 2 has Climate Data and Anthropogenic Data
model2 <- lmer(log(mean_pWater) ~ f_MxTemp + sp_MxTemp + su_MxTemp + w_MxTemp +
                                 f_MnTemp + sp_MnTemp + su_MnTemp + w_MnTemp +
                                 f_Pr + sp_Pr + su_Pr + w_Pr +
                                 f_pAg + sp_pAg + su_pAg + w_pAg +
                                 f_pInt + sp_pInt + su_pInt + w_pInt +
                                 f_pNat + sp_pNat + su_pNat + w_pNat +
                                 f_pPop + sp_pPop + su_pPop + w_pPop +
                                 (1|huc8), data = all_data)


##### TRY WITH LONG TABLE #####

fall_data <- all_data[c("huc8","f_pWater","f_MxTemp","f_MnTemp","f_Pr","f_pAg","f_pInt","f_pNat","f_pPop")]
names(fall_data) <- c("huc8","pWater","MxTemp","MnTemp","Pr","pAg","pInt","pNat","pPop")
fall_data$Season <- "Fall"

spring_data <- all_data[c("huc8","sp_pWater","sp_MxTemp","sp_MnTemp","sp_Pr","sp_pAg","sp_pInt","sp_pNat","sp_pPop")]
names(spring_data) <- c("huc8","pWater","MxTemp","MnTemp","Pr","pAg","pInt","pNat","pPop")
spring_data$Season <- "Spring"

summer_data <- all_data[c("huc8","su_pWater","su_MxTemp","su_MnTemp","su_Pr","su_pAg","su_pInt","su_pNat","su_pPop")]
names(summer_data) <- c("huc8","pWater","MxTemp","MnTemp","Pr","pAg","pInt","pNat","pPop")
summer_data$Season <- "Summer"

winter_data <- all_data[c("huc8","w_pWater","w_MxTemp","w_MnTemp","w_Pr","w_pAg","w_pInt","w_pNat","w_pPop")]
names(winter_data) <- c("huc8","pWater","MxTemp","MnTemp","Pr","pAg","pInt","pNat","pPop")
winter_data$Season <- "Winter"

long_data <- rbind(fall_data, spring_data, summer_data, winter_data)
long_data$MxTemp <- long_data$MxTemp * -1
long_data$MnTemp <- long_data$MnTemp * -1
long_data$Pr <- long_data$Pr * -1

write.csv(long_data, "G:/My Drive/GIS714/Project/hucData_2018.csv")


### TRY LMM Round 2
# Model 1 has only Climate Data
model1 <- lmer(log(pWater) ~ MxTemp + MnTemp + Pr + Season +
                             (1|huc8), data = long_data)

# Model 2 has Climate Data and Anthropogenic Data
model2 <- lmer(log(pWater) ~ MxTemp + MnTemp + Pr + 
                             pAg + pInt + pNat + 
                             pPop + Season +
                             (1|huc8), data = long_data)


summary(model1)
summary(model2)

MuMIn::r.squaredGLMM(model1)
MuMIn::r.squaredGLMM(model2)