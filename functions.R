# Your custom code is a bunch of functions.
brick_from_path <- function(rasters_path,
                            pattern="\\.tif$"){
  rasters <- list.files(rasters_path,
                        pattern=pattern,
                        full.names = TRUE)
  brik <- brick()
  for (i in 1:length(rasters))
  {
    brik<-addLayer(brik,raster(rasters[i]))
  }
  return(brik)
}


bbox_from_raster <- function(rast){
  bbox <- gbif_bbox2wkt(minx = xmin(rast),
                        miny = ymin(rast),
                        maxx = xmax(rast),
                        maxy = ymax(rast))
  return(bbox)
}


raster_from_points <- function(xydf, proj){
  coordinates(xydf) = ~x+y
  gridded(xydf) <- TRUE
  xydf <- raster(xydf)
  projection(xydf) <- proj
  return(xydf)
}


build_cellids <- function(rast){
  layer <- subset(rast, subset=1)
  data_table <- data.frame(rasterToPoints(layer))
  data_table$id <- NA
  gc()
  data_table$id <- 1:length(data_table$id)
  rast <- raster_from_points(data_table[, c(1, 2, 4, 3)], projection(layer))
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

