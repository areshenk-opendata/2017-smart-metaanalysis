# Load sample
load('data/cognitiveModelSamples')
samples = rstan::extract(fit)

# Labels
plotFrame = data.frame(Study = as.character(unique(fitData$Author)),
                       Mean = colMeans(samples$theta),
                       Lower = apply(samples$theta, 2, function(x) quantile(x, .025)),
                       Upper = apply(samples$theta, 2, function(x) quantile(x, .975)))

# We plot the studies in order of their mean effect size,
# so we get the ordering here
idx = order(plotFrame$Mean)
plotFrame = plotFrame[order(plotFrame$Mean),]

## The rest of the columns in the table. 
tabletext <- cbind(c("Study", "\n", as.character(plotFrame$Study), '\n', 'Overall\n', ''))

pdf("plots/cognitive_forestPlot.pdf",
    width = 6, height = 5)
forestplot(labeltext = tabletext, graph.pos=2, 
           mean=c(NA, NA, c(plotFrame$Mean, NA, mean(samples$mu), NA)), 
           lower = c(NA, NA, plotFrame$Lower, NA, quantile(samples$mu, .025), NA), 
           upper=c(NA, NA, plotFrame$Upper, NA, quantile(samples$mu, .975), NA),
           title = "",
           xlab = "Effect Size",
           hrzl_lines = list("2" = gpar(lwd=2, col="#99999922")), 
           col=fpColors(box = "black", lines = "black", zero = "gray50"),
           zero = 0, cex = 0.9, lineheight = "auto", 
           colgap = unit(6,"mm"), cex.lab = 1.5,
           lwd.ci = 2, ci.vertices = F, grid = T,
           txt_gp = fpTxtGp(ticks = gpar(cex=1),
                            xlab = gpar(cex=1)))
dev.off()

