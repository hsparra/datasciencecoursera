library(shiny)
source("predictor.R")

load("data/match4gram.RData")
load("data/match3grams.RData")
load("data/match2gram.RData")
load("data/decode.RData")

shinyServer(function(input, output) {
    observe({
        inPhrase <- input$phrase
        
        if (nchar(input$phrase) > 2 ) {
            pred <- qMatch(isolate(input$phrase), match4_sm, match3_sm, match2, wrds, 4)
            if (length(pred) == 0) {
                pred <- ""
                otherPreds <- ""
            }
            output$guess <- renderText(pred[1])
            otherTextLabel <- ""
            if (length(pred) >= 1) {
                if (length(pred) > 1) {
                    otherTextLabel <- "Other possibilities:"
                    otherPreds <- pred[2:length(pred)]
                } else {
                    otherPreds <- ""
                }
            }
            output$otherGuesses <- renderText(paste("<h5>",otherPreds, collapse="<br>"))
            output$oText <- renderText(otherTextLabel)
        }
    })

})