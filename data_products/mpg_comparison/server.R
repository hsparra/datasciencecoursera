library(shiny)
library(ggplot2)

data2 <- read.csv("data/electric_cars_addl2.csv",header=T,stringsAsFactors=F)

shinyServer(
  function(input, output, session) {
    # Combine the selected variables into a new data frame
    selectedData <- reactive({
      data2[, c(input$x, input$y)]
    })
    output$text1 <- renderPrint({input$x})
    output$graph <- reactivePlot(function() {
      p <- ggplot(selectedData(), aes_string(x=input$x, y=input$y)) + geom_point()
      print(p)
    })
#     
#   output$xSelect <- renderUI({
#     selectInput("x","X Axis",names(data))
#   })
#   output$ySelect <- renderUI({
#     selectInput("y","Y Axis",names(data))
#   })
#   output$colorSelect <- renderUI({
#     selectInput("c","Variable To Color With",names(data))
#   })

  
  
})