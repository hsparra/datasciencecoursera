
x <- cleanText(str)

z3 <- matchTable[V4 == match(ans, wrds)]

z <- matchTable[V3 == match(x[length(x)], wrds)]
za <- z[V2 == match(x[(length(x) - 1)], wrds)]
zb <- z[V1 == match(x[(length(x) - 2)], wrds)]

z <- matchTable[V3 == match(x, wrds)]
za <- z[V2 == match(x, wrds)]
zb <- z[V1 == match(x, wrds)]


z1 <- matchTable[V4 == match(ans, wrds)]
z1a <- z1[V1 == match(x[(length(x)-1)], wrds)]

z3 <- z3[order(-ratio)]
answers <- data.table(a1 = wrds[head(z3$V2)])
z3 <- z3[order(-bi_cnt, -count)]
answers <- answers[, a2 := wrds[head(z3$V2)]]
z3 <- z3[order(-count, -ratio)]
answers <- answers[,a3 := wrds[head(z3$V2)]]

x
answers

z1 <- z1[order(-bi_cnt, -ratio)]
wrds[head(z1$V3)]



matchTable <- addCountColumn(matchTable, "v1v2v3", c("V1", "V2", "V3"))
matchTable <- matchTable[,ratio2 := count/v1v2v3]

getPOS <- function(s) {
    sent_token_annotator <- Maxent_Sent_Token_Annotator()
    word_token_annotator <- Maxent_Word_Token_Annotator()
    a2 <- annotate(s, list(sent_token_annotator, word_token_annotator))
    pos_tag_annotator <- Maxent_POS_Tag_Annotator()
    a3 <- annotate(s, pos_tag_annotator, a2)
    a3
}


wrds_sm <- wrd_cnts[count >= 20000]
dim(wrds_sm)
inS <- paste(wrds_sm$V1, collapse=" ")
system.time(y <- getPOS(inS))

wrds_sm <- wrd_cnts[count >= 5000]
dim(wrds_sm)
inS <- paste(wrds_sm$V1, collapse=" ")
system.time(y <- getPOS(inS))


wrds_sm <- wrd_cnts[count >= 200]
dim(wrds_sm)
inS <- paste(wrds_sm$V1, collapse=" ")
system.time(y <- getPOS(inS))



## DISTRIBUTION of logp for all
require(ggplot2)
x <- seq(from = -20, to=-70, by=-1)
log_grps <- table(cut(matchTable2$logpAll, x))
df <- data.frame(log_grps)
df$val <- sort(x)[1:50]
ggplot(df, aes(x=val, y=Freq)) + geom_point()



# DISTRIBUTION of logpV3 to logpAll
matchTable2[, pV4_over_All := logpV4/logpAll]
x <- seq(from=.05, to=.55, by=.01)
v4Ratio <- table(cut(matchTable2$pV4_over_All, x))
df2 <- data.frame(v4Ratio)
df2$val <- x[1:50]
ggplot(df2, aes(x=val, y=Freq)) + geom_point()
