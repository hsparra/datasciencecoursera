#
library(shiny)

shinyUI(fluidPage(
  title = "EV Explorer",
  h2("EV Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      
      h4("First Car to Compare:"),
      selectInput("makeSel","Make","",selectize=F),
      selectInput("modelSel","Model","",selectize=F),
      h4("Second Car to Compare:"),
      selectInput("makeSel2","Make","",selectize=F),
      selectInput("modelSel2","Model","",selectize=F),

      hr(),
      h4("Average Daily Commute"),
      sliderInput("daily_com","",min=1, max=100, value=40),
      
      hr(),
      h4("Fuel Prices"),
      sliderInput("gas_price","Price of 1 Gallon on Gas",
                  min=2.5, max=5.0, value=3.5, step=.05),
      sliderInput("el_price", "Price of 1 kwh of Electricity", 
                        min=0.02, max=0.4, value=.12, step=.01)      
    ),
    
    mainPanel(
      plotOutput("plot1")
    )
    )
  ))