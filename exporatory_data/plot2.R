## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

## Plot 2
# Summarize total emmissions for year for Baltimore City - FIPS 24510
library(plyr)
bc <- subset(NEI, fips == "24510")
bctotal <- ddply(bc, .(year), summarize, total=sum(Emissions))

# Plot emissions over time using Base graphics
png(file="plot2.png")
with(bctotal, {
    plot(year, total, xaxt="n", ylab="Total Emissions (tons)", xlab="Year")
    lines(year, total)
    axis(1,at=year)
    title(main=expression("Total Baltimore City PM"[2.5]*"Emissions by Year"))
}
)
dev.off()