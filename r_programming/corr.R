corr <- function(directory, threshold = 0) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
    
    ## 'threshold' is a numeric vector of length 1 indicating the
    ## number of completely observed observations (on all
    ## variables) required to compute the correlation between
    ## nitrate and sulfate; the default is 0
    
    ## Return a numeric vector of correlations
    
    # Get files in passed directory
    file.list <- list.files(directory, full.names=TRUE)
    
    # Create vector to return, make full size so allocate once. Can return subset greater than threshold.
    # Read each file in list
    # For each file determine if number of complete cases > passed threshold
    # If greater than threashold compute correlation removing NAs and save for return
     
    cors <- numeric(length(file.list))
    i <- 0
    
    for (file in file.list) {
        temp.ds <- read.csv(file)

        if (sum(complete.cases(temp.ds)) >= threshold) {
            i <- i + 1
            cors[i] <- cor(temp.ds$sulfate, temp.ds$nitrate, use="pairwise.complete.obs")
        }
        rm(temp.ds)
    }
    
    if (i > 0) {
        cors.to.return <- cors[1:i]
    } else {
        cors.to.return <- numeric(0)
    }
    
    cors.to.return
}