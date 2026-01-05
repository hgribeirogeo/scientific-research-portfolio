## instalando e carregando os pacotes
library(randomForest)
library(sf)
library(raster)
library(tidyverse)
library(terra)

## configurando os diretorios
dir_imagens <- "D:/ORIENTACAO/ANA_CLARA/DATASET_SENTINEL/sentinel/" # Defina o diretório com as imagens Sentinel
dir_mascaras_filtradas <- "D:/ORIENTACAO/ANA_CLARA/DATASET_SENTINEL/sentinel_mask/" # Diretório para salvar as máscaras filtradas

setwd("D:/ORIENTACAO/ANA_CLARA/RASTER/")
getwd()

# Carregando os dados de treino (executar apenas uma vez para treinar o modelo) ----
amostras <- read_sf("D:/ORIENTACAO/ANA_CLARA/SHP/amostra_balanced.shp")

# Amostras de treino e de teste ----
teste <- amostras %>%
  group_by(class) %>%
  sample_n(size = 6)
treino <- amostras %>%
  filter(! id %in% (teste))
nrow(treino)
nrow(teste)

# Carregando a primeira imagem para extrair os valores de treino (executar apenas uma vez)
primeira_img <- stack(choose.files(caption = "Selecione UMA das imagens Sentinel para extrair os valores de treino")) %>% rast()
primeira_img <- project(primeira_img, "EPSG:4326")
primeira_img <- stack(primeira_img)
names(primeira_img) <- paste0(rep('band', nlayers(primeira_img)), 1:nlayers(primeira_img))

# Extração de dados de treino ----
valsTrain <- raster::extract(primeira_img, treino)
valsTrain <- data.frame(valsTrain, treino$class)
names(valsTrain)[ncol(valsTrain)] <- "class"
valsTrain$class <- as.factor(valsTrain$class)
valsTrain <- na.omit(valsTrain)
summary(valsTrain)

# Criando modelo randomForest (executar apenas uma vez) ----
rf.mdl <- randomForest(valsTrain$class ~., data = valsTrain, keep.forest = TRUE)
rf.mdl

# Criando o diretório para as máscaras filtradas, se não existir
if (!dir.exists(dir_mascaras_filtradas)) {
  dir.create(dir_mascaras_filtradas)
}

# Função para aplicar uma regra de retração (classe 1)
retract_class_1 <- function(x) {
  if (x[ceiling(length(x) / 2)] == 1) { # Se o pixel central é 1
    if (sum(x == 1, na.rm = TRUE) >= 6) { # Mantém como 1 se pelo menos 6 vizinhos (incluindo o central) são 1
      return(1)
    } else {
      return(0)
    }
  } else { # Se o pixel central é 0, permanece 0
    return(0)
  }
}

# Listando os arquivos Sentinel na pasta
lista_imagens <- list.files(dir_imagens, pattern = "\\.tif$", full.names = TRUE)

# Loop para processar cada imagem
for (arquivo_img in lista_imagens) {
  cat(paste("Processando:", basename(arquivo_img), "\n"))
  
  # Carregando a imagem
  img <- stack(arquivo_img) %>% rast()
  img <- project(img, "EPSG:4326")
  img <- stack(img)
  names(img) <- paste0(rep('band', nlayers(img)), 1:nlayers(img))
  
  # Classificação da imagem usando o modelo treinado
  rf.class <- raster::predict(img, rf.mdl, progress = "text", type = "response")
  
  # Gerando a máscara binária (classe 1 como valor de interesse)
  mascara_binaria <- raster::calc(rf.class, fun = function(x) ifelse(x == 1, 1, 0))
  
  # Aplicando filtro de retração (classe 1)
  kernel <- matrix(1, nrow = 3, ncol = 3) # Janela 3x3
  mascara_filtrada <- raster::focal(mascara_binaria, w = kernel, fun = retract_class_1, NA.rm = TRUE)
  
  # Definindo o nome do arquivo de saída para a máscara filtrada
  nome_arquivo_base <- gsub("\\.tif$", "", basename(arquivo_img))
  nome_arquivo_mascara_filtrada <- paste0(dir_mascaras_filtradas, nome_arquivo_base, "_mask.tif")
  
  # Salvando apenas a máscara binária filtrada
  writeRaster(mascara_filtrada, nome_arquivo_mascara_filtrada, overwrite = TRUE)
  cat(paste("Máscara binária filtrada salva em:", nome_arquivo_mascara_filtrada, "\n\n"))
}

cat("Processamento concluído!\n")