library(shiny)
source("predictor.R")

load("data/match4.RData")
load("data/match3.RData")
load("data/match2.RData")
load("data/decode.RData")

shinyServer(function(input, output, session) {
    observe({
        inPhrase <- input$phrase
        if (is.null(inPhrase)) {
            inPhrase <- ""
        }
        output$guess <- renderText("<em>Predicted next word: </em>")
        if (nchar(inPhrase) > 2 ) {
            pred <- qMatch(isolate(inPhrase), match4, match3, match2, wrds, input$numReturn)
            if (length(pred) == 0) {
                pred <- ""
            }
            outGuess <- ""
            if (length(pred) >= 1) {
                output$resultChoices <- renderUI({
                 radioButtons("choices", "Suggestions", pred[1:length(pred)])
                })
            }
            
            output$suggestionText <- renderText ({
                theChoice <- isolate(input$choices)
                theChoice <- input$choices
                paste(inPhrase, theChoice, sep=" ")
                
            })

        }
    })

    observe({
        actn <- input$action
        if (is.null(actn)) return()
        if (actn == 0) return()
        theChoice <- isolate(input$choices)
        inPhrase <- isolate(input$phrase)
        isolate(updateTextInput(session, "phrase", value=paste(inPhrase, theChoice, sep=" ")))            
    })

})