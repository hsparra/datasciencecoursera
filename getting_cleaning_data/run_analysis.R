## Process Galaxy S Smartphone accelerometer data
#
#  This script processes the Galaxy S Smartphone accelerometer data
#  gathered during experiments which recorded the data from volunteers
#  as they wore the phone on their waist and walked up and down stairs.
#  See the README.txt included with the data for more information.
#
#  Create a function to read in the data and append - May not be needed
rdfiles <- function(directory) {
    # Get file list of files in passed directory
    filelist <- dir(directory)
    filelist
}

# Read in training data set and test data sets, then combine.
train <- read.table("UCI HAR Dataset/train/X_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt", nrows=1000)

# Read in file with variable names
v <- read.table("UCI HAR Dataset/features.txt")

# Identify columns to keep by those that contain the characters "mean" or "std"
v$keep <- grepl("mean", v$V2) | grepl("std",v$V2) | grepl("Mean",v$V2)

# Remove columns that will not be used further
train <- subset(train, select=v$keep)
test <- subset(test, select=v$keep)

# Now add the activity name to the corresponding row in each data set
# First read in the activty list names
actv <- read.table("UCI HAR Dataset/activity_labels.txt")

# Read in the labels for the training dataset
labels <- read.table("UCI HAR Dataset/train/y_train.txt")

# Add the English decode of the activity value
library(plyr)
labels <- join(labels, actv)

# Add the labels to the training data set
train$actv <- labels$V2

# Do the same for the test data set
labels <- read.table("UCI HAR Dataset/test/y_test.txt")
labels <- join(labels, actv)

# Add the labels to the training data set
test$actv <- labels$V2

# Combine the training and test dataset into one dataset
fulldata <- rbind(train, test)