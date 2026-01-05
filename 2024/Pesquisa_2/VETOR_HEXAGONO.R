#-------------------------------------------------------------------------------------------------
# SCRIPT FINAL (v13) COM LÓGICA REESTRUTURADA E VERIFICAÇÃO ROBUSTA
#-------------------------------------------------------------------------------------------------
# Autor: Prof. Hugo Ribeiro / EECA / UFG
# Refatorado por Gemini AI & Usuário
#-------------------------------------------------------------------------------------------------

### 1. PACOTES E CONFIGURAÇÃO
library(sf)
library(terra)
library(dplyr)
library(ggplot2)
library(units)
library(purrr) # Certifique-se de que o purrr está carregado

setwd("D:/ORIENTACAO/ANA_CLARA/")
dir_out <- "D:/ORIENTACAO/ANA_CLARA/RESULTADOS/RELATORIO_SENSIBILIDADE"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

### 2. FUNÇÃO DE ANÁLISE (VERSÃO CORRIGIDA)
analisar_escala_hex <- function(grade_hex, imagens, anos, dir_out, area_pixel_m2, escala_label) {
  message(paste("\n### INICIANDO ANÁLISE PARA ESCALA:", escala_label, "m ###"))
  
  grade_hex <- st_make_valid(grade_hex)
  if (!"id_hex" %in% colnames(grade_hex)) grade_hex$id_hex <- 1:nrow(grade_hex)
  
  lista_resultados <- purrr::map(1:nrow(grade_hex), function(p) {
    hex <- grade_hex[p, ]
    message(paste("-- Processando Hexágono:", p, "/", nrow(grade_hex)))
    
    veg_part <- tryCatch(mask(crop(imagens, vect(hex)), vect(hex)), error = function(e) NULL)
    
    if (is.null(veg_part) || all(is.na(global(veg_part, "max", na.rm = TRUE)[,1]))) {
      return(data.frame(id_hex = hex$id_hex, anos_com_dados = 0, magnitude_total_m = NA, taxa_area_ha_ano = NA, magnitude_vetor_m = NA, direcao_vetor_graus = NA, geometria_vetor = st_as_text(st_linestring())))
    }
    
    centros <- list(); areas <- numeric(); anos_validos <- numeric()
    
    for (i in 1:nlyr(veg_part)) {
      camada <- veg_part[[i]]
      
      # --- INÍCIO DA CORREÇÃO DEFINITIVA ---
      # Esta verificação é à prova de falhas para camadas que contêm apenas NAs.
      maxval <- global(camada, "max", na.rm = TRUE)[1,1]
      if (!is.na(maxval) && maxval == 1) {
        # --- FIM DA CORREÇÃO DEFINITIVA ---
        
        pts <- as.data.frame(camada, xy = TRUE, na.rm = TRUE)
        # Verificação adicional para garantir que 'pts' não está vazio
        if(nrow(pts) > 0) {
          centros[[length(centros)+1]] <- st_point(c(mean(pts$x), mean(pts$y)))
          areas <- c(areas, (nrow(pts) * area_pixel_m2) / 10000)
          anos_validos <- c(anos_validos, anos[i])
        }
      }
    }
    
    if (length(centros) < 2) {
      return(data.frame(id_hex = hex$id_hex, anos_com_dados = length(centros), magnitude_total_m = NA, taxa_area_ha_ano = NA, magnitude_vetor_m = NA, direcao_vetor_graus = NA, geometria_vetor = st_as_text(st_linestring())))
    }
    
    centros_sf <- st_sfc(centros, crs = st_crs(grade_hex))
    dist_total <- sum(st_distance(centros_sf[-length(centros_sf)], centros_sf[-1])) %>% as.numeric()
    df_area <- data.frame(ano = anos_validos, area = areas)
    taxa <- if (var(df_area$area, na.rm=TRUE) == 0) 0 else coef(lm(area ~ ano, data = df_area))[2]
    linha <- st_cast(st_union(centros_sf[1], centros_sf[length(centros_sf)]), "LINESTRING")
    magn <- as.numeric(st_length(linha))
    coords <- st_coordinates(linha)
    angulo <- if (nrow(coords) < 2) NA else {
      dx <- coords[2, "X"] - coords[1, "X"]; dy <- coords[2, "Y"] - coords[1, "Y"]
      (atan2(dx, dy) * 180 / pi + 360) %% 360
    }
    
    return(data.frame(id_hex = hex$id_hex, anos_com_dados = length(anos_validos), magnitude_total_m = dist_total, taxa_area_ha_ano = taxa, magnitude_vetor_m = magn, direcao_vetor_graus = angulo, geometria_vetor = st_as_text(linha)))
  })
  
  df_result <- bind_rows(lista_resultados)
  df_result$escala_m <- escala_label
  
  relatorio_sf <- left_join(grade_hex, df_result, by = "id_hex")
  write_sf(relatorio_sf, file.path(dir_out, paste0("relatorio_poligonos_", escala_label, "m.gpkg")), delete_layer = TRUE)
  message(paste("\n>>> Relatório de polígonos salvo para escala", escala_label, "m"))
  
  df_vetores <- df_result %>% filter(!is.na(magnitude_vetor_m))
  if(nrow(df_vetores) > 0) {
    vetores_sf <- st_as_sf(df_vetores, wkt = "geometria_vetor", crs = st_crs(grade_hex))
    write_sf(vetores_sf, file.path(dir_out, paste0("vetores_direcao_", escala_label, "m.gpkg")), delete_layer = TRUE)
    message(paste(">>> Relatório de vetores salvo para escala", escala_label, "m"))
  } else {
    message(paste(">>> Nenhum vetor de direção válido para salvar para a escala", escala_label, "m"))
  }
  
  return(df_result)
}

