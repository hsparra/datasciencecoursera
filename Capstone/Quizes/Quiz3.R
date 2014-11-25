suppressMessages(library(magrittr))
suppressMessages(library(tm))
suppressMessages(library(SnowballC))
suppressMessages(library(dplyr))
suppressMessages(library(data.table))
library(RWeka)
library(tau)

source("shinyApp/predictor.R")

runTest <- function() {
    str <- "When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd"
    pos <- c("die", "eat", "sleep", "give")
    print("Q1. - should get -->  die  <--")
    findBestMatches(str, pos)
    findMatches(str, bi_t_c, dict)
    

    str <- "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
    pos <- c("horitcultural", "financial", "marital", "spiritual")
    print("Q2. - should get -->  marital  <--")
    findBestMatches(str, pos)
    
    str <- "I'd give anything to see arctic monkeys this"
    pos <- c("decade", "morning", "weekend", "month")
    print("Q3. - should get -->  weekend??  <--")
#     findBestMatches(str, pos)
    findMatches(str, trigrams, wrds)
    
    str <- "Talking to your mom has the same effect as a hug and helps reduce your"
    pos <- c("stress", "hunger", "sleepiness", "happiness")
    print("Q4. - should get -->  stress  <--")
    findBestMatches(str, pos)
    
    str <- "When you were in Holland you were like 1 inch away from me but you hadn't time to take a"
    pos <- c("walk", "look", "minute", "picture")
    print("Q5. - should get -->  picture or look?  <--")
    findBestMatches(str, pos)
    
    str <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
    pos <- c("matter", "incident", "case", "account")
    print("Q6. - should get -->  matter (or case)?  <--")
    findBestMatches(str, pos)
    
    str <- "I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each"
    pos <- c("toe", "arm", "hand", "finger")
    print("Q7. - should get -->  hand  (arm?)  <--")
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