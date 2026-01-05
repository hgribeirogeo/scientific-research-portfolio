# Análise Espacial e Monitoramento Ambiental (MapBiomas)

Este repositório contém um conjunto de algoritmos desenvolvidos em **Linguagem R** para processamento, extração de estatísticas e visualização de dados raster ambientais. Os scripts foram otimizados para trabalhar com séries temporais (coleções do MapBiomas) focando em quatro eixos principais: recursos hídricos, dinâmica de carbono, ocorrência de fogo e uso do solo.

## 📋 Descrição dos Scripts

Os códigos realizam o recorte espacial (máscara) baseado em vetores de biomas (via pacote `geobr`), processam pilhas de imagens (stacks) e geram estatísticas descritivas e gráficos (histogramas, boxplots e barras).

| Arquivo | Função Principal | Métricas Geradas |
| :--- | :--- | :--- |
| **`MAP_AGUA.R`** | Dinâmica de Superfície de Água | Quantificação de área (km²) e variação de lâminas d'água (1985-2020). Gera gráficos empilhados por classe. |
| **`MAP_CARBONO.R`** | Estoque de Carbono no Solo | Análise de armazenamento médio de carbono (Ton/ha). Inclui análise de tendência temporal e distribuição de frequência. |
| **`MAP_FOGO.R`** | Frequência de Queimadas | Análise da recorrência e frequência de fogo. Gera histogramas padronizados para identificar picos de queimadas por ano. |
| **`USO_SOLO.R`** | Uso e Cobertura do Solo | Análise de transição e evolução de classes de uso (ex: vegetação nativa vs. antropizada) ao longo da série histórica. |

## 🚀 Tecnologias e Dependências

Os scripts utilizam pacotes de manipulação espacial robustos (`terra`, `sf`) e ferramentas de visualização avançada (`ggplot2`).

**Linguagem:** R  
**Principais Bibliotecas:**
* `terra` / `raster` (Processamento Matricial)
* `sf` / `geobr` (Dados Vetoriais e Limites Oficiais)
* `exactextractr` (Extração Zonal Rápida)
* `tidyverse` (`dplyr`, `ggplot2`, `tidyr`, `readr`)

Para instalar todas as dependências:
```r
install.packages(c("ggplot2", "sf", "sp", "dplyr", "raster", "terra", "tmap", "geobr", "exactextractr", "tidyr", "readxl"))

⚙️ Configuração e Uso
Dados de Entrada: Os scripts esperam arquivos .tif (Raster) oriundos das coleções do MapBiomas organizados em pastas locais.

Caminhos: Antes de executar, edite a variável setwd e dir no início de cada script para apontar para o seu diretório local:

# Exemplo no código:
setwd("SEU_CAMINHO/PARA/RASTER/")

Máscara de Recorte: Atualmente, os scripts filtram automaticamente o Bioma 6 (Cerrado/Pantanal dependendo da versão do geobr) para o ano de 2019. Isso pode ser alterado na linha:

filter(code_biome == 6)

👤 Autoria
Prof. Hugo Ribeiro

Escola de Engenharia Civil e Ambiental (EECA)

Universidade Federal de Goiás (UFG)

Este repositório serve como documentação técnica de suporte à produção científica e análise de dados espaciais.
