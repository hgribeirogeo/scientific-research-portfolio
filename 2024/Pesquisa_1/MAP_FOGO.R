###-------------------------------------------------------------------------------------------------
### PROGRAMA PARA EXTRAIR GRAFICOS DAS IMAGENS DO MAPBIOMAS - Fogo
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
library(raster)
library(tmap)
library(ggplot2)
library(geobr)
library(pdftools)
library(readxl)
library(stringr)
library(exactextractr)
library(tidyr)
library(terra)

# Configurando o diretorio de trabalho
setwd("D:/ORIENTACAO/ANDRIELLY/RASTER/FOGO/")
getwd()

dir <- "D:/ORIENTACAO/ANDRIELLY/RASTER/FOGO/"

# Camada para recorte e extracao das estatisticas (Escolha um shapefile ou desenhe um poligono no mapa 
# com a funcao "drawExtend" para obter as estatisticas medias de um local especifico)
mascara <- read_biomes(year = 2019, simplified = TRUE, showProgress = TRUE) %>% 
           filter(code_biome == 6) %>% 
           st_transform(crs= 4326)

plot(mascara$geom)

## carregando e recortando as imagens na area de interesse 
lista <- list.files(dir, pattern = paste0(c("*.tif$", sep = "")), full.names = T, all.files = F)   
imagens <- rast(lista)

imagens <- crop(imagens, mascara) %>% mask(mascara)
imagens[imagens == 0] <- NA
names(imagens) <- c("u1990","u1995","u2000","u2005","u2010","u2015","u2020")

## Extraindo as estatisticas das imagens 
estat <- exact_extract(imagens, mascara, fun = "mean", progress= F)

# Convertendo para data.frame (para fogo retire o ano de 1985 na variavel estat e rownames)
estat <- as.data.frame(t(estat))
estat$ano <- c("1990", "1995", "2000", "2005", "2010", "2015", "2020")
colnames(estat) <- c("fogo", "ano")
rownames(estat) <- c("1990", "1995", "2000", "2005", "2010", "2015", "2020")

# Criando o gráfico de barras
ggplot(estat, aes(x = factor(ano), y = fogo)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Frequência de Fogo ao Longo dos Anos",
       x = "",
       y = "Frequência") +
  theme_minimal()


#############################################################

val <- as.data.frame(matrix(0, 7,2))

for (i in 1:7) {
  valores <- as.data.frame(summary(imagens[[i]]))
  valores$estat <- as.numeric(gsub(".*: ?", "", valores$Freq))
  valores <- valores %>% filter(!grepl("NA's", Freq))
  
    
  val[i, 1] <- min(valores$estat)
  val[i, 2] <- max(valores$estat)
}

# Determinar o valor mínimo e máximo para o eixo X
min_val <- min(val$V1)  # Valor mínimo global
max_val <- max(val$V2)  # Valor máximo global

# Padronizando os eixos X nos histogramas
par(mfrow=c(3,3))

hist(imagens$u1990, ylim=c(0, 150000), main="1990", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u1995, ylim=c(0, 150000), main="1995", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u2000, ylim=c(0, 150000), main="2000", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u2005, ylim=c(0, 150000), main="2005", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u2010, ylim=c(0, 150000), main="2010", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u2015, ylim=c(0, 150000), main="2015", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)
hist(imagens$u2020, ylim=c(0, 150000), main="2020", xlab="", col="lightblue", freq=TRUE, xlim=c(min_val, max_val), breaks=20)


# Função para criar histogramas com barras padronizadas e rótulos rotacionados
create_hist <- function(data, title, breaks = 20, ...) {
  hist(data, ylim=c(0, 150000), main = title, xlab="", col="lightblue", freq=TRUE, 
       xlim=c(min_val, max_val), breaks = breaks, right = FALSE, ...)
  h <- hist(data, plot=FALSE, breaks = breaks)
  text(h$mids, h$counts + 5000, labels = h$counts, srt = 90, adj = 0, xpd = TRUE)
}

anos <- c("1990", "1995", "2000", "2005", "2010", "2015", "2020")


# Adicionando rótulos aos histogramas com rotação e ajuste
for (i in 1:7) {
  create_hist(imagens[[i]], anos[i])
  
}

boxplot(imagens, notch=F, main= "Boxplot da Frequência de Fogo ao Longo dos Anos", na.rm=T)

