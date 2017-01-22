library(shiny)
library(visNetwork)

shinyServer(function( input, output, session ) {

  output$SymbolUI <- renderUI({
    
    inpt_lastprice <- input$lastprice
    inpt_exchange <- input$exchange
    
    out <- switch(inpt_exchange, 
                  `All` = {
                    stockSymbols(quiet = TRUE) %>%
                      filter(LastSale < inpt_lastprice) %$%
                      Symbol
                  },
                  
                  `NASDAQ` = {
                    stockSymbols("NASDAQ", quiet = TRUE) %>%
                      filter(LastSale < inpt_lastprice) %$%
                      Symbol
                  },
                  
                  `NYSE` = {
                    stockSymbols("NYSE", quiet = TRUE) %>%
                      filter(LastSale < inpt_lastprice) %$%
                      Symbol
                  },
                  
                  `AMEX` = {
                    stockSymbols("AMEX", quiet = TRUE) %>%
                      filter(LastSale < inpt_lastprice) %$%
                      Symbol
                  },
                  
                  `FX` = c("EUR/USD", "EUR/GBP", "EUR/JPY", "USD/JPY", "AUD/JPY"),
                  
                  `Metals` = c("XAU", "XAG", "XPD", "XPT")
    )
    
    
    selectizeInput("symbol", "Select Stock Symbol", choices = out)
    
  })
  
  
  Data <- eventReactive(input$get_stock, {
    
    inpt_symbol <- input$symbol
    
    inpt_exchange <- input$exchange
    
    dat <- switch(inpt_exchange, 
                  `All` = getSymbols(inpt_symbol, auto.assign = FALSE),
                  `NASDAQ` = getSymbols(inpt_symbol, auto.assign = FALSE),
                  `NYSE` = getSymbols(inpt_symbol, auto.assign = FALSE),
                  `AMEX` = getSymbols(inpt_symbol, auto.assign = FALSE),
                  `FX` = getFX(inpt_symbol, auto.assign = FALSE),
                  `Metals` = getMetals(inpt_symbol, auto.assign = FALSE)
    )
    
    # returns = dailyReturn(dat)
    # 
    # bcp_post <- bcp(returns) %$% 
    #   posterior.prob 
    # 
    # bcp_events <- index(dat)[which(bcp_post > 0.9)]
    # 
    # returns <- cbind(returns, bcp_post)
    # colnames(returns) <- c("Returns", "Postieror Probability")
    # 
    # list(Data = round(dat, 4),
    #      Returns = returns,
    #      Events = bcp_events)
    
    dat
    
  })
  
  
  output$dataset_network <- renderVisNetwork({
    
    visNetwork(nodes, edges = edges, main = "Dataset Network") %>%
      visOptions(nodesIdSelection = TRUE) %>%
      visInteraction(dragNodes = TRUE,
                     dragView = TRUE,
                     zoomView = TRUE,
                     navigationButtons = TRUE,
                     keyboard = TRUE) %>%
      visClusteringByGroup(groups = unique(nodes$group)) %>%
      visLegend()

  })

})
