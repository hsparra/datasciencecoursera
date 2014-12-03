library(shiny)
source("predictor.R")

# trigrams <- load("data/trigrams.RData")
# trigrams <- readRDS("data/tri_sm.RDS")

# load("data/trigrams.RData")
# load("data/decode.RData")
load("data/tri_sm.RData")
trigrams <- tri_sm
rm(tri_sm)
wrds <- readRDS("data/words.rds")

shinyServer(function(input, output) {
    
    observe({
        inPhrase <- input$phrase
#     })
#     trigrams <- readRDS("data/tri_sm.RDS")
#     wrds <- readRDS("data/wrds.RDS")

        if (nchar(isolate(input$phrase)) > 10 ) {
            output$guess <- renderText(triMatch(isolate(input$phrase), trigrams, wrds))
            output$tbl <- renderText(triMatch(isolate(input$phrase), trigrams, wrds))
        }
    })
})