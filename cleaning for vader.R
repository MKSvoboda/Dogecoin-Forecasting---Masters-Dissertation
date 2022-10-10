##### Cleaning for vader #####

library(tidyverse)
library(readxl)
library(writexl)


rawtweets <- read_xlsx("D:/Desktop/dogecoin 3/NLP analysis/python/fully labeled data/dogecoin3svmlabeled.xlsx")

tweets <- rawtweets



tweets$text2 <- tolower(tweets$text)



tweets$text <- gsub("bull", " bull ", tweets$text)
tweets$text <- gsub("bear", " bear", tweets$text)

tweets$text <- gsub("bull", "great", tweets$text)
tweets$text <- gsub("moon", "great", tweets$text)
tweets$text <- gsub("mooon", "great", tweets$text)
tweets$text <- gsub("moooon", "great", tweets$text)
tweets$text <- gsub("bear", "bad", tweets$text)
tweets$text <- gsub("red", "bad", tweets$text)
tweets$text <- gsub("candle", "bad", tweets$text)



write_xlsx(tweets, "D:/Desktop/dogecoin 3/sentiment analysis/vader/preparedforvader.xlsx")
