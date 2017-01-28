library(RPostgreSQL)
library(dplyr)
library(tidyr)
library(lubridate)
library(plotly)
library(dygraphs)
library(xts)
library(zoo)
library(magrittr)
library(DT)
library(visNetwork)
library(shiny)


shinyServer(function(input, output, session) {
  
  observe({
  
  updateSelectInput(session, "xvar", "Select X Variable", choices = nodes$label[nodes$group == input$dataset])
  updateSelectInput(session, "yvar", "Select Y Variable", choices = nodes$label[nodes$group == input$dataset])
  
  })
  
  output$field_network <- renderVisNetwork({
    
    # from global
    visNetwork(nodes, main = "Field Network") %>%
      visOptions(nodesIdSelection = TRUE) %>%
      visInteraction(dragNodes = TRUE,
                     dragView = TRUE,
                     zoomView = TRUE,
                     navigationButtons = TRUE,
                     keyboard = TRUE) %>%
      visClusteringByGroup(groups = unique(nodes$group)) %>%
      visLegend()
    
  })
  
  
  Data <- reactive({
    
    #   dat <- pgsrc %>%
    #     tbl(pgsrc, datname) %>%
    #     arrange() %>%
    #     group_by() %>%
    #     filter() %>%
    #     mutate() %>%
    #     
    #   dat
    
    inpt_dataset <- input$dataset
    
    switch(inpt_dataset,
           mtcars = mtcars,
           mortality = mort_summary)
    
  })
  
  
  ## Calling Modules
  observeEvent(input$show_mod, {
      # scatter plot call
    callModule(scatterServer, "scat", data = Data, input$xvar, input$yvar, 1, "red")
    
    
    # modular call 
        
    switch(input$dataset, 
           
           mortality = {
             
             output$out_mod <-renderUI({
               ControlChartUI("control")
             })
             
             callModule(ControlChartServer, "control", data = Data, input$xvar, input$yvar)
           },
           
           mtcars = {
             
             output$out_mod <-renderUI({
               PlotlyHeatmapScatterUI("heatscat")
             })
             
               callModule(PlotlyHeatmapScatterServer, "heatscat", data = Data)
            
           }
           
           )
    
  })
  
  
  callModule(DataViewServer, "tab1", data = Data)
  
  
})
