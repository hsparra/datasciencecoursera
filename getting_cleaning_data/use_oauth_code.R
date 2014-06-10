# Simple app to connect to Github and retreive information
# See https://github.com/hadley/httr/blob/master/demo/oauth2-github.r for
# original usage of oauth example

library(httr)
library(httpuv)
library(jsonlite)
# 1. Find OAuth settings for github:
#    http://developer.github.com/v3/oauth/
oauth_endpoints("github")

# 2. Register an application at https://github.com/settings/applications
#    Insert your values below - if secret is omitted, it will look it up in
#    the GITHUB_CONSUMER_SECRET environmental variable.
#
#    Use http://localhost:1410 as the callback url
myapp <- oauth_app("github", 
                   key="your Key here", 
                   secret="your secret here")

# 3. Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# 4. Use API
req <- GET("https://api.github.com/users/jtleek/repos", config(token = github_token))
stop_for_status(req)
req_content <- content(req)

req2 <- jsonlite::fromJSON(toJSON(req_content))

req2$created_at[req2$name == "datasharing"]

## Question 4
#library(httr)
#url <- "http://biostat.jhsph.edu/~jleek/contact.html"
con = url("http://biostat.jhsph.edu/~jleek/contact.html")
htmlCode <- readLines(con)
close(con)
x <- c(10,20,30,100)
nchar(htmlCode[x])

## Question 5
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for", 
              "cpc.for", method="curl")
widths <- c(15,4,9,4,9,4,9,4,4)
temp <- read.fwf("cpc.for", widths=widths, skip=4, stringsAsFactors=FALSE)
sum(temp[,4])