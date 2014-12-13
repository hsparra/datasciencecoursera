library(shiny)

shinyUI( fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),
    sidebarLayout(
    
        sidebarPanel(
        h4("Begin typing"),
        hr(),
        
        helpText("Begin typing to see prediction of next word:"),
        tags$textarea(id="phrase", rows=5, cols=40, ""),
        sliderInput("numReturn", "Maximum Number of Suggested Words", min=1, max=4, value=1),

        uiOutput("resultChoices"),
        actionButton("action", "Select Suggestion"),
        width=4
        ),

    mainPanel(
        p(em("Your selected phrase:")),
        wellPanel(
            textOutput("suggestionText")
            )
        )
    )
))
