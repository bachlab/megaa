# Script for statistical analysis of sensors representations during deliberation in AAA
# relies on extraction of results via Matlab
# G Castegnetti --- start: 2017 --- last update: 05/2019

# initialise & settings
# ------------------------------------------------------------
rm(list = ls())
graphics.off()
.libPaths("/Users/gcastegnetti/Desktop/tools/R")
library(R.matlab)
library(lme4)
library(car)
Sys.setenv(LANG = "en")

# specify folders
# -------------------------------------------------------------
folder_in <- '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms/TrlSrt/'
folder_out <- paste(folder_in,'From_R/',sep = '')
dir.create(folder_out, showWarnings = TRUE, recursive = FALSE, mode = "0777")

NumPerm = 100;
permute = 1;

# read conditions
# -------------------------------------------------------------
cn <- paste(folder_in,'lmeCond.mat',sep = '')
inCond <- readMat(cn)
M.Cond <- inCond$lmeCond

# read data
# -------------------------------------------------------------
fn <- paste(folder_in,'lmeData/lme_Real.mat',sep = '')
indata.Real <- readMat(fn)
M.Real.Cau <- as.data.frame(indata.Real$lme.Real[[1]])
M.Real.Col <- as.data.frame(indata.Real$lme.Real[[2]])

M.Real.Cau <- logit(M.Real.Cau)
M.Real.Col <- logit(M.Real.Col)

# Prepare data for LMM
# -------------------------------------------------------------
SUBJ <- M.Cond[ ,1] # subject - random factor
RUNN <- M.Cond[ ,2] # run - fixed factor
TRLL <- M.Cond[ ,3] # trial - fixed factor
TL   <- M.Cond[ ,4] # threat level - fixed factor
PL   <- M.Cond[ ,5] # potential loss - fixed factor
GO   <- M.Cond[ ,6] # approach - fixed factor
PREV <- M.Cond[ ,7] # previous outcome - fixed factor

# Number of time points to consider (change if aligned to token appearance)
MinDur <- 150

# remove NaNs
indx <- which(is.nan(GO))
SUBJ <- SUBJ[-indx]
RUNN <- RUNN[-indx]
TRLL <- TRLL[-indx]
TL   <- TL[-indx]
PL   <- PL[-indx]
GO   <- GO[-indx]
PREV <- PREV[-indx]

SUBJ <- factor(SUBJ)
RUNN <- ordered(RUNN)
TRLL <- ordered(TRLL)
TL <- ordered(TL)
PL <- ordered(PL)
GO <- ordered(GO)
PREV <- factor(PREV)

# Allocate memory for results
mdl.Real.Cau <- mdl.Real.Col <- list()

F.Real.Cau <- F.Real.Col <- matrix(NaN, ncol = MinDur, nrow = 7)
F.Real.Col.PL.L <- F.Real.Col.PL.Q <- F.Real.Col.PL.C <- list()

# Loop over deliberation time points
# -------------------------------------------------------------
for (t in 1:MinDur){
  
  Y.Cau <- M.Real.Cau[-indx , t] # Cau data from time point t only
  Y.Col <- M.Real.Col[-indx , t] # Col data from time point t only
  attributes(Y.Cau) <- NULL # remove attributes for lme to work
  attributes(Y.Col) <- NULL 
  
  # Create data frame suitable for LMM
  data.Cau <- data.frame(Y.Cau, SUBJ, RUNN, TRLL, TL, PL, GO)
  data.Col <- data.frame(Y.Col, SUBJ, RUNN, TRLL, TL, PL, GO)
  
  # CAU
  # -----------------------------------------------------------
  mdl.Real.Cau[[t]] <- lmer(Y.Cau ~ 1 + TL*PL*GO + (1|SUBJ), data = data.Cau)
  F.Real.Cau[1:7,t] <- anova(mdl.Real.Cau[[t]])[ ,4]

  # COL
  # -----------------------------------------------------------
  mdl.Real.Col[[t]] <- lmer(Y.Col ~ 1 + TL*PL*GO + (1|SUBJ), data = data.Col)
  F.Real.Col[1:7,t] <- anova(mdl.Real.Col[[t]])[ ,4]
  
}

# analyse permutations
# -------------------------------------------------------------
F.Perm.Cau <- F.Perm.Col <- array(NaN, dim = c(8,MinDur,NumPerm))
if (permute == 1){
  for (p in 1:NumPerm){
    
    print(paste('Permutation#',toString(p), sep = '')) # update user
    
    # select file
    fn <- paste(folder_in,'lmeData/lme_Perm_',toString(p),'.mat',sep = '')
    indata.Perm <- readMat(fn)
    M.Perm.Cau <- as.data.frame(indata.Perm$lme.Perm[[1]])
    M.Perm.Col <- as.data.frame(indata.Perm$lme.Perm[[2]])
    
    M.Perm.Cau <- logit(M.Perm.Cau)
    M.Perm.Col <- logit(M.Perm.Col)
    
    for (t in 1:MinDur){
      Y.Perm.Cau <- M.Perm.Cau[-indx,t] # Cau data from time point t only
      Y.Perm.Col <- M.Perm.Col[-indx,t] # Col data from time point t only
      attributes(Y.Perm.Cau) <- NULL # remove attributes for lme to work
      attributes(Y.Perm.Col) <- NULL 
      
      # Create data frame suitable for LME
      data.Perm.Cau <- data.frame(Y.Perm.Cau, SUBJ, RUNN, TRLL, TL, PL, GO)
      data.Perm.Col <- data.frame(Y.Perm.Col, SUBJ, RUNN, TRLL, TL, PL, GO)
      
      # Run model(s) for every permutation and every time point
      mdl.Perm.Cau  <- lmer(Y.Perm.Cau ~ 1 + TL*PL*GO + (1|SUBJ), data = data.Perm.Cau)
      mdl.Perm.Col  <- lmer(Y.Perm.Col ~ 1 + TL*PL*GO + (1|SUBJ), data = data.Perm.Col)
      
      # Results from the ANOVA
      F.Perm.Cau[1:7,t,p] <- anova(mdl.Perm.Cau)[ ,4]
      F.Perm.Col[1:7,t,p] <- anova(mdl.Perm.Col)[ ,4]

    }
  }
}

