source("misc/predictor_old.R")
source("capstone_shinyApp/predictor.R")

# load("data/tables/_rweka/match4gram_gte7.RData")
# load("data/tables/_rweka/match3grams_gt6.RData")
# load("data/tables/_rweka/match2gram_gt5_80prct.RData")
# load("data/tables/_rweka/decode.RData")
load("capstone_shinyApp/data/match2.RData")
load("capstone_shinyApp/data/match3.RData")
load("capstone_shinyApp/data/match4.RData")
load("capstone_shinyApp/data/decode.RData")

load("data/tables/_rweka/word_counts.RData")
tot_wrds <- sum(wrd_cnts$count)
match2[,logp := log(wrd_cnts[wrds[V2], count]/tot_wrds)]
match3[,logp := log(wrd_cnts[wrds[V3], count]/tot_wrds)]
match4[,logp := log(wrd_cnts[wrds[V4], count]/tot_wrds)]

test <- fread("data/split/news_9.txt", sep="\n", header=FALSE, skip = 25000, nrows=500)

test2 <- test[1:300]

batchTestWithSummary(test2, 3, qMatch)   # ties by stopwords, -ratio, logp
batchTestWithSummary(test2, 3, qMatch2)  # ties by -ratio
batchTestWithSummary(test2, 3, qMatch3)  # ties by logp, -ratio

testAndShowResults(start=10,end=15)


batchTestWithSummary <- function(test2, maxToReturn = 3, FUN) {
    temp <- sapply(test2, strsplit, split= " ")
    tst_ans <-  sapply(temp, last)
    tst_ans <- gsub("[[:punct:]]", "", tst_ans)
    
    tst_input <- sapply(temp, allButLast)
    
    system.time(predictions <- sapply(tst_input, FUN, match4, match3, match2, wrds, maxToReturn))
    
    names(predictions) <- NULL
    dt <- data.table(pred=predictions, ans=tst_ans)
    first_pred <- character(0)
    for (i in 1:dim(dt)[1]) {
        dt$match[i] <- dt$ans[i] %in% unlist(dt$pred[i])
        first_pred <- append(first_pred, unlist(dt$pred[i])[1])
    }
    
    correct_exact <- sum(first_pred == tst_ans, na.rm=TRUE)
    # correct_exact <- sum(predictions == tst_ans, na.rm=TRUE)
    correct <- sum(dt$match)
    cat("4-gram prediction results:", "\n",
        "  single correct:", correct_exact, "\n",
        "  percent singe: ", correct_exact/length(predictions), "\n",
        "  correct in 3:", correct, "\n",
        "  percent in 3:", correct/length(predictions), "\n")
}


testAndShowResults <- function(start=1, end=10, nToShow=3) {
    n <- end - start + 1
    df <- data.frame(pred = character(n), ans = character(n), stringsAsFactors=FALSE)
    j <- 0
    for (idx in start:end) 
    {
        j = j + 1
        str <- tst_input[idx]
        ans <- tst_ans[idx]
        y <- cleanTextForMatch(str)
        x <- match(y, wrds)
        df$pred[j] <- qMatch(str, match4_sm, match3_sm, match2, wrds, maxToReturn = nToShow) %>% unlist %>% na.omit %>% toString
        df$ans[j] <- ans
    }
    df$input <- tst_input[start:end]
    print(df)
}


# 4 gram matching
y <- cleanTextForMatch(tst_input[2])
x <- match(y, wrds)
n <- length(x)
z <- match4_sm[V3 == x[n]]
z1 <- z[V2 == x[(n-1)]]
z2 <- z1[V1 == x[(n-2)]]

w <- match3_sm[V2 == x[n]]
w1 <- w[V1 == x[(n-1)]]


# 4-gram prediction
# system.time(predictionsÇΩ_exact <- sapply(tst_input, q4Match, matchTable, wrds, maxToReturn=3))
# names(predictions_exact) <- NULL
system.time(predictions <- sapply(tst_input, q4Match, matchTable, wrds, maxToReturn=3))
names(predictions) <- NULL

dt <- data.table(pred=predictions, ans=tst_ans)
# dt <- dt[, match := (ans %in% unlist(pred))]
first_pred <- character(0)
for (i in 1:dim(dt)[1]) {
    dt$match[i] <- dt$ans[i] %in% unlist(dt$pred[i])
    first_pred <- append(first_pred, unlist(dt$pred[i])[1])
}

# dt <- dt[,match := pred == ans]
correct_exact <- sum(first_pred == tst_ans, na.rm=TRUE)
correct <- sum(dt$match)
cat("4-gram prediction results:", "\n",
    "  single correct:", correct_exact, "\n",
    "  percent singe: ", correct_exact/length(predictions), "\n",
    "  correct in 3:", correct, "\n",
    "  percent in 3:", correct/length(predictions), "\n")


# 3-gram prediction
system.time(predictions2 <- sapply(tst_input, triMatch, trigrams, wrds2, n=1))
names(predictions2) <- NULL
correct2 <- match(predictions2, tst_ans) %>% na.omit %>% length
cat("3-gram prediction results:", "\n",
    "  correct:", correct2, "\n",
    "  percent:", correct2/length(predictions2), "\n")


allButLast <- function(x) {
    paste(x[1:(length(x) -1)], collapse=" ")
}


broadMatch <- function(inText, matchTable) {
    x <- cleanTextForMatch(inText)
    z <- matchTable[V3 == match(x, wrds)]
    z1 <- z[V2 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z1 <- z[V1 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z <- z[order(-logpV4, -logpAll, -count)]
#     pred <- wrds[z$V4[1]] %>% na.omit
#     pred
}

