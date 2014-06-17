## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

# Select the NEI records for Baltimore City, FIPS=24510, 
# and for Los Angeles, FIPS=06037
library(plyr)
twocity<- subset(NEI, fips == "24510" | fips == "06037")

# Add vehicle column to SCC data that identifies emission types from vehicles.
# Use EI.Sector containing "On-Road" to identify vehicles. This will identify
# both heavy duty and light duty vehicles. Excluding non-road since category
# probably contains items like construction equipment.
SCC$vehicle <- grepl("On-Road", SCC$EI.Sector)

# Merge the SCC data with the data from the two cities so we know for a given
# record if the emission source is from a vehicle. The SCC variable in
# each data frame is used for the merge.
merged <- join(twocity, SCC)

# Compute the total emissions for each year for each city
yearlytotal <- ddply(merged[merged$vehicle == TRUE,], .(year,fips), summarize, total=sum(Emissions))

# Add column with city name that correspsondes to the FIPS code
yearlytotal$city <- ifelse(yearlytotal$fips == "24510", "Baltimore City", "Los Angeles")

# Change year to a factor for graphing
yearlytotal$year <- factor(yearlytotal$year)

# Compute the change in emissions using 1999 as the base year
yearlytotal$change <- yearlytotal$total - yearlytotal$total[yearlytotal$year == "1999" & yearlytotal$city == yearlytotal$city]

# Add variable to use for the fill of the graph
yearlytotal$pos <- ifelse(yearlytotal$change <= 0, "Decrease","Increase")

# Create faceted bar chart showing change in emissions over time for each city
png(file="plot6.png")
library(ggplot2)

ggplot(yearlytotal, aes(year, change, fill=pos)) + geom_bar(stat="identity") +
    facet_grid(. ~ city) + 
    scale_fill_manual(values=c("seagreen","red3")) + guides(fill=guide_legend(title="",reverse=TRUE)) +
    labs(title=expression("Change in Vehicular PM"[2.5]*" Over Time (1999 base)")) +
    labs(x="Year", y="Change in Emissions (tons) from 1999") + 
    theme(axis.text.y = element_text(colour=c("seagreen", "black", "red3", "red3")))

dev.off()