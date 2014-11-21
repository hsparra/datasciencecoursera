library(doMC)
registerDoMC(2)
library(tau)
# suppressMessages(library(ggplot2))
suppressMessages(library(magrittr))
suppressMessages(library(tm))
suppressMessages(library(SnowballC))
suppressMessages(library(dplyr))
suppressMessages(library(data.table))

splitFile<- function(inFile, outLocation, outPrefix, folds = 10) {
    con <- file(inFile,"r")
    f_file <- readLines(con)
    close(con)
    #inFile <- paste("sed 's/\\0\\0//g'", inFile, sep=" ")
    #f_file <- fread(inFile, sep="\n", header=FALSE)
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
splitFile("en_US/en_US.blogs.txt", "data/split/", "blogs", 10)
splitFile("en_US/en_US.news.txt", "data/split/", "news", 10)


cleanText <- function(data, split=FALSE) {
    data <- tolower(data)
    data <- gsub("[[:punct:]]", " ", data)
    data <- gsub("[^a-z]", " ", data)
    data <- unlist(strsplit(data, split=" "))
    data <- remove_stopwords(data, stopwords())
    data <- data[ data != " "]
#    data <- wordStem(data)
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

cleanFiles <- function (inFile, outFile, step=100, progressCount = 10000) {
    #con <- file(inFile,"r")
    data <- fread(inFile, sep="\n", header=FALSE)
    end <- length(data$V1)
    cat("the number of lines in", outFile, "is ", end, "\n")
    conOut <- file(outFile, "w")
    
    i <- 1
    j <- 1
    msg_cnt <- 1
    while (j < end) {
        j <- i + step
        if (j > end) { j <- end }
        cleaned <- sapply(data$V1[i:j], cleanText, TRUE)
        cleaned <- cleaned[cleaned != ""]
        writeLines(cleaned, con=conOut)
        i <- i + step + 1
        msg_cnt <- msg_cnt + step
        #cat("msg_cnt = ", msg_cnt, "   progressCount = ", progressCount, "\n")
        if (msg_cnt >= progressCount) {
            cat(j, " lines have been processed -", date(),"\n")
            msg_cnt <- 1
        }
    }
    close(conOut)
}

cleanFile <- function(f, step=100, progressCount=10000) {
    #f <- paste("/data/split/", f, sep="")
    f <- gsub("//", "/", f)
    outF <- paste("data/cleaned/",  strsplit(f, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub(".txt", "_clean.txt", x)
    cleanFiles(f, outF, step, progressCount)
}

files <- list.files("data/split/", pattern="_[12].txt", full.names = TRUE)
sapply(files, cleanFile)

# If can do multicore and have plenty of memory
library(parallel)
numCores <- 5       # Number of cores you want to use
for (f in list.files("data/split/", pattern = "twitter", full.names = FALSE)) {
    if (grepl("twitter_1.txt", f)) { next }
    
    cat(date(), "- Cleaning file", f, "\n")
    outF <- paste("data/cleaned/", gsub(".txt", "_clean.txt", f), sep="")
    
    data <- fread(paste("data/split/", f, sep=""), sep="\n", header=FALSE)
    cln <- unlist(mclapply(f, cleanText, TRUE, mc.cores=getOption("mc.cores", numCores)))
    
    conOut <- file(outF, "w")
    write(cln, out)
    close(con)
}

#cleanFiles("en_us/en_US.blogs.txt", "data/cleaned/blog_clean.txt")
#cleanFiles("en_us/en_US.news.txt", "data/cleaned/news_clean.txt")

createTableOfFrequencies <- function(x) {
#     wrds <- table(x)
#     data.table(word = names(wrds), count = as.numeric(wrds))
    n <- names(x)
    wrds <- unique(x[,count := .N, by=n], by=n)
}
}

createTableOfCounts <- function(x, id="default") {
    
    df <- createTableOfFrequencies(x) %>%
        mutate(src = id) %>%
        arrange(desc(count)) %>%
        mutate(index = seq_len(length(count)), cum_count = cumsum(count))
}



createNGrams <- function (inFile, outFile, nGramType=2, step=100, progressCount=10000) {
    #con <- file(inFile,"r")
    d <- fread(inFile, sep="\n", header=FALSE)
    end <- length(d$V1)
    cat("the number of lines for file", inFile, "is ", end, "\n")
    cat("out file will be", outFile, "\n")
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
#         cat("msg_cnt = ", msg_cnt, "   progressCount = ", progressCount, "\n")
        if (msg_cnt >= progressCount) {
            cat(j, "  lines have been processed", "\n")
            msg_cnt <- 1
        }
    }
    close(conOut)
    cat("All", j, "lines have been processed", "\n")
}

library(RWeka)

processCleanedFile <- function (inFile, outFile, identifier="none", nGramType=2, progressCount=10000) {
    nGramFile <- paste("data/temp/", outFile, ".txt", sep="")
    createNGrams(inFile, nGramFile, nGramType=2, progressCount)
    grams <- fread(nGramFile, sep="\n", header=FALSE)
    table <- createTableOfCounts(grams, identifier)
    tableFile <-paste("data/tables/t_", outFile, ".txt", sep="")
    write.table(table, tableFile)
    tableObj <- paste("data/tables/t_", outFile, ".RData", sep="")
    save(table, file=tableObj)
}

for (f in list.files("data/cleaned/", pattern = "twitter", full.names = data)) {
    cat(date(), "- Processing file", f, "\n")
    outF <- strsplit(f, "/") %>% function(x) x[length(x)] %>%  gsub(".txt", "_clean.txt", x)
    #cleanFiles(paste("data/split/", f, sep=""), paste("data/clean/", outF, sep="") )
}

createMatchTable <- function(t, dict) {
    require(qdap)
    setkey(t, word)
    t$word <- mgsub(dict$word, dict$id, t$word)
    t
}

createDictionary <- function(t) {
    wrds <- strsplit(t$word, split =" ") %>% unlist %>% unique 
    dict <- data.table(id = seq_len(length(wrds)), word = wrds)
}

compressTable <- function(t) {
    wrds <- strsplit(t$word, split=" ") %>% unlist
    dict <- unique(wrds)
    m <- matrix(wrds, ncol=2, byrow=TRUE)
    V1 <- match(m[,1], dict)
    V2 <- match(m[,2], dict)
    tbl <- data.table(w1 = V1, w2 = V2, count = t$count)
    l <- list(tbl, dict)
}

createNGramsFromVector <- function(v, nGramType=2, progressCount=10000) {
    v <- gsub("//", "/", v)
    outF <- paste("data/ngrams/",  strsplit(v, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub("clean", paste(nGramType, "gram", sep=""), x)
    createNGrams(v, outF, nGramType, progressCount)
}

inF <- c("data/cleaned/blogs_1_clean.txt")
inF <- list.files("data/cleaned/", full.names = TRUE)
sapply(inF, createNGramsFromVector, nGramType=2)

extractUniqueWords <- function(f, lvl=1) {
    # get file
    #f <- fread(f, header=FALSE)
    # create vector of words basd on columns
    #  need to find out to dynamically refrer to columns
    
    w1 <- unique(f$V1)
    if (lvl == 1) { print("works")}
    if (lvl <= 1)  { return(w1) } 
    w1 <- append(w1, setdiff(f$V2, w1))
    if (lvl == 2) { return(w1) }
    w1 <- append(w1, setdiff(f$V3, w1))
    if (lvl == 3) { return(w1) }
    w1 <- append(w1, setdiff(f$V4, w1))
    w1
}


createNGrams("data/cleaned/twitter_1_clean.txt", "data/temp/bi_twit_1.txt", nGramType = 2,progressCount = 10000)
bigrams <- fread("data/temp/bi_twit_1.txt", sep="\n", header=FALSE)
bi_table <- createTableOfCounts(bigrams, "twitter")
write.table(bi_table, "data/tables/t_bigram_twit_1.txt")
save(bi_table, file="data/tables/t_bi_twit_1.RData")  # save as an R object
rm(bigrams)

trigrams <- fread("data/temp/tri_twit_1.txt", sep="\n", header=FALSE)
tri_table2 <- createTableOfCounts(trigrams, "twitter")
save(tri_table2, file="data/tables/t_tri_twit_`.RDdata")
write.table(tri_table2, "data/tables/t_trigram_twit_1.txt")
rm(trigrams)

gc()

