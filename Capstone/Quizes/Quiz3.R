suppressMessages(library(magrittr))
suppressMessages(library(tm))
suppressMessages(library(SnowballC))
suppressMessages(library(dplyr))
suppressMessages(library(data.table))
library(RWeka)
library(tau)


### NOTE: Look at testing for other words, not just the last
###       Merge tables
cleanText <- function(data, split=FALSE) {
    data <- unlist(strsplit(data, split=" "))
    data <- tolower(data)
    data <- remove_stopwords(data, stopwords())
    #data <- gsub("[[:punct:]]", " ", data)
    data <- gsub("[^a-z]", " ", data)
    #data <- gsub("[ ]{2}", " ", data)
    data <- data[ data != " "]
    data <- wordStem(data)
    data <- data[data != ""]
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

createRegex <- function(str, level=1) {
    if (debug) {
        print("in createRegex")
    }
    x <- cleanText(str)
    
    if (level == 1) {
        m_regex <- paste("^", x[length(x)], sep="")
    } else {
        m_regex <- paste(x[(length(x) -(level - 1)) : length(x)], collapse=" ")
        m_regex <- paste("^", m_regex, sep="")
    }
}

returnMatches <- function(str, tbl1, clean = TRUE, level=1) {
    if (debug) {
        print("in returnMatches")
    }
    if (clean) {
        x <- cleanText(str)
        
        if (level == 1) {
            m_regex <- paste("^", x[length(x)], sep="")
        } else {
            m_regex <- paste(x[(length(x) -(level - 1)) : length(x)], collapse=" ")
            m_regex <- paste("^", m_regex, sep="")
        }
    } else {
        m_regex <- paste("^", str, sep="")
    }
    #cat("regex pattern -", m_regex, "\n")   # TEST
    y <- tbl1[grep(m_regex, tbl1$word)]
}

checkForMatch <- function(str, tbl, origStr="") {
    if (debug) {
        print("in checkForMatch")
    }
    str <- cleanText(str)
    if (origStr > "") {
        m <- paste(origStr, str, sep=" ")
    } else {
        m <- paste("[ ]", str, sep="")
    }
    #cat("   checking for match with regex", m, "\n")   # TEST
    x <- tbl[grep(m, tbl$word)]
    if (dim(x)[1] == 0 ) {
        m <- paste(str,"[ ]",  sep="")
        x <- tbl[grep(m, tbl$word)]
    }
    x
}

findMatch <- function(x, pos, origStr = "") {
    if (debug) {
        print("in findMatch")
    }
    z <- data.table()
    for (i in pos) {
        cleaned <- cleanText(i)
        y <- data.table()
        y <- checkForMatch(i, x, origStr)
        if (dim(y)[1] > 0) {
            z <- rbind(z, y)
        }
    }
    z
}

findBestMatches <- function(str, possibles = c("")) {
    if (debug) {
        print("in findBestMatches")
    }
    x <- returnMatches(str, tri_table, level=2)
    m <- data.table(word = character(0), 
                        count = numeric(0), 
                        src = character(0),
                        index = integer(0),
                        cum_count = numeric(0))
    #print(dim(x)[1])       # TEST
    if (dim(x)[1] > 0) {
        m <- findMatch(x, possibles)
        #cat("check tri match NULL -", is.null(match))  # TEST
    }
    
    
    x <- returnMatches(str, bi_table)
    if (dim(x)[1] > 0) {
        match2 <- findMatch(x, possibles)
        if (!is.null(match2)) {
            m <- rbind(m, match2)
        }
    }
    if (!is.null(m) & dim(m)[1] > 0) {
        #print("Returning from bi")   # TEST
        if (debug2) {
            m[order(index)]
        }
        return(m[order(index)])
    }
    
    #return(y)
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

debug <- FALSE
debug2 <- FALSE
load("data/tables/t_bi_twit_1.RData")
load("data/tables/t_tri_twit_1.RData")

matches <- returnMatches("some sring", tri_table)

runTest <- function() {
    str <- "When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd"
    pos <- c("die", "eat", "sleep", "give")
    print("Q1. - should get -->  die  <--")
    findBestMatches(str, pos)
    findMatches(str, dict, twit_1)
    

    str <- "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
    pos <- c("horitcultural", "financial", "marital", "spiritual")
    print("Q2. - should get -->  ??  <--")
    findBestMatches(str, pos)
    
    str <- "I'd give anything to see arctic monkeys this"
    pos <- c("decade", "morning", "weekend", "month")
    print("Q3. - should get -->  ??  <--")
    findBestMatches(str, pos)
    
    str <- "Talking to your mom has the same effect as a hug and helps reduce your"
    pos <- c("stress", "hunger", "sleepiness", "happiness")
    print("Q4. - should get -->  stress  <--")
    findBestMatches(str, pos)
    
    str <- "When you were in Holland you were like 1 inch away from me but you hadn't time to take a"
    pos <- c("walk", "look", "minute", "picture")
    print("Q5. - should get -->  picture or look  <--")
    findBestMatches(str, pos)
    
    str <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
    pos <- c("matter", "incident", "case", "account")
    print("Q6. - should get -->  matter  <--")
    findBestMatches(str, pos)
    
    str <- "I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each"
    pos <- c("toe", "arm", "hand", "finger")
    print("Q7. - should get -->  ?hand?  <--")
    findBestMatches(str, pos)
    
    str <- "Every inch of you is perfect from the bottom to the"
    pos <- c("side", "middle", "center", "top")
    print("Q8. - should get -->  ?top?  <--")
    findBestMatches(str, pos)
    
    str <- "I’m thankful my childhood was filled with imagination and bruises from playing"
    pos <- c("inside", "weekly", "outside", "daily")
    print("Q9. - should get -->  outside  <--")
    findBestMatches(str, pos)
    
    str <- "I like how the same people are in almost all of Adam Sandler's"
    pos <- c("stories", "pictures", "novels", "movies")
    print("Q10. - should get -->  movies  <--")
    findBestMatches(str, pos)
}

# Manual steps to see what is returned
xy <- returnMatches(str, bi_table)
reg <- createRegex(str)
xy_m <- findMatch(xy, pos)