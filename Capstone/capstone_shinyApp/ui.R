library(shiny)

shinyUI(fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),
    

#     sidebarLayout(
#         sidebarPanel(
#         helpText("Enter a phase except for the last word and
#                  see what the app guesses.")
#         ),
    
    mainPanel(
            h3("Word Prediciton"),
            hr(),
            helpText("Begin typing to see prediction of next word:"),
            textInput("phrase", "",""),
            tags$head(tags$style(type="text/css", "#phrase {width: 450px}")),

            br(),
            hr(),
            p(em("Predicted next word:")),
            span(h3(textOutput("guess")), style="color:green"),

            hr(),
            em(textOutput("oText")),
            htmlOutput("otherGuesses")
            
        )
    
    ))
