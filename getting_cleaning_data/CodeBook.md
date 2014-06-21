Code Book for Creating Tidy Data for Samsung Fit Experiment
==============================================

## Source Data
The data comes from experiments carried out with a group of 30 volunteers. Each person performed six activities (walking, walking upstairs, walking downstairs, siting, standing, laying down) wearing a smartphone (Samsung Galaxy S II) on the waist. Data was captured from the smartphones impbedded accelerometer and gyroscope. The experiments were video-recorded and the data was labeled manually. The dataset was randomly split into two sets, where 70% generating the training data and 30% the test data.

The accelerometer and gyroscope sensor signals were pre-processed by applying nose filters. A total of 561 variables were created. Additionally, the data was split with 70% The README.txt and the features_info.txt files contained with the data have more detailed information on the processing that was performed.

## Processing and tranformation process

### Input files
- **X_train.txt** - File with training data of 561 variables
- **y_train.txt** - File containing the corresponding activity id for the X_train.txt data
- **X_test.txt** - File with test data of 561 variables
- **y_test.txt** - File containing the corresponding activity id for the X_test.txt data
- **activity_labels.txt** - File contains the activities and their decodes
- **features.txt** - Contains the names of the 561 variables

### Output files
- **tidied_fit_data.txt** - Tidied data composed of data from the X_train.txt and X_test.txt files
- **average_activity_values.txt** - Has the averages of the variables from the tidied data set for each activity

### Processing
To process the data the training and test data were read in. To identify the columns the *features.txt* file in the data was  used. This file contains a list of variables that comprise the 561 variable vector.

To select the mean and standard deviation amounts, the variable were scanned of the existense of the strings "mean()", "std()", or "meanFrequency()". If any of these strings appeared in variable name then that variable was kept for further processesing. The remaining variables were removed from the data set. This reduced the number of variabls to 79 and helped improve memory usage and reduced the total processing time for later steps. 

The variable names were expanded using a function that took the components of the variable names and expanded them into full words. The full words were seperated by a period, ".", to make them more readable. The usage of a period as a separater is a common pattern found in the R community. The expanded variable names were the used as the column names.

The identity of the activity associated with each observation was located in the *y_train.txt* and *y_test.txt* as a single long vector of the same lenght as the number of rows in the associated data sets, "X_train.txt" and "X_test.txt". The names of the activities were found in the *actities.txt* file. These names were joined with the vector of activities and the resultant vector was used to add a column to the associated test and training data sets. 

The full test and train datasets were then concatentated together and then melted to produce the *tidied.txt* file.

The *averages.txt* file was created by taking the tidied data and applying the dcast() function from the plyr package and specifying to use the mean() function.


