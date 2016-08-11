library(shiny)

shinyUI(fluidPage(
  title = "TwitterCloud",
  plotOutput("cloud"),
  hr(),
  
  fluidRow(
    column(3,
           h4("Twitter Handle"),
           textInput("handle", "Enter handle", "mzhang13"),
           actionButton("execute", "Generate word cloud")
           ),
    column(9,
           uiOutput("tweets")
           )
    )
))