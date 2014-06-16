## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

# Select only the emissions for Baltimore City - FIPS 24510
library(plyr)
bc <- subset(NEI, fips == "24510")

# Summarize Baltimore City emissions by year and type.
bctype <- ddply(bc, .(year, type), summarize, total=sum(Emissions))

# Create plot of the emissions by year for each type. 
# Use a facet to show each type as its own graph.
library(ggplot2)
png(file="plot3.png")
ggplot(bctype, aes(year, total)) + geom_line() + facet_grid(. ~ type) + labs(title = expression("Baltimore City PM"[2.5]*" Emisions by Type")) + 
    labs(x="Year", y="Yearly Emissions (tons)")

dev.off()