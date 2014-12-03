library(shiny)

shinyUI(fluidPage(
    
    titlePanel("Predict the Next Word"),
    

#     sidebarLayout(
#         sidebarPanel(
#         helpText("Enter a phase except for the last word and
#                  see what the app guesses.")
#         ),
    
    mainPanel(
        h3("Phrase to guess:"),
        textInput("phrase", "",""),
        submitButton("Make guess"),
        
        verbatimTextOutput("guess"),
        textOutput("tbl")
        )
    
    ))
