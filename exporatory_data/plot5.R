## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

# Add vehicle column to SCC data that identifies emission types from vehicles.
# Use EI.Sector containing "On-Road" to identify vehicles. This will identify
# both heavy duty and light duty vehicles. Excluding non-road since category
# probably contains items like construction equipment.
SCC$vehicle <- grepl("On-Road", SCC$EI.Sector)

# Select only the emissions for Baltimore City - FIPS 24510
library(plyr)
bc <- subset(NEI, fips == "24510")

# Merge the SCC data with the Baltimore City data so we know for a given
# record if the emission source is from a vehicle. The SCC variable in
# each data frame is used for the merge.
merged <- join(bc, SCC)

# Compute the total emissions by year for all the records that have vehicle = TRUE.
# This will give the total emissions by year for vehicles.
bcvehicle <- ddply(merged[merged$vehicle == TRUE,], .(year), summarize, total=sum(Emissions))

# Plot emissions over time using Base graphics
png(file="plot5.png")
with(bcvehicle, {
    plot(year, total, xaxt="n", ylab="Total Emissions", xlab="Year")
    lines(year, total)
    axis(1,at=year)
    title(main=expression("Baltimore City Motor Vehicle PM"[2.5]*"Emissions by Year"))
}
)
dev.off()