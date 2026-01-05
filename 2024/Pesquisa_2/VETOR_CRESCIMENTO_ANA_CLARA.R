###-------------------------------------------------------------------------------------------------
### PROGRAMA PARA CRIAR UM VETOR DE CRESCIMENTO DE MANCHA URBANA  
###-------------------------------------------------------------------------------------------------

### Autor: Prof. Hugo Ribeiro / EECA / UFG
###-------------------------------------------------------------------------------------------------
### Instalacao e carregamento dos pacotes
###-------------------------------------------------------------------------------------------------

#Carregar os pacotes na memoria
library(readr)
library(sf)
library(sp)
library(dplyr)
library(plyr)
library(raster)
library(terra)
library(geobr)
library(tidyr)
library(plotrix)
library(leaflet)

# Configurando o diretorio de trabalho
setwd("D:/ORIENTACAO/ANA_CLARA/")
getwd()

dir <- "D:/ORIENTACAO/ANA_CLARA/RESULTADOS"

# Camada para recorte e extracao das estatisticas (Escolha um shapefile ou desenhe um poligono no mapa 
# com a funcao "drawExtend" para obter as estatisticas medias de um local especifico)
mascara <- read_sf("D:/ORIENTACAO/ANA_CLARA/SHP/vale_pati.shp")
plot(mascara$geometry)

## carregando e recortando as imagens na area de interesse 
imagens <- rast(choose.files())
names(imagens) <- paste0("class", seq(1985,2025,5))

veg <- imagens
veg <- project(veg, "EPSG:32724")

veg[veg != 1] <- NA
plot(veg$class2000)

veg <- stack(veg)

# Vetor para armazenar os centros
centros <- list()

## LOOP PARA VARIAS IMAGENS 
for (i in 1:9) {
  pts <- rasterToPoints(veg[[i]]) %>% as.data.frame() 
  pts <- st_as_sf(pts, coords = c("x", "y"))
  st_crs(pts) <- 32724
  # pts <- st_transform(pts, crs= 32722)
  attr(pts, "sf_column")
  
  # head(pts)
  
  # Transforma as coordenadas para UTM
  utm_coords <- st_coordinates(pts)
  pts$x <- utm_coords[,1]
  pts$y <- utm_coords[,2]
  
  # head(pts)
  
  # plot(urbano)
  # plot(pts$geometry)
  
  ## aplicacao da equacao centro medio e desvio padrao
  ## calculo da media 
  xc <- mean(pts$x)
  yc <- mean(pts$y)
  
  ## calculo dos numeradores da equacao 
  x_xi <- (pts$x - xc)^2
  y_yi <- (pts$y - yc)^2
  
  ## resultado sd (raio do circulo)
  sd <- sqrt((sum(x_xi) + sum(y_yi)) / nrow(pts))
  
  ## criando o circulo
  centro <- t(c(xc,yc)) %>% as.data.frame()
  centro$x <- xc
  centro$y <- yc
  
  centro <- st_as_sf(centro, coords = c("x", "y"), crs = 32724, remove=F)
  attr(pts, "sf_column")
  
  circulo <- st_buffer(centro, dist = sd)
  circulo <- st_transform(circulo, crs= 32724)
  
  # Adicionar uma coluna com o nome do centro
  centro$nome <- paste0("Centro ", i)
  
  # Armazenar o centro no vetor de centros
  centros[[i]] <- centro
  
  plot(veg[[i]])
  plot(circulo$geometry, add=T)
}

# Criar a linha conectando os centros
centros_sf <- do.call(rbind, centros)
linha <- st_cast(st_union(centros_sf), "LINESTRING")

# Plotar a linha conectando os centros
plot(veg[[9]])
plot(linha, add=T, col="red", lwd=2)

write_sf(linha, paste0("linha_vale", ".shp", sep=""))
write_sf(centros_sf, paste0("centros_vale", ".shp", sep=""))

# Visualização interativa com leaflet
# Transformar a linha para WGS84 para ser usada no leaflet
linha_wgs84 <- st_transform(linha, crs = 4326)

# Visualização interativa com leaflet
map <- leaflet() %>%
  addTiles() %>%  # Fundo padrão do leaflet
  addPolylines(data = linha_wgs84, color = "red", weight = 2) %>%
  setView(lng = mean(st_coordinates(linha_wgs84)[,1]), lat = mean(st_coordinates(linha_wgs84)[,2]), zoom = 12)

# Exibir o mapa
print(map)
