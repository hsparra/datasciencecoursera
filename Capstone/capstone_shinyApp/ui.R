library(shiny)

shinyUI(fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),

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

#     fluidRow(
#         column(12,
#                h3("Word Prediciton"),
#                hr()
#                )
#         ),
#     
#     fluidRow(
#         column(6,
#                helpText("Begin typing to see prediction of next word:"),
#                textInput("phrase", "",""),
#                tags$head(tags$style(type="text/css", "#phrase {width: 450px}"))
#             ),
#         column(6,
#                p(em("Predicted next word:")),
#                span(h3(textOutput("guess")), style="color:green"),
#                
#                hr(),
#                em(textOutput("oText")),
#                htmlOutput("otherGuesses")  
#                )
#         )
    
    
    )
)
