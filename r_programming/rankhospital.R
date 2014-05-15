library(datasets)

rankhospital <- function(state, outcome, num="best") {
    
    # validate state
    if (!(state %in% state.abb)) {
        stop("invalid state")
    }
    # validate outcome
    # if valid assign index for column
    if (outcome == "heart attack") {
        col <- 11
    } else if (outcome == "heart failure") {
        col <- 17
    } else if (outcome == "pneumonia") {
        col <- 23
    } else {
        stop("invalid outcome")
    }
    
    # validate ranking
    if (num == "best") {
        rank <- 1
    } else if (num == "worst") {
        rank <- 0
    } else if (is.numeric(num)) {
        rank <- num
    } else {
        stop("invalid rank")
    }
    
    #read outcome data
    outcomes <- read.csv("outcome-of-care-measures.csv", na.strings=c("NA","Not Available"), stringsAsFactors=FALSE)
    
    # set column of interest to numeric
    outcomes[,col] <- as.numeric(outcomes[,col])
    
    # remove NAs from outcomes, keep Hosp
    good <- outcomes[!is.na(outcomes[,col]) & outcomes[,7] == state,c(2,col)]
    
    # order hospitals with by lowest rate in alpha orde within rate
    ordered <- good[order(good[2], good[1]),]
    
    # return hospital(s) with lowest 30-day death rate
    #best.hosp <- good[good[,2] == min(good[,2]),1]
    
    # sort output and return lowest value
    #best.hosp[order(best.hosp)[1]]
    
    # return selected rank
    if (num == "worst") {
        selected <- ordered[nrow(ordered),1]
    } else {
        selected <- ordered [rank,1]
    }
    
    selected
}