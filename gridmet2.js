// Aggregate GRIDMET climate data to HUC8 level

// var avgStAnomaly = function(){
  
// };

var huc8_outline = ee.FeatureCollection("users/mdgaines/HUC08_outline");
var huc8 = ee.FeatureCollection("users/mdgaines/HUC08_trimmed");

var GRIDMET_data = ee.ImageCollection('IDAHO_EPSCOR/GRIDMET')
                  .filterBounds(huc8_outline)
                  .filter(ee.Filter.date('1985-01-01', '2019-03-01'))
                  .map(function(img) {return img.clip(huc8_outline)});


// Winter

var winterAll_AvgMaxTemp = GRIDMET_data.select('tmmx')
                          .filterDate('2018-12-01','2019-03-01')
                          .reduce(ee.Reducer.mean());
  
var winterAll_StdevMaxT = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(12,2,'month'))
                          .reduce(ee.Reducer.stdDev());

var winter18_maxTemp = GRIDMET_data.select('tmmx')
                        .filterDate('2018-12-01','2019-03-01')
                        .reduce(ee.Reducer.mean());

var winter18_stAnomaly = winter18_maxTemp.subtract(winterAll_AvgMaxTemp)
                          .divide(winterAll_StdevMaxT);
  
var w18_huc8_MxTanom = winter18_stAnomaly.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.mean(),
  scale: 4000 
});

var w18_huc8_MxTanom_out = w18_huc8_MxTanom.select(['.*'],null,false);

w18_huc8_MxTanom_out = w18_huc8_MxTanom_out.map(function(feature){
  return feature.set('Yr_Szn','2018_W');
});

Export.table.toDrive({
  collection: w18_huc8_MxTanom_out,
  description: 'GRIDMET_winter18_maxTemp_anomoly_by_HUC08',
  folder: 'ClimateData',
  fileFormat: 'CSV'
});



// Spring

var springAll_AvgMaxTemp = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(3,5,'month'))
                          .reduce(ee.Reducer.mean());
  
var springAll_StdevMaxT = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(3,5,'month'))
                          .reduce(ee.Reducer.stdDev());

var spring18_maxTemp = GRIDMET_data.select('tmmx')
                        .filter(ee.Filter.calendarRange(3,5,'month'))
                        .filter(ee.Filter.calendarRange(2018,2018,'year'))
                        .reduce(ee.Reducer.mean());

var spring18_stAnomaly = spring18_maxTemp.subtract(springAll_AvgMaxTemp)
                          .divide(springAll_StdevMaxT);
  
var sp18_huc8_MxTanom = spring18_stAnomaly.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.mean(),
  scale: 4000 
});

var sp18_huc8_MxTanom_out = sp18_huc8_MxTanom.select(['.*'],null,false);

sp18_huc8_MxTanom_out = sp18_huc8_MxTanom_out.map(function(feature){
  return feature.set('Yr_Szn','2018_Sp');
});

Export.table.toDrive({
  collection: sp18_huc8_MxTanom_out,
  description: 'GRIDMET_spring18_maxTemp_anomoly_by_HUC08',
  folder: 'ClimateData',
  fileFormat: 'CSV'
});



// Summer

var summerAll_AvgMaxTemp = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(6,8,'month'))
                          .reduce(ee.Reducer.mean());
  
var summerAll_StdevMaxT = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(6,8,'month'))
                          .reduce(ee.Reducer.stdDev());

var summer18_maxTemp = GRIDMET_data.select('tmmx')
                        .filter(ee.Filter.calendarRange(6,8,'month'))
                        .filter(ee.Filter.calendarRange(2018,2018,'year'))
                        .reduce(ee.Reducer.mean());

var summer18_stAnomaly = summer18_maxTemp.subtract(summerAll_AvgMaxTemp)
                          .divide(summerAll_StdevMaxT);
  
var su18_huc8_MxTanom = summer18_stAnomaly.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.mean(),
  scale: 4000 
});

var su18_huc8_MxTanom_out = su18_huc8_MxTanom.select(['.*'],null,false);

su18_huc8_MxTanom_out = su18_huc8_MxTanom_out.map(function(feature){
  return feature.set('Yr_Szn','2018_Su');
});

Export.table.toDrive({
  collection: su18_huc8_MxTanom_out,
  description: 'GRIDMET_summer18_maxTemp_anomoly_by_HUC08',
  folder: 'ClimateData',
  fileFormat: 'CSV'
});



// Fall

var FallAll_AvgMaxTemp = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(6,8,'month'))
                          .reduce(ee.Reducer.mean());
  
var FallAll_StdevMaxT = GRIDMET_data.select('tmmx')
                          .filter(ee.Filter.calendarRange(6,8,'month'))
                          .reduce(ee.Reducer.stdDev());

var Fall18_maxTemp = GRIDMET_data.select('tmmx')
                        .filter(ee.Filter.calendarRange(6,8,'month'))
                        .filter(ee.Filter.calendarRange(2018,2018,'year'))
                        .reduce(ee.Reducer.mean());

var Fall18_stAnomaly = Fall18_maxTemp.subtract(FallAll_AvgMaxTemp)
                          .divide(FallAll_StdevMaxT);
  
var f18_huc8_MxTanom = Fall18_stAnomaly.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.mean(),
  scale: 4000 
});

var f18_huc8_MxTanom_out = f18_huc8_MxTanom.select(['.*'],null,false);

f18_huc8_MxTanom_out = f18_huc8_MxTanom_out.map(function(feature){
  return feature.set('Yr_Szn','2018_F');
});

Export.table.toDrive({
  collection: f18_huc8_MxTanom_out,
  description: 'GRIDMET_Fall18_maxTemp_anomoly_by_HUC08',
  folder: 'ClimateData',
  fileFormat: 'CSV'
});


// print(sp18_huc8_MxTanom);

// var maximumTemperatureVis = {
//   min: 290.0,
//   max: 314.0,
//   palette: ['d8d8d8', '4addff', '5affa3', 'f2ff89', 'ff725c'],
// };

// var stAnom = {
//   min: -1,
//   max: 1,
//   palette: ['d8d8d8', '4addff', '5affa3', 'f2ff89', 'ff725c'],
// };

// Map.setCenter(-84.629, 34.162, 5);
// //Map.addLayer(springAll_AvgMaxTemp, maximumTemperatureVis, 'Spring Average');
// Map.addLayer(fall18_maxTemp, maximumTemperatureVis, 'Fall 2018 Average');
// Map.addLayer(fall18_stAnomaly, stAnom, 'Fall 2018 StAnom');
// Map.addLayer(sp18_huc8_MxTanom, stAnom, 'Spring 18 HUC Average');

// var dataset = ee.ImageCollection('IDAHO_EPSCOR/GRIDMET')
//                   .filter(ee.Filter.date('2018-08-01', '2018-08-15'));
// var precip = dataset.select('pr');
// var prVis = {
//   min: 0,
//   max: 50.0,
//   palette: ['d8d8d8', '4addff', '5affa3', 'f2ff89', 'ff725c'],
// };
// Map.setCenter(-115.356, 38.686, 5);
// Map.addLayer(precip, prVis, 'Precipitation');
