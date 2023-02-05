
output$page01_dist_result <- renderUI({

  if (input$page01_dist == "period") {
    sliderInput(
      "page01_period_slide",
      "Period: ",
      min = 1,
      max = 10,
      value = 1
    )
  } else if (input$page01_dist == "phone") {
    selectInput(
     "page01_resource",
     "Resource: ",
     choices = c("iPhone", "Android", "Web App")
    )
  }
})



bra_table = bra_content %>%
  filter(period == 1) %>%
  head(10)
arg_table = arg_content %>%
  filter(period == 1) %>%
  head(10)
por_table = por_content %>%
  filter(period == 1) %>%
  head(10)
fra_table = fra_content %>%
  filter(period == 1) %>%
  head(10)

for (i in 2:10) {

  temp = bra_content %>%
    filter(period == i) %>%
    head(10)
  bra_table = rbind(bra_table, temp)

  temp = arg_content %>%
    filter(period == i) %>%
    head(10)
  arg_table = rbind(arg_table, temp)

  temp = por_content %>%
    filter(period == i) %>%
    head(10)
  fra_cont_table = rbind(fra_table, temp)

  temp = por_content %>%
    filter(period == i) %>%
    head(10)
    fra_table = rbind(fra_table, temp)
  
}

table = list()
table[["bra"]] = bra_table
table[["arg"]] = arg_table
table[["por"]] = por_table
table[["fra"]] = fra_table


### content table
output$content <- renderUI({
  renderDT(select(table[[input$page01_team]], -(X)))
})



# wordcloud
observe({
  output$wordcloud <- renderPlot({

    team = content[[input$page01_team]]
    title = ""
    if (input$page01_dist == "period") {
      team = team %>%
        filter(period == as.numeric(input$page01_period_slide))
        title = paste(" in period", input$page01_period_slide)
    } else if (input$page01_dist == "phone") {
      team = team %>%
        filter(statusSource == input$page01_resource)
        title = paste(" from", input$page01_resource)
    }
    text_clean = team %>%
      select(text) %>%
      unnest_tokens(word, text) %>%
      # remove stop words
      anti_join(stop_words) %>%
      # remove brazil keyword
      filter(!(word %in% countries)) %>%
      filter(!(word %in% c("argentina", "im", "dont", "didnt", "gonna",
        "1", "2", "3", "4")
      )
    )
    count_df = count(text_clean, word, sort = TRUE)

    wordcloud(words = count_df$word, freq = count_df$n,
      min.freq = 0, max.words = as.numeric(input$page01_max_num),
      random.order = FALSE, rot.per = 0.35, colors = brewer.pal(8, "Dark2")
    )
    title = paste("World Cloud", title)
    text(x = 0.5, y = 0.9, title, cex = 2.5)

  })
})


observe({
  output$comparison_plot <- renderPlot({
    team = content[[input$page01_team]]
    title = ""
    if (input$page01_dist == "period") {
      team = team %>%
        filter(period == as.numeric(input$page01_period_slide))
      title = paste(" in period", input$page01_period_slide)
    } else if (input$page01_dist == "phone") {
      team = team %>%
        filter(statusSource == input$page01_resource)
      title = paste(" from", input$page01_resource)
    }
    text_clean = team %>%
      select(text) %>%
      unnest_tokens(word, text) %>%
      # remove stop words
      anti_join(stop_words) %>%
      # remove brazil keyword
      filter(!(word %in% countries)) %>%
      filter(!(word %in% c("argentina", "im", "dont", "didnt", "gonna",
                           "1", "2", "3", "4")
      )
    )

    sentiments <- text_clean %>%
      inner_join(get_sentiments("bing"), by = c(word = "word")) %>%
      count(word, sentiment, sort = TRUE)

    sentiments %>%
      acast(word ~ sentiment, value.var = "n", fill = 0) %>%
      comparison.cloud(colors = c("#F71735", "#090446"),
        max.words = as.numeric(input$page01_max_num), match.colors = TRUE,
        title.size = 1, scale = c(10, 1),  main = "Title"
      )
    title = paste("Comparison Cloud by",  title)
    text(x = 0.5, y = 0.92, "Comparison Cloud", cex = 2.5)
  })
})
