#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
load(file="province91.RData")
selectedProvince91 <- select(province91, POP91, LAB91, UE91, HOU85, URB85)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Province91 data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = nrow(selectedProvince91),
                        value = 15),
            selectInput("mja", "Variable:", 
                        choices=colnames(selectedProvince91), 
                        selected = "POP91"),
            hr(),
            helpText("Select a variable and try different number of bins.")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x <- selectedProvince91[, input$mja]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)
        x <- as.numeric(unlist(x))

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white', 
             xlab = paste0(" ", input$mja), main = ' ')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
