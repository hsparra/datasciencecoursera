library(shiny)

shinyUI( fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),
    sidebarLayout(
    
        sidebarPanel(
        h3("Settings"),
        hr(),
        
        helpText("Use slider to adjust the maximum number of predicted words returned."),
        sliderInput("numReturn", "Maximum Number of Suggested Words", min=1, max=4, value=1),
        width=4
        ),

    mainPanel(
        
        helpText("Begin typing to see prediction of next word:"),
        textInput("phrase","",""),
        tags$style(type="text/css", "#phrase {width: 500px"),
        br(),
        actionButton("action", "Add selection to input"),
        uiOutput("resultChoices"),
        
        
        br(),
        br(),
        br(),
        p(em("Phrase with selection added:")),
        wellPanel(
            textOutput("suggestionText")
            ),
        width=8
        )
    )

))
