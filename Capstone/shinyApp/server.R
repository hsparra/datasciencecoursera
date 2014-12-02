library(shiny)
source("predictor.R")

# trigrams <- load("data/trigrams.RData")
# trigrams <- readRDS("data/tri_sm.RDS")
# wrds <- readRDS("data/wrds.RDS")
load("data/trigrams.RData")
load("data/decode.RData")

shinyServer(function(input, output) {
    observe({
        inPhrase <- input$phrase
#     })
#     trigrams <- readRDS("data/tri_sm.RDS")
#     wrds <- readRDS("data/wrds.RDS")

    if (nchar(isolate(input$phrase)) > 10 ) {
        output$guess <- renderText(quickMatch(isolate(input$phrase), n=1))
        output$message <- renderText("did a guess")
        output$tbl <- renderText(quickMatch(isolate(input$phrase)))
    }
})
})