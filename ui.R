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

shinyUI(fluidPage(

  # Application title
  titlePanel("Dashboard"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("keys", "Select a Key", choices = c("Date", "OOS", "MRN", "EmployeeNumber", "Location")),
      
      conditionalPanel(
        condition = "input.keys == 'Date'",
          selectInput("date_interval", 
                      "Select Date Interval", 
                      choices = list(Week = "week", 
                                     `Pay Period` = "payperiod",
                                     Month = "month",
                                     Quarter = "quarter"))
      ),
      
      h3("Add Other Inputs and Filters"),
      selectInput("dataset", "Select a table", choices = levels(nodes$group)),
      selectInput("xvar", "Select X Variable", choices = nodes$label, selected = "mpg"),
      selectInput("yvar", "Select Y Variable", choices = nodes$label, selected = "disp"),
      actionButton("show_mod", "Show Modular")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      
      tabsetPanel(
        
        tabPanel("Data Navigation",
          visNetworkOutput("field_network")
        ),
        
        tabPanel("Table View",
          DataViewUI("tab1")
        ),
        
        tabPanel("Scatter",
          scatterUI("scat")
        ),
        
        tabPanel("Modular Call",
          uiOutput("out_mod")
        )
        
        # tabPanel("Control Chart",
        #   ControlChartUI("control")
        # ),
        # 
        # tabPanel("Heatmap & Scatter",
        #   PlotlyHeatmapScatterUI("heatscat")
        # )


      ) # tabsetPanel
    ) # mainPanel
  )
))
