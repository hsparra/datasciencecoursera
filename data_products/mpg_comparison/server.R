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
# 
#     output$plot1 <- renderPlot({
#       
#       p <- ggplot(selectedData(), aes_string(x=input$x, y=input$y)) + 
#         geom_point(aes_string(size=3, color=input$color)) 
# #       + geom_text(aes(vjust=-2, label=model)) 
#        if (input$names == TRUE)
#          p <- p + geom_text(aes(vjust=-2, label=model)) 
#       p #print(p)
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
      if (input$modelSel > ""){
        mods <- c(input$modelSel)
        epa_data <- epa[epa$Model == input$modelSel,]
        costs <- c(compCost(epa_data, as.integer(input$daily_com)))
      }
      if (input$modelSel2 > "") {
        mods <- c(mods, input$modelSel2)
        epa_data <- epa[epa$Model == input$modelSel2,]
        costs <- c(costs, Cost=compCost(epa_data, as.integer(input$daily_com)))
      }
      
      out <- data.frame(Model=mods, Cost=costs)
      ggplot(out, aes(x=Model, y=Cost, fill=Model)) + geom_bar(stat="identity") + 
        geom_text(aes(label=sprintf("$ %3.2f",Cost), vjust=-0.2))
    })
  
})