cleantypes <- function(x) {
    # Change to a character so can more easily change factor levels
    x <- as.character(x)
    # Thunderstorms and Tornadoes
    x[grepl("TORNADO",x)] <- "TORNADO"
    x[grepl("TORNDAO",x)] <- "TORNADO"
    x[grepl("FUNNEL CLOUD",x)] <- "TORNADO"
    x[grepl("HAIL",x)] <- "HAIL"
    x[grepl("THUNDERSTORM",x)] <- "THUNDERSTORM"
    x[grepl("TSTM",x)] <- "THUNDERSTORM"
    x[grepl("Tstm",x)] <- "THUNDERSTORM"
    x[grepl("MICROBURST",x)] <- "MICROBURST"
    x[grepl("Microburst",x)] <- "MICROBURST"
    
    # Tropical Systems
    x[grepl("HURRICANE",x)] <- "HURRICANE/TROPICAL STORM"
    x[grepl("Hurricane",x)] <- "HURRICANE/TROPICAL STORM"
    x[grepl("TYPHOON",x)] <- "HURRICANE/TROPICAL STORM"
    x[grepl("TROPICAL STORM",x)] <- "HURRICANE/TROPICAL STORM"
    x[grepl("COASTAL",x)] <- "COASTAL STORM"
    x[grepl("Coastal",x)] <- "COASTAL STORM"
    #x[grepl("SURGE",x)] <- "STORM SURGE"
    x[grepl("SURGE",x)] <- "HURRICANE/TROPICAL STORM"
    
    # Heat Waves
    x[grepl("HEAT",x)] <- "HEAT"
    x[grepl("Heat",x)] <- "HEAT"
    x[grepl("WARM",x)] <- "HEAT"
    
    # High Winds
    x[grepl("WIND",x)] <- "HIGH WINDS"
    x[grepl("Wind",x)] <- "HIGH WINDS"
    x[grepl("wind",x)] <- "HIGH WINDS"
    
    # Excessive Rain
    x[grepl("RAIN",x)] <- "RAIN"
    x[grepl("Rain",x)] <- "RAIN"
    # Period where not enough time to dry out before next rain
    x[grepl("EXCESSIVE WETNESS",x)] <- "RAIN" 
    
    # Extreme Cold and Winter Storms
    x[grepl("WINTER",x)] <- "WINTER STORM"
    x[grepl("Winter",x)] <- "WINTER STORM"
    x[grepl("SNOW",x)] <- "WINTER STORM"
    x[grepl("Snow",x)] <- "WINTER STORM"
    x[grepl("BLIZZARD",x)] <- "WINTER STORM"
    x[grepl("WINTRY MIX",x)] <- "WINTER STORM"
    x[grepl("COLD",x)] <- "EXTREME COLD"
    x[grepl("cold",x)] <- "EXTREME COLD"
    x[grepl("Cold",x)] <- "EXTREME COLD"
    x[grepl("FREEZE",x)] <- "EXTREME COLD"
    x[grepl("LOW TEMP",x)] <- "EXTREME COLD"
    x[grepl("MIX",x)] <- "WINTERY MIX"
    x[grepl("Mix",x)] <- "WINTERY MIX"
    x[grepl("FREEZING",x)] <- "WINTERY MIX"
    x[grepl("Freezing",x)] <- "WINTERY MIX"
    
    # Coastal Surf and High Seas
    x[grepl("SURF",x)] <- "HIGH SURF/RIP CURRENTS"
    x[grepl("Surf",x)] <- "HIGH SURF/RIP CURRENTS"
    x[grepl("HIGH SEAS",x)] <- "HIGH SURF/RIP CURRENTS"
    x[grepl("RIP CURRENT",x)] <- "HIGH SURF/RIP CURRENTS"
    x[grepl("HIGH SWELLS",x)] <- "ROUGH SEAS"
    
    # Flooding
    x[grepl("FLASH FLOOD",x)] <- "FLASH FLOOD"
    x[grepl("FLOOD/FLASH",x)] <- "FLASH FLOOD"
    x[grepl("STREAM",x)] <- "FLASH FLOOD"
    x[grepl("FLOOD",x)] <- "FLOODING"
    
    # Forest and Wildfires
    x[grepl("FOREST FIRE",x)] <- "FOREST FIRES"
    x[grepl("WILD",x)] <- "WILDFIRES"
    
    # Lightning
    x[grepl("LIGHTNING",x)] <- "LIGHTNING"
    x[grepl("LIGHNTING",x)] <- "LIGHTNING"
    x[grepl("LIGNTNING",x)] <- "LIGHTNING"
    x[grepl("LIGHTING",x)] <- "LIGHTNING"
    
    # Miscellaneous
    x[grepl("MUD",x)] <- "MUD SLIDES"
    x[grepl("Mud",x)] <- "MUD SLIDES"
    x[grepl("ICE JAM",x)] <- "JAM"
    x[grepl("Ice jam",x)] <- "JAM"
    x[grepl("ICE FLOW",x)] <- "JAM"
    x[grepl("AVALANCE",x)] <- "AVALANCHE"
    x[grepl("HYPOTHERM",x)] <- "HYPOTHERMIA"
    x[grepl("HYPERTHERM",x)] <- "HYPOTHERMIA"
    x[grepl("Hypotherm",x)] <- "HYPOTHERMIA"
    x[grepl("LANDSLIDE",x)] <- "LANDSLIDE"
    x[grepl("MARINE",x)] <- "MARINE MISHAP"
    x[grepl("Marine",x)] <- "MARINE MISHAP"
    
    # Snow and Ice not able to directly associate with a storm
    x[grepl("ICE",x)] <- "SNOW/ICE"
    x[grepl("Ice",x)] <- "SNOW/ICE"
    x[grepl("GLAZE",x)] <- "SNOW/ICE"
    x[grepl("Glaze",x)] <- "SNOW/ICE"
    x[grepl("snow",x)] <- "SNOW/ICE"
    x[grepl("ICY",x)] <- "SNOW/ICE"
    x[grepl("SLEET",x)] <- "SNOW/ICE"
    
    # Change back into a factor
    x <- factor(x)
    x
}