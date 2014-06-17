## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

## Plot 2
# Summarize total emmissions for year for Baltimore City - FIPS 24510
library(plyr)
# Select the Baltimore City records
bc <- subset(NEI, fips == "24510")

# Fine the total emissions for each year
bctotal <- ddply(bc, .(year), summarize, total=sum(Emissions))

# Convert data frame to matrix for use with barplot function in Base package
yearly.m <- as.matrix(bctotal)

# Add rownames which will be used by barplot function for x-axis labels
rownames(yearly.m) <- yearly.m[,1]

# Plot emissions over time using Base graphics
png(file="plot2.png")
barplot(yearly.m[,2], ylab="Total Emissions (tons)", xlab="Year", col="lightblue")
title(main=expression("Total Baltimore City PM"[2.5]*"Emissions by Year"))

dev.off()