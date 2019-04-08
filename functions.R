# Your custom code is a bunch of functions.
brick_from_path <- function(rasters_path,
                            pattern="\\.tif$"){
  rasters <- list.files(rasters_path,
                        pattern=pattern,
                        full.names = TRUE)
  .brik <- brick()
  for (i in 1:length(rasters))
  {
    .brik<-addLayer(brik, raster(rasters[i]))
  }
  return(.brik)
}


datos_sp <- function(sp = "Panthera onca", rast)
{
    bbox <- gbif_bbox2wkt(minx = xmin(rast),
                          miny = ymin(rast),
                          maxx = xmax(rast),
                          maxy = ymax(rast))

    layer <- subset(rast, subset=1)
    data_table <- data.frame(rasterToPoints(layer))
    data_table$id <- NA
    gc()
    data_table$id <- 1:length(data_table$id)
    brik_cellids <- raster_from_points(data_table[, c(1, 2, 4, 3)], projection(layer))
    gbif_query <- occ_search(scientificName =sp,
                             geometry=bbox,
                             eventDate="2000,2019",
                             hasCoordinate = TRUE,
                             hasGeospatialIssue = FALSE)
    rast <- addLayer(rast, harmonize(brik_cellids, rast))
    gbif_points <- records_to_spatial(gbif_query, projection(rast))
    gbif_points_cellids <- extract_unique(brik_cellids, gbif_points)
    brik_table <- brik_table_add_sp_abs(rast, gbif_points_cellids)
    return(list(rast, brik_table, gbif_points))
}


raster_from_points <- function(xydf, proj){
  coordinates(xydf) = ~x+y
  gridded(xydf) <- TRUE
  xydf <- raster(xydf)
  projection(xydf) <- proj
  return(xydf)
}


harmonize <- function(raster1, raster2){
  raster1 <- extend(crop(raster1, raster2), raster2)
  return(raster1)
}


records_to_spatial <- function(gbif_records, proj,columns=1:4)
{
  gbif_data <- gbif_records$data[, columns]
  coordinates(gbif_data) = ~decimalLongitude+decimalLatitude
  projection(gbif_data) <- proj
  return(gbif_data)
}


extract_unique <- function(rast, points)
{
  extraction <- unlist(extract(rast, points))
  extraction <- extraction[!is.na(extraction)]
  extraction <- extraction[!duplicated(extraction)]
  return(extraction)
}


add_pseudoabsence <- function(brik_t, sample_size)
{
  species_vector <- brik_t$sp
  sp_nas <- (1:length(species_vector))[is.na(species_vector)]
  sp_nas_sample <- sample(sp_nas, sample_size)
  species_vector[sp_nas_sample] <- 0
  return(species_vector)
}


calc_sample_size <- function(species_vector,proportion=0.7){
  sample_size <- floor(proportion*min(table(species_vector)))
  return(sample_size)
}

brik_table_add_sp_abs  <- function(brik, cell_ids)
{
  brik_table <- data.frame(rasterToPoints(brik))
  brik_table <- brik_table[complete.cases(brik_table), ]
  brik_table$sp <- NA
  brik_table$sp[brik_table$id %in% cell_ids] <- 1
  brik_table$sp <- add_pseudoabsence(brik_table, 3000)
  return(brik_table)
  #brik_table$id <- NA,
}

analisis  <- function(table)
{
  train_table <- table[!is.na(table$sp),]
  sampsize <- calc_sample_size(train_table$sp)
  rf_model <- randomForest(y=as.factor(train_table$sp),
                           x=train_table[3:(ncol(train_table)-1)],
                           sampsize = c(sampsize, sampsize))
  sdm_prediction <- predict(rf_model, table[3:(ncol(table)-1)],
                            type="prob")
  return(sdm_prediction)
}


resultados  <- function(data_set, prediction)
{
  output_df <- data.frame(x=data_set[[2]]$x, y=data_set[[2]]$y, sdm_prob=prediction[,2])
  output_raster <- raster_from_points(output_df, projection(data_set[[1]]))
  writeOGR(data_set[[3]], "sp_points.shp", "sp_points", driver="ESRI Shapefile", 
           overwrite_layer = TRUE)
  writeRaster(output_raster, filename="sdm.tif", format="GTiff", overwrite=TRUE)
}
