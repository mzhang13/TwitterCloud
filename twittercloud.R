source("config.R")
library(twitteR)
library(purrr)
library(tm)
library(wordcloud)
library(RColorBrewer)

# set up OAuth
setup_twitter_oauth(getOption("twitter_consumer_key"),
                    getOption("twitter_consumer_secret"),
                    getOption("twitter_access_token"),
                    getOption("twitter_access_token_secret"))

# Replace string with Twitter handle of interest
handle <- "mzhang13"

# put username in as first argument
raw <- userTimeline(handle, n = 3200)
tweets <- map_df(raw, as.data.frame)
# utf-8-mac conversion solves some pesky processing issues (untested on non-OS X)
tweets$text <- iconv(tweets$text, to = "utf-8-mac")
tweets$text <- unlist(tweets$text)
# tweets$text <- lapply(tweets$text, function(x) gsub("@\\S+", "", x))
# tweets$text <- lapply(tweets$text, function(x) gsub("#\\S+", "", x))
# remove links?

corpus <- Corpus(VectorSource(tweets$text))
corpus <- tm_map(corpus, PlainTextDocument)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, removePunctuation)
wordcloud(corpus, max.words = 100, random.order = FALSE, 
          colors = brewer.pal(12, "Paired")) # add ability to customize colors?

# write.csv(tweets, file = "me.csv")
