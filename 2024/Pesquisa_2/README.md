# Dinâmica Espaço-Temporal de *Dicranopteris flexuosa* (Vale do Pati - BA)

Este repositório contém o conjunto de algoritmos desenvolvidos para a análise da distribuição espacial e vetor de crescimento da espécie *Dicranopteris flexuosa* (Gleicheniaceae) na Chapada Diamantina. Os scripts dão suporte metodológico à pesquisa que investiga o comportamento cíclico (expansão/retração) e o deslocamento altitudinal desta espécie pioneira entre 1985 e 2025.

## 📋 Descrição dos Módulos

O fluxo de trabalho integra sensoriamento remoto (Landsat/Sentinel), aprendizado de máquina e geoestatística.

| Arquivo | Função Principal | Metodologia |
| :--- | :--- | :--- |
| **`class_lote.R`** | Classificação Supervisionada | Implementação do algoritmo **Random Forest** para detecção da espécie. Inclui treinamento do modelo, predição e filtragem pós-classificação (janela móvel 3x3) para redução de ruído. |
| **`VETOR_CRESCIMENTO...R`** | Análise Vetorial de Deslocamento | Cálculo de centroides ponderados das manchas de vegetação ano a ano. Gera vetores que indicam a direção e magnitude do deslocamento da espécie (têndencia altitudinal). |
| **`VETOR_HEXAGONO.R`** | Análise de Sensibilidade de Escala | Agregação dos dados em grades hexagonais de diferentes tamanhos (500m, 1000m, 2500m) para avaliar a magnitude das mudanças na paisagem. |
| **`GRAFICO_SANKEY.R`** | Dinâmica de Transição (Fluxos) | Gera diagramas de Sankey multitemporais (1985-2000-2023) para visualizar quantitativamente as trocas entre classes (ex: Onde a *Dicranopteris* ganhou ou perdeu área). |

## 🚀 Tecnologias e Dependências

**Linguagem:** R (Ambiente RStudio)
**Bibliotecas Principais:**
* `randomForest`: Modelagem preditiva.
* `terra` / `sf`: Manipulação de dados raster e vetoriais.
* `networkD3`: Geração dos diagramas de fluxo interativos.
* `ggplot2` / `tidyr`: Visualização de dados e manipulação estatística.

## 📄 Contexto Científico
Estes scripts são parte integrante da pesquisa:
> *Distribuição Espacial e Vetor de Crescimento da Espécie Dicranopteris flexuosa no Vale do Pati, Chapada Diamantina – BA.*

## 👥 Autoria
**Ana Clara Borges de Oliveira** & **Prof. Hugo Ribeiro**
Universidade Federal de Goiás (UFG)


