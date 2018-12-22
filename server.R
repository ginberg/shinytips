source("global.R")

credentials <- list("test" = "098f6bcd4621d373cade4e832627b4f6")
ZOOM_LEVEL <- 3

shinyServer(function(input, output, session) {
  source('ui.R') #login page

  USER <- reactiveValues(Logged = FALSE)
  INIT <- FALSE
  
  observeEvent(input$.login, {
    
    error <- FALSE
    user <- input$.username
    pwd <- input$.password
    if(user == "" | pwd == ""){
      error <- TRUE
    }
    if(!error){
      if (!is.null(credentials[[user]]) && credentials[[user]] == pwd){
        USER$Logged <- TRUE
      } else {
        error <- TRUE
      }  
    }
    if(error){
      show("message")
      output$message = renderText("Invalid user name or password")
      delay(5000, hide("message", anim = TRUE, animType = "fade"))
    }
  })
  
  # Output the main content panel
  output$content = renderUI(
    ifelse(USER$Logged, uiNormal(), uiLogin())
  )
  
  # reactive expression for data
  data <- reactive({
    range_m <- input$life_exp_m
    range_f <- input$life_exp_f
    df_filtered <- df %>% filter(male >= range_m[1]) %>% filter(male <= range_m[2]) %>% filter(female >= range_f[1]) %>% filter(female <= range_f[2])
    return(df_filtered)
  })
  
  # map with locations of facilities 
  output$map <- renderLeaflet({
    df <- data()
    if(nrow(df) > 0){
      leaflet()  %>%  
        addTiles() %>% 
        setView(lng = df[1,]$lon, lat = df[1,]$lat, zoom = ZOOM_LEVEL) %>%
        addMarkers(data = df, lat = ~lat, lng = ~lon) %>%
        addCircles(data = df[1,], lng = ~lon, lat = ~lat, weight = 1, radius = ~(input$distance * 1000))
    }
  })
  
  # print content of data
  output$df_contents <- DT::renderDataTable(rownames = FALSE, extensions = 'Buttons',{
    df
  }, options = list(pageLength = 50, 
                    paging = TRUE, 
                    dom = 'Blfrtip',
                    buttons = list('csv', 'print', 'pdf',
                                   list(extend = 'excel', exportOptions = list(columns = ':visible')), 
                                   list(extend = 'colvis', text='Show/Hide Columns', collectionLayout='fixed two-column')
                                  )
                  )
  )
  
  # plotly content
  output$plot <- renderPlotly({
    df <- data()
    m <- list(l = 150, r = 0, b = 150, t = 50, pad = 4)
    plot_ly(df, y = ~country, x = ~male, type = 'bar', name = 'Male') %>%
      add_trace(x = ~female, name = 'Female') %>%
      layout(title = "Life expectancy per country", yaxis = list(title = ''), xaxis = list(title = 'Age (years)'), barmode = 'group', margin = m)
  })                                                                                                                                                                                                                                                           
  
  observeEvent(input$showDataTab, {
    if(!INIT){
      show(selector = "a[data-value=DataTable]")
      INIT <<- TRUE
    } else{
      # switch tab if currently on data tab
      if (input$main == "DataTable"){
        updateTabsetPanel(session, inputId = 'main', selected = 'Leaflet')
      }
      toggle(selector = "a[data-value=DataTable]")
    }
  })
  
  # update the map markers and view on location selectInput changes
  observeEvent(c(input$location, input$distance), { 
    proxy <- leafletProxy("map")
    if (nrow(df) > 0){
      # Add markers for chosen facility and the ones within chosen distance x
      df <- data()
      df_circle <- df[df$country == input$location,]
      proxy %>% clearShapes() %>% clearPopups() %>%
        addCircles(data = df_circle, lng = ~lon, lat = ~lat, weight = 1, radius = ~(input$distance * 1000)) %>% 
        setView(lng = df_circle[1,'lon'], lat = df_circle[1,'lat'], zoom = ZOOM_LEVEL)   # update the center of the map with the location of the selected facility (use current zoom level)
    }
  })                                                                    
  
  # When map is clicked, show a popup with info
  observeEvent(input$map_marker_click, {
    event <- input$map_marker_click
    loc <- df[df$lat == as.numeric(event$lat) & df$lon == as.numeric(event$lng),]
    content <- paste("Country:", loc$country, "<br>", "Male:", loc$male, "<br>", "Female:", loc$female)
    leafletProxy("map") %>% clearPopups() %>% addPopups(event$lng, event$lat, content, layerId = event$id)
  })                                                                                                                              
  
  # when sliders are changed, update dropdown
  observeEvent(c(input$life_exp_f, input$life_exp_m), {
    updateSelectInput(session, "location", choices = data()$country)
  })
  
  # Reactive timer
  autoInvalidate <- reactiveTimer(3000)
  
  # Generate a new histogram each time the timer fires
  output$contPlot <- renderPlot({
    autoInvalidate()
    hist(rnorm(10), xlab = "Value", main = "Histogram of a random normal distribution with 10 observations")
  })
  
  observeEvent(input$playSound, {
    disable("playSound")
    js$playMusic()
  })
  observeEvent(input$stopSound, {
    enable("playSound")
    js$stopMusic()
  })
  
})