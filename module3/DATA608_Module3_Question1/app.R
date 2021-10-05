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
    
    #Filter to year 2010
    data = reactive({
        req(input$sel_mortality)
        df = mortality %>% filter(ICD.Chapter %in% input$sel_mortality) %>% subset(Year == 2010, select= c(State, Crude.Rate))
    })
        
    #Update Select Input dynamically
    observe({
        updateSelectInput(session,"sel_mortality", choices = sort(mortality$ICD.Chapter))
    })
    
    #Barplot
    output$plot = renderPlot({
        g = ggplot(data(), aes(y=Crude.Rate, x= reorder(State,-Crude.Rate)))
        g + geom_bar(stat="sum")        
    })
    
}

ui = basicPage(
    h1("Mortality Rates in 2010"),
    selectInput(inputId = "sel_mortality",
                label = "Choose a disease","Names"),
    plotOutput("plot")
)

# Run the application 
shinyApp(ui = ui, server = server)
