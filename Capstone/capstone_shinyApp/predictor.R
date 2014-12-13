require(data.table)
require(tm)
require(tau)
require(magrittr)

singleLettersResultsToRemove <- setdiff(letters, c("a", "i"))
maxToReview <- 5

cleanTextForMatch <- function(data) {
    data <- unlist(strsplit(data, split=" "))
    
    data <- tolower(data)
    data <- gsub("’", "'", data)   # replace right single quote mark with chracter used in stopwords()
    
    data <- gsub("[^a-z]", " ", data)
    data <- unlist(strsplit(data, split=" "))
    data <- data[ data != " "]
    if (length(data) <= 1) {
        return("")
    }
    
    data <- data[data != ""]
    data <- unlist(strsplit(data, split = " ")) 
    data <- data[ data != ""]

    data <- gsub("^[ ]+", "", data)
    data
}


selectReturn <- function(m, wrds, maxToReturn = 1) {
    m <- m[order(-ratio)]
}

match2Gram <- function(x, m2gram) {
    m <- m2gram[V1 == last(x)]
}

match3Gram <- function(x, m3gram) {
    n <- length(x)
    m <- m3gram[V2 == x[n]]
    if (dim(m)[1] == 0){
        return(m)
    }
    m <- m[V1 == x[(n-1)]]
}

match4Gram <- function(x, m4gram) {
    n <- length(x)
    m <- m4gram[V3 == x[n]]
    if (dim(m)[1] == 0){
        return(m)
    }
    m <- m[V2 == x[(n-1)]]
    if (dim(m)[1] == 0){
        return(m)
    }
    m <- m[V1 == x[(n-2)]]
}

cleanResults <- function(x, maxToReturn = 1) {
    y <- setdiff(x, singleLettersResultsToRemove)
    # If only single letters returned then go ahead and return them
    if (length(y) == 0) {
        y <- x
    }
    y <- ifelse(y == "i", "I", y)
    y <- y[1:maxToReturn]
    na.omit(y)
}

qMatch <- function(inText, m4gram, m3gram, m2gram, wrds, maxToReturn = 1) {
    x <- cleanTextForMatch(inText)
    x <- match(x, wrds)
    if (length(x) == 0) {
        return("")
    }
    m <- data.table()
    if (length(x) >= 3) {
        m <- match4Gram(x, m4gram)
        if (dim(m)[1] > 0) {
            m <- m[order(stopWord, -ratio)]
            return( wrds[m$V4[1:maxToReview]] %>% cleanResults(maxToReturn))
        }
    }
    
    if (length(x) >= 2) {
        m <- match3Gram(x, m3gram)
        if (dim(m)[1] > 0) {
            m <- m[order(stopWord, -bi_cnt, -ratio)]
            return( wrds[m$V3[1:maxToReview]] %>% cleanResults(maxToReturn))
        }
    }
    
    m <- match2Gram(x, m2gram)
    if (dim(m)[1] > 0) {
        m <- m[order(-count)]
        return( wrds[m$V2[1:maxToReview]] %>% cleanResults(maxToReturn))
    }
    return("")
}

