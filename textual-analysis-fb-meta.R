install.packages(c("tidyverse", "tidytext", "ggplot2", "sentimentr", "widyr",
                   "tm", "topicmodels", "ldatuning", "ggraph", "rtweet"))

library(tidyverse)
library(tidytext)

data <- readRDS("C:/Users/lilya/Downloads/tweetdf.Rdata")

data_tidy <- data %>%
  tidytext::unnest_tokens(word, text, token = "words") 

data_tidy <- data_tidy %>%
  select(user_id, word) %>%
  anti_join(tidytext::stop_words) %>%
  filter(!grepl('t.co|https', word))


#1. Which words are most commonly used in the dataset?

data_count <- data_tidy %>%
  group_by(word) %>%
  summarize(n=n()) %>%
  slice_max(order_by = n, n = 25) %>%
  arrange(desc(n))
data_count

#2. Do you find anything interesting when looking at a word cloud of the data?

install.packages("RColorBrewer")
library(RColorBrewer)
install.packages("wordcloud2")
library(wordcloud2)

wordcloud2(data=data_count, size=1.6, color='random-dark')

#From the world cloud we can see that people talk a lot about crypto currencies
#like bitcoin, dogecoin, nft, etc, because these are the most popular words after
#social media platform names(facebook, meta, etc).

#3. What are the most common sentiments in the tweets?

data_tidy_nrc <- data_tidy %>%
  group_by(user_id, word) %>%
  summarise(n = n()) %>%
  tidytext::bind_tf_idf(word, user_id, n) %>%
  inner_join(
    tidytext::get_sentiments("nrc")) %>%
  ungroup()

data_tidy_sent <- data_tidy_nrc %>%
  group_by(sentiment) %>%
  summarize(n= n()) %>%
  arrange(desc(n))

data_tidy_sent

# The most common sentiments are the following: positive: 940, trust: 502,
# negative: 458, anticipation: 431
