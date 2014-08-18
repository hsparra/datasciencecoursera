library(caret)
library(psych)

# if doing multi-core
library(doMC)
registerDoMC(3)


#
# Read in training data
#data <- read.csv("data/pml-training.csv",stringsAsFactors=F)
data <- read.csv(unz("data/pml-data.zip","pml-training.csv"),stringsAsFactors=F)
unlink("data/pml-data.zip")

# remove time and person columns
data <- data[, -c(1:7)]
# Split training dataset so have another test dataset
inTrain <- createDataPartition(y=data$classe, p=0.7, list=FALSE)
train <- data[inTrain,]
test <- data[-inTrain,]

## Select subset for initial testing so does not take so long to iterate
set.seed(260)
train.sm <- train[sample(nrow(train), size=2000, replace=FALSE),]
#train.sm <- data[, -c(1:7)]

# Check for zero covariates and remove
nsv2 <- nearZeroVar(train.sm, saveMetrics = TRUE)
nsv <- nearZeroVar(train.sm)
train.sm <- train.sm[,-nsv]

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

lotsNas <- naCheck(train.sm, .95)
train.sm2 <- train.sm[,-lotsNas$colNum]

# Remove non-numeric columns, Note: could convert instead
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
m <- abs(cor(train.sm2[,-28]))
ft <- train.sm2
ft$classe <- as.numeric(ft$classe)
#m <- abs(cor(ft))   # Seems results not as good, but close. 

diag(m) <- 0
which(m > .8, arr.ind=T)
## Note: reduced accuracy of results
#train.sm2 <- train.sm2[, -which(names(train.sm) %in% c("yaw_belt", "gyros_arm_x"))]

# find variables with correlation < 0.05 with classe and remove
## Keep - results in better prediction on "test" dataset
## TODO
#   - Try > .8
#   - switch back to using the original m and < .05  # Predicted 92.x% on test dataset
#rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .02]  # Predicted 92.3% on test dataset
rowsLittleCor <- row.names(m)[m[,dim(m)[2]] > .8]   # Predicted 92.7 % of test dataset - confusion matrix 95.7% accuracy
#m <- abs(cor(ft))   # Seems results not as good, but close. 
#rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .02]  # Not correlated with classe - confusion matrix 95% on test dataset - 17 variables
#rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .01]  # confusion matrix 95.3% - 23 variables
train.sm3 <- train.sm2[,!(colnames(train.sm2) %in% rowsLittleCor[-length(rowsLittleCor)])]

finalTrain <- train.sm2
finalTrain <- train.sm3

## Cross Validate predicted performance using rfcv()


## ~~~~~~~~~~~~~~~ Create model ~~~~~~~~~~~~~~~~~~ 
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
sum(test.sm$predRight)/length(test.sm$predRight)
confusionMatrix(pred, test.sm$classe)
qplot(pred, test.sm$classe, colour=test.sm$classe) + geom_jitter()

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

