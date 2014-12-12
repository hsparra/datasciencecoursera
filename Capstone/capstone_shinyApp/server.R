library(shiny)
source("predictor.R")

load("data/match4.RData")
load("data/match3.RData")
load("data/match2.RData")
load("data/decode.RData")

shinyServer(function(input, output) {
    observe({
        inPhrase <- input$phrase
        
        if (nchar(input$phrase) > 2 ) {
            pred <- qMatch(isolate(input$phrase), match4, match3, match2, wrds, 4)
            if (length(pred) == 0) {
                pred <- ""
                otherPreds <- ""
            }
            output$guess <- renderText(pred[1])
            otherTextLabel <- ""
            outGuess <- ""
            if (length(pred) >= 1) {
                outGuess <- paste(input$phrase, pred[1], sep=" ")
                if (length(pred) > 1) {
                    otherTextLabel <- "Other predicted words:"
                    otherPreds <- pred[2:length(pred)]
                } else {
                    otherPreds <- ""
                }
            }
            output$otherGuesses <- renderText(paste("<h5>",otherPreds, collapse="<br>"))
            output$oText <- renderText(otherTextLabel)
            output$outPhrase <- renderText(outGuess)
        }
    })

})