### 3. EXECUÇÃO
imagens <- rast(choose.files())
anos <- seq(1985, 2025, 5)
names(imagens) <- as.character(anos)
veg_original <- project(imagens, "EPSG:32724")
veg_original[veg_original != 1] <- NA
area_pixel_m2 <- prod(res(veg_original))

grade_500 <- st_read("D:/ORIENTACAO/ANA_CLARA/SHP/relatorio_500m.shp")
grade_1000 <- st_read("D:/ORIENTACAO/ANA_CLARA/SHP/relatorio_1000m.shp")
grade_2500 <- st_read("D:/ORIENTACAO/ANA_CLARA/SHP/relatorio_2500m.shp")

resultado_500 <- analisar_escala_hex(grade_500, veg_original, anos, dir_out, area_pixel_m2, 500)
resultado_1000 <- analisar_escala_hex(grade_1000, veg_original, anos, dir_out, area_pixel_m2, 1000)
resultado_2500 <- analisar_escala_hex(grade_2500, veg_original, anos, dir_out, area_pixel_m2, 2500)

df_comparativo <- bind_rows(resultado_500, resultado_1000, resultado_2500)

### 4. GRÁFICOS
if(nrow(df_comparativo) > 0 && sum(!is.na(df_comparativo$magnitude_total_m)) > 0) {
  graf_magnitude <- ggplot(df_comparativo, aes(x = factor(escala_m), y = magnitude_total_m, fill = factor(escala_m))) +
    geom_boxplot() +
    labs(title = "Magnitude Total por Escala", x = "Escala (m)", y = "Magnitude Total (m)") +
    theme_minimal()
  
  graf_area <- ggplot(df_comparativo, aes(x = factor(escala_m), y = taxa_area_ha_ano, fill = factor(escala_m))) +
    geom_boxplot() +
    labs(title = "Taxa de Variação de Área por Escala", x = "Escala (m)", y = "ha/ano") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    theme_minimal()
  
  ggsave(file.path(dir_out, "grafico_magnitude.png"), graf_magnitude)
  ggsave(file.path(dir_out, "grafico_area.png"), graf_area)
  
  print(graf_magnitude)
  print(graf_area)
} else {
  message("AVISO: Nenhum dado válido encontrado para gerar gráficos.")
}

message("\n### ANÁLISE FINALIZADA COM SUCESSO PARA TODAS AS ESCALAS ###")
