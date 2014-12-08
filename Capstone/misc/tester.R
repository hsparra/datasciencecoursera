source("misc/predictor_old.R")
source("shinyApp/predictor.R")

test <- fread("data/split/blogs_1.txt", sep="\n", header=FALSE, nrow=1000)

test2 <- copy(test[100:200])

temp <- sapply(test2, strsplit, split= " ")
tst_ans <-  sapply(temp, last)
tst_ans <- gsub("[.?!]", "", tst_ans)

tst_input <- sapply(temp, allButLast)

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
    x <- cleanText(inText)
    z <- matchTable[V3 == match(x, wrds)]
    z1 <- z[V2 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z1 <- z[V1 == match(x, wrds)]
    if (dim(z1)[1] > 0) {
        z <- z1
    }
    z <- z[order(-ratio2, -ratio, -logp)]
    pred <- wrds[z$V4[1]] %>% na.omit
    pred
}

