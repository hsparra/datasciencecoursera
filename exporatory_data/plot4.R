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

# Plot emissions over time using Base graphics
png(file="plot4.png")
with(coaltotal, {
    plot(year, total/1000, xaxt="n", ylab="Total Emissions (1000s tons)", xlab="Year")
    lines(year, total/1000)
    axis(1,at=year)
    title(main=expression("Total Coal PM"[2.5]*"Emissions by Year"))
}
)
dev.off()