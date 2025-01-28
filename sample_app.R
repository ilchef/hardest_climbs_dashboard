rm(list=ls())

source("r/load_data.R")
source("r/ui.R")
source("r/server.R")
source("r/functions.R")

# Run the app
shinyApp(ui = ui, server = server)