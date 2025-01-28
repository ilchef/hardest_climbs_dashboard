
# UI Definition
ui <- dashboardPage(
  dashboardHeader(title = "Outdoor Climbs Leaderboard"),
  
  # Sidebar with controls
  dashboardSidebar(
    sidebarMenu(
      menuItem("About the Data", tabName = "git", icon = icon("github")),
      menuItem("Latest Ascents", tabName = "sends", icon = icon("trophy")),
      menuItem("About The People", tabName = "climbers", icon = icon("user")),
      menuItem("About The Climbs", tabName = "climbs", icon = icon("map")),
      
      # Controls
      
      selectInput("climb_type_filer", 
                  "Climb Type to Include:",
                  choices = list("Boulder and Sport","Boulder","Sport")),
      
      selectInput("gender_filter", 
                  "Gender to Include:",
                  choices = list("Both","Female Only","Male Only"))
      
      # selectInput("min_grade_filter",
      #             "Minimum Grade to Include:",
      #             choices=list("8C/+","8C+","8C+/9A","9A","9B","9B/+","9B+","9C"))
    )
  ),
  
  # Main dashboard body
  dashboardBody(
    tabItems(
      tabItem(tabName= "sends",
               fluidRow(
                 box(
                   title = "Latest 50 sends"
                   ,status="primary"
                   ,solidHeader = TRUE
                   ,width=12
                   ,dataTableOutput("filtered_data")
                 )
               )
      ),
      tabItem(tabName = "climbers",
              fluidRow(
                # First row with two panels
                conditionalPanel(
                  condition = TRUE,
                  box(
                    title = "Elite Climbers by # of Ascents:",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 6,
                    plotOutput("chart_climber_asc")
                  ),
                  conditionalPanel(
                    condition = TRUE,
                    box(
                      title = "# of Elite Climbers by Nationality:",
                      status = "primary",
                      solidHeader = TRUE,
                      width = 6,
                      plotOutput("chart_climber_country")
                    )
                  )
                )
              ),
              fluidRow(
                # Second row with two panels
                
                conditionalPanel(
                  condition = TRUE,
                  box(
                    title = "Climber-association Network (interactive):",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 12,
                    verbatimTextOutput("summary1"),
                    p("A connection between two climbers indicates they have shared an ascent of one or more hard climbs."),
                    simpleNetworkOutput("chart_climber_network")
                  )
                )
              ),
              
              # Value boxes for summary statistics
              fluidRow(
                valueBoxOutput("value1", width = 4),
                valueBoxOutput("value2", width = 4),
                valueBoxOutput("value4", width = 4)
              )
      ),

      tabItem(tabName= "climbs",
               fluidRow(
                 box(
                   title = "under construction"
                   ,status="success"
                   ,solidHeader = TRUE
                   ,width=12
                 )
               )
      ),
      tabItem(tabName= "git",
               fluidRow(
                 box(
                   title = "Introduction:"
                   ,status="primary"
                   ,solidHeader = TRUE
                   ,width=12
                   ,HTML("
                         <p>Hardest climbs is an open source, community-led github project aiming to catalogue and store data around significant acheivements in the sport of outdoor climbing.</p>
                         <p>Out of all the sports humans enjoy to watch or participate in, climbing (and especially outdoor climbing) has been particularly resistant to digitisation and diligent record keeping. 
                         This has led to a lot ofinformation still being stored in disparate books, blogs, forums and word of mouth. 
                         These sources are not widely known, consistently updated, or easily found. Hardest climbs aims to solve part of this problem by preserving the most historic moments of our sport in the annals of history. </p>
                         <p>The criteria for an ascent being included in this data are as follows:</p>
                         <ul>
                          <li>For sport/lead climbing, a consensus grade of 9b or higher</li>
                          <li>For bouldering, a consensus grade of 8c or higher or higher</li>
                         </ul>
                         ")
                 )
                 ,box(
                   title = "Suggestions or Report an Error:"
                   ,status="primary"
                   ,solidHeader = TRUE
                   ,width=12
                   ,HTML("
                         <p>This project is community maintained, with information collected from vague and sometimes contradicting sources. Much data is currently missing, or an approximation, or is prone to changing over time (i.e. grades).</p>
                         <p>If you have found or suspect an error, please either raise and issue or a pull-request on the <a href='https://github.com/9cpluss/hardest-climbs' target='_blank'>github project</a>.</p>
                         ")
                 )
               )
      )
    )
  )
)