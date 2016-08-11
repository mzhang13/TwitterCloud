source("config.R")
library(shiny)
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

shinyServer(
  function(input, output, session) {
    # set up reactivity for table
    values <- reactiveValues()
    
    # create a reactive corpus
    corpus <- reactive({
      input$execute
      isolate({
        withProgress({
          setProgress(message = "Requesting tweets...")
          handle <- input$handle
          
          raw <- userTimeline(handle, n = 3200)
          tweets <- map_df(raw, as.data.frame)
          # for displaying sample tweets
          values$sample <- tweets$text
          
          setProgress(message = "Processing corpus...")
          tweets$text <- lapply(tweets$text, function(x) gsub("@\\S+", "", x))
          tweets$text <- lapply(tweets$text, function(x) gsub("#\\S+", "", x))
          
          corpus <- Corpus(VectorSource(tweets$text))
          corpus <- tm_map(corpus, PlainTextDocument)
          corpus <- tm_map(corpus, removeWords, stopwords("en"))
          corpus <- tm_map(corpus, removePunctuation)
        })
      })
    })
    
    output$cloud <- renderPlot({
      for_cloud <- corpus()
      wordcloud(for_cloud, max.words = 100, random.order = FALSE, 
                colors = brewer.pal(12, "Paired")) # add ability to customize colors?
    })

    output$tweets <- renderTable({
      # show first 10 tweets from the user
      tweets <- data.frame(head(values$sample, n = 10))
      colnames(tweets) <- c("tweet")
      tweets
    })
  }
)