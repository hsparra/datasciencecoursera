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

decodeTopMatches <- function(matchesIn, dict, n=3) {
    matches <- as.vector(as.matrix(matchesIn))
    if (length(matches) < n) {
        n <- length(matches)
    }
    top <- character(0)
    for (i in 1:n) {
        top <- append(top, dict[matches[i]])
    }
    top
}

findMatches <- function(str, t, dict, n=3) {
    
    l <- findAllMatches(str, t, dict, n)
    l[[1]]     # First entry are the top matches
}

buildMatchString <- function(x, dict, lvl=2) {
    vars <- x[(length(x) - lvl + 1) : length(x)]
    vars <- gsub(" ", "", vars)
    vars <- match(vars, dict)
    paste("V", 1:lvl,"==",vars, sep="", collapse=" & ")
}

findAllMatches <- function(str, t, dict, n=3) {
    x <- cleanTextForMatch(str)
    lngth <- dim(t)[2] - 2

    cat("length is", lngth, "\n")   # TEST

    for (i in lngth:1) {
        key <- buildMatchString(x, dict, i)
        cat("search with key", key, "\n")    #TEST
        matches <- eval(parse(text=paste("t[", key, "]")))

        if (dim(matches)[1] > 0) {
            matches <- matches[order(-count)]
            break
        }
    }
    

    if (is.null(matches)) { return(list())}
    # decode values
    list(decodeTopMatches(matches[, (i+1), with=FALSE], dict, n), matches)
}

