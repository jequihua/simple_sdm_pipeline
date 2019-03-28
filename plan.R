# Pipeline
plan <- drake_plan(
  brik <- brick_from_path("./data"),
  brik_cellids <- build_cellids(brik),
  brik <- addLayer(brik, harmonize(brik_cellids, brik)),
  bbox <- bbox_from_raster(brik),
  gbif_query <- occ_search(scientificName="Panthera onca",
                           geometry=bbox,
                           eventDate="2000,2019",
                           hasCoordinate = TRUE,
                           hasGeospatialIssue = FALSE),
  gbif_points <- records_to_spatial(gbif_query, projection(brik)),
  gbif_points_cellids <- extract_unique(brik_cellids, gbif_points),
  brik_table <- brik_table_add_sp_abs(brik, gbif_points_cellids),
  sdm_prediction <- analisis(brik_table),
  resultados(brik, brik_table, sdm_prediction, gbif_points)
)
