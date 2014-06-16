## Load data
NEI <- readRDS("NEI_data/summarySCC_PM25.rds")
SCC <- readRDS("NEI_data/Source_Classification_Code.rds")

# Select the NEI records for Baltimore City, FIPS=24510, 
# and for Los Angeles, FIPS=06037
library(plyr)
twocity<- subset(NEI, fips == "24510" | fips == "06037")
yearlytotal <- ddply(twocity, .(year,fips), summarize, total=sum(Emissions))

yearlytotal$city <- ifelse(yearlytotal$fips == "24510", "Baltimore City", "Los Angeles")
yearlytotal$city <- factor(yearlytotal$city)

# Plot 
libary(ggplot2)
ggplot(yearlytotal, aes(year, log(total))) + geom_line() + facet_grid(fips ~ .)

library(lattice)
xyplot(total ~ year | city, yearlytotal)