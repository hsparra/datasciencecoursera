
df.from.csv.files <- function(file_list) {
  for (file in file_list) {

    if (!exists("dataset")) {
      dataset <- read.csv(file)
    } else {
      temp.ds <- read.csv(file)
      dataset <- rbind(dataset, temp.ds)
      rm(temp.ds)  
    }
  }

  return(dataset)
}

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

  # Read into files and Combine data into a single dataframe
  all.data <- df.from.csv.files(files.to.get)
  
  # remove rows with an na for the selected pollutant
  pollutant.of.interest <- all.data[pollutant]
  noNAs <- pollutant.of.interest[!is.na(pollutant.of.interest)]
  
  # Compute mean on passed pollutant
  mean(noNAs)

}