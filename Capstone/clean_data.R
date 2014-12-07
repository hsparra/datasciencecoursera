library(doMC)
registerDoMC(5)
library(tau)
# suppressMessages(library(ggplot2))
suppressMessages(library(magrittr))
suppressMessages(library(tm))
suppressMessages(library(SnowballC))
suppressMessages(library(dplyr))
suppressMessages(library(data.table))
library(RWeka)

# If can do multicore and have plenty of memory
library(parallel)
numCores <- 5       # Number of cores you want to use


# - GENERAL FUNCTIONS - #
# Create another file path for output based upon a given file
createFilePath <- function(inPath, outPath, outSuffix) {
    outF <- paste(outPath,  strsplit(inPath, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub(".txt", outSuffix, x)
    outF
}

getLastWord <- function(in_wrds) {
    last_wrd <- strsplit(in_wrds, split=" ") %>%
        unlist %>%
        last
    last_wrd
}


# - SPLIT FILE FUNCTIONS - #
splitIntoSentences <- function(inFile, outLocation, outPrefix) {
    print(inFile)    # TEST
    inFile <- gsub("//", "/", inFile)
    f_file <- fread(inFile, sep="\n", header=FALSE)
    
    o_data <- strsplit(f_file$V1, split="[.?!] ") %>% unlist
    o_data <- gsub("\n", "", o_data)
    o_data <- o_data[o_data != ""]
    o_data <- o_data[o_data != " "]
    
    o_fname <- strsplit(inFile, split="/") %>% unlist
    o_fname <- o_fname[length(o_fname)]
    out_f <- paste(outLocation, o_fname, sep = "")
    print(out_f)    # TEST
    out_con <- file(out_f, "w")
    writeLines(o_data, out_con)
    close(out_con)
}


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

# library(caret)
set.seed(2014)

splitFile("en_US/en_US.twitter.txt", "data/split/", "twitter", 10)
splitFile("en_US/en_US.blogs.txt", "data/split/", "blogs", 10)
splitFile("en_US/en_US.news.txt", "data/split/", "news", 10)

files <- list.files("data/split/pre_final/", pattern="blogs_", full.names=TRUE)
sapply(files, splitIntoSentences, "data/split/", "blogs")



# - CLEAN FILE FUNCTIONS - #
cleanTextSplitting <- function(data, split=FALSE, stemWords=TRUE, noStemLast=FALSE) {
    d <- unlist(strsplit(data, "[.?!]"))
    sapply(d, cleanPhrase, split, stemWords, noStemLast)
}

cleanText <- function(data, split=FALSE, stemWords=TRUE, noStemLast=FALSE) {
    data <- tolower(data)
    data <- unlist(strsplit(data, split=" "))
    data <- remove_stopwords(data, stopwords())
    data <- gsub("[[:punct:]]", " ", data)
    data <- gsub("[^a-z]", " ", data)
    data <- data[ data != " "]
    if (length(data) <= 1) {
        return("")
    }
    if (noStemLast) {
        lastWord <- data[length(data)]
        data <- data[1:(length(data) - 1)]
    }
    if (stemWords) {
        data <- wordStem(data)
    }
   
    data <- remove_stopwords(data, stopwords())   # Remove stopwords created by stemming
    if (noStemLast) {
        data <- c(data, lastWord)
    }
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

cleanFiles <- function (inFile, outFile, step=1000, progressCount = 10000) {
    #con <- file(inFile,"r")
    data <- fread(inFile, sep="\n", header=FALSE)
    end <- length(data$V1)
    cat("the number of lines in", inFile, "is ", end, "\n")
    conOut <- file(outFile, "w")
    
    i <- 1
    j <- 1
    msg_cnt <- 1
    outData <- as.character()
    while (j < end) {
        j <- i + step
        if (j > end) { j <- end }
        cleaned <- unlist(mclapply(data$V1[i:j], cleanText, TRUE, noStemLast=TRUE, mc.cores=getOption("mc.cores", numCores)))
        cleaned <- cleaned[cleaned != ""]
        writeLines(cleaned, con=conOut)
        i <- i + step + 1
        msg_cnt <- msg_cnt + step
        if (msg_cnt >= progressCount) {
            cat(j, " lines have been processed -", date(),"\n")
            msg_cnt <- 1
        }
    }

    close(conOut)
}

cleanFile <- function(f, step=1000, progressCount=10000) {
    #f <- paste("/data/split/", f, sep="")
    f <- gsub("//", "/", f)
    outF <- paste("data/cleaned/",  strsplit(f, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub(".txt", "_clean.txt", x)
    cleanFiles(f, outF, step, progressCount)
}



# - COUNT AND FREQUENCY FUNCTIONS - #
getWordCounts <- function(file) {
    d <- fread(file, sep="\n",sep2 = " ", header=FALSE)
    d2 <- sapply(d, strsplit, " ") %>% unlist %>% tolower
    d2 <- gsub("[^a-z]", "", d2) %>% data.table
    d3 <- unique(d2[, count := .N, by=V1], by="V1")
    d3 <- d3[V1 != ""]
    d3 <- d3[order(-count)]
}

createTableOfFrequencies <- function(x) {
addCountColumn <- function(x, count_name = "bi_cnt", by_cols = c("V1", "V2")) {
    expr <- parse( text = paste0(count_name, ":=.N"))
    x <- x[, eval(expr), by=by_cols]
    x
}
    n <- names(x)
    x <- x[,bi_cnt := .N, by=c("V1", "V2")]
    wrds <- unique(x[,count := .N, by=n], by=n)
    wrds <- wrds[,ratio := count/bi_cnt]
}

combineCountTables <- function (t1, t2=data.table()) {
    if (dim(t2)[1] == 0) { return(t1)}
    m_cols <- names(t1) %>% function(x) x[1:(length(x) -3)]
    t <- merge(t1, t2, by=m_cols, all = TRUE)
    t[is.na(t)] <- 0
    t_l <- t[, count := count.x + count.y]
    t_l <- t[, bi_cnt := bi_cnt.x + bi_cnt.y]
    t_l <- t[, ratio := count/bi_cnt]
    t_l <- t_l[,-c(4:9), with=FALSE]
    t_l
}

getWordCounts <- function(in_dt, cum_dt = data.table(), last_word_only = FALSE) {
    if (last_word_only) {
        temp <- strsplit(in_dt$V1, split = " ") %>%
            sapply(last) %>%
            data.table
    }  else {
        temp <- as.matrix(in_dt) %>%
            as.vector %>%
            strsplit(split = " ") %>%
            unlist %>%
            data.table
    }
    temp <- temp[,count := .N, by=V1]
    temp <- unique(temp, by="V1")
    if (dim(cum_dt)[1] == 0) {
        cum_dt <- copy(temp)
    } else {
        cum_dt <- merge(cum_dt, temp, all=TRUE, by="V1")
        cum_dt[is.na(cum_dt)] <- 0
        cum_dt <- cum_dt[, count := count.x + count.y]
        cum_dt <- cum_dt[,c(1,4), with=FALSE]
    }
    
    cum_dt
}

read.And.Get.Counts <- function(x, cum_cnts, last_word_only=FALSE) {
    f <- fread(x, sep="\n", header=FALSE)
    getWordCounts(f, cum_cnts, last_word_only)
}


# - NGRAM CREATION FUNCTIONS - #
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
        if (msg_cnt >= progressCount) {
            cat(j, "  lines have been processed", "\n")
            msg_cnt <- 1
        }
    }
    close(conOut)
    cat("All", j, "lines have been processed", "\n")
}

# Create NGrams using only the last portion of line
create3Grams <- function(data) {
    data <- strsplit(data, " ") %>% unlist
    if length(data <= 3) {
        return("")
    }
    out_data <- character(0)
    n <- length(data) - 1
    for (j in n:2) {
        out_data <- append(out_data, paste(data[j-1], data[j], data[length(data)], sep = " "))
    }
    out_data
}

createNGramsFromVector <- function(v, nGramType=2, progressCount=10000) {
    v <- gsub("//", "/", v)
    outF <- paste("data/ngrams/",  strsplit(v, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub("clean", paste(nGramType, "gram", sep=""), x)
    createNGrams(v, outF, nGramType, progressCount)
}

create3GramsFromVector <- function(v, progressCount=10000) {
    v <- gsub("//", "/", v)
    outF <- paste("data/ngrams/",  strsplit(v, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub("clean", "clean_end", x)
    create3GramFromEnd(v, outF, progressCount)
}

create3GramFromEnd <- function(inFile, outFile, progressCount=10000) {
    #con <- file(inFile,"r")
    d <- fread(inFile, sep="\n", header=FALSE)
    end <- length(d$V1)
    cat("the number of lines for file", inFile, "is ", end, "\n")
    cat("out file will be", outFile, "\n")
    conOut <- file(outFile, "w")
    
    i <- 1
    msg_cnt <- 1
    while (i < end) {
        grams <- create3Grams(d$V1[i])
        i <- i + 1
        msg_cnt <- msg_cnt + 1
        if (nchar(grams[1])[1] == 0) { 
            next
        }
        writeLines(grams, con=conOut)
        if (msg_cnt >= progressCount) {
            cat(i, "  lines have been processed", "\n")
            msg_cnt <- 1
        }
    }
    close(conOut)
    cat("All", end, "lines have been processed", "\n")
}



# - COMPRESSION FUNCTIONS - #
compressTableWithWordMapping <- function(t, w) {
    n <- names(t)
    n <- n[1:(length(n)-3)]
    tOut <-t[,(n):= lapply(.SD, match, w), .SDcols=n]
}

addToDecode <- function(dt, out=character(0)) {
    m <- as.matrix(dt)
    w <- as.vector(m)
    if (length(out) == 0) {
        wrds <- unique(w)
    } else {
        wrds <- append(out, setdiff(w, out))
    }
    wrds
}





#### -----  PROCESSING ----- ####



### CLEAN FILES
files <- list.files("data/split/", pattern="blogs.*_[123456].txt", full.names = TRUE)
sapply(files, cleanFile)

# for multicore
# mclapply(files, cleanFile, mc.cores=getOption("mc.cores", numCores))



### CREATE NGRAMS
inF <- c("data/cleaned/blogs_1_clean.txt")
inF <- list.files("data/cleaned/", pattern="(blogs|twitter)_", full.names = TRUE)
sapply(inF, createNGramsFromVector, nGramType=2)
sapply(inF, createNGramsFromVector, nGramType=3)

sapply(inF, create3GramsFromVector)
#files <- list.files("data/ngrams/", pattern="twitter_._2gram", full.names = TRUE)



### CREATE WORD COUNTS
files <- list.files("data/cleaned/", pattern="(blogs|twitter).*.txt", full.names = TRUE)
wrd_cnts <- data.table()
# wrd_cnts <- lapply(files, read.And.Get.Counts, wrd_cnts)  # Returns list with data tables
for (f in files) {
    cat("processing file:", f, date(), "\n")
    wrd_cnts <- read.And.Get.Counts(f, wrd_cnts)
}
save(wrd_cnts, file="data/tables/word_counts.RData")

# get count of last word in sentences
last_wrds <- data.table()
for (f in files) {
    cat("processing file:", f, date(), "\n")
    last_wrds <- read.And.Get.Counts(f, last_wrds, last_word_only=TRUE)
}
save(last_wrds, file="data/tables/last_word_counts.RData")



# CREATE DECODE TABLE
# Note: Do not need to do if have word counts table (can use first column)
# Only need to process the bigram files since they already contain all the words
files <- list.files("data/ngrams/", pattern="(blogs|twitter).*2gram.txt", full.names = TRUE)
wrds <- character(0)
for (f in files) {
    cat("Processing file:", f, "\n")
    dt <- fread(f, header=FALSE)
    #dt <- createMatchTable(dt)
    wrds <- addToDecode(dt, wrds)
}
save(wrds, file="data/tables/decode.RData")
rm(dt)
gc()




# CREATE COUNT TABLES AND COMPRESS
files <- list.files("data/ngrams/endLine_3grams/", full.names = TRUE)
files <- list.files("data/ngrams/", pattern="_[3456]_",full.names = TRUE)
files <- list.files("data/ngrams/", pattern="(blogs|twitter).*3gram", full.names = TRUE)

for (f in files) {
    cat("Processing file:", f, "\n")
    dt <- fread(f, header=FALSE)
    dt <- createTableOfFrequencies(dt)
    dt <- compressTableWithWordMapping(dt, wrds)
    outF <- createFilePath(f, outPath = "data/tables/", outSuffix = ".RData")
    varN <- paste(strsplit(f, split="/") %>% unlist %>% last, sep="") %>% 
        function(x) gsub(".txt", "", x)
    l <- list(varN = dt)
    save(l, file=outF)
}




# CREATE COMBINED TABLE FOR MATCHING
files <- list.files("data/tables/", pattern="blogs.*RData", full.names=TRUE) 
files <- list.files("data/tables/", pattern="_1_2gram.RData", full.names=TRUE) 
files <- list.files("data/tables/", pattern="_2gram.RData", full.names=TRUE)
files <- list.files("data/tables/", pattern="_3gram.RData", full.names=TRUE)

outDt <- data.table()
for (f in files) {
    cat("Processing file:", f, "  ", date(), "\n")
    load(f)
    dt <- l[[1]]
    outDt <- combineCountTables(dt, outDt)
}

bigrams <- outDt   # when bigrams
save(bigrams, file="data/tables/bigrams_1.RData")

trigrams <- outDt   # when trigrams
save(trigrams, file="data/tables/trigrams.RData")


### Reduce data used

## TO DO ##



gc()




#### -----  DEPRECATED CODE SECTION  ----- ####

####   deprecated Clean txt calls
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

#Deprecated
createTableOfCounts <- function(x, id="default") {
    
    df <- createTableOfFrequencies(x) %>%
        mutate(src = id) %>%
        arrange(desc(count)) %>%
        mutate(index = seq_len(length(count)), cum_count = cumsum(count))
}

# Deprecated
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

# Deprecated
for (f in list.files("data/cleaned/", pattern = "twitter", full.names = data)) {
    cat(date(), "- Processing file", f, "\n")
    outF <- strsplit(f, "/") %>% function(x) x[length(x)] %>%  gsub(".txt", "_clean.txt", x)
    #cleanFiles(paste("data/split/", f, sep=""), paste("data/clean/", outF, sep="") )
}

# Deprecated
createMatchTable <- function(t, dict) {
    require(qdap)
    setkey(t, word)
    t$word <- mgsub(dict$word, dict$id, t$word)
    t
}

# Deprecated
createDictionary <- function(t) {
    wrds <- strsplit(t$word, split =" ") %>% unlist %>% unique 
    dict <- data.table(id = seq_len(length(wrds)), word = wrds)
}

# Deprecated - Crate Ngrams
inF <- c("data/cleaned/blogs_1_clean.txt")
inF <- list.files("data/cleaned/", pattern="_[34]_clean", full.names = TRUE)
sapply(inF, createNGramsFromVector, nGramType=2)
sapply(inF, createNGramsFromVector, nGramType=3)
sapply(inF, createNGramsFromVector, nGramType=4)

# Deprecated
# Use only if having a single table
compressTable <- function(t) {
    wrds <- strsplit(t$word, split=" ") %>% unlist
    dict <- unique(wrds)
    m <- matrix(wrds, ncol=2, byrow=TRUE)
    V1 <- match(m[,1], dict)
    V2 <- match(m[,2], dict)
    tbl <- data.table(w1 = V1, w2 = V2, count = t$count)
    l <- list(tbl, dict)
}


# Deprecated
# get the counts for each
cnts <- data.table(outDt$count)[,.N, keyby=outDt$count][, prcnt := N/sum(N)]

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