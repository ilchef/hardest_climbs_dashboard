library(magrittr)
library(shiny)
library(shinydashboard)
library(stringr)
library(forcats)
library(httr)
library(dplyr)
library(networkD3)
library(data.table)
library(ggplot2)

sends_table <- fread(text = content(GET("https://raw.githubusercontent.com/9cpluss/hardest-climbs/master/data/sends_table.csv"), "text"))%>%
  .[,date:=as.Date(case_when(date==""~NA_character_,TRUE~date),"%d/%m/%Y")]


routes_table <- fread(text = content(GET("https://raw.githubusercontent.com/9cpluss/hardest-climbs/master/data/routes_table.csv"), "text"))

climbers_table <- fread(text = content(GET("https://raw.githubusercontent.com/9cpluss/hardest-climbs/master/data/climbers_table.csv"), "text"))#fread("data/climbers_table.csv") 

data <- sends_table %>% 
  merge(routes_table,by="route_id")%>% 
  merge(climbers_table,by="climber_id")   
