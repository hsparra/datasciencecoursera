#
library(shiny)

shinyUI(fluidPage(
  titlePanel("EV Explorer"),
  sidebarLayout(
    sidebarPanel(
      
#       htmlOutput("xSelect"),
#       htmlOutput("ySelect"),
#       htmlOutput("colorSelect"),
#       submitButton("Submit")
      selectInput("x", "X", c("range","combined","kwh.t","kwh.p.100mi","lbs"),selected="range"),
      selectInput("y", "Y", c("range","combined","kwh.t","kwh.p.100mi","lbs"), selected="lbs"),
      submitButton("Submit")
      ),
    mainPanel(
      plotOutput("graph")
      )
    )
  ))