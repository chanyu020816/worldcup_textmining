### using packages
library(tidyverse)
library(twitteR)
library(remoji)
library(tm)
library(tidytext)
library(wordcloud)
library(syuzhet)
library(lubridate)

library(scales)

### setting twitter api
# read my twitter api
api_csv =  "/Users/liuchenyu/Desktop/worldcup_textmining/data/twitterAPI.csv"
loc = "/home/chanyu/Desktop/school/webscrapping/project/data/"
api = read.csv(api_csv)
API_key = api$api_key[1]
API_secret = api$api_secret[1]
Access_token = api$access_token[1]
Access_secret = api$access_secret[1]
setup_twitter_oauth(API_key,API_secret,Access_token,Access_secret)

### web scrapping for 4 different teams in terms of their twitter content
# set 50000 post
# removing the retweet by strip_retweets() function

twitterScrap <- function(keywords, n, start_date, end_date) {
  start = as.Date(start_date)
  end = as.Date(end_date)
  period = seq(start, end, by = "days")

  days = length(period) - 1
  t = round(n / days / 100)
  cont = searchTwitter(keywords, lang = "en", n = 1)
  for (d in 1:length(period)) {
    for (i in 1:t) {
      last_id = cont[[length(cont)]]$id
      start = as.character(as.Date(period[d] - 1, format = "%Y-%m-%d"))
      new = searchTwitter(
        keywords, 
        lang = "en",
        n = 100,
        maxID = last_id,
        since = start
      )
      cont = append(cont, new)
      Sys.sleep(5)
    } # for end
    # Sys.sleep(60)
    cat(start, "\n")
  } # for end
  cont = cont %>%
    strip_retweets() %>%
    twListToDF() %>%
    mutate(text = unsub_emoji(text))
  cat("done!!!!")
  return(cont)
}

# bra = twitterScrap("Brazil", 50000, "2022/12/02", "2022/12/11")
# arg = twitterScrap("Argentina", 50000, "2022/12/02", "2022/12/11")
# por = twitterScrap("Portugal", 50000, "2022/12/03", "2022/12/12")
# fra = twitterScrap("equipedefrance", 50000, "2022/12/03", "2022/12/12")
df = list()
df$bra = read.csv(paste0(loc, "/brazil.csv"))
df$arg = read.csv(paste0(loc, "/argentina.csv"))
df$por = read.csv(paste0(loc, "/portugal.csv"))
df$fra = read.csv(paste0(loc, "/france.csv"))

for (i in 1:4) {
  # remove emoji
  df[[i]]$text = gsub("[^\x01-\x7F]", "", df[[i]]$text)
  # remove links  
  df[[i]]$text = gsub("https:.+", "", df[[i]]$text)
  # remove tags => @xxxx
  df[[i]]$text = gsub("@[0-9a-zA-Z_]+", "", df[[i]]$text)
  df[[i]]$text = gsub("[[:punct:]]", "", df[[i]]$text)

  # clean resource
  df[[i]]$statusSource = gsub("</a>", "", df[[i]]$statusSource)
  df[[i]]$statusSource = gsub("<.+>Twitter\\s", "", df[[i]]$statusSource)
  df[[i]]$statusSource = gsub("for\\s", "", df[[i]]$statusSource)
  df[[i]]$statusSource = gsub("<.+>", "", df[[i]]$statusSource)
  
  # clean created time
  df[[i]]$created = gsub("\\s.+", "", df[[i]]$created)
  
  # select variable needed 
  df[[i]] = select(df[[i]], text, favoriteCount, created, statusSource)
  
  # since there is no date variable, 
  # separate the sample into ten period
  n = nrow(df[[i]])
  df[[i]]$period = head(rep(1:10, each = ceiling(n / 10)), n)
}
write.csv(df[[4]], "./fra_text.csv",)

bra_full_text = df[[1]]
countries = c("portugal", "world", "cup", "england", "croatia", " argentina", 
  "france", "morocco", "croatia", "germany", "brazil", "netherlands")
bra_text_clean = df[[1]] %>%
  # filter(period == as.character()) %>%
  select(text) %>%
  unnest_tokens(word, text) %>%
  # remove stop words
  anti_join(stop_words) %>%
  # remove brazil keyword
  filter(!(word %in% countries)) %>%
  filter(!(word %in% c("im", "dont", "didnt", "gonna",
                       "1", "2", "3", "4"))
  )

