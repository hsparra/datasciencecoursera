library(datasets)

best <- function(state, outcome) {
    
    # validate state
    if (!(state %in% state.abb)) {
        stop("invalid state")
    }
    # validate outcome
    # if valid assign index for column
    if (outcome == "heart attack") {
        col <- 11
    } else if (outcome == "heart failure") {
        col <- 19
    } else if (outcome == "pneumonia") {
        col <- 23
    } else {
        stop("invalid outcome")
    }
    
    #read outcome data
    outcomes <- read.csv("outcome-of-care-measures.csv", na.strings=c("NA","Not Available"), stringsAsFactors=FALSE)
    
    # set column of interest to numeric
    outcomes[,col] <- as.numeric(outcomes[,col])

    #remove NAs from outcomes
    good <- outcomes[!is.na(outcomes[,col]),c(2,col)]
    
    # return hospital(s) with lowest 30-day death rate
    best.hosp <- good[good[,2] == min(good[,2]),1]
    
    # sort output and return lowest value
    best.hosp[order(best.hosp)[1]]
}