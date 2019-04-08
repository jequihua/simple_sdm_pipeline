# Pipeline
plan <- drake_plan(
  datos_base = target(command = brik <- brick_from_path("./data")),
  datos_spp = target(command = data_set <- datos_sp("Panthera onca", brik)),
  calculo = target(command = sdm_prediction <- analisis(data_set[[2]])),
  resultado = target(resultados(data_set, sdm_prediction))
)
