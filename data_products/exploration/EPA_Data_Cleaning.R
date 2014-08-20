## This script processes the EPA data file from http://www.fueleconomy.gov/feg/ws/index.shtml
#

# To read directly from EPA uncomment this line and comment out the next line
# temp <- tempfile()
# download.file("http://www.fueleconomy.gov/feg/ws/index.shtml",temp)
# data <- read.csv(unz(temp,"vehicles.csv"), header=T, stringAsFactor=F) 
# Could aslo do
# data <- read.table(unz(temp, "vehicls.csv"))
data <- read.csv("vehicles.csv",header=T,stringsAsFactor=F)
#
#cols_of_interest <- c("charge120","charge240","city08","cithA08","cityCD","cityE","cityUF","comb08","combA08","combE",
#                      "combinedCD","combinedUF","fuelCost08","fuelCostA08","highway08","highwayA08","highwayCD","highwayE","highwayUF",
#                      "hlv","hpv","lv2","lv4","make","model","phevBlended","pv2","pv4","range","rangeCity","rangeCityA","rangeHwy",
#                      "rangeHwyA","VClass","year","youSave","atvType","rangeA","evMotor",)

#
cols_of_interest <- c("make","model","atvType","VClass","year","city08","highway08","comb08","cityA08","highwayA08","combA08",
                      "rangeCity","rangeHwy","range","cityE","highwayE","combE",
                      "cityCD","highwayCD","combinedCD","charge120","charge240","fuelCost08","fuelCostA08","cityUF",
                      "highwayUF","combinedUF",
                      "hlv","hpv","lv2","lv4","pv2","pv4","phevBlended","evMotor",
                      "rangeCityA","rangeHwyA","youSaveSpend","rangeA")

data <- subset(data, atvType %in% c("EV","Plug-in Hybrid") & year == "2014",select = names(data) %in% cols_of_interest)
data <- data[cols_of_interest]

#
# Move rangeA to range for Plug-in Hybrids since range = 0 for Plug-in Hybrids and electric range is stored in rangeA. Do same for city and hwy.
data$range[data$atvType == "Plug-in Hybrid"] <- data[data$atvType == "Plug-in Hybrid", "rangeA"]
data$rangeCity[data$atvType == "Plug-in Hybrid"] <- data[data$atvType == "Plug-in Hybrid", "rangeCityA"]
data$rangeHwy[data$atvType == "Plug-in Hybrid"] <- data[data$atvType == "Plug-in Hybrid", "rangeHwyA"]
data <- subset(data, select= -c(rangeA,rangeCityA,rangeHwyA))
#

# Function to reverse values if the second passed colun is not zero
f <- function(d, mainCol, zeroCol) {
    d[d[,zeroCol] != 0, c(mainCol, zeroCol)] <- d[d[,zeroCol] != 0, c(zeroCol, mainCol)]
    d
}

data <- f(data, "city08","cityA08")
data <- f(data, "highway08","highwayA08")
data <- f(data, "comb08","combA08")
data <- f(data, "fuelCost08","fuelCostA08")
# Put the cargo and passenger volumes in a comman column
data <- f(data, "hlv","lv4")
data <- f(data, "hlv", "lv2")
data <- f(data, "hpv", "pv4")
data <- f(data, "hpv", "pv2")

# Remove old volume columns
data <- subset(data, select = -c(lv4, lv2, pv4, pv2))

# change the column names to to more common names
new_column_names <- c("Make","Model","Type","Class","Year","MPGe.City","MPGe.Hwy","MPGe.Combined","MPG.City.Gas","MPG.Hwy.Gas","MPG.Combined.Gas",
                      "Range.City","Range.Hwy","Range","Kwh.100mi.City","Kwh.100mi.Hwy","Kwh.100mi.Combined",
                      "cityCD","highwayCD","combinedCD","Charge120","Charge240","Electricity.Cost","Gas.Cost","cityUF",
                      "highwayUF","combinedUF",
                      "Cargo","Passenger","phevBlended","EV.Motor","Savings.5Yr")
names(data) <- new_column_names

# Round range to nearest mile
data$Range.City <- round(data$Range.City)
data$Range.Hwy <- round(data$Range.Hwy)

# Add Base MSRPs
data$MSRP[data$Model == "Accord Plug-in Hybrid"] <- 40570
data$MSRP[data$Model == "FIT EV"] <- 37415
data$MSRP[data$Model == "500e"] <- 31800
data$MSRP[data$Model == "B-Class Electric Drive"] <- 42375
data$MSRP[data$Model == "C-MAX Energi Plug-in Hybrid"] <- 31635
data$MSRP[data$Model == "ELR"] <-75000
data$MSRP[data$Model == "Fit EV"] <- 36625
data$MSRP[data$Model == "Focus Electric"] <- 35170
data$MSRP[data$Model == "fortwo electric drive convertible"] <-28000
data$MSRP[data$Model == "fortwo electric drive coupe"] <- 25000
data$MSRP[data$Model == "Fusion Energi Plug-in Hybrid"] <- 34700
data$MSRP[data$Model == "i3 BEV"] <- 41350
data$MSRP[data$Model == "i3 REX"] <- 45200
data$MSRP[data$Model == "i-MiEV"] <- 22995
data$MSRP[data$Model == "Leaf"] <- 29010
data$MSRP[data$Model == "Model S (60 kW-hr battery pack)"] <- 69900
data$MSRP[data$Model == "Model S (85 kW-hr battery pack)"] <- 93400
data$MSRP[data$Model == "Panamera S E-Hybrid"] <- 107605
data$MSRP[data$Model == "Prius Plug-in Hybrid"] <- 29990
data$MSRP[data$Model == "RAV4 EV"] <- 49800
data$MSRP[data$Model == "Spark EV"] <- 26685
data$MSRP[data$Model == "Volt"] <- 34170

# Shorten some of the names
data$Model[data$Model == "Accord Plug-in Hybrid"] <- "Accord Plug-in"
data$Model[data$Model == "B-Class Electric Drive"] <- "B-Class"
data$Model[data$Model == "C-MAX Energi Plug-in Hybrid"] <- "C-MAX Energi"
data$Model[data$Model == "Focus Electric"] <- "Focus EV"
data$Model[data$Model == "fortwo electric drive convertible"] <- "ForTwo EV Convertible"
data$Model[data$Model == "fortwo electric drive coupe"] <- "ForTwo EV Coupe"
data$Model[data$Model == "Fusion Energi Plug-in Hybrid"] <- "Fusion Energi"
data$Model[data$Model == "Model S (60 kW-hr battery pack)"] <- "Model S (60 kwh)"
data$Model[data$Model == "Model S (85 kW-hr battery pack)"] <- "Model S (85 Kwh)"
data$Model[data$Model == "Prius Plug-in Hybrid"] <- "Prius Plug-in"

write.csv(data,"EPA_EV_Data.csv")