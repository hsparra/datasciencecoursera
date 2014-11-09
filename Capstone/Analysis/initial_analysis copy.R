## Initial data exploration
# Notes:
#  - Use tm
#  - Use RWeka for n-grams

library(doMC)
registerDoMC(2)

library(SnowballC)
library(tm)
library(ggplot2)
library(magrittr)

# Check on the number of twitter records
system("wc -l ../en_US/en_US.twitter.txt")

createSampleFile <- function(inFile, outFile) {
  con <- file(inFile,"r")
  fullFile <- readLines(con)
  close(con)
  
  to_select <- rbinom(n = length(fullFile), size = 1, prob=.01)
  to_select <- to_select > 0
  file_subset <- fullFile[to_select]
  
  # Write out to file so can free space
  outCon <- file(outFile, "w")
  writeLines(file_subset, con = outCon)
  close(outCon)
  
  # Free up memory from full set
  #rm(fullFile)
}

getFileData <- function(inFile) {
  con <- file(inFile,"r")
  fullFile <- readLines(con)
  close(con)
  print(dim(fullFile))
  fullFile
}

removeNonASCII <- function(x) {
  iconv(x, "UTF-8", "ASCII", sub="")
}

# Create function to convert passed characters to spaces
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
# specific transformations
replaceStringWith <- content_transformer(function(x, from, to) gsub(from, to, x))

cleanCorpus <- function(crp) {
  clean_crp <- tm_map(crp, content_transformer(tolower))   # Will convert proper names to lower case  
  clean_crp <- tm_map(clean_crp, toSpace, "/|@|\\|")
  clean_crp <- tm_map(clean_crp, removeNumbers)
  clean_crp <- tm_map(clean_crp, removePunctuation)
  clean_crp <- tm_map(clean_crp, removeWords, stopwords("english"))    # Remove english stop words
  clean_crp <- tm_map(clean_crp, stripWhitespace)
  clean_crp <- tm_map(crp, stemDocument)
  clean_crp
}

# Create sample files of file
set.seed(10)
createSampleFile("../en_US/en_US.twitter.txt", "../twit_samp.txt")
createSampleFile("../en_US/en_US.blogs.txt", "../blog_samp.txt")
createSampleFile("../en_US/en_US.news.txt", "../news_samp.txt")
gc()

# Read in a sample of the Twitter Data
twit_subset <- getFileData("../twit_samp.txt")

# Read in Twitter Subset
head(twit_subset)

# Replace unicode characters - Not working
twit_subset <- gsub("/\U[0-9a-f]{8}", "" twit_subset)
twit_subset <- na.omit(wf[iconv(wf$word, "UTF-8", "ASCII", sub=""),])
## NEED to Remove WWW. URLs
# Need to handle Unicode characters

# Read into a corpus
crp <- VCorpus(DirSource("..", pattern="twit_samp.txt"), readerControl = list(language="english"))

# look at the first 10 lines
crp[[1]]$content[100:120]
# Clean up corpus
crp <- cleanCorpus(crp)

# Free space
gc()

# or if processing vector
<<<<<<< HEAD
twit_subset <- tolower(twit_subset)
twit_subset <- gsub("/|@|\\|", " ", twit_subset)

# getTransformations() lists available options for tm_map
twit_subset <- gsub([0-9], "", twit_subset)
=======
#twit_subset <- tolower(twit_subset)

# Create function to convert passed characters to spaces
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
clean_crp <- tm_map(clean_crp, toSpace, "/|@|\\|")


# getTransformations() lists available options for tm_map
clean_crp <- tm_map(clean_crp, removeNumbers)

>>>>>>> FETCH_HEAD
# clean_crp <- tm_map(clean_crp, removePunctuation)

# remove own stopwords
# clean_crp <- tm_map(clean_crp, removeWords, c("word1", "word2"))
#docs <- tm_map(docs, replaceStringWith, "harbin institute technology", "HIT")




# get rid of bad words
Need to find a decent list, perhaps: https://github.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words

### Need to remove repeating punctuations
# regex ex. "!{2,}" or "-{2,}"

# Stemp the words
stemmed <- tm_map(crp, stemDocument)

# create a Term Document matrix
dtm <- DocumentTermMatrix(stemmed)
dtm
inspect(dtm[1, 1:10])
dim(dtm)

# Transpose the matrix
tdm <- TermDocumentMatrix(stemmed)
dim(tdm)
inspect(tdm[1:10,1])


# Find fequency of terms (see if same as tdm)
freq <- colSums(as.matrix(dtm))
head(freq)

# Order frequencies and look at most common
ord <- order(freq,decreasing = TRUE)
freq[head(ord)]
# and least commong
freq[tail(ord)] 


# Distribution of terms
head(table(freq), 15)   # notice how many with only 1 occurence 
plot(freq[ord])

# plot most common term frequencies
mostCommon <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
wf <- data.frame(word = names(mostCommon), freq=mostCommon)
subset(wf, freq > 700) %>%
  ggplot(aes(word, freq)) +
  geom_bar(stat="identity") 
