# Load packages

usePackage <- function(p) 
{
  # En caso de no tener instalado el paquete lo descarga antes de llamarlo
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

# Lista de librerias que se utilizan en el pipeline
usePackage("randomForest")
usePackage("drake")
usePackage("rgbif")
usePackage("raster")
usePackage("rgdal")
usePackage("rgeos")
usePackage("dplyr")
