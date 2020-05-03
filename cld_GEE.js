
var huc8_outline = ee.FeatureCollection("users/mdgaines/HUC08_outline");
var huc8 = ee.FeatureCollection("users/mdgaines/HUC08_trimmed");

var dataset = ee.ImageCollection('USDA/NASS/CDL')
                  .filterBounds(huc8_outline)
                  .filter(ee.Filter.calendarRange(2019,2019,'year')) //did this for 2018 and 2019
                  .map(function(img) {return img.clip(huc8_outline)})
                  .first();
print(dataset)
  
var cropLandcover = dataset.select('cropland');
//print(cropLandcover);

// Natural Environments
var reclass_natural = function(image){
  var natural = image.remap([63,60,64,58,87,88,141,142,143,152,176,190,195],
                             [1, 1, 1, 1, 1, 1,  1,  1,  1,  1,  1,  1,  1],
                             null);
  return natural;
};

// Intensive Use
var reclass_intensive = function(image){
  var intensive = image.remap([65,61,82,121,122,123,124,131],
                               [1, 1, 1,  1,  1,  1,  1,  1],
                             null);
  return intensive;
};

// Agriculture
var reclass_ag = function(image){
  var agriculture = image.remap([63,60,64,58,87,88,141,142,143,152,176,190,195,
                                 65,61,82,121,122,123,124,131,
                                 81,83,111,112],
                                 [0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0,
                                  0, 0, 0,  0,  0,  0,  0,  0,
                                  0, 0,  0,  0],
                             1);
  return agriculture;
};


var natural_rcl = reclass_natural(cropLandcover);
var intense_rcl = reclass_intensive(cropLandcover);
var agricul_rcl = reclass_ag(cropLandcover);

Map.setCenter(-84.629, 34.162, 5);
Map.addLayer(cropLandcover, {}, 'Crop Landcover');
Map.addLayer(natural_rcl,{},'Reclass Natural');
Map.addLayer(intense_rcl,{},'Reclass Intense');
Map.addLayer(agricul_rcl,{},'Reclass Agricul');

  
var n_sum = natural_rcl.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.sum(),
  scale: 30 
});

var n_sum_out = n_sum.select(['.*'],null,false);

n_sum_out = n_sum_out.map(function(feature){
  return feature.set('Yr_Szn','2019_N');
});

Export.table.toDrive({
  collection: n_sum_out,
  description: 'CDL_natural19_sum_by_HUC08',
  folder: 'LandCover',
  fileFormat: 'CSV'
});


var i_sum = intense_rcl.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.sum(),
  scale: 30 
});

var i_sum_out = i_sum.select(['.*'],null,false);

i_sum_out = i_sum_out.map(function(feature){
  return feature.set('Yr_Szn','2019_N');
});

Export.table.toDrive({
  collection: i_sum_out,
  description: 'CDL_intense19_sum_by_HUC08',
  folder: 'LandCover',
  fileFormat: 'CSV'
});


var a_sum = agricul_rcl.reduceRegions({
  collection: huc8,
  reducer: ee.Reducer.sum(),
  scale: 30 
});

var a_sum_out = a_sum.select(['.*'],null,false);

a_sum_out = a_sum_out.map(function(feature){
  return feature.set('Yr_Szn','2019_N');
});

Export.table.toDrive({
  collection: a_sum_out,
  description: 'CDL_agro19_sum_by_HUC08',
  folder: 'LandCover',
  fileFormat: 'CSV'
});