ncoef <- dim(coef(mdl.Real.Cau[[1]])[[1]])
df2 <- length(Y.Cau) - (ncoef[1] + ncoef[2] - 1)

# save.image()
# Write data for Matlab
# -------------------------------------------------------------
writeMat(con = paste(folder_out,'fVal_realCau.mat',sep = ''), x = F.Real.Cau)
writeMat(con = paste(folder_out,'fVal_realCol.mat',sep = ''), x = F.Real.Col)

if (permute == 1){
  writeMat(con = paste(folder_out,'R_out_Perm_Cau.mat',sep = ''), x = F.Perm.Cau)
  writeMat(con = paste(folder_out,'R_out_Perm_Col.mat',sep = ''), x = F.Perm.Col)
  writeMat(con = paste(folder_out,'R_out_df2.mat',sep = ''), x = df2)
}

# Plot main effects
# -------------------------------------------------------------
x11()
par(mfrow=c(3,2))

# TL
plot(1:MinDur,F.Real.Cau[1, ], col="blue")
title(main="TL - Cau", col.main="black", font.main=3, cex.main = 1.5)
plot(1:MinDur,F.Real.Col[1, ], col="blue")
title(main="TL - Col", col.main="black", font.main=3, cex.main = 1.5)

# PL
plot(1:MinDur,F.Real.Cau[2, ], col="blue")
title(main="PL - Cau", col.main="black", font.main=3, cex.main = 1.5)
plot(1:MinDur,F.Real.Col[2, ], col="blue")
title(main="PL - Col", col.main="black", font.main=3, cex.main = 1.5)

# Go/NoGo
plot(1:MinDur,F.Real.Cau[3, ], col="blue")
title(main="GO - Cau", col.main="black", font.main=3, cex.main = 1.5)
plot(1:MinDur,F.Real.Col[3, ], col="blue")
title(main="GO - Col", col.main="black", font.main=3, cex.main = 1.5)


# Plot separate components PL
# -------------------------------------------------------------
x11()
par(mfrow=c(3,1))

# TL
plot(1:MinDur,F.Real.Col.PL.L, col="blue")
title(main="Col - PL linear", col.main="black", font.main=3, cex.main = 1.5)
plot(1:MinDur,F.Real.Col.PL.Q, col="blue")
title(main="Col - PL quadratic", col.main="black", font.main=3, cex.main = 1.5)
plot(1:MinDur,F.Real.Col.PL.C, col="blue")
title(main="Col - PL cubic", col.main="black", font.main=3, cex.main = 1.5)


# # Plot interactions
# # -------------------------------------------------------------
# x11()
# par(mfrow=c(4,2))
# 
# # TL:PL
# plot(1:MinDur,F.Real.Cau[4, ], col="blue")
# title(main="TL:PL - Cau", col.main="black", font.main=3, cex.main = 1.5)
# plot(1:MinDur,F.Real.Col[4, ], col="blue")
# title(main="TL:PL - Col", col.main="black", font.main=3, cex.main = 1.5)
# 
# # TL:GO
# plot(1:MinDur,F.Real.Cau[5, ], col="blue")
# title(main="TL:GO - Cau", col.main="black", font.main=3, cex.main = 1.5)
# plot(1:MinDur,F.Real.Col[5, ], col="blue")
# title(main="TL:GO - Col", col.main="black", font.main=3, cex.main = 1.5)
# 
# # PL:GO
# plot(1:MinDur,F.Real.Cau[6, ], col="blue")
# title(main="PL:GO - Cau", col.main="black", font.main=3, cex.main = 1.5)
# plot(1:MinDur,F.Real.Col[6, ], col="blue")
# title(main="PL:GO - Col", col.main="black", font.main=3, cex.main = 1.5)
# 
# # TL:PL:GO
# plot(1:MinDur,F.Real.Cau[7, ], col="blue")
# title(main="TL:PL:GO - Cau", col.main="black", font.main=3, cex.main = 1.5)
# plot(1:MinDur,F.Real.Col[7, ], col="blue")
# title(main="TL:PL:GO - Col", col.main="black", font.main=3, cex.main = 1.5)
# 
# # Plot intercept
# # -------------------------------------------------------------
# x11()
# par(mfrow=c(1,2))
# plot(1:MinDur,F.Real.Cau[8, ], col="blue")
# title(main="Intercept - Cau", col.main="black", font.main=3, cex.main = 1.5)
# plot(1:MinDur,F.Real.Col[8, ], col="blue")
# title(main="Intercept - Col", col.main="black", font.main=3, cex.main = 1.5)
# 
