### using packages
library(tidyverse)
library(twitteR)
library(rtweet)

# setting twitter api
# secreting my twitter api
api = dataframe(read.csv("./twitterAPI.csv"))
API_key = api$api_key[1]
API_secret = api$api_secret[1]
Access_token = api$access_token[1]
Access_secret = api$access_secret[1]