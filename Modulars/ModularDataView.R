library(DT)

# MODULE UI
DataViewUI <- function(id) {
  ns <- NS(id)
  
  list(
    div(DT::dataTableOutput(ns("table1")))
  )
  
}



# MODULE Server
DataViewServer <- function(input, output, session, data) {
  
  output$table1 <- DT::renderDataTable({
    
    DT::datatable(data(), filter = "top")
    
  })
  
}