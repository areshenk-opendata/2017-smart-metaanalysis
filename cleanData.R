library(plyr)

# Load data spreadsheet
raw <- read.table('data/masterSpreadsheet.csv', sep = ',', 
                  header = T, na.strings = 'NR')

# Study info frame
studyInfo <- ddply(raw, c("Author", "Condition"), summarise,
                   Year                = Year[1],
                   N                   = Sample.Size[1],
                   Age                 = Age[1],
                   Group.or.Individual = Group.or.Individual[1],
                   Control.Type        = Control[1],
                   Percent.Male        = Percent.Male[1],
                   Percent.White       = Percent.White[1],
                   MMSE                = MMSE[1],
                   PEDro               = PEDro[1],
                   Treatment.Length    = Treatment.Length[1],
                   Treatment.Frequency = Treatment.Frequency[1],
                   Session.Duration    = Tx.Sesson.Duration[1])

# Compute mean differences
# Note that some studies report both pre- and post-test means,
# while others report pre-test means and mean differences.
# For the former, we compute the differences here.
for (i in 1:dim(raw)[1]){
    if (is.na(raw$Mean.Change[i])){
        raw$Mean.Change[i] <- raw$Mean.Post[i] - raw$Mean.Pre[i]
    }
}

# Comput effect sizes and variances
# For each study, we compute the Morris effect size using
# the control as a baseline.
raw$Effect.Size <- NA
raw$ES.Variance <- NA
numStudies      <- length(levels(raw$Author))
studies         <- levels(raw$Author)
for (i in 1:numStudies){
    
    dummyStudy <- subset(raw, Author == studies[i])
    
    # Split by condition
    numConditions <- length(levels(factor(dummyStudy$Condition))) - 1
    treatmentIdx  <- which(levels(factor(dummyStudy$Condition)) != 'Control')
    conditions    <- levels(factor(dummyStudy$Condition))[treatmentIdx]
    dummyControl  <- subset(dummyStudy, Condition == 'Control')
    
    for (j in 1:numConditions){
        
        # Compute effect size
        dummyCondition <- subset(dummyStudy, Condition == conditions[j])
        nT             <- dummyCondition$Sample.Size
        nC             <- dummyControl$Sample.Size
        cP             <- 1 - 3 / ( 4*(nT + nC - 2) - 1 )
        SD             <- sqrt( ( (nT-1)*dummyCondition$SD.Pre^2 + (nC-1)*dummyControl$SD.Pre^2 ) / 
                                    (nT+nC-2))
        ES             <- cP * ( ( dummyCondition$Mean.Change - dummyControl$Mean.Change ) / SD)
        raw$Effect.Size[raw$Author == studies[i] & raw$Condition == conditions[j]] <- ES
        
        # Compute variance
        raw$ES.Variance[raw$Author == studies[i] & raw$Condition == conditions[j]] <- 
            (nT+nC)/(nT*nC) + (ES^2)/(2*(nT + nC - 2))
    }
    
}

# Remove the control studies
maData <- subset(raw, Condition != 'Control')

# Flip effects sizes to that positive is better
maData$Effect.Size <- maData$Effect.Size * maData$Higher.Score.Direction

# Save
write.table(studyInfo, file = 'data/studyInfo.csv',
            sep = ',', row.names = F)
write.table(maData, file = 'data/maData.csv',
            sep = ',', row.names = F)

