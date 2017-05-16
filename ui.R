source("global.R")

df <- read.csv("life_exp.csv", stringsAsFactors = FALSE)

uiLogin <- function(){
  tagList(
    fluidRow(
      column(12,
        fluidRow(column(width=6, offset = 3,
                        div(
                          HTML("<p><p>This shiny app contains some tips and tricks that you can use in your application. Most of these are solutions I am frequently using in my apps. It contains:
                               <p>
                               <ul>
                                 <li>A multi-tabbed application (base shiny)</li>
                                 <li>Filtering of data through the use of sliders (base shiny)</li>
                                 <li>CSS integration</li>
                                 <li>Displaying and R-Markdown document</li>  
                                 <li>Displaying data in a table using DataTable package</li>
                                 <li>Display data on a map with markers and circles using Leaflet package</li>
                                 <li>Enabling/disabling components with shinyJS package</li>
                                 <li>A simple login page</li>
                                 <li>Download functionality</li>
                                 <li>Contineous updating plot</li>
                               </ul>")
                          )
        )),
        hr(),
        fluidRow(column(width=3, offset = 4,
                        wellPanel(id = "login",
                                  textInput(".username", "Username:"),
                                  passwordInput(".password", "Password:"),
                                  div("Please login with test/test", align = "center"), p(),
                                  div(actionButton(".login", "Log in"), style="text-align: center;"), style = "opacity: 0.72"
                        ),
                        textOutput("message")
        ))
      )
    )
  )
}

# Sidebar with a slider input for number of bins
uiNormal <- function(){
  tagList(
    sidebarLayout(
      sidebarPanel(
        selectInput('location', 'Country', choices = unique(df$country)),
        sliderInput("distance", "Distance (kms):", min = 0, max = 10000, value = 1000),
        sliderInput("life_exp_m", "Life expectancy male:", min = min(df$male), max = max(df$male), value = c(min(df$male), 60)),
        sliderInput("life_exp_f", "Life expectancy female:", min = min(df$female), max = max(df$female), value = c(min(df$female), 60)),
        checkboxInput("showDataTab", "Show DataTable Tab", TRUE),
        width = 3
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(id='main',
          tabPanel('Documentation', includeMarkdown('README.Rmd')),
          tabPanel("DataTable", dataTableOutput('df_contents')),
          tabPanel("Leaflet", fluidRow(leafletOutput("map", height = "700px"))), 
          tabPanel("Plotly", fluidRow(plotlyOutput("plot"))),
          tabPanel("Contineous update", fluidRow(plotOutput("contPlot")))
        )
      )
    )
  )
}

shinyUI(fluidPage(
  # Add Javascript
  tags$head(
    tags$link(rel="stylesheet", type="text/css",href="style.css"),
    tags$script(type="text/javascript", src = "md5.js"),
    tags$script(type="text/javascript", src = "passwdInputBinding.js")
  ),
  useShinyjs(),
  HTML("<!-- common header-->
             <div id='headerSection'>
             <h1 style='color:white;'>Shiny tips&trics</h1>
             <span style='font-size: 1.2em'>
             <span>Created by </span>
             <a href='http://gerinberg.com'>Ger Inberg</a>
             &bull;
             <span>April 2017</span>
             &bull;
             <a href='http://gerinberg.com/shiny'>More apps</a> by Ger
             </span>
             </div>"),
  div(titlePanel("Shiny tips & tricks"), align = "center"),
  uiOutput("content")
))