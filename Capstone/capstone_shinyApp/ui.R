library(shiny)

shinyUI(fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),

#     mainPanel(
#             h3("Word Prediciton"),
#             hr(),
#             helpText("Begin typing to see prediction of next word:"),
#             textInput("phrase", "",""),
#             tags$head(tags$style(type="text/css", "#phrase {width: 450px}")),
# 
#             br(),
#             hr(),
#             p(em("Predicted next word:")),
#             span(h3(textOutput("guess")), style="color:green"),
#             
#             br(),
#             hr(),
#             em(textOutput("oText")),
#             htmlOutput("otherGuesses")            
#         )

    fluidRow(
        column(12,
               h3("Word Prediciton"),
               hr()
               )
    ),
    fluidRow(
        column(7,
               helpText("Begin typing to see prediction of next word:"),
               textInput("phrase", "",""),
               tags$head(tags$style(type="text/css", "#phrase {width: 450px}"))
               )
#         column(5,
#               h3(" "),
#               hr(),
#               helpText("Predicted phrase"),
#               wellPanel(
#                 textOutput("outPhrase")
#                 ),
#               
#               )
        ),
    
    fluidRow(
        column(3,
               p(em("Predicted next word:")),
               span(h3(textOutput("guess")), style="color:green")
            ),
        
        column(4,
               em(textOutput("oText")),
               br(),
               htmlOutput("otherGuesses")  
        )
        )
#     fluidRow(
#         column(5,
#                h3(" "),
#                hr(),
#                helpText("Predicted phrase"),
#                wellPanel(
#                    textOutput("outPhrase")
#                )
#                
#         ),
#         
#         column(2,
#                em(textOutput("oText")),
#                br(),
#                htmlOutput("otherGuesses")  
#         )
#         
#         )
    
    
    )
)
