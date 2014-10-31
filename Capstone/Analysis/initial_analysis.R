## Initial data exploration
# Notes:
#  - Use tm
#  - Use RWeka for n-grams

# Check on the number of twitter records
readLines("wc -l ../en_US/en_US.twitter.txt")

# Read in a sample of the Twitter Data
# Note: can just use tm directly to read into a corpus done farther on
con <- file("../en_US/en_US.twitter.txt","r")
twit <- readLines(con)
close(con)

# Select a subs
set.seed(10)
to_select <- rbinom(n = length(twit), size = 1, prob=.01)
to_select <- to_select > 0
twit_subset <- twit[to_select]

# Write out to file so can free space
outCon <- file("../small_twitter.txt", "w")
writeLines(twit_subset, con = outCon)
close(outCon)

# Free up memory from full set
rm(twit)

head(twit_subset)

# Replace unicode characters - Not working
twit.sub <- gsub("/\U[0-9a-f]{8}", "" twit.subset)

# Need to handle Unicode characters

# Read into a corpus
library(tm)
#crp <- VCorpus(DirSource("../en_US", pattern="twitter"), readerControl = list(language="en_US"))
crp <- VCorpus(DirSource("..", pattern="twitter"), readerControl = list(language="english"))

# look at the first 10 lines
crp[[1]]$content[100:120]

# Clean up corpus
clean_crp <- tm_map(crp, content_transformer(tolower))   # Will convert proper names to lower case
# Create function to convert passed characters to spaces
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
clean_crp <- tm_map(clean_crp, toSpace, "/|@|\\|")

# getTransformations() lists available options for tm_map
clean_crp <- tm_map(clean_crp, removeNumbers)
# clean_crp <- tm_map(clean_crp, removePunctuation)
clean_crp <- tm_map(clean_crp, removeWords, stopwords("english"))    # Remove english stop words
# remove own stopwords
# clean_crp <- tm_map(clean_crp, removeWords, c("word1", "word2"))
clean_crp <- tm_map(clean_crp, stripWhitespace)

# specific transformations
toString <- content_transformer(function(x, from, to) gsub(from, to, x))
#docs <- tm_map(docs, toString, "harbin institute technology", "HIT")

# get rid of bad words
Need to find a decent list, perhaps: https://github.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words

### Need to remove repeating punctuations
# regex ex. "!{2,}" or "-{2,}"

# Stemp the words - currently receiving error
library(SnowballC)
stemmed <- tm_map(clean_crp, stemDocument)

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
#library(ggplot2)
#ggplot(data=freq[ord], aes()) + geom_density()

only_one <- freq <= 1
sum(only_one)
# or
table(freq)[1]
sum(only_one) / length(freq)   # ~ 70%

more_than_one <- freq[freq > 1]
more_than_one_s <- more_than_one[order(more_than_one, decreasing = TRUE)]
#plot(more_than_one_s)

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


## N-Grams
library(RWeka)