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
m <- abs(cor(ft))   # Seems results not as good, but close. 
rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .02]  # Not correlated with classe - confusion matrix 95% on test dataset - 17 variables
rowsLittleCor <- row.names(m)[m[,dim(m)[2]] < .01]  # confusion matrix 95.3% - 23 variables
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
  #otherCols <- df[,-compareColumn]
  y <- df[,compareColumn]
  for (i in names(df)[!names(df) %in% compareColumn]) {
    x <- df[,i]
    fileName <- paste("images/",compareColumn, "_", i, ".png",sep="")
    print(fileName)
    png(file=fileName, width=400, height=400)
    #qplot(df[[compareColumn]], df[[i]], data=df, geom="boxplot") + ylab(i)
    print(qplot(y, x, geom="boxplot"))
    #dev.copy(png, file=paste(compareColumn, "_", i, ".png"))
    dev.off()
  }
  #p <- qplot(df[,compareColumn], df)
}
cols2 <- c("Graphs show as possible good vars","amplitude_pitch_arm","amplitude_pitch_belt","amplitude_pitch_dumbbell",
           "amplitude_pitch_forearm","amplitdue_roll_arm","amplitude_belt_roll","amplitude_roll_dumbbell","amplitude_yaw_arm",
           "amplitude_roll_forearm","amplitude_avg_pitch","avg_pitch_belt","avg_pitch_dumbell","avg_pitch_forearm",
           "avg_roll_dumbbell","avg_roll_forearm","avg_yaw_dumbbell","max_pitch_arm","max_pitch_belt","max_roll_forearm",
           "stddev_roll_belt","stddev_roll_dumbbell","stddev_roll_forearm","stddev_yaw_belt","stddev_yaw_dumbbell",
           "var_accel_arm","var_roll_belt","var_roll_forearm","var_total_accel_belt","var_yaw_dumbbell","var_yaw_forearm","classe")
# Graphs show as possible good vars
# amplitude_pitch_arm  - D
# amplitude_pitch_belt  - E+
# amplitude_pitch_dumbbell - split betwen A&C, B&E, D
# amplitude_pitch_forearm - D
# amplitdue_roll_arm - D+
# amplitude_belt_roll - E+
# amplitude_roll_dumbbell - split groups A&C, B&E&D
# amplitude_yaw_arm - A+
# amplitude_roll_forearm - B&C above a point
# amplitude_avg_pitch - A&D
# avg_pitch_belt - D+
# avg_pitch_dumbell - D&B above a pt, C below a pt
# avg_pitch_forearm - A&E, B&C, D +
# avg_roll_dumbbell - C below a pt
# avg_roll_forearm - C above a pt
# avg_yaw_dumbbell - D+
# max_pitch_arm - split B&E vs A&C&D
# max_pitch_belt - D&E above a pt
# max_roll_forearm - A&E
# stddev_roll_belt - E+
# stddev_roll_dumbbell - A&C vs B&D&E
# stddev_roll_forearm - D+
# stddev_yaw_belt - E
# stddev_yaw_dumbbell - A&C vs B&E vs D
# var_accel_arm - A+
# var_roll_belt - E+
# var_roll_forearm - B
# var_total_accel_belt - E+
# var_yaw_dumbbell - B&E
# var_yaw_forearm


## ~~~~~~~ The rest ~~~~~~~~
# try PCA
# TODO - not current working
modelPCA <- train(classe ~ ., method="glm", preProcess="pca", data=finalTrain)
confusionMatrix(test$classe, predict(modelPCA, test))

# Try Tree
modTree <- train(classe ~ ., method="rpart", data=finalTrain)
#modTree <- train(x=answers, y=train.sm,method="rpart")



## Try using Boosting
modBoost <- train(classe ~ ., method="gbm",data=finalTrain, verbose=FALSE)
qplot(predict(modBoost, test.sm), classe, data=test.sm)


## Linear Model - does not work for classification
modLmAll <- train(as.numeric(classe) ~ ., data=finalTrain, method="lm")

## Linear model using only highest correclated vars
modLmHigh <- train(as.numeric(classe) ~  magnet_dumbbell_z + roll_forearm + roll_arm + yaw_arm + 
                     roll_belt + magnet_forearm_y + pitch_dumbbell, data=finalTrain, method="lm")
modLmHigh <- train(as.numeric(classe) ~  magnet_dumbbell_z + roll_belt + yaw_belt + 
                     gyros_belt_y + 
                     pitch_arm + roll_dumbbell + pitch_dumbbell + yaw_dumbbell +
                     gyros_dumbbell_y + gyros_dumbbell_z + 
                     roll_forearm + pitch_forearm +
                     roll_arm + gyros_arm_x + magnet_forearm_y,
                   data=finalTrain, method="lm")
                   

modLmHigh2 <- lm(as.numeric(classe) ~  magnet_dumbbell_z + roll_forearm + roll_arm + 
                     roll_belt + magnet_forearm_y, data=finalTrain)


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
