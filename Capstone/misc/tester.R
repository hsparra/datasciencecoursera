source(shinyApp/predictor.R)

test <- fread("data/split/twitter_8.txt", sep="\n", header=FALSE)

test2 <- copy(test[1:5])

temp <- sapply(test2, strsplit, split= " ")
tst_ans <-  sapply(temp, last)
tst_ans <- gsub("[.?!]", "", tst_ans)

tst_input <- sapply(temp, allButLast)

predictions <- sapply(tst_input, qMatch)
names(predictions) <- NULL
correct <- match(predictions, tst_ans) %>% na.omit %>% length
cat("correct:", correct, "\n")
cat("percent:", correct/length(predictions), "\n")

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