maData = read.table('data/maData.csv', sep = ',', header = T)

# Load data
fitData        <- maData[maData$Method == 'Cognitive' & 
                         maData$Condition == 'Cognitive',]
fitData$Author <- factor(fitData$Author, 
                         levels = unique(as.character(fitData$Author)))

# Prepare data for Stan
stanData       <- list(N = dim(fitData)[1],
                       K = length(levels(fitData$Author)),
                       Y = fitData$Effect.Size,
                       V = fitData$ES.Variance,
                       Study = as.numeric(fitData$Author))

# Fit model
fit = stan(file = 'models/maModel.stan',
           data = stanData)
save(fit, file = 'data/cognitiveModelSamples')