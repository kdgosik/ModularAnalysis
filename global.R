## Create Directory Structure #################################################################
if( !dir.exists( paste0( getwd() , '/Data') ) ) {
  dir.create( paste0( getwd() , '/Data') )
}

if( !dir.exists( paste0( getwd() , '/output') ) ) {
  dir.create( paste0( getwd() , '/output') )
}

if( !dir.exists( paste0( getwd() , '/input') ) ) {
  dir.create( paste0( getwd() , '/input') )
}


#library(RPostgreSQL)
library(dplyr)
library(tidyr)
library(lubridate)
library(plotly)
library(dygraphs)
library(quantmod)
library(xts)
library(zoo)
library(magrittr)
library(DT)
library(visNetwork)
library(shiny)
rm(list=ls()); gc(reset = TRUE)

# load modulars
# move to make these dynamically loaded from user input
source("Modulars/ModularCSVFileInput.R")
source("Modulars/ModularDataView.R")
source("Modulars/ModularScatterPlot.R")
source("Modulars/ModularControlChart.R")
source("Modulars/ModularPlotlyHeatmapScatter.R")

## Helper Functions #####################################

latest_file <- function( path = ".", file_name ) {
  tmp <- file.info(dir(path = path, pattern = file_name, full.names = TRUE))
  fname <- rownames(tmp[which.max(tmp$ctime),])
  fname
}

# datasets from all packages

dat <- as.data.frame(data(package = .packages(all.available = TRUE))$results, stringsAsFactors = FALSE)
nodes <- dat[, c(1,3)]
nodes$id <- 1 : nrow(nodes)
colnames(nodes) <- c("group", "label", "id")
nodes <- nodes[,c(3, 2, 1)]

grp <- unique(nodes$group)
nodes_grp <- data.frame(id = (nrow(nodes) + 1) : (nrow(nodes) + length(grp)),
                        label = grp,
                        group = grp, stringsAsFactors = FALSE)

edges <- merge(nodes, nodes_grp, by = "group")[,c(2,4)]
colnames(edges) <- c("from", "to")

nodes <- rbind(nodes, nodes_grp)

stock <- read.csv("data.stock.symbols 2017-01-18 .csv", stringsAsFactors = FALSE)
# stock <- fread("data.stock.symbols 2017-01-18 .csv")
# 
# 
# stock[,.N, by = .(Symbol, Sector, Exchange)]
# stock[,.N, by = .(Sector, Industry)]
# 
# 
# sub <- sample(nrow(stock), 500)
# stock_sub <- stock[sub, c(1, 8)]
# stock_sub$id <- 1 : 500
# colnames(stock_sub) <- c("label", "group", "id")
# stock_sub <- stock_sub[,c(3, 1, 2)]
# 
# visNetwork(stock_sub, main = "Field Network") %>%
#   visOptions(nodesIdSelection = TRUE) %>%
#   visInteraction(dragNodes = TRUE,
#                  dragView = TRUE,
#                  zoomView = TRUE,
#                  navigationButtons = TRUE,
#                  keyboard = TRUE) %>%
#   visClusteringByGroup(groups = unique(stock_sub$group)) %>%
#   visLegend()