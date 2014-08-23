#
library(shiny)

shinyUI(fluidPage(
  title = "EV Explorer",
  titlePanel("EV Explorer - Compare Weekly Commute Fuel Costs"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Select Vehicles to Compare"),
      helpText("Pick up to two EV/plug-in Hybrid models",
               " to compare the weekly fuel costs compared",
               " to the current average US car."),
      h5("First Vehicle to Compare:"),
      selectInput("makeSel","Make","",selectize=F),
      selectInput("modelSel","Model","",selectize=F),
      #p(),
      h5("Second Vehicle to Compare:"),
      selectInput("makeSel2","Make","",selectize=F),
      selectInput("modelSel2","Model","",selectize=F),

      hr(),
      h4("Average Daily Roundtrip Commute"),
      helpText("You can change the daily commute distance to",
               "be how far you drive each weekday. (default to US Average)"),
      sliderInput("daily_com","",min=1, max=120, value=51),
      
      hr(),
      h4("Fuel Prices"),
      helpText("You can change the cost of gas and electricity",
               "to see how that affects the weekly commute",
               "fuel cost. You can get electricity costs from",
               "your power bill (defaulted to US average)."),
      sliderInput("gas_price","Price of 1 Gallon on Gas",
                  min=2.5, max=5.0, value=3.5, step=.05),
      sliderInput("el_price", "Price of 1 kwh of Electricity", 
                        min=0.02, max=0.4, value=.12, step=.01)      
    ),
    
    mainPanel(
      plotOutput("plot1"),
      helpText("* Fuel costs calculated using EPA data for combined MPG for gas",
               "operation and and kWh/100 miles electrical operation.",
               "Assumed no mid-day recharge of battery unless car is a pure EV",
               "and total daily commute is greater than total range of car on one charge."),
      helpText("** Current average US car gets 23 MPG combined.")
    )
    )
  ))