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

decodeTopMatches <- function(matchesIn, dict, n=3) {
    
    if (length(matchesIn) < n) {
        n <- length(matchesIn)
    }
#     top <- character(0)
#     for (i in 1:n) {
#         top <- append(top, dict[matches[i]])
#     }
#     top
    head(dict[matchesIn], n)
}

findMatches <- function(str, t, dict, n=3) {
    
    l <- findAllMatches(str, t, dict, n)
    l[[1]]     # First entry are the top matches
}

decodeVars <- function(vars, dict) {
    vars <- gsub(" ", "", vars)
    vars <- match(vars, dict)
}

buildMatchString <- function(x, dict, lvl=2) {
    vars <- x[(length(x) - lvl + 1) : length(x)]
#     vars <- gsub(" ", "", vars)
#     vars <- match(vars, dict)
    paste("V", 1:lvl,"==",decodeVars(vars), sep="", collapse=" & ")
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

getTriMatches <- function(vals, mainPos, tbl) {
    vals <- match(vals, wrds)
    v1 <- vals[mainPos]
    v2s <-  setdiff(vals, v1) 
    matches <- tbl[V1==v1] [V2==v2s]
}

triMatch <- function(str, tbl, dict, n=5) {
    matches <- triMatchAll(str, tbl, dict, n)
    #matches[[1]]
    matches <- matches[, head(.SD, 5), by=V1]
    matches <- matches[order(-m_cnt)]
    #list(decodeTopMatches(matches[, V3], dict, n), matches)
    ## Look at taking top matches and bouncing against V2 in biGram
    ## possibly match first on bigrams then use those answers to 
    ## look up V3 on Tri, in addition to straight tri finds
    decodeTopMatches(matches[, V3], dict, n)
}

triMatchAll <- function(str, tbl, dict, n=5) {
    x <- cleanTextForMatch(str)
#     x <- cleanText(str)    # TEST - uses clean_data.R cleaner
    keys <- match(x, dict)
    lastCheck <- length(keys) - 3
    if (lastCheck < 1) { lastCheck == 1 }
    
    matches <- tbl[V2 == keys[length(keys)]][V1 == keys[lastCheck:(length(keys)-1)]]
#     matches <- tbl[V2 == keys[length(keys)]][V1 == keys[1:(length(keys)-1)]]  # less restrictive
    if (dim(matches)[1] == 0) {
        print("In triMatchAll no trigram match so try bigram")   # TEST
        matches <- tbl[V2 == keys[length(keys)]]
    }

    matches <- unique(matches[, m_cnt := sum(count), by=V3], by="V3")
    # Select the top 2 for each V1 match - this will give the highest counts
    # for the V1 & V2 combos with the corresponding V3 value
    setkey(matches, V1, m_cnt)
    matches <- matches[order(V1, -m_cnt)]
    
}

triMatch2 <- function(str, tbl, dict, n=4) {
    x <- cleanTextForMatch(str)
    #matches <- getTriMatches(x, length(x), tbl)
    #print(dim(matches))    # TEST
    #matches <- rbind(matches, getTriMatches(x, (length(x) - 1), tbl))
    
    keys <- match(x, dict)
#     matches <- tbl[V1==keys][V2==keys]
    ndx <- length(keys)
    matches <- tbl[V2 == keys[ndx]][V1 == keys[(ndx - 1)]]
    

    matches <- matches[order(-count)]
    list(decodeTopMatches(matches[, V3], dict, n), matches)
}

quickMatch <- function(x, n=5) {
    triMatch(x, trigrams, wrds, n)
}

