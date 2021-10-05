#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Helpful links
#https://www.youtube.com/watch?v=rlcUiSw49FY
#[R Shiny BasicApp]#8 Dynamically create Drop Down List](https://www.youtube.com/watch?v=mHRVFMQ54ZE)

library(shiny)
library(dplyr)
library(ggplot2)

# Define server logic required to create a bar chart
server <- function(input, output,session) {

    #Load data
    mortality = read.csv("cleaned-cdc-mortality-1999-2010-2.csv")
    
    national = mortality %>%
        group_by(ICD.Chapter, Year) %>% 
        summarise(natl_average = weighted.mean(Deaths))
    
    #Filter
    data = reactive({
        req(input$sel_mortality)
        df = mortality %>% filter(ICD.Chapter %in% input$sel_mortality) %>% filter(State %in% input$sel_state)
    })
    
    national_data = reactive({
        req(input$sel_mortality)
        national_df = national %>% filter(ICD.Chapter %in% input$sel_mortality)
    })
        
    #Update Select Input dynamically
    observe({
        updateSelectInput(session,"sel_mortality", choices = sort(mortality$ICD.Chapter))
        updateSelectInput(session,"sel_state", choices = (mortality$State))
    })
    
    #Barplot
    output$plot = renderPlot({
        #g = ggplot(data=data(), aes(x=Year, y=Deaths, group=1))
        #g + geom_line(color='blue') + geom_point(color='blue')
        ggplot() +
            geom_line(data=data(), aes(x=Year, y=Deaths),group = 1, color='blue') +
            geom_line(data=national_data(), aes(x=Year, y=natl_average, group = 1), color='red')
    })
    
}

ui = basicPage(
    h1("Mortality Rates in 2010"),
    selectInput(inputId = "sel_mortality",
                label = "Choose a disease","Diseases"),
    selectInput(inputId = "sel_state",
                label = "Choose a state","States"),
    plotOutput("plot")
)

# Run the application 
shinyApp(ui = ui, server = server)
