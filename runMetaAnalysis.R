library(rstan)
library(forestplot)
library(plyr)

# Load raw data and calculate effect sizes
# The script generates two spreadsheets in the 'data/' folder
#   maData.csv:    Contains effect sizes and associated information
#                  for each outcome in each study.
#   studyInfo.csv: Contains information about each study
source('cleanData.R')
rm(list = ls())

# Fit the model for the cognitive outcomes
# This script imports maData.csv and fits the meta-analysis
# model described in Smart et al. (2017) using the model code
# in 'models/maModel.stan'. The fitted model is saved in
# 'data/cognitiveModelSamples'
source('cognitiveModelFit.R')

# Finally, create a forest plot of the posterior means and
# 95% posterior intervals. The plot is saved as 
# 'plots/cognitive_forestPlot.pdf'
source('cognitiveForestPlot.R')
