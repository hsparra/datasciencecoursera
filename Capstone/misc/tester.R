source("misc/predictor_old.R")
source("shinyApp/predictor.R")

load("data/tables/_rweka/match4gram_gte7.RData")
load("data/tables/_rweka/match3grams_gt6.RData")
load("data/tables/_rweka/match2gram_gt5_80prct.RData")
load("data/tables/_rweka/decode.RData")

test <- fread("data/split/blogs_9.txt", sep="\n", header=FALSE, nrows=500)

test2 <- test[1:20]

temp <- sapply(test2, strsplit, split= " ")
tst_ans <-  sapply(temp, last)
tst_ans <- gsub("[[:punct:]]", "", tst_ans)

tst_input <- sapply(temp, allButLast)

system.time(predictions <- sapply(tst_input, qMatch, match4_sm, match3_sm, match2, wrds, maxToReturn=1))

names(predictions) <- NULL
dt <- data.table(pred=predictions, ans=tst_ans)
correct_exact <- sum(predictions == tst_ans, na.rm=TRUE)
cat("4-gram prediction results:", "\n",
    "  single correct:", correct_exact, "\n",
    "  percent singe: ", correct_exact/length(predictions), "\n")


testAndShowResults(1,10)

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


qMatch <- function(inText) {
    x <- cleanText(inText, noStemLast = FALSE)
    z <- matchTable[V3 == match(x, wrds)]
    z1 <- z[V2 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z1 <- z[V1 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z <- z[order(-logV4, -logAll, -count)]
    pred <- wrds[z$V4[1]] %>% na.omit
    pred
}

