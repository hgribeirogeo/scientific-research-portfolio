###-------------------------------------------------------------------------------------------------
### SCRIPT PARA GERAÇÃO DE GRÁFICO DE SANKEY MULTI-TEMPORAL (1985-2000-2023)
###-------------------------------------------------------------------------------------------------
### Este script compara três mapas de classificação (inicial, intermediário e final)
### e gera um único gráfico de Sankey para visualizar a trajetória dos fluxos de mudança.
###-------------------------------------------------------------------------------------------------

### 1. CONFIGURAÇÃO INICIAL
#-------------------------------------------------------------------------------------------------

# --- Pacotes Necessários ---
library(terra)
library(sf)
library(dplyr)
library(tidyr) 
library(networkD3)
library(webshot2)
library(purrr)

# --- Ajuste os Caminhos e Anos Aqui ---
setwd("D:/ORIENTACAO/ANA_CLARA/")
dir_out <- "D:/ORIENTACAO/ANA_CLARA/RESULTADOS/GRAFICO_SANKEY/"

# IMPORTANTE: Forneça o caminho para os TRÊS arquivos de imagem raster
caminho_raster_1985 <- "D:/DADOS/MAPBIOMAS_30m/a1985.tif"
caminho_raster_2000 <- "D:/DADOS/MAPBIOMAS_30m/a2000.tif"
caminho_raster_2023 <- "D:/DADOS/MAPBIOMAS_30m/a2023.tif"

# Garante que o diretório de resultados exista
if (!dir.exists(dir_out)) {
  dir.create(dir_out, recursive = TRUE)
}


### 2. PREPARAÇÃO DOS DADOS
#-------------------------------------------------------------------------------------------------
message("Carregando rasters...")
rec <- read_sf("D:/ORIENTACAO/ANA_CLARA/SHP/vale_pati.shp")

raster_inicial <- rast(caminho_raster_1985)
raster_meio <- rast(caminho_raster_2000)
raster_final <- rast(caminho_raster_2023)

raster_inicial <- crop(raster_inicial, rec)
raster_meio <- crop(raster_meio, rec)
raster_final <- crop(raster_final, rec)

# Verificação de segurança
compareGeom(raster_inicial, raster_meio, raster_final)

# Legenda de classes do MapBiomas (Ajuste se necessário)
mapbiomas_legenda <- data.frame(
  ID = c(3, 4, 15, 21, 23, 24, 33), # Simplificando para classes comuns, adicione mais se precisar
  Classe = c("Floresta", "Savana", "Pastagem", "Mosaico Agricultura-Pastagem", 
             "Área Urbanizada", "Mineração", "Rio e Lago")
)

### 3. CÁLCULO DAS MATRIZES DE TRANSIÇÃO
# (Igual ao script anterior)
message("Calculando transições...")
calcular_transicao <- function(r_de, r_para) {
  as.data.frame(c(r_de, r_para), na.rm = TRUE) %>%
    setNames(c("de", "para")) %>%
    group_by(de, para) %>%
    summarise(value = n(), .groups = 'drop')
}
links1_raw <- calcular_transicao(raster_inicial, raster_meio)
links2_raw <- calcular_transicao(raster_meio, raster_final)

### 4. FORMATAÇÃO AVANÇADA PARA O GRÁFICO
#-------------------------------------------------------------------------------------------------
message("Formatando dados para o gráfico de publicação...")

# 4.1: Processar e combinar as transições
processar_links <- function(links_df, legenda, ano_de, ano_para) {
  links_df %>%
    left_join(legenda, by = c("de" = "ID")) %>% rename(source_name = Classe) %>%
    left_join(legenda, by = c("para" = "ID")) %>% rename(target_name = Classe) %>%
    na.omit() %>%
    mutate(
      source_unique = paste0(source_name, "_", ano_de),
      target_unique = paste0(target_name, "_", ano_para)
    ) %>%
    select(source_unique, target_unique, value)
}
links1 <- processar_links(links1_raw, mapbiomas_legenda, 1985, 2000)
links2 <- processar_links(links2_raw, mapbiomas_legenda, 2000, 2023)
links_total <- bind_rows(links1, links2)

# --- INÍCIO DAS MELHORIAS VISUAIS ---

# 4.2: Criar os nós e uma coluna para rótulos limpos (sem o ano)
nodes <- data.frame(name = unique(c(links_total$source_unique, links_total$target_unique)))
nodes$display_name <- sub("_\\d{4}$", "", nodes$name) # Remove o _ANO do final
nodes$group <- sub(".*_", "", nodes$name) # Grupo para colorir por ano

