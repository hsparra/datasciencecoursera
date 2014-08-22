library(shiny)
library(ggplot2)
source("epa_helpers.R")

epa <- read.csv("data/EPA_EV_Data.csv",header=T,stringsAsFactors=F)
epa$year <- as.factor(epa$Year)



shinyServer(
  function(input, output, session) {
    # Combine the selected variables into a new data frame
#     selectedData <- reactive({
#       if (input$recent == FALSE)
#         data2
#       else
#         data2[data2$year %in% c("2009","2010","2011","2012","2013","2014"),]
#     })

    
    observe({
      models <- epa[epa$Make==input$makeSel,"Model"]
      models2 <- epa[epa$Make==input$makeSel2,"Model"] 
      updateSelectInput(session, "makeSel", choices = sort(unique(epa$Make)),
                        selected=input$makeSel)
      updateSelectInput(session, "makeSel2", choices = sort(unique(epa$Make)),
                        selected=input$makeSel2)
      updateSelectInput(session, "modelSel", choices = sort(models))
      updateSelectInput(session, "modelSel2", choices = sort(models2))
    })
    
    
    output$plot1 <- renderPlot({
      mods <- character()
      costs <- numeric()
      dailyCommute <-  as.integer(input$daily_com)
      if (input$modelSel > ""){
        mods <- c(input$modelSel)
        epa_data <- epa[epa$Model == input$modelSel,]
        costs <- c(compDailyCost(epa_data, dailyCommute, input$el_price, input$gas_price) * 5)
      }
      if (input$modelSel2 > "") {
        mods <- c(mods, input$modelSel2)
        epa_data <- epa[epa$Model == input$modelSel2,]
        costs <- c(costs, Cost=compDailyCost(epa_data, dailyCommute) * 5)
      }
      
      mods <- c(mods,"Average Car")
      costs <- c(costs, dailyCommute / 23 * 5 * input$gas_price)
      
      out <- data.frame(Model=mods, Cost=costs)
      out$dispCost <- sprintf("$%3.2f",costs)
      if (max(out$Cost) < 40)
          maxY <- 40
      else
          maxY <- max(out$Cost) + 5
      ggplot(out, aes(x=Model, y=Cost, fill=Model)) + geom_bar(stat="identity") + 
        geom_text(aes(label=dispCost), vjust=1.5, colour="white") +
        ggtitle("Weekly Fuel Cost") + ylim(0,maxY)
    })
  
})