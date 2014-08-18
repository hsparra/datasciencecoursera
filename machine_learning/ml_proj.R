library(caret)
library(psych)

# if doing multi-core
library(doMC)
registerDoMC(2)

#
# Read in training data
#data <- read.csv("data/pml-training.csv",stringsAsFactors=F)
data <- read.csv(unz("data/pml-data.zip","pml-training.csv"),stringsAsFactors=F)
#test <- read.csv(unz("data/pml-data.zip","pml-testing.csv"),stringsAsFactors=F)


# remove time and person columns
data <- data[, -c(1:7)]
# Split training dataset so have another test dataset
inTrain <- createDataPartition(y=data$classe, p=0.7, list=FALSE)
train <- data[inTrain,]
test <- data[-inTrain,]


## Select subset for initial testing so does not take so long to iterate
#set.seed(260)
#train.sm <- train[sample(nrow(train), size=2000, replace=FALSE),]

# Check for zero covariates and remove
nsv <- nearZeroVar(train)
train <- train[,-nsv]

# function to check for excessive NAs for a variable and remove
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

lotsNas <- naCheck(train, .95)
train <- train[,-lotsNas$colNum]

# Remove non-numeric columns, Note: could convert instead
colsOfType <- function (df, type) {
  x <- integer()
  for (i in 1:length(df)) {
    if (class(df[,i]) == type)
      x <- append(x, i)
  }
  x
}

colsToRemove <- colsOfType(train, "integer")
train <- train[,-colsToRemove]

# make resonse a factor
train$classe <- as.factor(train$classe)

# Look for high correlations and remove
m <- abs(cor(train[,-28]))
diag(m) <- 0
rowsLittleCor <- row.names(m)[m[,dim(m)[2]] > .8]
train <- train[,!(colnames(train) %in% rowsLittleCor[-length(rowsLittleCor)])]


## ~~~~~~~~~~~~~~~ Create model ~~~~~~~~~~~~~~~~~~ 
# Random Forest 
modFit <- train(classe ~ ., data=train, method="rf", prox=TRUE)

#test.sm <- test[sample(nrow(test), size=300, replace=FALSE),]
# Remove same columns as removed on training data
test <- test[,-nsv]
test <- test[,-lotsNas$colNum]
test <- test[,-colsToRemove]
test$classe <- as.factor(test$classe)

pred <- predict(modFit, test); 
test$predRight <- pred == test$classe
table(pred, test$classe)
sum(test$predRight)/length(test$predRight)
confusionMatrix(pred, test$classe)
qplot(pred, test$classe, colour=test$classe) + geom_jitter()

## Do with train control
ctrl<- trainControl(method="repeatedcv",repeats=5, allowParallel=T)
modFit.tc <- train(classe ~ ., data=finalTrain, method="rf", trControl=ctrl)
pred.tc <- predict(modFit.tc, test.sm); 
table(pred.tc, test.sm$classe)
test.sm$predRightTc <- pred.tc == test.sm$classe
sum(test.sm$predRightTc)/length(test.sm$predRightTc)
confusionMatrix(pred.tc, test.sm$classe)

## ~~~ Function to make plot comparing multiple columns to a given column  ~~~~~~ ##
multBoxPlot <- function(df, compareColumn) {
  y <- df[,compareColumn]
  for (i in names(df)[!names(df) %in% compareColumn]) {
    x <- df[,i]
    fileName <- paste("images/",compareColumn, "_", i, ".png",sep="")
    png(file=fileName, width=400, height=400)
    print(qplot(y, x, geom="boxplot"))
    dev.off()
  }
  #p <- qplot(df[,compareColumn], df)
}

