library(shiny)
source("predictor.R")

# trigrams <- load("../data/tables/trigrams.RData")
trigrams <- readRDS("../data/tables/trigrams.RDS")
wrds <- readRDS("../data/tables/words.RDS")

shinyServer(function(input, output) {
#     observe({
#         inPhrase <- input$phrase
#     })
    trigrams <- readRDS("../data/tables/trigrams.RDS")
    wrds <- readRDS("../data/tables/words.RDS")
    output$guess <- renderText(quickMatch(input$phrase, n=1))
    output$message <- renderText("did a guess")
    output$tbl <- renderText(quickMatch(input$phrase))
})