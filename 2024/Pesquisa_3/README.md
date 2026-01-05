# Análise de Efetividade de Terras Indígenas na Amazônia (LULC)

> 🏆 **Trabalho Publicado**
> Os algoritmos deste repositório fundamentaram a pesquisa publicada na revista **Sociedade & Natureza**.
>
> 📄 **Artigo:** *Análise da qualidade da vegetação em terras indígenas e no seu entorno na região hidrográfica da Amazônia*
> 🔗 **DOI do Artigo:** doi.org/10.14393/SN-v37-2025-74902

Este diretório contém os módulos computacionais desenvolvidos para analisar a dinâmica de uso e cobertura do solo (LULC) em Terras Indígenas (TIs) da Amazônia Legal. Os scripts avaliam a qualidade da vegetação e a pressão antrópica no interior das áreas protegidas versus suas zonas de amortecimento.

## 📋 Descrição dos Módulos

O fluxo de trabalho foca na comparação estatística entre áreas protegidas e áreas sob pressão externa.

| Arquivo | Função Principal | Metodologia |
| :--- | :--- | :--- |
| **`MAPBIOMAS_TI2.R`** | Análise Comparativa (Interno vs. Externo) | Automatiza a extração de dados do MapBiomas para dois contextos espaciais: o polígono da TI e um buffer externo (entorno). Gera painéis gráficos comparativos (Grid Plot) para visualizar a diferença na conservação da vegetação. |
| **`ANALISE_AGUA2.R`** | Quantificação Temporal e Estatística | Realiza o cálculo de áreas absolutas (km²) e relativas (%) para séries temporais longas. Normaliza os dados para permitir a comparação entre áreas de tamanhos diferentes e gera as estatísticas descritivas finais. |

## 🚀 Tecnologias Utilizadas

**Linguagem:** R (Ambiente RStudio)
**Bibliotecas Principais:**
* `sf` / `raster`: Manipulação espacial e recorte de zonas.
* `ggplot2` / `gridExtra`: Geração de gráficos comparativos lado a lado.
* `dplyr` / `tidyr`: Manipulação de tabelas de atributos e estatísticas.

## 📄 Contexto Científico
O estudo investiga se as TIs funcionam efetivamente como barreiras contra o desmatamento e a expansão agropecuária em comparação com o uso do solo em suas fronteiras imediatas.

## 👥 Autoria
**Letícia Longanezi Bento**, **Prof. Hugo Ribeiro** & **Kátia Alcione Kopp**
Universidade Federal de Goiás (UFG)
