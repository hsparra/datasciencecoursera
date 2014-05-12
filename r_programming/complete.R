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

  
  # Preallocate dataframe so more efficient. Make each column numeric.
  # Base size on number of files to read since each file only contains data for one site/id
  # Note: not really important for this assignment but doing for experience

  # Split out length computation so more clear for others
  len <- length(files.to.get)
  num.of.obs.by.site <- data.frame(id=numeric(len), nobs=numeric(len))
  # Create variable to use to keep track of which row working with in file list
  i <- 0
  
  # Read into files, as record number of full observations for each site
  for (file in files.to.get) {
    temp.ds <- read.csv(file)
    i = i + 1
    # Used passed site for id, could use the id value from the first data row from file which would be more error proof
    num.of.obs.by.site$id[i] <- id[i]
    # Count the number of complete observations for the site
    num.of.obs.by.site$nobs[i] <- sum(complete.cases(temp.ds))
    rm(temp.ds)  
  }
  num.of.obs.by.site
}