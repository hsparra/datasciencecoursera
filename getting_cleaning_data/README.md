Samsung Fit Tidy Dataset Creation
=================================

## Introduction
The *run_analsis.md* script creates a tidy dataset *tidied.txt* of the Galaxy S Smartphone accelerometer data consisting of the mean and standard deviation measurements in the data. Additionally, another tidy dataset *averages.txt1* is created that consists of he averages of the tidied values for each variable and activity combinations.

The orignal data came from experiments which recorded the data from volunteers as they wore a Galaxy S II smartphone on their waist as they performed different activities. See the README.txt included with the data for more information.

* Dataset: [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) (63MB)
* Full description site where data is available: [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
* Output
    * **tidied.txt**: This file contains the mean and standard deviation measurements from the orignal data set in three columns (activity, variable, and value).
    * **averages.txt**: This file contains the averages of the variables found in the tidied.txt file. Each row is one of the six activities and each column is one of the variables.

## Processing the Data
**Data Files Used**: Not all data sets were used in the creation of the tidy data sets. For the smartphone accelerometer readings the *X_test.txt* and *X_train.txt* files were used. The files located in the test/Inertial Signals and the train/Inertial Signals were not used. The data in these files can be mapped to the X_test.txt and X_train.txt files.

**Variable Reduction**: The tidy dataset is limited to only the mean and standard deviation variables in the data sets. The variabls that represented these measures were identified and only those variables were kept for further processing. The other variables do not appear in the tidy data.

## For More Information
* For information regarding the details of how the data was processed see the *Codebook.md* file in this directory.
* For more detail on the original data see the README.txt file located at the root level of the data after it has been extracted from the .zip file.
