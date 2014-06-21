Samsung Fit Tidy Dataset Creation
=================================

## Introduction
The data came from experiments involving 30 participants who wore the Samsung Galaxy S II on their waist and performed a series of activities. Data was taken from the accelerometer and the gyroscope and measurements were created. A total of 561 variables were created by the pre-processing. The *run_analsis.md* script creates a tidy dataset *tidied.txt* of the Galaxy S Smartphone accelerometer data consisting of the mean and standard deviation measurement variables in the data. Additionally, another tidy dataset *averages.txt* is created that consists of he averages of the tidied values for each variable and activity combinations.

For more information on the original data and how it was processed see the README.txt.

- Dataset: [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) (63MB)
- Full description site where data is available: [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
- Output
    + **tidied_fit_data.txt**: This file contains the mean and standard deviation measurements from the orignal data set in three columns (activity, variable, and value).
    + **average_activity_values.txt**: This file contains the averages of the variables found in the tidied.txt file. Each row is one of the six activities and each column is one of the variables.

## Instructions
1. Obtin the test data from the links above and place in a directory.
2. Place the run_analysis.R script inthe same directory as the zip file.
3. Run the run_analsysis.R script.

## How Data is Processed
**Data Files Used**: Not all data sets were used in the creation of the tidy data sets. For the smartphone accelerometer readings the *X_test.txt* and *X_train.txt* files were used. The files located in the test/Inertial Signals and the train/Inertial Signals were not used. The data in these files can be mapped to the X_test.txt and X_train.txt files.

**Variable Reduction**: The tidy dataset is limited to only the mean and standard deviation variables in the data sets. The variabls that represented these measures were identified and only those variables were kept for further processing. The other variables do not appear in the tidy data.

**Variable Naming**: The variable names identified in the original data explanation were expanded so that they would more human readable. See the CodeBoook.md file for more detail.

## For More Information
- For information regarding the details of how the data was processed see the *CodeBook.md* file in this directory.
- For more detail on the original data see the README.txt file located at the root level of the data after it has been extracted from the .zip file.
