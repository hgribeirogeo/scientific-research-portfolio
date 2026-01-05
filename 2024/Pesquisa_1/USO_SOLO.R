###-------------------------------------------------------------------------------------------------
### PROGRAMA PARA EXTRAIR GRAFICOS DAS IMAGENS DO MAPBIOMAS - Uso Solo 
###-------------------------------------------------------------------------------------------------
### Autor: Prof. Hugo Ribeiro / EECA / UFG
###-------------------------------------------------------------------------------------------------
### Instalacao e carregamento dos pacotes
###-------------------------------------------------------------------------------------------------

install.packages("ggplot2")
install.packages("trend")
install.packages("rgeos")

#Carregar os pacotes na memoria
library(readr)
library(sf)
library(sp)
library(dplyr)
library(plyr)
library(terra)
library(raster)
library(tmap)
library(ggplot2)
library(geobr)
library(pdftools)
library(readxl)
library(stringr)
library(exactextractr)
library(tidyr)


# Configurando o diretorio de trabalho
setwd("D:/ORIENTACAO/ANDRIELLY/RASTER/USO_SOLO/")
getwd()

dir <- "D:/ORIENTACAO/ANDRIELLY/RASTER/USO_SOLO/"


# Camada para recorte e extracao das estatisticas (Escolha um shapefile ou desenhe um poligono no mapa 
# com a funcao "drawExtend" para obter as estatisticas medias de um local especifico)

mascara <- read_biomes(year = 2019, simplified = TRUE, showProgress = TRUE, cache = TRUE) %>% 
           filter(code_biome == 6) %>% 
           st_transform(crs= 4326)

plot(mascara$geom)

## carregando e recortando as imagens na area de interesse 
lista <- list.files(dir, pattern = paste0(c("*.tif$", sep = "")), full.names = T, all.files = F)   
imagens <- rast(lista)
names(imagens) <- c("u1985","u1990","u1995","u2000","u2005","u2010","u2015","u2020")


plot(imagens$u1985)
plot(mascara$geom, add=T)


## carregando o arquivo excel da legenda
legenda <- read_excel("D:/ORIENTACAO/ANDRIELLY/RASTER/USO_SOLO/Legenda.xlsx")

## extraindo as estatisticas de cada raster em um stack 
for (i in 1:8) {
  a1985 <- exactextractr::exact_extract(imagens[[i]], mascara) %>% 
    as.data.frame() %>% 
    dplyr::group_by(value) %>% 
    dplyr::summarise(coverage_area = (sum(coverage_fraction) * 900) / 1000000) %>% 
    na.omit()
  
  legenda <- legenda %>% full_join(a1985, by = "value")
}

## retirando valores NA e inserindo os nomes das colunas
result <- na.omit(legenda)
colnames(result) <- c("classes","codigo","1985","1990","1995","2000","2005","2010","2015","2020")

vetor <- result$classes

## Transformando dados para o formato de tabela sequencial 
result2 <- result %>% 
  pivot_longer(
    cols = -c('classes', 'codigo'),
    #names_to controla o nome da nova coluna que ira receber os nomes das colunas transpostas
    names_to = "Ano",
    # values_to controla o nome da nova coluna que ira receber os valores das colunas transpostas 
    values_to = "Areas")


# Gráfico de barras usando ggplot2
ggplot(data = result2, aes(x = classes, y = Areas, fill = Ano)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.9) +
  scale_fill_brewer(palette = "Paired") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Evolução do uso e Cobertura do Solo ao Longo dos Anos",
       x = "", y = "Área (km²)")





gc()











































