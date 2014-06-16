## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

## Plot 1
# Summarize total emissions by year
library(plyr)
yearly <- ddply(NEI, .(year), summarize, total=sum(Emissions))

# Plot emissions over time using Base graphics
png(file="plot1.png")
with(yearly, {
    plot(year, total/1000, xaxt="n", ylab="Total Emissions (1000s tons)", xlab="Year")
    lines(year, total/1000)
    axis(1,at=year)
    title(main=expression("Total PM"[2.5]*"Emissions by Year"))
}
)
dev.off()