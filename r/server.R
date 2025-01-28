
# Server logic
server <- function(input, output, session) {
  # ------------- Step 0 ---------------------
  #   dynamic data  -   apply filters
  #-------------------------------------------
  filtered_data <- reactive({
    temp = copy(data) %>%
      #.[!is.na(date)] %>% 
      .[,climber_name := paste0(first_name," ",last_name)]
    
    if(input$gender_filter != "Both"){
     temp <-temp[gender == case_when(input$gender_filter=="Male Only"~"male",T~"female")]
    }
    if(input$climb_type_filer != "Boulder and Sport"){
      temp <- temp[type ==case_when(input$climb_type_filer=="Boulder" ~ "boulder",T~"sport")]
    }
    
    temp <-temp[order(-date)]
    return(temp)
  })
  
  # ------------- Step 1 ---------------------
  #   sends     output
  #-------------------------------------------
  
  display_table <- reactive({
    filtered_data() %>%
      .[,date := format(date,"%d %B %Y")]%>%
      .[,.(date,grade,route_name,type,climber_name,gender,country,crag_country,crag)] %>% head(50)
  })
  
  output$filtered_data <- renderDataTable({
    display_table()
  })
  
  
  # ------------- Step 2 ---------------------
  #   climbers     output
  #-------------------------------------------
  
   chart_climber_asc <- reactive({
     filtered_data() %>% 
       .[,.(asc=.N),climber_name] %>% 
       .[,climber_name := fct_reorder(climber_name,asc)] %>%
       .[,temp:=rank(-asc,ties.method="average")]%>%
       .[temp<=20]%>%
       ggplot()+
       geom_bar(aes(y=climber_name,x=asc),stat="identity",fill="#EE5246")+
       geom_text(aes(y = climber_name, x = asc, label = asc), 
                 hjust = -0.2, # Adjust for better placement
                 size = 5) + 
       ti_aes()+
       coord_cartesian(xlim = c(0, max(filtered_data()[, .N,climber_name]$N) * 1.2)) + 
       theme(axis.text.x=element_blank()
             ,axis.ticks.x=element_blank(),
             axis.text.y = element_text(size = 12))
   })
  output$chart_climber_asc <- renderPlot({chart_climber_asc()})
  
  
  chart_climber_country <- reactive({
    filtered_data() %>%
      .[,.(N=.N),.(country,climber_name)]%>%
      .[,.(asc=.N),country] %>% 
      .[,country:= fct_reorder(country,asc)] %>%
      .[,temp:=rank(-asc,ties.method="average")]%>%
      .[temp<=20]%>%
      ggplot()+
      geom_bar(aes(y=country,x=asc),stat="identity",fill="#EE5246")+
      geom_text(aes(y = country, x = asc, label = asc), 
                hjust = -0.2, # Adjust for better placement
                size = 4) + 
      ti_aes()+
      coord_cartesian(xlim = c(0, max(filtered_data()[, .N,country]$N) * 1.2)) + 
      theme(axis.text.x=element_blank()
            ,axis.ticks.x=element_blank(),
            axis.text.y = element_text(size = 12))
  })
  output$chart_climber_country <- renderPlot({chart_climber_country ()})
  
  chart_climber_network <- reactive({
    filtered_data()%>%.[fa==1] %>% .[,.(route_id,climber_name)] %>%
      merge(
        filtered_data()%>%.[fa==0] %>% .[,.(route_id,climber_name)] 
        ,by="route_id",allow.cartesian = T
      ) %>%
      .[,route_id:=NULL]%>%
      networkD3::simpleNetwork(fontSize = 12
                               ,charge=-60
                               ,linkDistance=60
                               ,nodeColour = "#EE5246"
      )
  })
  output$chart_climber_network <- renderSimpleNetwork({chart_climber_network()})
  
  
  youngest_climber <- reactive({
    filtered_data()%>%
      setDT()%>%
      .[!is.na(date)]%>%
      .[,temp:= year(as.Date(date,"%d %b %Y"))-year_of_birth]%>%
      .[temp==min(temp,na.rm=T)] %>%
      .[,date := format(as.Date(date,"%d %b %Y"),"%b-%y")]%>%
      .[,.(climber_name,route_name,temp,date,grade)] %>% 
      head(1)
  })
  
  oldest_climber <- reactive({
    filtered_data()%>%
      setDT()%>%
      .[!is.na(date)]%>%
      .[,temp:= year(as.Date(date,"%d %b %Y"))-year_of_birth]%>%
      .[temp==max(temp,na.rm=T)] %>%
      .[,date := format(as.Date(date,"%d %b %Y"),"%b-%y")]%>%
      .[,.(climber_name,route_name,temp,date,grade)] %>% 
      head(1)
  })
  
  longest_active <- reactive({
    filtered_data()%>%
      .[,temp:= year(as.Date(date,"%d %b %Y"))-year_of_birth]%>%
      .[, temp2 := as.integer(max(temp, na.rm = T) - min(temp, na.rm = T)), climber_name] %>% 
      .[temp2==max(temp2,na.rm=T)]%>%
      .[,.(climber_name,temp2)] %>% unique()
  })
  #----------------------------trash----------------------
  # Value boxes
  output$value1 <- renderValueBox({
    valueBox(
      "Youngest Climber",
      paste0(youngest_climber()$climber_name,", ",youngest_climber()$route_name,": ",youngest_climber()$temp,"yo"),
      icon = icon("trophy"),
      color = "purple",
      width=6
    )
  })
  
  output$value2 <- renderValueBox({
    valueBox(
      "Oldest Climber",
      paste0(oldest_climber()$climber_name,", ",oldest_climber()$route_name,": ",oldest_climber()$temp,"yo"),
      icon = icon("trophy"),
      color = "blue",
      width=6
    )
  })
  
  
  output$value4 <- renderValueBox({
    valueBox(
      "Longest Active",
      paste0(longest_active()$climber_name,", ",longest_active()$temp2,"yrs"),
      icon = icon("clock-o"),
      color = "red",
      width=6
    )
  })
}