# 4.3: Opcional - Ordenar os nós verticalmente para um fluxo melhor
ordem_classes <- c("Floresta", "Savana", "Mosaico Agricultura-Pastagem", "Pastagem", "Rio e Lago", "Área Urbanizada", "Mineração")
ordem_completa <- unlist(lapply(c("_1985", "_2000", "_2023"), function(ano) paste0(ordem_classes, ano)))
# Filtra apenas os nós que realmente existem nos dados
nodes_ordenados <- nodes[match(ordem_completa, nodes$name),] %>% na.omit()
nodes <- nodes_ordenados

# 4.4: Recalcular os índices de base zero com os nós ordenados
links_total$IDsource <- match(links_total$source_unique, nodes$name) - 1
links_total$IDtarget <- match(links_total$target_unique, nodes$name) - 1

# 4.5: Definir uma paleta de cores customizada
# Azul para 1985, Cinza para 2000, Laranja para 2023
colour_scale <- 'd3.scaleOrdinal() .domain(["1985", "2000", "2023"]) .range(["#2c7bb6", "#abd9e9", "#fdae61"])'

# --- FIM DAS MELHORIAS VISUAIS ---

### 5. GERAÇÃO E SALVAMENTO DO GRÁFICO DE PUBLICAÇÃO
#-------------------------------------------------------------------------------------------------
message("Gerando o gráfico de Sankey final...")

sankey_plot <- sankeyNetwork(
  Links = links_total,
  Nodes = nodes,
  Source = "IDsource",
  Target = "IDtarget",
  Value = "value",
  NodeID = "display_name",  # Usa o nome limpo para o rótulo
  NodeGroup = "group",      # Usa o ano para a cor do nó
  colourScale = colour_scale, # Aplica a paleta de cores customizada
  units = "pixels",
  fontSize = 12,
  nodeWidth = 30,
  sinksRight = FALSE
)

# Salvar o HTML
caminho_html <- file.path(dir_out, "Sankey_Final_Publicacao.html")
saveNetwork(sankey_plot, caminho_html)
message(paste("--> Gráfico de Sankey INTERATIVO salvo em:", caminho_html))

# Salvar a imagem estática (PNG)
caminho_png <- file.path(dir_out, "Sankey_Final_Publicacao.png")
webshot(
  url = caminho_html,
  file = caminho_png,
  delay = 1,
  vwidth = 1200,
  vheight = 800 # Aumentar um pouco a altura para os títulos
)
message(paste("--> Imagem estática (PNG) do gráfico salva em:", caminho_png))

message("\n### PROCESSO CONCLUÍDO! ###")
print(sankey_plot)

### 6. GERAÇÃO E SALVAMENTO DAS TABELAS DE TRANSIÇÃO
#-------------------------------------------------------------------------------------------------
message("Gerando tabelas de transição com percentuais...")

# Função auxiliar para criar e salvar a matriz de transição
gerar_matriz_transicao <- function(links_data_raw, legenda, periodo_label) {
  
  # Calcula a área total de cada classe de ORIGEM
  total_origem <- links_data_raw %>%
    group_by(de) %>%
    summarise(total_pixels_origem = sum(value))
  
  # Calcula os percentuais e junta os nomes das classes
  matriz <- links_data_raw %>%
    left_join(total_origem, by = "de") %>%
    mutate(percentual = round((value / total_pixels_origem) * 100, 2)) %>%
    left_join(legenda, by = c("de" = "ID")) %>%
    rename(Classe_Origem = Classe) %>%
    left_join(legenda, by = c("para" = "ID")) %>%
    rename(Classe_Destino = Classe) %>%
    select(Classe_Origem, Classe_Destino, percentual) %>%
    na.omit()
  
  # Pivota a tabela para o formato de matriz (largo)
  matriz_final <- matriz %>%
    pivot_wider(names_from = Classe_Destino, values_from = percentual, values_fill = 0)
  
  # Salva a tabela em um arquivo CSV
  caminho_csv <- file.path(dir_out, paste0("matriz_transicao_", periodo_label, ".csv"))
  write.csv(matriz_final, caminho_csv, row.names = FALSE, fileEncoding = "UTF-8")
  
  message(paste("--> Tabela de transição salva em:", caminho_csv))
  return(matriz_final)
}

# Gerar e salvar a tabela para o primeiro período
tabela1 <- gerar_matriz_transicao(links1_raw, mapbiomas_legenda, "1985-2000")

# Gerar e salvar a tabela para o segundo período
tabela2 <- gerar_matriz_transicao(links2_raw, mapbiomas_legenda, "2000-2023")

message("\n### PROCESSO CONCLUÍDO! ###")
print(sankey_plot)

