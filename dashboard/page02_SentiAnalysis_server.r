output$page02_time <- renderUI({
  req(input$page02_dist)
  if(input$page02_dist == "Time") {
    dateRangeInput(
      "page02_date",
      "Period:",
      start = "2022-11-20", # 2022 world cup start
      end = "2022-12-09"
      # dor dynamic web scrap
      # end = Sys.Date()+10
    )
  }
})