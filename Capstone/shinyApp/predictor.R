require(data.table)
require(tm)
require(tau)
reguire(magrittr)

cleanTextForMatch <- function(str) {
    str <- tolower(str)
    str <- gsub("[[:punct:]]", " ", str)
    str <- gsub("[^a-z]", " ", str)
    str<- unlist(strsplit(str, split=" "))
    str <- remove_stopwords(str, stopwords())
    str <- str[ str != " "]
    #    data <- wordStem(data)
    str <- str[str != ""]
    str <- unlist(strsplit(str, split = " ")) %>%
        function (x) x[ x != ""]
    str <- gsub("[ ]{2,}", " ", str)
    str <- gsub("^[ ]+", "", str)
    str
}

decodeTopMatches <- function(matches, dict, n=3) {
    if (length(matches) < n) {
        n <- length(matches)
    }
    top <- character(0)
    for (i in 1:n) {
        #         cat("looking for decode of:", matches[i], "  which =", dict[matches[i]], "\n")   # TEST
        top <- append(top, dict[matches[i]])
    }
    top
}

findMatches <- function(str, t, dict, n=3) {
    
    l <- findAllMatches(str, t, dict, n)
    l[[1]]
}

findAllMatches <- function(str, t, dict, n=3) {
    x <- cleanText(str)
    key <- match(x[length(x)], dict)
    if (!is.na(key)) {
        matches <- t[w1 == key]
        matches <- matches[order(-count)]
    }
    # decode values
    list(decodeTopMatches(matches$w2, dict, n), matches)
}

