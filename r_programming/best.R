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
    
    # return hospital(s) with lowest 30-day death rate
}