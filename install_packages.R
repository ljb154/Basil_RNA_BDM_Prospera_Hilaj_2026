
# CRAN packages
cran_packages <- c(
  "stringr", "ggplot2", "gridExtra",
  "gplots", "viridis", "dplyr",
  "tidyr", "tibble", "cowplot",
  "eulerr", "VennDiagram",
  "ggrepel", "patchwork",
  "rmarkdown", "knitr"
)

install.packages(
  setdiff(cran_packages,
          rownames(installed.packages()))
)

# Bioconductor packages
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

bioc_packages <- c(
  "DESeq2", "topGO",
  "GO.db", "AnnotationDbi"
)

BiocManager::install(
  bioc_packages,
  ask = FALSE,
  update = FALSE
)