for (i in 1:10) {
  text_clean = df[[2]] %>%
    filter(period == as.character(i)) %>%
    select(text) %>%
    unnest_tokens(word, text) %>%
    # remove stop words
    anti_join(stop_words) %>%
    # remove brazil keyword
    filter(!(word %in% countries)) %>%
    filter(!(word %in% c("argentina", "im", "dont", "didnt", "gonna",
      "1", "2", "3", "4"))
      )
  plot = text_clean %>%
    count(word, sort = TRUE) %>%
    top_n(20) %>%
    mutate(word = reorder(word, n)) %>%
    ggplot(aes(word, n)) +
    geom_col() +
    xlab(NULL) +
    coord_flip() + 
    ggtitle(paste0("day", i, ">> word count")) + 
    theme(plot.title = element_text(hjust = 0.5))
  print(plot)
  sentiments <- text_clean %>%
    inner_join(get_sentiments("bing"), by = c(word = "word") )%>%
    count(word, sentiment, sort = TRUE) 
  sent_plot = sentiments %>%
    top_n(20)%>%
    mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
    mutate(word = reorder(word, n)) %>%
    ggplot(aes(word, n, fill = sentiment)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ylab("Contribution to sentiment") + 
    coord_flip() + 
    ggtitle(paste0("day", i, "  >> sentiments")) + 
    theme(plot.title = element_text(hjust = 0.5))
  print(sent_plot)
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
  pie_plot = ggplot(pie_data, aes(x = "", y = prop, fill = type)) +
    geom_col() +
    geom_label(aes(label = labels),
               position = position_stack(vjust = 0.5),
               show.legend = FALSE) +
    coord_polar(theta = "y") + 
    ggtitle(paste0("day", i, "  >> sentiments proportion")) + 
    theme(plot.title = element_text(hjust = 0.5))
  print(pie_plot)
  Sys.sleep(10)
}
  
bra_sentiments <- bra_text_clean %>%
  inner_join(get_sentiments("bing"), by = c(word = "word"))

sent = bra_sentiments %>%
  count(word, sentiment, sort = TRUE) %>%
  top_n(20) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Contribution to sentiment") + 
  coord_flip()

sent

bra_text_count = count(bra_text_clean, word)
wordcloud(words = bra_text_count$word, freq = bra_text_count$n, min.freq = 20,
  max.words = 200,  random.order=FALSE, rot.per=0.35, colors=brewer.pal(8, "Dark2"))


# comparison cloud
library(reshape2)

sentiments %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F71735", "#090446"),
    max.words = 100, match.colors = TRUE, title.size = 1, scale = c(10, 1),  main="Title") 
text(x=0.5, y=0.9, "Comparison Cloud", cex = 2.5)


sen = get_nrc_sentiment(df[[2]]$text)
barplot(colSums(sen),
        las = 2,
        col = rainbow(10),
        ylab = 'Count',
        main = 'Sentiment Scores Tweets')

bra_cont = df[[1]] %>%
  filter(period == 1) %>%
  head(10)
for (i in 2:10) {
  temp = df[[1]] %>%
    filter(period == i) %>%
    head(10)
  bra_cont = cbind(bra_cont, temp)
  
}

bra_text_clean = df[[1]] %>%
  filter(period == as.character(i)) %>%
  select(text) %>%
  unnest_tokens(word, text) %>%
  # remove stop words
  anti_join(stop_words) %>%
  # remove brazil keyword
  filter(!(word %in% countries)) %>%
  filter(!(word %in% c("argentina", "im", "dont", "didnt", "gonna",
    "1", "2", "3", "4"))
  )
write.csv(bra_text_clean, "./bra_text_clean.csv")



bra_sent_df = data.frame(sent_type, n = colSums(bra_sen))

ggplot(bra_sent_df, aes(sent_type, colSums.bra_sen.)) +
  geom_col() +
  coord_flip()

sentiments <- text_clean %>%
  inner_join(get_sentiments("bing"), by = c(word = "word") )%>%
  count(word, sentiment, sort = TRUE) 
sentiments
