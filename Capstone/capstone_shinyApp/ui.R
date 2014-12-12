library(shiny)

shinyUI( fluidPage(
    
    titlePanel("Coursera Data Science Capstone"),
    sidebarLayout(
    
        sidebarPanel(
        h3("Word Prediciton"),
        hr(),
        sliderInput("numReturn", "Maximum Number of Suggested Words", min=1, max=4, value=1),
        helpText("Begin typing to see prediction of next word:"),
        textInput("phrase", "",""),
#         tags$style(type="text/css", "#phrase {width: 300px; height:100px"),
#         tags$textarea(id="phrase", rows=4, cols=1, ""),
        tags$head(tags$style(type="text/css", "#phrase {width: 450px; height=150px}")),
        uiOutput("resultChoices"),
        width=4
        ),
#     
    mainPanel(
        p(em("Predicted next word:")),
        span(h3(textOutput("guess")), style="color:green"),
        em(textOutput("oText")),
        br(),
        htmlOutput("otherGuesses")  
            )
        )
    )
)

# Back-up
# shinyUI(fluidPage(
#     
#     titlePanel("Coursera Data Science Capstone"),
#     
#     #     mainPanel(
#     #             h3("Word Prediciton"),
#     #             hr(),
#     #             helpText("Begin typing to see prediction of next word:"),
#     #             textInput("phrase", "",""),
#     #             tags$head(tags$style(type="text/css", "#phrase {width: 450px}")),
#     # 
#     #             br(),
#     #             hr(),
#     #             p(em("Predicted next word:")),
#     #             span(h3(textOutput("guess")), style="color:green"),
#     #             
#     #             br(),
#     #             hr(),
#     #             em(textOutput("oText")),
#     #             htmlOutput("otherGuesses")            
#     #         )
#     
#     fluidRow(
#         column(12,
#                h3("Word Prediciton"),
#                hr()
#         )
#     ),
#     fluidRow(
#         column(7,
#                helpText("Begin typing to see prediction of next word:"),
#                textInput("phrase", "",""),
#                tags$head(tags$style(type="text/css", "#phrase {width: 450px}"))
#         )
#         #         column(5,
#         #               h3(" "),
#         #               hr(),
#         #               helpText("Predicted phrase"),
#         #               wellPanel(
#         #                 textOutput("outPhrase")
#         #                 ),
#         #               
#         #               )
#     ),
#     
#     fluidRow(
#         column(3,
#                p(em("Predicted next word:")),
#                span(h3(textOutput("guess")), style="color:green")
#         ),
#         
#         column(4,
#                em(textOutput("oText")),
#                br(),
#                htmlOutput("otherGuesses")  
#         )
#     )
#     #     fluidRow(
#     #         column(5,
#     #                h3(" "),
#     #                hr(),
#     #                helpText("Predicted phrase"),
#     #                wellPanel(
#     #                    textOutput("outPhrase")
#     #                )
#     #                
#     #         ),
#     #         
#     #         column(2,
#     #                em(textOutput("oText")),
#     #                br(),
#     #                htmlOutput("otherGuesses")  
#     #         )
#     #         
#     #         )
#     
#     
# )
# )