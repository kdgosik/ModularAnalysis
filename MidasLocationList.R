library(shiny)
library(shinydashboard)
library(rhandsontable)


shinyApp(
  shinyUI(
  bootstrapPage(
    fluidRow(

  column(width = 4,
         
      box(width = 12,
          
      fileInput("file1", "Upload File", accept = "csv"),
      actionButton("upload_to_database", "Upload to Datebase")
      
         )
      ),   

   column(width = 8, 
          
      box(width = 12,
          
        rHandsontableOutput("hot")
      )
      
          )

   )
  )
  
),
  
shinyServer(function(input, output, session) {
    values = reactiveValues()
  
    data <- reactive({

    if (!is.null(input$hot)) {
        DF = hot_to_r(input$hot)
      } else {
        if (is.null(values[["DF"]])){
          inFile <- input$file1
          
          if (is.null(inFile))
            return(NULL)
          
          DF <- data.frame(
            read.csv(inFile$datapath, header = TRUE),
            EffectiveDate = Sys.Date()
          )
          
          
          # DF = inpt_data()
        }else
          DF = values[["DF"]]
      }


      values[["DF"]] = DF
      DF
    })
    
    output$hot <- renderRHandsontable({
      DF = data()
      if (!is.null(DF))
        rhandsontable(DF)
    })
  })
)

