### using packages
library(tidyverse)
library(twitteR)
library(remoji)

### setting twitter api
# read my twitter api
loc =  "/Users/liuchenyu/Desktop/worldcup_textmining/data/twitterAPI.csv"
loc = "/home/chanyu/Desktop/school/webscrapping/project/data/"
api = read.csv(loc)
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
  
}
