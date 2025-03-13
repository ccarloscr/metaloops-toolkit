#!/usr/bin/env Rscript

# Vectors containing package names
cran_packages <- c("optparse", "data.table", "igraph", "mlpack")
bioc_packages <- c("EBImage", "rhdf5")

# Installation of BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Funcion to install cran packages
install_cran <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)}
}

# Funcion to install bioconductor packages
install_bioc <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg, dependencies = TRUE)}
}

# Installation loop
lapply(cran_packages, install_cran)
lapply(bioc_packages, install_bioc)

# Function to load packages
load_library <- function(pkg) {
  library(pkg, character.only = TRUE)
}

# Loading loop
lapply(cran_packages, load_library)
lapply(bioc_packages, load_library)
