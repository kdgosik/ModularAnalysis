library(shiny)
library(visNetwork)

shinyUI(fluidPage(

  # Application title
  titlePanel("Modular Interface"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("lastprice", "Select Last Price", 
                  min = 1, 
                  max = max(stock$LastSale, na.rm = TRUE),
                  value = 5),
      selectInput("exchange", "Select Exchange", 
                  choices = c("All", "NASDAQ", "NYSE", "AMEX", "FX", "Metals")),
      uiOutput("SymbolUI")

    ),

    # Show a plot of the generated distribution
    mainPanel(
      visNetworkOutput("dataset_network")

    )
  )
))
