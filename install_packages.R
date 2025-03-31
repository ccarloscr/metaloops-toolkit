#!/usr/bin/env Rscript

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Set FFTW environment
Sys.setenv(PKG_CONFIG_PATH = paste0(Sys.getenv("CONDA_PREFIX"), "/lib/pkgconfig"))

# Install and load ffwtools
install.packages("fftwtools", configure.args = paste0("--with-fftw=", Sys.getenv("CONDA_PREFIX")))
library(fftwtools)

# Install and load EBImage
BiocManager::install("EBImage")
library(EBImage)

# Install and load optparse
install.packages("optparse")
library(optparse)


# Vectors containing package names
cran_packages <- c("data.table", "igraph", "mlpack", "reshape2")
bioc_packages <- c("rhdf5")

# Installation of BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Function to install cran packages
install_cran <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)}
}

# Function to install bioconductor packages
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
