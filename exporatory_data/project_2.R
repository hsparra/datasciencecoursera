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

# Plot emissions over time using Base graphics

with(yearly, {
    plot(year, total/1000, xaxt="n", ylab="Total Emissions (1000s tons)", xlab="Year")
    lines(year, total/1000)
    axis(1,at=year)
    title(main=expression("Total PM"[2.5]*"Emissions by Year"))
    }
)


#with(yearly, {
yearly.m <- as.matrix(yearly)
rownames(yearly.m) <- yearly.m[,1]
yearly.m[,2] <- yearly.m[,2]/1000
barplot(yearly.m[,2], ylab="Total Emissions (1000s tons)", xlab="Year")
lines(yearly.m[,1], yearly.m[,2])
    lines(yearly, total/1000)
    title(main=expression("Total PM"[2.5]*"Emissions by Year"))
#}
#)
## Plot 2
# Summarize total emissions for year for Baltimore City - FIPS 24510
libary(plyr)
bc <- subset(NEI, fips == "24510")
bctotal <- ddply(bc, .(year), summarize, total=sum(Emissions))

# Plot emissions over time using Base graphics
with(bctotal, {
    plot(year, total, xaxt="n", ylab="Total Emissions (tons)", xlab="Year")
    lines(year, total)
    axis(1,at=year)
    title(main=expression("Total Baltimore City PM"[2.5]*"Emissions by Year"))
}
)


## Plot 3s
# Summarize Baltimore City emissions by year and type
bctype <- ddply(bc, .(year, type), summarize, total=sum(Emissions))
library(ggplot2)
g <- ggplot(bctype, aes(year, total))
g + geom_line() + facet_grid(. ~ type) + labs(title = expression("Baltimore City PM"[2.5]*" Emisions by Type")) + 
    labs(x="Year", y="Yearly Emissions (tons)")

dev.copy(png, file="plot3.png")
dev.off()

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

# Plot emissions over time using Base graphics
with(coaltotal, {
    plot(year, total/1000, xaxt="n", ylab="Total Emissions (1000s tons)", xlab="Year")
    lines(year, total/1000)
    axis(1,at=year)
    title(main=expression("Total Coal PM"[2.5]*"Emissions by Year"))
}
)
dev.copy(png, file="plot4.png")
dev.off()


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

# Plot emissions over time using Base graphics
with(bcvehicle, {
    plot(year, total, xaxt="n", ylab="Total Emissions (tons)", xlab="Year")
    lines(year, total)
    axis(1,at=year)
    title(main=expression("Baltimore City Motor Vehicle PM"[2.5]*"Emissions by Year"))
}
)


