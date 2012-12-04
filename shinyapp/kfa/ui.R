library(shiny)

shinyUI(bootstrapPage(
  
  headerPanel("KF Data Analytics"),
  
  sidebarPanel(
    
    wellPanel(
      h4("Choose Analytics"),
      selectInput(inputId = "analytics",
                  label = "",
                  choices = c("Basic Analysis" = "basic",
                              "Temporal Analysis" = "temporal",
                              "Semantic Analysis" = "semantic",
                              "Social Network Analysis" = "sna")
      )
    ),
    
    wellPanel(
      h4("Show Results"),
      conditionalPanel(condition = "input.analytics == 'basic'",
                       checkboxInput(inputId = "basic_notes",
                                     label = "Notes by user",
                                     value = TRUE),
                       checkboxInput(inputId = "basic_data",
                                     label = "Data table",
                                     value = FALSE)
      ),
      
      conditionalPanel(condition = "input.analytics == 'temporal'",
                       checkboxInput(inputId = "temp_overall",
                                     label = "Show overall pattern",
                                     value = TRUE),
                       checkboxInput(inputId = "temp_individual",
                                     label = "Show individual patterns",
                                     value = FALSE),
                       selectInput("timescale", "Select timescale", 
                                   c("Day by day" = "byday", 
                                     "By week day" = "bywday", 
                                     "By hour" = "byhr")),
                       checkboxInput(inputId = "temp_hour_wday",
                                     label = "Show hour vs. day pattern",
                                     value = FALSE)
                       #uiOutput("time_range_slider")
      ),
      
      conditionalPanel(condition = "input.analytics == 'semantic'",
                       h5("Ngram Viewer:"),
                       textInput(inputId = "ngram_query", 
                                 label = "Comma-separated phrases:"),
                       p(em("Note: Please type in multiple search terms, separated by commas.")
                       )
      ),
      
      conditionalPanel(condition = "input.analytics == 'sna'",
                       h5("Choose a network to analyze:"),
                       selectInput("sna_network", "", 
                                   c("Note read" = "read", 
                                     "Note buildon" = "buildon", 
                                     "Idea pick" = "pick"))
      )
    )
  ),
  
  mainPanel(
    conditionalPanel(condition = "input.analytics == 'basic'",
                     h3("Basic Analysis"),
                     conditionalPanel(condition = "input.basic_notes == true",
                                      plotOutput(outputId = "basic_notes_plot")
                     ),
                     conditionalPanel(condition = "input.basic_in_replies == true",
                                      plotOutput(outputId = "basic_irepies_plot")
                     ),
                     conditionalPanel(condition = "input.basic_out_replies == true",
                                      plotOutput(outputId = "basic_orepies_plot")
                     ),
                     conditionalPanel(condition = "input.basic_data == true",
                                      h5("All users:"),
                                      tableOutput("basic_table")
                     ),
                     conditionalPanel(condition = "input.basic_corr == true",
                                      h5("Correlations:"),
                                      tableOutput(outputId = "basic_cor_table"),
                                      plotOutput(outputId = "corr_plot")
                     )
    ),
    
    conditionalPanel(condition = "input.analytics == 'temporal'",
                     conditionalPanel(condition = "input.temp_overall == true",
                                      h3("Overall pattern:"),
                                      plotOutput(outputId = "ts_plot"),
                                      p("Note: x axis represents the time of notes, 
                                        and y axis represents the frequency of notes.")
                     ),
                     conditionalPanel(condition = "input.temp_individual == true",
                                      h3("Patterns of individual users:"),
                                      plotOutput(outputId = "ts_user_plot")
                     ),
                     conditionalPanel(condition = "input.temp_hour_wday == true",
                                      h3("Patterns of hour vs. wday:"),
                                      plotOutput(outputId = "ts_hr_wday_plot")
                     )
                     ),
    
    conditionalPanel(condition = "input.analytics == 'semantic'",
                     conditionalPanel(condition = "input.ngram_query != ''",
                                      h3("Ngram Viewer"),
                                      plotOutput(outputId = "ngram_plot")
                     )
                     
    ),
    
    conditionalPanel(condition = "input.analytics == 'sna'",
                     h3("Social network visualization:"),
                     plotOutput(outputId = "sna_plot")
    )
    )
  ))
