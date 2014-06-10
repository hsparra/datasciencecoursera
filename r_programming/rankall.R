

rankall <- function(outcome, num="best") {
    
   
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
    
    # remove NAs from outcomes, keep Hosp and state
    good <- outcomes[!is.na(outcomes[,col]),c(2,7,col)]
    names(good)[3] <- "Rate"
    names(good)[1] <- "Hospital"
    
    # split by state
    s <- split(good, good$State)
    
    
    # order hospitals with by lowest rate in alpha orde within rate
    #ordered <- lapply(good, funtion(x) x[order(x$Rate, x$Hospital),]
    
    # Create vectors to load results
    len <- length(s)
    hospital <- character(len)
    state <- character(len) 
    i <- 0
    
    for (state.data in s) {
        # return selected rank
        i <- i + 1
        if (num == "worst") {
            rank <- nrow(state.data)
        }
        
        state[i] <- state.data$State[1]
        if (nrow(state.data) < rank) {
            hospital[i] <- NA
        }
        else {
            ordered <- state.data[order(state.data$Rate,state.data$Hospital),]
            hospital[i] <-ordered[rank,"Hospital"]
        }        
    }
    
    
    data.frame(hospital, state, row.names=state)
}