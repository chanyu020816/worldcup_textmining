labelWithInfo = function(label, id) {
  HTML(
    label,
    as.character(
      actionLink(
        id,
        label = '',
        icon = icon(name = 'question-circle', lib = 'font-awesome', 'fa-xs')
      )
    )
  )
}

output$page01_time <- renderUI({
  
  if(input$pae01_dist == "Time") {
    dateRangeInput(
      "page01_date",
      "Period:",
      start = "2022-11-20", # 2022 world cup start
      end = "2022-12-09"
      # dor dynamic web scrap
      # end = Sys.Date()+10
    )
  }
})