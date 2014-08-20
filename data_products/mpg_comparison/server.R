library(shiny)
library(ggplot2)

data2 <- read.csv("data/electric_cars_addl2.csv",header=T,stringsAsFactors=T)
data2$year <- as.factor(data2$year)
d <- list(Range = "range",
          MPGe = "combined",
          Weight = "lbs",
          Efficience = "kwh.p.100mi",
          Battery = "kwh.t")

shinyServer(
  function(input, output, session) {
    # Combine the selected variables into a new data frame
    selectedData <- reactive({
      if (input$recent == FALSE)
        data2
      else
        data2[data2$year %in% c("2009","2010","2011","2012","2013","2014"),]
    })

    output$plot1 <- renderPlot({
      
      p <- ggplot(selectedData(), aes_string(x=input$x, y=input$y)) + 
        geom_point(aes_string(size=3, color=input$color)) 
#       + geom_text(aes(vjust=-2, label=model)) 
       if (input$names == TRUE)
         p <- p + geom_text(aes(vjust=-2, label=model)) 
      p #print(p)
    })
    
#   output$xSelect <- renderUI({
#     selectInput("x","X Axis",names(d),selected="Range")
#   })
#   output$ySelect <- renderUI({
#     selectInput("z","Y Axis 2",names(d),selected="Weight")
#   })
#   output$colorSelect <- renderUI({
#     selectInput("c","Variable To Color With",names(data))
#   })

  
  
})