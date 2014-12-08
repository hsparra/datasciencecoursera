require(data.table)
require(tm)
require(tau)
require(magrittr)

cleanTextForMatch<- function(data) {
    data <- unlist(strsplit(data, split=" "))
    data <- tolower(data)
    data <- gsub("’", "'", data)   # replace right single quote mark with chracter used in stopwords()
    data <- remove_stopwords(data, stopwords())
    data <- gsub("[[:punct:]]", " ", data)
    data <- gsub("[^a-z]", " ", data)
    data <- unlist(strsplit(data, split=" "))
    data <- data[ data != " "]

    if (length(data) <= 1) {
        return("")
    }
    
    data <- wordStem(data)
    data <- remove_stopwords(data, stopwords())   # Remove stopwords created by stemming

    data <- gsub("(?<=[^[se]])s$", "", data, perl = TRUE)    # Remove at end of word if not preceded by an s
    data <- data[data != ""]

#     if (split) {
#         data <- paste(data, collapse = " ")
#     } else {
        data <- unlist(strsplit(data, split = " ")) %>%
            function (x) x[ x != ""]
#     }
    
    data <- gsub("[ ]{2,}", " ", data)
    data <- gsub("^[ ]+", "", data)
    data
}


q4Match <- function(inText, matchTable, wrds, maxToReturn=1) {
    x <- cleanTextForMatch(inText)
    n <- length(x)
    z <- matchTable[V3 == match(x[n], wrds) ]
    z1 <- z[V2 == match(x[(n-1)], wrds) ]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z1 <- z[V1 ==match(x[(n-2)], wrds) ]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z <- z[order(-logpAll, -logpV4, -count)]
    pred <- wrds[z$V4[1:maxToReturn]] %>% na.omit
    pred
}