## Variables
1. **body.acceleration.average.x.axis** - Average accelerometer reading due to the body along the x-axis for the time step.
2. **body.acceleration.average.y.axis** - Average accelerometer reading due to the body along the y-axis for the time step.
3. **body.acceleration.average.z.axis** - Average accelerometer reading due to the body along the z-axis for the time step.
4. **body.acceleration.standard.deviation.x.axis** - Standard deviation of the accelerometer reading due to the body along the x-axis for the time step.
5. **body.acceleration.standard.deviation.y.axis** - Standard deviation of the accelerometer reading due to the body along the y-axis for the time step.
6. **body.acceleration.standard.deviation.z.axis** - Standard deviation of the accelerometer reading due to the body along the z-axis for the time step.
7. **gravity.acceleration.average.x.axis** - Average of the portion of acceleration along the x-axis due to gravity for the time step.
8. **gravity.acceleration.average.y.axis** - Average of the portion of acceleration along the y-axis due to gravity for the time step.
9. **gravity.acceleration.average.z.axis** - Average of the portion of acceleration along the z-axis due to gravity for the time step.
10. **gravity.acceleration.standard.deviation.x.axis** - Standard deviation of the portion of acceleration along the x-axis due to gravity for the time step.
11. **gravity.acceleration.standard.deviation.y.axis** - Standard deviation of the portion of acceleration along the y-axis due to gravity for the time step.
12. **gravity.acceleration.standard.deviation.z.axis** - Standard deviation of the portion of acceleration along the z-axis due to gravity for the time step.
13. **body.acceleration.jerk.average.x.axis** - Average of computed Jerk along the x-axis due to the body for the time step.
14. **body.acceleration.jerk.average.y.axis** - Average of computed Jerk along the y-axis due to the body for the time step.
15. **body.acceleration.jerk.average.z.axis** - Average of computed Jerk along the z-axis due to the body for the time step.
16. **body.acceleration.jerk.standard.deviation.x.axis** - Standard deviation of computed Jerk along the x-axis due to the body for the time step.
17. **body.acceleration.jerk.standard.deviation.y.axis** - Standard deviation of computed Jerk along the y-axis due to the body for the time step.
18. **body.acceleration.jerk.standard.deviation.z.axis** - Standard deviation of computed Jerk along the z-axis due to the body for the time step.
19. **body.gyroscope.average.x.axis** - Average acceleration measurement  from gyroscope signal along the x-axis due to the body for the time step.
20. **body.gyroscope.average.y.axis** - Average acceleration measurement  from gyroscope signal along the y-axis due to the body for the time step.
21. **body.gyroscope.average.z.axis** - Average acceleration measurement  from gyroscope signal along the z-axis due to the body for the time step.
22. **body.gyroscope.standard.deviation.x.axis** - Standard deviation of acceleration measurement from gyroscope signal along the x-axis due to the body for the time step.
23. **body.gyroscope.standard.deviation.y.axis** - Standard deviation of acceleration measurement from gyroscope signal along the y-axis due to the body for the time step.
24. **body.gyroscope.standard.deviation.z.axis** - Standard deviation of acceleration measurement from gyroscope signal along the z-axis due to the body for the time step.
25. **body.gyroscope.jerk.average.x.axis** - Average computed jerk from gyroscope signal along the x-axis due to the body for the time step.
26. **body.gyroscope.jerk.average.y.axis** - Average computed jerk from gyroscope signal along the y-axis due to the body for the time step.
27. **body.gyroscope.jerk.average.z.axis** - Average computed jerk from gyroscope signal along the z-axis due to the body for the time step.
28. **body.gyroscope.jerk.standard.deviation.x.axis** - Standard deviation of the computed jerk from gyroscope signal along the x-axis due to the body for the time step.
29. **body.gyroscope.jerk.standard.deviation.y.axis** - Standard deviation of the computed jerk from gyroscope signal along the y-axis due to the body for the time step.
30. **body.gyroscope.jerk.standard.deviation.z.axis** - Standard deviation of the computed jerk from gyroscope signal along the z-axis due to the body for the time step.
31. **body.acceleration.magnitude.average** - Average magnitude of the acceleration vector due to the body.
32. **body.acceleration.magnitude.standard.deviation** - Standard deviation of the magnitude of the acceleration vector due to the body.
33. **gravity.acceleration.magnitude.average** - Average magnitude of the acceleration vector due to gravity.
34. **gravity.acceleration.magnitude.standard.deviation** - Standard deviation of the magnitude of the acceleration vector due to the gravity.
35. **body.acceleration.jerk.magnitude.average** - Average magnitude of the computed jerk vector due to the body.
36. **body.acceleration.jerk.magnitude.standard.deviation** - Standard deviation of the magnitude of the computed jerk vector due to the body.
37. **body.gyroscope.magnitude.average** - Average magnitude of the acceleration vector from the gyroscope signal.
38. **body.gyroscope.magnitude.standard.deviation** - Standard deviation of the magnitude of the acceleration vector from the gyroscope signal.
39. **body.gyroscope.jerk.magnitude.average** - Average magnitude of the computed jerk vector from the gyroscope signal.
40. **body.gyroscope.jerk.magnitude.standard.deviation** - Standard deviation of the magnitude of the computed jerk vector from the gyroscope signal.
41. **frequency.body.acceleration.average.x.axis** - Average of the Fast Fourier transform of the acceleration along the x-axis due to the body.
42. **frequency.body.acceleration.average.y.axis** - Average of the Fast Fourier transform of the acceleration along the y-axis due to the body.
43. **frequency.body.acceleration.average.z.axis** - Average of the Fast Fourier transform of the acceleration along the x-axis due to the body.
44. **frequency.body.acceleration.standard.devitation.x.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the x-axis due to the body.
45. **frequency.body.acceleration.stadard.deviation.y.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the y-axis due to the body.
46. **frequency.body.acceleration.standard.deviation.z.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the z-axis due to the body.
47. **frequency.body.acceleration.averageFreq.x.axis** - Mean frequency of the Fast Fourier transform of the acceleration along the x-axis due to the body.
48. **frequency.body.acceleration.averageFreq.y.axis** - Mean frequency of the Fast Fourier transform of the acceleration along the y-axis due to the body.
49. **frequency.body.acceleration.averageFreq.z.axis** - Mean frequency of the Fast Fourier transform of the acceleration along the z-axis due to the body.
50. **frequency.body.acceleration.jerk.average.x.axis** - Mean computed jerk of the Fast Fourier transform of the acceleration along the x-axis due to the body.
51. **frequency.body.acceleration.jerk.average.y.axis** - Mean computed jerk of the Fast Fourier transform of the acceleration along the y-axis due to the body.
52. **frequency.body.acceleration.jerk.average.z.axis** - Mean computed jerk of the Fast Fourier transform of the acceleration along the z-axis due to the body.
53. **frequency.body.acceleration.jerk.standard.deviation.x.axis** - Standard deviation computed jerk of the Fast Fourier transform of the acceleration along the x-axis due to the body.
54. **frequency.body.acceleration.jerk.standard.deviation.y.axis** - Standard deviation computed jerk of the Fast Fourier transform of the acceleration along the y-axis due to the body.
55. **frequency.body.acceleration.jerk.standard.deviation.z.axis** - Standard deviation computed jerk of the Fast Fourier transform of the acceleration along the z-axis due to the body.
56. **frequency.body.acceleration.jerk.averageFreq.x.axis** - Average fequency of computed jerk of the Fast Fourier transform of the acceleration along the z-axis due to the body.
57. **frequency.body.acceleration.jerk.averageFreq.y.axis** - Average fequency of computed jerk of the Fast Fourier transform of the acceleration along the y-axis due to the body.
58. **frequency.body.acceleration.jerk.averageFreq.z.axis** - Average fequency of computed jerk of the Fast Fourier transform of the acceleration along the z-axis due to the body.
59. **frequency.body.gyroscope.average.x.axis** - Average of the Fast Fourier transform of the acceleration along the x-axis from gyroscope signal.
60. **frequency.body.gyroscope.average.y.axis** - Average of the Fast Fourier transform of the acceleration along the y-axis from gyroscope signal
61. **frequency.body.gyroscope.average.z.axis** - Average of the Fast Fourier transform of the acceleration along the z-axis from gyroscope signal.
62. **frequency.body.gyroscope.standard.deviation.x.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the x-axis from gyroscope signal.
63. **frequency.body.gyroscope.standard.deviation.y.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the y-axis from gyroscope signal.
64. **frequency.body.gyroscope.standard.deviation.z.axis** - Standard deviation of the Fast Fourier transform of the acceleration along the z-axis from gyroscope signal.
65. **frequency.body.gyroscope.averageFreq.x.axis** - Mean fequency of the Fast Fourier transform of the acceleration along the x-axis from gyroscope signal.
66. **frequency.body.gyroscope.averageFreq.y.axis** - Mean fequency of the Fast Fourier transform of the acceleration along the y-axis from gyroscope signal.
67. **frequency.body.gyroscope.averageFreq.z.axis** - Mean fequency of the Fast Fourier transform of the acceleration along the z-axis from gyroscope signal.
68. **frequency.body.acceleration.magnitude.average** - Average of Fast Fourier transform of acceleration due to the body.
69. **frequency.body.acceleration.magnitude.standard.deviation** - Standard deviation of Fast Fourier transform of acceleration due to the body.
70. **frequency.body.acceleration.magnitude.averageFreq** - Mean fequency of Fast Fourier transform of acceleration due to the body.
71. **frequency.body.acceleration.jerk.magnitude.average** - Average of Fast Fourier transform of computed jerk due to the body.
72. **frequency.body.acceleration.jerk.magnitude.standard.deviation** - Standard deviation of Fast Fourier transform of computed jerk due to the body.
73. **frequency.body.acceleration.jerk.magnitude.averageFreq**  - Mean fequency of Fast Fourier transform of computed jerk due to the body.
74. **frequency.body.gyroscope.magnitude.average**  - Average of Fast Fourier transform of acceleration from gyroscope signal.
75. **frequency.body.gyroscope.magnitude.standard.deviation**  - Standard deviation of Fast Fourier transform of acceleration from gyroscope signal.
76. **frequency.body.gyroscope.magnitude.averageFreq** - Mean frequency of Fast Fourier transform of acceleration from gyroscope signal.
77. **frequency.body.gyroscope.jerk.magnitude.average** - Average of Fast Fourier transform of computed jerk from gyroscope signal.
78. **frequency.body.gyroscope.jerk.magnitude.standard.deviation** - Standard deviation of Fast Fourier transform of computed jerk from gyroscope signal.
79. **frequency.body.gyroscope.jerk.magnitude.averageFreq** - Mean frequency of Fast Fourier transform of computed jerk from gyroscope signal.
