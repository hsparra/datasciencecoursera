library(doMC)
registerDoMC(2)
library(tau)
suppressMessages(library(ggplot2))
suppressMessages(library(magrittr))
suppressMessages(library(tm))
suppressMessages(library(SnowballC))
suppressMessages(library(dplyr))
suppressMessages(library(data.table))

splitFile<- function(inFile, outLocation, outPrefix, folds = 10) {
    #con <- file(inFile,"r")
    #f_file <- readLines(con)
    #close(con)
    f_file <- fread(inFile, sep="\n", header=FALSE)
    print("create folds")
    #f_file <- readLines(inFile, "r")
    sets <- createFolds(1:length(f_file), k = folds)
    print(paste(folds, "folds created, write out files"))
    for (i in 1:folds) {
        #out <- f_file[ folds[[i]] ]
        #write.table(out, file = paste(outFileLocation, outFilePrefix, i, ".txt", sep=""))
        print(paste("file", i, "written"))
        outCon <- file(paste(outLocation, outPrefix, "_", i, ".txt", sep = ""), "w")
        writeLines(f_file[ sets[[i]] ], con = outCon)
        close(outCon)
    }
}

library(caret)
set.seed(2014)

splitFile("en_US/en_US.twitter.txt", "data/split/", "twitter", 10)

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

cleanFiles <- function (inFile, outFile, step=100) {
    #con <- file(inFile,"r")
    data <- fread(inFile, sep="\n", header=FALSE)
    end <- length(data$V1)
    cat("the number of lines is ", end, "\n")
    conOut <- file(outFile, "w")
    
    i <- 1
    j <- 1
    while (j < end) {
        j <- i + step
        if (j > end) { j <- end }
        cleaned <- sapply(data$V1[i:j], cleanText, TRUE)
        cleaned <- cleaned[cleaned != ""]
        writeLines(cleaned, con=conOut)
        i <- i + step + 1       
    }
    close(conOut)
}

cleanFiles("data/split/twitter_1.txt", "data/cleaned/twitter_1_clean.txt") # ~500 sec.

for (f in list.files("data/split/", pattern = "blogs", full.names = FALSE)) {
    cat(date(), "- Cleaning file", f, "\n")
    outF <- gsub(".txt", "_clean.txt", f)
    cleanFiles(paste("data/split/", f, sep=""), paste("data/clean/", outF, sep="") )
}

#cleanFiles("en_us/en_US.blogs.txt", "data/cleaned/blog_clean.txt")
#cleanFiles("en_us/en_US.news.txt", "data/cleaned/news_clean.txt")


createTableOfCounts <- function(x, id="default") {
    wrds <- table(x)
    df <- data.table(word = names(wrds), count = as.numeric(wrds)) %>%
        mutate(src = id) %>%
        arrange(desc(count)) %>%
        mutate(index = seq_len(length(count)), cum_count = cumsum(count))
}

createNGrams <- function (inFile, outFile, nGramType=2, step=100, progressCount=100000) {
    #con <- file(inFile,"r")
    d <- fread(inFile, sep="\n", header=FALSE)
    end <- length(d$V1)
    cat("the number of lines is ", end, "\n")
    conOut <- file(outFile, "w")
    
    i <- 1
    j <- 1
    msg_cnt <- 1
    while (j < end) {
        j <- i + step
        if (j > end) { j <- end }
        grams <- NGramTokenizer(d$V1[i:j], control=Weka_control(min=nGramType, max=nGramType, dilimeters = " "))
        writeLines(grams, con=conOut)
        i <- i + step + 1
        msg_cnt <- msg_cnt + step
        #cat("msg_cnt = ", msg_cnt, "   progressCount = ", progressCount, "\n")
        if (msg_cnt >= progressCount) {
            cat(j, " lines have been processed", "\n")
            msg_cnt <- 1
        }
    }
    close(conOut)
}

library(RWeka)
#d <- fread("data/cleaned/twitter_1_clean.txt", sep="\n", header=FALSE)
#bigrams <- NGramTokenizer(d, control=Weka_control(min=2, max=2, dilimeters = " "))
#rm(d)
#writeLines(bigrams, "data/tables/bigrams_twit_1.txt")
createNGrams("data/cleaned/twitter_2_clean.txt", "data/temp/bi_twit_2.txt", nGramType = 2,progressCount = 10000)
bigrams <- fread("data/temp/bi_twit_2.txt", sep="\n", header=TRUE)
bi_table2 <- createTableOfCounts(bigrams, "twitter")
write.table(bi_table2, "data/tables/t_bigram_twit_2.txt")
save(bi_table, file="data/tables/t_bi_twit_1.RData")  # save as an R object
rm(bigrams)

trigrams <- fread("data/temp/tri_twit_1.txt", sep="\n", header=TRUE)
tri_table2 <- createTableOfCounts(trigrams, "twitter")
save(tri_table2, file="data/tables/t_tri_twit_2.RDdata")
write.table(tri_table2, "data/tables/t_trigram_twit_2.txt")
rm(trigrams)

gc()

