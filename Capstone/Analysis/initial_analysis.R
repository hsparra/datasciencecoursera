## Initial data exploration

# Check on the number of twitter records
system("wc -l ../en_US/en_US.twitter.txt")

# Read in a sample of the Twitter Data
con <- file("../en_US/en_US.twitter.txt","r")
twit <- readLines(con)
close(con)

# Select a subs
set.seed(10)
to.select <- rbinom(n = length(twit), size = 1, prob=.01)
to.select <- to.select > 0
twit.subset <- twit[to.select]

# Write out to file so can free space
write

head(twit.subset)

# Replace unicode characters
twit.sub <- gsub("/\U[0-9a-f]{8}", "" twit.subset)

# Need to handle Unicode characters

# Read into a corpus
library(tm)
crp <- VCorpus(DirSource("../en_US", pattern="twitter"), readerControl = list(language="en_US"))

# look at the first 10 lines
crp[[1]]$content[1:10]

lower_c <- tm_map(crp, content_transformer(tolower))   # Will convert proper names to lower case