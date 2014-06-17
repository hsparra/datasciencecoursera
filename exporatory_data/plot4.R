## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

# Add coal column to SCC data that identifies sources that use coal.
# Use EI.Sector since it seems to consistently identfiy coal usage with the word Coal
SCC$coal <- grepl("Coal", SCC$EI.Sector)

# Merge the SCC data with NEI data to identify the coal sources in the NEI data
# SCC is the common variable in both data frames.
library(plyr)
merged <- join(NEI, SCC)

# Summarize total emissions by year for the coal using sources
coaltotal <- ddply(subset(merged, coal == TRUE), .(year), summarize, total=sum(Emissions))

# Convert data frame to matrix for use with barplot function in Base package
yearly.m <- as.matrix(coaltotal)

# Add rownames which will be used by barplot function for x-axis labels
rownames(yearly.m) <- yearly.m[,1]

# Convert tons to 1000s of tons so y-axis is easier to read
yearly.m[,2] <- yearly.m[,2]/1000

# Create a bar chart showing emissions for each year
png(file="plot4.png")
barplot(yearly.m[,2], ylab="Total Emissions (1000s tons)", xlab="Year", col="lightblue")
title(main=expression("Total Coal PM"[2.5]*"Emissions by Year"))
dev.off()