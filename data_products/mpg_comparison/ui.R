#
library(shiny)

shinyUI(fluidPage(
  #titlePanel("EV Explorer"),
  title = "EV Explorer",
  h2("EV Explorer"),
#   p("Use this app to compare different characteristics of some recent and no recent electric vehicles."),
#   plotOutput("plot1"),
#   fluidRow(
#     column(3, 
#            selectInput("y", "Y", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"), selected="range")
#            ),
#    column(3, 
#           selectInput("x", "X", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"),selected="lbs")
#           ),
#    column(3,
#           selectInput("color","Color", c("year","make","class"),selected="year"),
#           checkboxInput("names",label="Show Model Names"),
#           checkboxInput("recent",label="Show Only Recent")
#           )
#     )
  
  sidebarLayout(
    sidebarPanel(
      
#       htmlOutput("make"),
#       htmlOutput("model")
      h4("First Car to Compare:"),
      selectInput("makeSel","Make","",selectize=F),
      selectInput("modelSel","Model","",selectize=F),
      h4("Second Car to Compare:"),
      selectInput("makeSel2","Make","",selectize=F),
      selectInput("modelSel2","Model","",selectize=F),
      
      h4("Average Daily Commute"),
      sliderInput("daily_com","",min=1, max=100, value=40),
      
      h4("Fuel Prices"),
      sliderInput("gas_price","Price of 1 Gallon on Gas",
                  min=2.5, max=5.0, value=3.5, step=.05),
      sliderInput("el_price", "Price of 1 kwh of Electricity", 
                        min=0.02, max=0.4, value=.12, step=.01)
      
#       htmlOutput("colorSelect"),
#       submitButton("Submit")
#       h4("Selected X:"),verbatimTextOutput("text1")
#       selectInput("y", "Y", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"), selected="lbs"),
#       selectInput("x", "X", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"),selected="range"),
#       selectInput("color","Color", c("year","make","class"),selected="year"),
#       checkboxInput("names",label="Show Model Names")
#       submitButton("Submit")
      ),
    mainPanel(
      plotOutput("plot1")
      )
    )
  ))