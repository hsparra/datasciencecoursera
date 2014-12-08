require(data.table)
require(tm)
require(tau)
require(magrittr)

cleanTextForMatch <- function(str) {
    str <- tolower(str)
    str <- gsub("[[:punct:]]", " ", str)
    str <- gsub("[^a-z]", " ", str)
    str<- unlist(strsplit(str, split=" "))
    str <- remove_stopwords(str, stopwords())
    str <- str[nchar(str) > 2] # TEST
    str <- str[ str != " "]
    str <- str[str != "can"]    # Seems to be very common
    #    data <- wordStem(data)
    str <- str[str != ""]
    str <- gsub("(?<=[^[se]])s$", "", str, perl = TRUE)    # Remove at end of word if not preceded by an s
    str <- unlist(strsplit(str, split = " ")) %>%
        function (x) x[ x != ""]
    str <- gsub("[ ]{2,}", " ", str)
    str <- gsub("^[ ]+", "", str)
    str
}

cleanText_prior <- function(data, split=FALSE) {
    data <- tolower(data)
    data <- unlist(strsplit(data, split=" "))
    data <- remove_stopwords(data, stopwords())
    data <- gsub("[[:punct:]]", " ", data)
    data <- gsub("[^a-z]", " ", data)
    data <- data[ data != " "]
    #    data <- wordStem(data)
    data <- data[data != ""]
    data <- gsub("(?<=[^[se]])s$", "", data, perl = TRUE)    # Remove at end of word if not preceded by an s
    if (split) {
        data <- paste(data, collapse = " ")
    } else {
        data <- unlist(strsplit(data, split = " ")) %>%
            function (x) x[ x != ""]
    }
    data <- gsub("[ ]{2,}", " ", data)
    data <- gsub("^[ ]+", "", data)
    data
}

cleanText <- function(data, split=FALSE, stemWords=TRUE) {
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
    
    if (stemWords) {
        data <- wordStem(data)
    }
    data <- remove_stopwords(data, stopwords())   # Remove stopwords created by stemming
    
    
    data <- gsub("(?<=[^[se]])s$", "", data, perl = TRUE)    # Remove at end of word if not preceded by an s
    data <- data[data != ""]
#     if (length(data) < 4) {
#         return("")
#     }
    if (split) {
        data <- paste(data, collapse = " ")
    } else {
        data <- unlist(strsplit(data, split = " ")) %>%
            function (x) x[ x != ""]
    }
    
    data <- gsub("[ ]{2,}", " ", data)
    data <- gsub("^[ ]+", "", data)
    data
}


q4Match <- function(inText, matchTable, wrds, maxToReturn=1) {
    x <- cleanText(inText)
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

q4Match_all <- function(inText, matchTable, wrds, maxToReturn=1) {
    x <- cleanText(inText, noStemLast = FALSE)
    z <- matchTable[V3 == match(x, wrds)]
    z1 <- z[V2 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z1 <- z[V1 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z <- z[order(-logpAll, -logpV4, -count)]
    pred <- wrds[z$V4[1:maxToReturn]] %>% na.omit
    pred
}