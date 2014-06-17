## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

## Plot 1
# Summarize total emissions by year
library(plyr)
yearly <- ddply(NEI, .(year), summarize, total=sum(Emissions))

# Convert data frame to matrix for use with barplot function in Base package
yearly.m <- as.matrix(yearly)

# Add rownames which will be used by barplot function for x-axis labels
rownames(yearly.m) <- yearly.m[,1]

# Convert tons to 1000s of tons so y-axis is easier to read
yearly.m[,2] <- yearly.m[,2]/1000

# Create a bar chart showing emissions for each year
png(file="plot1.png")
barplot(yearly.m[,2], ylab="Total Emissions (1000s tons)", xlab="Year", col="lightblue")
title(main=expression("Total PM"[2.5]*" Emissions by Year"))

dev.off()