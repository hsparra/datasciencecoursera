complete <- function(directory, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return a data frame of the form:
  ## id nobs
  ## 1  117
  ## 2  1041
  ## ...
  ## where 'id' is the monitor ID number and 'nobs' is the
  ## number of complete cases
  
  # Create list of files from id and pad with leading zeroes if needed
  files.to.get <- paste(sprintf("%03d", id), ".csv", sep="")
  
  # Add directory before file so will read in correct location
  files.to.get <- paste(directory, "/", files.to.get, sep="")
}