# system2("docker", "cp '/data/projects/MICU_LOS/.' shiny:/srv/shiny-server/uniteventlos/")
# system2('docker' , 'exec shiny chown -R :shiny /srv')
# system2('docker' , 'exec shiny touch /srv/shiny-server/uniteventlos/restart.txt')

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

rm(list = ls()); gc(reset = TRUE)

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


## Code Space ###########################################

pgsrc <- 
  read.csv( 'creds.csv', colClasses = rep("character", 2)) %$%  
  src_postgres(
    host = 'datascience'
    , dbname = 'dev'
    , port = 5432
    , user = username
    , password = password
    , options="-c search_path=public"
  )


tables_list <- dbListTables(pgsrc$con)



nodes <- lapply(tables_list, function(tab){
  
  tryCatch({
  data.frame(id = 1,
             label = colnames(tbl(pgsrc, tab)),
             group = tab,
             title =  colnames(tbl(pgsrc, tab)))
  }, error = function(e) NULL)
  
}) %>%
  do.call(rbind,.)

# dummy data for easy checking
mtcars_nodes <- data.frame(id = 1,
                           label = names(mtcars),
                           group = "mtcars",
                           title = names(mtcars))

nodes <- rbind(mtcars_nodes, nodes)



## Mortality Data to be put in Postgres later ######
mort <- read.csv("Data/data.kpi.mortoe.2017.01.csv", stringsAsFactors = F)

serv_cross_walk_idx <- which(mort$KPI.Name == "Division Description")
month_idx <- which(mort$KPI.Name == "Calendar Year-Month Formatted")

cfg.service.unit <- mort[(serv_cross_walk_idx + 1) : (month_idx - 1), ]
colnames(cfg.service.unit) <- mort[serv_cross_walk_idx, ]
cfg.service.unit <- cfg.service.unit[, 1 : 3]

cfg.month <- mort[(month_idx + 1) : nrow(mort), ]
colnames(cfg.month) <- mort[month_idx, ]
cfg.month <- cfg.month[,1, drop = F]

mort_summary <- mort[1 : (serv_cross_walk_idx - 1), ] %>%
  mutate(Date = ymd_hms(KPI.Date, tz = "EST"), 
         Date = floor_date(Date, unit = "month"), 
         KPI.Numerator.SUM = as.numeric(KPI.Numerator.SUM)) %>%
  group_by(Date) %>%
  summarise(Numerator = sum(KPI.Numerator.SUM), Denominator = sum(KPI.Denominator.SUM))


mort_nodes <- data.frame(id = 1,
                           label = names(mort_summary),
                           group = "mortality",
                           title = names(mort_summary))

nodes <- rbind(mort_nodes, nodes)
nodes$id <- 1 : nrow(nodes)



  # All KPI reports only drill down to division/department not nurse unit
kpi_list <- dir("Data", pattern  ="kpi", full.names = TRUE)

avglos <- read.csv(kpi_list[1], stringsAsFactors = F)
end_idx <- which(avglos[["KPI.Name"]] == "Division Description")
avglos <- avglos[1 : (end_idx - 1), ]


avglos %>%
  group_by()

