
pollutantmean <- function(directory, pollutant, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'pollutant' is a character vector of length 1 indicating
  ## the name of the pollutant for which we will calculate the
  ## mean; either "sulfate" or "nitrate".
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return the mean of the pollutant across all monitors list
  ## in the 'id' vector (ignoring NA values)
  
  # Create list of files from id and pad with leading zeroes if needed
  files.to.get <- paste(sprintf("%03d", id), ".csv", sep="")
  
  # Add directory before file so will read in correct location
  files.to.get <- paste(directory, "/", files.to.get, sep="")
  
  # Read in files - apply read.csv function to each file name
  pollutant.data <- sapply(files.to.get, read.csv)

  #
  
}