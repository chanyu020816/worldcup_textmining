output$page02_period <- renderUI({
  req(input$page02_dist)
  if (input$page02_dist == "period") {
    sliderInput(
      "page02_period_slide",
      "Period:",
      min = 1,
      max = 10,
      value = 1
    )
  } else if (input$page02_dist == "phone") {
    selectInput(
     "page02_resource",
     "Resource: ",
     choices = c("iPhone", "Android", "Web App")
    )
  }
})



observe({
  output$page02_bar <- renderPlot({

    team = content[[input$page02_team]]
    title = ""
    if (input$page02_dist == "period") {
      team = team %>%
        filter(period == as.numeric(input$page02_period_slide))
        title = paste(" in period", as.character(input$page02_period_slide))
    } else if (input$page02_dist == "phone") {
      team = team %>%
        filter(statusSource == input$page02_resource)
        title = paste(" from", input$page02_resource)
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
      inner_join(get_sentiments("bing"), by = c(word = "word") )%>%
      count(word, sentiment, sort = TRUE) 

    if (input$page02_type == "Positive / Negative") {
      sentiments %>%
        top_n(input$page02_max_num) %>%
        mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
        mutate(word = reorder(word, n)) %>%
        ggplot(aes(word, n, fill = sentiment)) +
        geom_bar(stat = "identity") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        ylab("Contribution to sentiment") + 
        coord_flip() + 
        ggtitle(paste("Top", as.character(input$page02_max_num), "Sentiments", title)) + 
        theme(plot.title = element_text(hjust = 0.5))
    } else if (input$page02_type == "Sentiment") {
      ggplot(sent_df[[input$page02_team]], aes(sent_type, n)) +
        geom_col() +
        coord_flip() + 
        ggtitle(paste("Sentiments", title)) + 
        theme(plot.title = element_text(hjust = 0.5))
    } else {
      text_clean %>%
        count(word, sort = TRUE) %>%
        top_n(input$page02_max_num) %>%
        mutate(word = reorder(word, n)) %>%
        ggplot(aes(word, n)) +
        geom_bar(stat = "identity") +
        xlab(NULL) +
        coord_flip() + 
        ggtitle(paste("Top", as.character(input$page02_max_num), "words", title)) +
        theme(plot.title = element_text(hjust = 0.5))
    }
  })
})

observe({
  output$page02_pie <- renderPlot({

    team = content[[input$page02_team]]
    title = ""
    if (input$page02_dist == "period") {
      team = team %>%
        filter(period == as.numeric(input$page02_period_slide))
        title = paste(" in period", as.character(input$page02_period_slide))
    } else if (input$page02_dist == "phone") {
      team = team %>%
        filter(statusSource == input$page02_resource)
        title = paste(" from", input$page02_resource)
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
      inner_join(get_sentiments("bing"), by = c(word = "word") )%>%
      count(word, sentiment, sort = TRUE) 
    sent_count = sentiments %>% 
      group_by(sentiment) %>% 
      summarize(total = sum(n))
    neg = filter(sent_count, sentiment == "negative")$total
    pos = filter(sent_count, sentiment == "positive")$total
    pie_data = data.frame(
      type = c("Pos", "Neg"),
      num = c(pos, neg)
    )
    pie_data <- pie_data %>% 
      arrange(desc(type)) %>%
      mutate(prop = num / sum(pie_data$num) * 100) %>%
      mutate(labels = paste0(round(prop, 2), "%"))
    ggplot(pie_data, aes(x = "", y = prop, fill = type)) +
      geom_col() +
      geom_label(aes(label = labels),
        position = position_stack(vjust = 0.5),
        show.legend = FALSE) +
      coord_polar(theta = "y") + 
      ggtitle(paste("Sentiments proportion", title)) + 
      theme(plot.title = element_text(hjust = 0.5))
  })
})

observe({
  output$page02_line <- renderPlot({

    team = content[[input$page02_team]]
    title = ""
    if (input$page02_dist == "phone") {
      team = team %>%
        filter(statusSource == input$page02_resource)
        title = paste(" from", input$page02_resource)
    }
    pos_vec = c()
    neg_vec = c()
    for (i in 1:10) {
      text_clean = team %>%
        filter(period == i) %>%
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
        inner_join(get_sentiments("bing"), by = c(word = "word") )%>%
        count(word, sentiment, sort = TRUE)
      sent_count = sentiments %>% 
        group_by(sentiment) %>% 
        summarize(total = sum(n))
      pos = filter(sent_count, sentiment == "positive")$total
      neg = filter(sent_count, sentiment == "negative")$total

      pos_vec[i] = pos / (pos + neg) * 100
      neg_vec[i] = neg / (pos + neg) * 100
    }
    #cat(pos)
    df = data.frame(
      period = 1:10,
      prop = c(pos_vec),
      type = rep("Positive", time = 10)
    )
    df %>%
      ggplot(aes(period, prop, group = type, color = type)) +
        geom_line() +
        ggtitle(
          paste("Proportion of Positive sentence from period 1 to 10", title)
        ) + 
        theme(plot.title = element_text(hjust = 0.5))


  })
})