#ggplot(data=freq[ord], aes()) + geom_density()

# Get rid of non-ASCII words
wf <- na.omit(wf[iconv(wf$word, "UTF-8", "ASCII"),])
# Add cummulative freq column
wf$cum_freq <- cumsum(wf$freq)

# Add index column to graph
wf$index <- seq_len(dim(wf)[1])

# Plot the frequency distribution to show fast fall-off
subset(wf, index < 1000) %>%
  ggplot(aes(x=index, y=freq)) +
  geom_area()
#  geom_bar(stat="identity") 
#  geom_line()
#  geom_point()


# find how many terms required to cover 50 percent of word instances
fifty_percent <- wf$cum_freq[dim(wf)[1]] * .5
min(which(wf$cum_freq >= fifty_percent))
min(which(wf$cum_freq >= fifty_percent)) / dim(wf)[1]

# find how many terms required to cover 90 percent of word instances
ninety_percent <- wf$cum_freq[dim(wf)[1]] * .9
min(which(wf$cum_freq >= ninety_percent))
min(which(wf$cum_freq >= ninety_percent)) / dim(wf)[1]

# Words that occur more than 1000 times
findFreqTerms(dtm, lowfreq = 1000)
# 20 most common terms
findFreqTerms(dtm, lowfreq = 1000)[1:20]

# Find words with correlation limit with a specific word
findAssocs(dtm, "actual", corlimit = 0.6)

# What percent of the words occur only once
only_one <- wf$freq <= 1
sum(only_one)
# or
table(wf$freq)[1:4]
sum(only_one) / length(freq)   # ~ 70%

more_than_one <- wf[wf$freq > 1,]
#more_than_one_s <- more_than_one[order(more_than_one, decreasing = TRUE)]
#plot(more_than_one_s)
plot(more_than_one$freq)

more_than_one_s_df <- as.data.frame(more_than_one_s)
names(more_than_one_s_df) <- c("freq")
more_than_one_s_df$index <- seq(from = 1, to = length(more_than_one_s_df$freq))
more_than_one_s_df$word <- row.names(more_than_one_s_df)

ggplot(more_than_one_s_df, aes(x=index, y=freq)) + geom_line()
summary(more_than_one_s_df)

## Count number of occurences of word using table function
con <- file("../small_twitter.txt", "r")
wrd_cnt <- table(unlist(lapply(readLines(con), strsplit, "")))
close(con)



## work with small file only
# read and clean up small file
con <- file("../small_twitter.txt")
sm_t <- readLines(con)
close(con)
sm_t <- tolower(sm_t)
sm_t <- gsub("/|@|\\|", " ", sm_t)
sm_t <- gsub("[0-9]", "", sm_t)  # remove numbers
# stemming - want to remove 'ing' from words that match "grep [aeiou].*ing$"
library(tm)
myStopWords <- stopwords(kind = "english")
libarary(tm)
sm_t <- remove_stopwords(sm_t, myStopWords, lines=TRUE)
library(SnowballC)
sm_t <- tokenize(sm_t, lines = TRUE) %>%
    wordStem %>%
    paste(collapse = "") %>%
    strsplit(split = "\n") %>%
    unlist


## N-Grams
crp <- VCorpus(VectorSource(twit_subset), readerControl = list(language="english"))
crp <- cleanCorpus(crp)

library(RWeka)  # <--- Crashes on OS x
#               requires Java 6, install java 6 and intall.package("RWeka", type="source")
bigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=2, max=2))
# NGramTokenizer(txt, Weka_control(min = 2, max = 3, delimiters = " \\r\\n\\t.,;:\"()?!"))
tdm_bigram <- TermDocumentMatrix(stemmed, control=list(tokenizer=bigramTokenizer))
bigram_freq <- as.matrix(tdm_bigram)
bigram_ord <- order(bigram_freq,decreasing = TRUE)
bigram_freq[head(bigram_ord),]
# Notice how many have only one occurence
head(table(bigram_freq),15)
sum(bigram_freq > 1)
bigram_common <- bigram_freq[bigram_ord,]
bigram_wf <- data.frame(word = names(bigram_common), freq=bigram_common)
bigram_wf$cum_freq <- cumsum(bigram_wf$freq)

subset(bigram_wf, freq > 20) %>%
  ggplot(aes(word, freq)) +
  geom_bar(stat="identity") 

# Plot the frequency distribution 
subset(wf, index < 200) %>%
  ggplot(aes(x=index, y=freq)) +
  geom_area()

library(tau)  # see http://www.rdocumentation.org/packages/tau/functions/textcnt
<<<<<<< HEAD
txt <- textcnt(more_than_one_s, method="string", n=2L)  # bigram
=======
words <- textcnt(sm_t, method = "string", n = 1L)   # get words
word_df <- data.frame(word = names(words), counts = unclass(words), size = nchar(names(words)))
#stem

one_gram <- textcnt(more_than_one_s, method="string", n=2L)  # 1-gram
two_gram <- textcnt(more_than_one_s, method="string", n=3L)  # 2-gram
>>>>>>> FETCH_HEAD
#library(ngram)


