##  Process Galaxy S Smartphone accelerometer data
#
#   This script processes the Galaxy S Smartphone accelerometer data
#   gathered during experiments which recorded the data from volunteers
#   as they wore the phone on their waist and walked up and down stairs.
#   See the README.txt included with the data for more information.
#

## Packages used in this script
library(plyr)

#  Check for files, if they do not exist expand zip file if zip file exists.
if !file.exists("UCI HAR Dataset/") {
    file.exists("UCI HAR Dataset.zip") {
        unz("UCI HAR Dataset.zip")
    } else {
        stop("Data not found. Please run in a directory with the UCI HAR Dataset. ",
             "You do not have to unzip the dataset prior to running.")
    }
}

## Read in training data set and test data sets
#  and remove variables not interested in at this time.
###### TEST - remove limit before submitting
train <- read.table("UCI HAR Dataset/train/X_train.txt", nrow=200)
test <- read.table("UCI HAR Dataset/test/X_test.txt", nrow=200)

#  Read in file with variable names
v <- read.table("UCI HAR Dataset/features.txt")

#  Identify columns to keep by those that contain the characters "mean" or "std"
v$keep <- grepl("mean()", v$V2) | grepl("std()",v$V2) | grepl("meanFreq()",v$V2)

#  add column names
colnames(train) <- v$V2
colnames(test) <- v$V2

#  Remove columns that will not be used further
train <- subset(train, select=v$keep)
test <- subset(test, select=v$keep)

## Now add the activity name to the corresponding row in each data set

#  First read in the activty list names
actv <- read.table("UCI HAR Dataset/activity_labels.txt")

#  Read in the activity labels for the training data set, 
#  get the English decode, then label the training data with the
#  associated activity
labels <- read.table("UCI HAR Dataset/train/y_train.txt", nrow=200)
labels <- join(labels, actv)    # English decode
train$activity <- labels$V2

#  Read in the activity labels for the test data set, 
#  get the English decode, then label the test data with the
#  associated activity
labels <- read.table("UCI HAR Dataset/test/y_test.txt", nrow=200)
labels <- join(labels, actv)
test$activity <- labels$V2

#  Combine the training and test dataset into one dataset
fulldata <- rbind(train, test)

#  For the tidy data set use melt version of the data set.
#  Could have used the unmelted version also.
tidied <- melt(fulldata, id=c("activity"))

#  Write out tidied data set
write.table(tidied, "tidied_fit_data.txt")

#  Get average value for each variable
averages <- dcast(tidied, activity ~ variable,mean)

#  WRite out averages data set
write.table(activity, "average_activity_values.txt")