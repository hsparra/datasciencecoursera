## Exploratory Data Analysis Project 2
#
#
#

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
barplot(yearly.m[,2], ylab="Total Emissions (1000s tons)", xlab="Year", col="lightblue")
title(main=expression("Total PM"[2.5]*" Emissions by Year"))


## Plot 2
# Summarize total emissions for year for Baltimore City - FIPS 24510
libary(plyr)
bc <- subset(NEI, fips == "24510")
bctotal <- ddply(bc, .(year), summarize, total=sum(Emissions))

# Convert data frame to matrix for use with barplot function in Base package
yearly.m <- as.matrix(bctotal)

# Add rownames which will be used by barplot function for x-axis labels
rownames(yearly.m) <- yearly.m[,1]

# Plot emissions over time using Base graphics
barplot(yearly.m[,2], ylab="Total Emissions (tons)", xlab="Year", col="lightblue")
title(main=expression("Total Baltimore City PM"[2.5]*"Emissions by Year"))


## Plot 3s
# Summarize Baltimore City emissions by year and type
bctype <- ddply(bc, .(year, type), summarize, total=sum(Emissions))

# Change year to a factor for graphing
bctype$year <- factor(bctype$year)
library(ggplot2)
ggplot(bctype, aes(year, total, fill=type)) + geom_bar(stat="identity", fill="blue") + 
    facet_grid(. ~ type) + labs(title = expression("Baltimore City PM"[2.5]*" Emisions by Type")) + 
    labs(x="Year", y="Yearly Emissions (tons)")


## Plot 4
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
barplot(yearly.m[,2], ylab="Total Emissions (1000s tons)", xlab="Year", col="lightblue")
title(main=expression("Total Coal PM"[2.5]*"Emissions by Year"))


## Plot 5
# Add vehicle column to SCC data that identifies emission types from vehicles.
# Use EI.Sector containing "On-Road" to identify vehicles. This will identify
# both heavy duty and light duty vehicles. Excluding non-road since category
# probably contains items like construction equipment.
SCC$vehicle <- grepl("On-Road", SCC$EI.Sector)

# Merge the SCC data with the Baltimore City data so we know for a given
# record if the emission source is from a vehicle. The SCC variable in
# each data frame is used for the merge.
merged <- join(bc, SCC)

# Compute the total emissions by year for all the records that have vehicle = TRUE.
# This will give the total emissions by year for vehicles.
bcvehicle <- ddply(merged[merged$vehicle == TRUE,], .(year), summarize, total=sum(Emissions))

# Change year to a factor for graphing
bcvehicle$year <- factor(bcvehicle$year)

# Create a bar chart showing emissions for each year
ggplot(bcvehicle, aes(year, total)) + geom_bar(stat="identity", fill="blue") + 
    labs(title = expression("Baltimore City Motor Vehicle PM"[2.5]*"Emissions by Year")) + 
    labs(x="Year", y="Total Emissions (tons)")



## Plot 6
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
ggplot(yearlytotal, aes(year, change, fill=pos)) + geom_bar(stat="identity") +
    facet_grid(. ~ city) + 
    scale_fill_manual(values=c("seagreen","red3")) + guides(fill=guide_legend(title="",reverse=TRUE)) +
    labs(title=expression("Change in Vehicular PM"[2.5]*" Over Time (1999 base)")) +
    labs(x="Year", y="Change in Emissions (tons) from 1999") + 
    theme(axis.text.y = element_text(colour=c("seagreen", "black", "red3", "red3")))


## To show side by side of total emissions change
yearlytotal$abschange <- abs(yearlytotal$total - yearlytotal$total[yearlytotal$year == "1999" & yearlytotal$city == yearlytotal$city])
ggplot(yearlytotal, aes(year, abschange, fill=city)) + geom_bar(position="dodge", stat="identity") +
    labs(title=expression("Change in Vehicular PM"[2.5]*" Over Time (1999 base)")) +
    labs(x="Year", y="Change in Emissions (tons) from 1999")

## Plot 6 bonus - Map multiple values on a facet using ggplot
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

yearlytotal <- ddply(merged[merged$vehicle == TRUE,], .(year,fips), summarize, total=sum(Emissions))

yearlytotal$city <- ifelse(yearlytotal$fips == "24510", "Baltimore City", "Los Angeles")
yearlytotal$city <- factor(yearlytotal$city)

# Change year to a factor for graphing
yearlytotal$year <- factor(yearlytotal$year)

yearlytotal$change <- yearlytotal$total / yearlytotal$total[yearlytotal$year == "1999" & yearlytotal$city == yearlytotal$city]
# yearlytotal$abschange <- abs(yearlytotal$total - yearlytotal$total[yearlytotal$year == "1999" & yearlytotal$city == yearlytotal$city])
yearlytotal$reduced.tons <- yearlytotal$total[yearlytotal$year == "1999" & yearlytotal$city == yearlytotal$city] - yearlytotal$total

library(reshape2)
library(ggplot2)
melted <- melt(yearlytotal, id.vars = c("year","fips","city"))

meltsmall <- melted[melted$variable == "change" | melted$variable == "reduced.tons",]

ggplot(meltsmall, aes(year, value, fill=variable)) + geom_bar(stat="identity") + 
    facet_grid(variable ~ city, scale="free_y") + 
    labs(title=expression("Change in Vehicular PM"[2.5]*" Over Time"))

