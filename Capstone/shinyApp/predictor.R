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
    matches[[1]]
    
    ## Look at taking top matches and bouncing against V2 in biGram
    ## possibly match first on bigrams then use those answers to 
    ## look up V3 on Tri, in addition to straight tri finds
}

triMatchAll <- function(str, tbl, dict, n=5) {
    x <- cleanTextForMatch(str)
    keys <- match(x, dict)
    matches <- tbl[V2 == keys[length(keys)]][V1 == keys]
#     matches <- tbl[V2 == keys][V1 == keys]
    matches <- unique(matches[, tot := sum(count), by=V3], by="V3")
    matches <- matches[order(-tot)]
    #     print("before decode")   # TEST
    #     print(head(matches))     # TEST
    list(decodeTopMatches(matches[, V3], dict, n), matches)
}

triMatch2 <- function(str, tbl, dict, n=4) {
    x <- cleanTextForMatch(str)
    #matches <- getTriMatches(x, length(x), tbl)
    #print(dim(matches))    # TEST
    #matches <- rbind(matches, getTriMatches(x, (length(x) - 1), tbl))
    
    keys <- match(x, dict)
    print(keys)    # TEST
    matches <- tbl[V1==keys][V2==keys]
    print(dim(matches))    # TEST
#    v1 <- x[length(x)]
#    v2s <- setdiff(v1, x)
#    matches <- data.table()
#    matches <- rbind(tbl[V1==v1 & V2==v2s])
#     primary <- length(x)
#     vars <- x[(length(x) - 1) : length(x)]
#     matches <- data.table()
#     
#     for (j in 1:2) {
#         for (i in (primary - 1):1) {
#             vars <- c(x[primary], x[i])
#             key <- paste("V", 1:2,"==",decodeVars(vars, dict), sep="", collapse=" & ")
#             print(key)
#             matches <- rbind(matches, eval(parse(text=paste("tbl[", key, "]"))))
#         }
#     }
    
    matches <- matches[order(-count)]
    print("before decode")   # TEST
    print(head(matches))     # TEST
    list(decodeTopMatches(matches[, V3], dict, n), matches)
}

