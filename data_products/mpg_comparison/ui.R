#
library(shiny)

shinyUI(fluidPage(
  #titlePanel("EV Explorer"),
  title = "EV Explorer",
  h2("EV Explorer"),
  p("Use this app to compare different characteristics of some recent and no recent electric vehicles."),
  plotOutput("plot1"),
  fluidRow(
    column(3, 
           selectInput("y", "Y", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"), selected="range")
           ),
   column(3, 
          selectInput("x", "X", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"),selected="lbs")
          ),
   column(3,
          selectInput("color","Color", c("year","make","class"),selected="year"),
          checkboxInput("names",label="Show Model Names"),
          checkboxInput("recent",label="Show Only Recent")
          )
    )
  
#   sidebarLayout(
#     sidebarPanel(
#       
# #       htmlOutput("ySelect"),
# #       htmlOutput("xSelect"),
#       
# #       htmlOutput("colorSelect"),
# #       submitButton("Submit")
# #       h4("Selected X:"),verbatimTextOutput("text1")
#       selectInput("y", "Y", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"), selected="lbs"),
#       selectInput("x", "X", c("range","combined","kwh.t","kwh.p.100mi","lbs","year"),selected="range"),
#       selectInput("color","Color", c("year","make","class"),selected="year"),
#       checkboxInput("names",label="Show Model Names")
# #       submitButton("Submit")
#       ),
#     mainPanel(
#       plotOutput("plot1")
#       )
#     )
  ))