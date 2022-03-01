#!/usr/bin/env Rscript
## kernlab regression using nifti files
## James Cole 24/09/2019
## Edited by A.T. to take in a mask file as 7th argument. If a mask file exists, PCA projection will be based only on voxels in mask.

rm(list = ls())
args <- commandArgs(trailingOnly = TRUE)
## test if there are two argument: if not, return an error
if (length(args) < 6) {
  stop("Six arguments must be supplied (brainageR directory full path; list of GM nifti files; list of WM nifti files; list of CSF nifti files, kernlab PCA model; output filename).n", call. = FALSE)
}
## set remote or local for testing. Uncomment accordingly
brainageR_dir <- args[1]

## libraries
library(kernlab)
library(RNifti)
library(stringr)
## get new data and load masks
gm.list <- read.table(file = args[2], header = FALSE, colClasses = "character")$V1
wm.list <- read.table(file = args[3], header = FALSE, colClasses = "character")$V1
csf.list <- read.table(file = args[4], header = FALSE, colClasses = "character")$V1

## read in average smwc files for GM, WM and CSF and convert to vectors
gm_average <- as.vector(readNifti(paste(brainageR_dir, "/software/templates/average_smwc1.nii", sep = "")))
wm_average <- as.vector(readNifti(paste(brainageR_dir, "/software/templates/average_smwc2.nii", sep = "")))
csf_average <- as.vector(readNifti(paste(brainageR_dir, "/software/templates/average_smwc3.nii", sep = "")))

if (length(args) > 6) {
msk <- as.vector(readNifti(args[7])) # import mask -- A.T.
}

## create nifti vector matrices
## set mask threshold
threshold <- 0.3
## function to read and mask nifti files from list above.
read_mask_nii <- function(arg1){
  gm <- as.vector(readNifti(gm.list[arg1]))
  gm <- gm[gm_average > threshold]
  wm <- as.vector(readNifti(wm.list[arg1]))
  wm <- wm[wm_average > threshold]
  csf <- as.vector(readNifti(csf.list[arg1]))
  csf <- csf[csf_average > threshold]
  
  # extract only parts of gm, wm, csf in mask before concatenating -- A.T.
  if (length(args) > 6) {
  mskG <- msk
  mskG <- mskG[gm_average > threshold]
  gm <- gm[mskG > 0]
  
  mskW <- msk
  mskW <- mskW[wm_average > threshold]
  wm <- wm[mskW > 0]
  
  mskC <- msk
  mskC <- mskC[csf_average > threshold]
  csf <- csf[mskC > 0]
  }
  
  gm.wm.csf <- c(gm, wm, csf)
  
  return(gm.wm.csf)
}

paste("loading nifti data", date(),sep = " " )
new_data_mat <- matrix(unlist(lapply(1:length(gm.list), function(x) read_mask_nii(x))), nrow = length(gm.list), byrow = TRUE)
dim(new_data_mat)

## load and then apply PCA parameters
rotation <- readRDS(file = paste(brainageR_dir, "/software/pca_rotation.rds", sep = ""))
center <- readRDS(file = paste(brainageR_dir, "/software/pca_center.rds", sep = ""))
scale <- readRDS(file = paste(brainageR_dir, "/software/pca_scale.rds", sep = ""))

# remove parts of projection matrix not in mask -- A.T. (not very elegant code, but it works and I don't enjoy R)
if (length(args) > 6) {
mskG <- msk
mskG <- mskG[gm_average > threshold]
mskW <- msk
mskW <- mskW[wm_average > threshold]
mskC <- msk
mskC <- mskC[csf_average > threshold]

tmp1 <- mskG > 0
tmp2 <- mskW > 0
tmp3 <- mskC > 0
tmp <- c(tmp1,tmp2,tmp3)
scale <- scale[tmp]
center <- center[tmp]
rotation <- rotation[tmp,]
}

newx <- scale(new_data_mat, center, scale) %*% rotation

## load previously trained regression model
paste("loading regression model", date(),sep = " ")
load(args[5])

## generate predictions
brain.ages <- read.csv(paste(brainageR_dir, "/software/brains.train_labels.csv", sep = ""), header = FALSE)
test.res.gpr <- as.data.frame(predict(model.gpr, newx) + mean(brain.ages$V1))
names(test.res.gpr) <- "gpr.brain.age"

## generate prediction confidence intervals
test.sd.gpr <- predict(model.gpr, newx, type = "sdev")
test.res.gpr$lower.CI <- as.numeric(test.res.gpr$gpr.brain.age - (1.96 * test.sd.gpr))
test.res.gpr$upper.CI <- as.numeric(test.res.gpr$gpr.brain.age + (1.96 * test.sd.gpr))

## save predictions to text file
paste("saving new results", date(),sep = " ")
str_sub(gm.list, 1, str_locate(gm.list, "smwc1")[,2]) <- ""
str_sub(gm.list, str_locate(gm.list, ".nii")[,1], str_length(gm.list)) <- ""
write.table(cbind(gm.list, round(test.res.gpr,4)), 
            file = args[6],
            row.names = F,
            quote = F,
            col.names = c("File", "brain.predicted_age", "lower.CI", "upper.CI"), sep = ",")

