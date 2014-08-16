library(caret)
library(psych)
#
# Read in training data
data <- read.csv("data/pml-training.csv",stringsAsFactors=F)

# remove time and person columns
data <- data[, -c(1:7)]
# Split training dataset so have another test dataset
inTrain <- createDataPartition(y=data$classe, p=0.7, list=FALSE)
train <- data[inTrain,]
test <- data[-inTrain,]

set.seed(210)
train.sm <- train[sample(nrow(train), size=2000, replace=FALSE),]

# Check for zero covariates
nsv2 <- nearZeroVar(train.sm, saveMetrics = TRUE)
nsv <- nearZeroVar(train.sm)

train.sm <- train.sm[,-nsv]

# function to check for excessive NAs for a variable
naCheck <- function (df, check) {
  y <- character()
  z <- numeric()
  x <- numeric()
  for (i in 1:length(names(df))) {
    w <- sum(is.na(df[,i]))/length(df[,i])
    if (w > check) {
      x <- append(x, i)
      y <- append(y,names(df)[i])
      z <- append(z,w)
    }
  }
  data.frame(colNum=x, colName=y, percent=z, stringsAsFactors=FALSE)
}

lotsNas <- naCheck(train.sm, .95)

train.sm2 <- train.sm[,-lotsNas$colNum]

# Remove non-numeric columns
colsOfType <- function (df, type) {
  x <- integer()
  for (i in 1:length(df)) {
    if (class(df[,i]) == type)
      x <- append(x, i)
  }
  x
}

colsToRemove <- colsOfType(train.sm2, "integer")

train.sm2 <- train.sm2[,-colsToRemove]

# make resonse a factor
train.sm2$classe <- as.factor(train.sm2$classe)

# Look for high correlations and remove
m <- abs(cor(finalTrain[,-28]))
diag(m) <- 0
which(m > .8, arr.ind=T)
#train.sm2 <- train.sm2[, -c("yaw_belt", "gyros_arm_x")]
# find variables with correlation < 0.05 with classe
rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .05]
train.sm3 <- train.sm2[,!(colnames(train.sm2) %in% rowsLittleCor)]

finalTrain <- train.sm2
# try PCA
# TODO - not current working
modelPCA <- train(classe ~ ., method="glm", preProcess="pca", data=finalTrain)
confusionMatrix(test$classe, predict(modelPCA, test))

# Try Tree
modTree <- train(classe ~ ., method="rpart", data=finalTrain)
#modTree <- train(x=answers, y=train.sm,method="rpart")

## The BEST
## TODO - move up higher on final
# Random Forest 
modFit <- train(classe ~ ., data=finalTrain, method="rf", prox=TRUE)

test.sm <- test[sample(nrow(test), size=300, replace=FALSE),]
# Remove same columns as removed on training data
test.sm <- test.sm[,-nsv]
test.sm <- test.sm[,-lotsNas$colNum]
test.sm <- test.sm[,-colsToRemove]

pred <- predict(modFit, test.sm); 
test.sm$predRight <- pred == test.sm$classe
table(pred, test.sm$classe)
qplot(pred, test.sm$classe, colour=test.sm$classe) + geom_jitter()


## Try using Boosting
modBoost <- train(classe ~ ., method="gbm",data=finalTrain, verbose=FALSE)
qplot(predict(modBoost, test.sm), classe, data=test.sm)


## Linear Model - does not work for classification
modLmAll <- train(classe ~ ., data=finalTrain, method="lm")

## lda and naive Bayes - not near Random Forest
modlda <- train(classe ~ ., data=finalTrain, method="lda")
modnb <- train(classe ~ ., data=finalTrain, method="nb")

plda <- predict(modlda, test.sm)
pnb <- predict(modnp, test.sm)

## Random Forest example using IRIS dataset
inT <- createDataPartition(y=iris$Species, p=0.7, list=FALSE)
t <- iris[inT,]
tst <- iris[-inT,]
mFit <- train(Species ~ ., data=t, method="rf",proxy=TRUE)
mFit
p <- predict(mFit, tst)
tst$predRight <- pred == tst$Species
#p <- predict(mFit, tst); tst$predRight <- pred == tst$Species
table(p, tst$Species)
