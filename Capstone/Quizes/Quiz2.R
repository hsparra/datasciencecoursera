createRegex <- function(str, level=1) {
    x <- cleanText(str)
    
    if (level == 1) {
        m_regex <- paste("^", x[length(x)], sep="")
    } else {
        m_regex <- paste(x[(length(x) -(level - 1)) : length(x)], collapse=" ")
        m_regex <- paste("^", m_regex, sep="")
    }
}

returnMatches <- function(str, tbl1, clean = TRUE, level=1) {
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
    cat("regex pattern -", m_regex, "\n")
    y <- tbl1[grep(m_regex, tbl1$word)]
}

checkForMatch <- function(str, tbl, origStr="") {
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
    x <- returnMatches(str, tri_table, level=2)
    m <- data.table(word = character(0), 
                        count = numeric(0), 
                        src = character(0),
                        index = integer(0),
                        cum_count = numeric(0))
    #print(dim(x)[1])       # TEST
    if (dim(x)[1] > 0) {
        #m_regex <- createRegex(str, level=1)
        m <- findMatch(x, possibles)
        cat("check tri match NULL -", is.null(match))  # TEST
#        if (!is.null(m) & dim(m)[1] > 0 ) {
            #if (!is.null(m) & dim(match)[1] > 0) {
#            print(dim(m))
#            print("returning from tri")    # TEST
#            return(m[order(index)])
#        }
    }
    
    
    x <- returnMatches(str, bi_table)
    cat("after bi search - ", dim(x), "\n")   # TEST
    if (dim(x)[1] > 0) {
        match2 <- findMatch(x, possibles)
        if (!is.null(match2)) {
            m <- rbind(m, match2)
        }
    }
    if (!is.null(m) & dim(m)[1] > 0) {
        print("Returning from bi")   # TEST
        return(m[order(index)])
    }
    
    #return(y)
}

matches <- returnMatches("some sring", tri_table)

runTest <- function() {
    str <- "The guy in front of me just bought a pound of bacon, a bouquet, and a case of"
    pos <- c("cheese", "beer", "soda", "pretzels")
    print("Q1. - should get beer")
    findBestMatches(str, pos)
    
    str <- "You're the reason why I smile everyday. Can you follow me please? It would mean the"
    pos <- c("universe", "world", "most", "best")
    print("Q2. - should get world")
    findBestMatches(str, pos)
    
    str <- "Hey sunshine, can you follow me and make me the"
    pos <- c("saddest", "smelliest", "happiest", "bluest")
    print("Q3. - should be happiest?")
    findBestMatches(str, pos)
    
    str <- "Very early observations on the Bills game: Offense still struggling but the"
    pos <- c("crowd", "players", "defense", "referees")
    print("Q4. - should be --> defense  <--")
    findBestMatches(str, pos)
    
    str <- "Go on a romantic date at the"
    pos <- c("grocery", "movies", "mall", "beach")
    print("Q5. - should be -->  beach  <--")
    findBestMatches(str, pos)
    
    str <- "Well I'm pretty sure my granny has some old bagpipes in her garage I'll dust them off and be on my"
    pos <- c("motorcycle", "horse", "phone", "way")
    print("Q6. - should be -->  way  <--")
    findBestMatches(str, pos)
    
    str <- "Ohhhhh #PointBreak is on tomorrow. Love that film and haven't seen it in quite some"
    pos <- c("weeks", "thing", "time", "years")
    print("Q7. - should be -->  time  <--")
    findBestMatches(str, pos)
    
    str <- "After the ice bucket challenge Louis will push his long wet hair out of his eyes with his little"
    pos <- c("ears", "fingers", "toes", "eyes")
    print("Q8. - should be -->  fingers  <--")
    findBestMatches(str, pos)
    
    str <- "Be grateful for the good times and keep the faith during the"
    pos <- c("bad", "hard", "sad", "worse")
    print("Q9. - should be -->  bad  <--")
    findBestMatches(str, pos)
    
    str <- "If this isn't the cutest thing you've ever seen, then you must be"
    pos <- c("insensitive", "callous", "insane", "asleep")
    print("Q10. - should be -->  insane  <--")
    findBestMatches(str, pos)

}
