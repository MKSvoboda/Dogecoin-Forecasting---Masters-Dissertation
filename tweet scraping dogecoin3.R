### Dissertation tweet scraping dogecoin


library(tidyverse)
library(academictwitteR)
library(writexl)
library(readxl)
library(lubridate)

#set_bearer()
get_bearer()

######################################################################
processtweets <- function(data){
  
  data <-select(data,!c(entities, withheld,attachments))
  
  data$like_count <- data$public_metrics$like_count
  data$retweet_count <- data$public_metrics$retweet_count
  data$reply_count <- data$public_metrics$reply_count
  
  data$public_metrics <- NULL
  
  data$geo <- NULL
  
  data$referenced_tweets <- NULL
  
  data$possibly_sensitive <- NULL
  
  data
}
#######################################################################




### SCRAPING ###########################################################################################


query <- build_query(query = "dogecoin", is_retweet = FALSE, is_reply = FALSE, lang = "en")


count_all_tweets(query = query,
                 start_tweets = "2022-01-01T00:00:00Z",
                 end_tweets = "2022-07-01T00:00:00Z",
                 bearer_token = get_bearer(),
                 granularity = "hour",
                 n = 720)




tweetsraw <-
  get_all_tweets(
    query = query,
    start_tweets = "2022-01-01T00:00:00Z",
    end_tweets = "2022-07-01T00:00:00Z",
    n = 5000000
  )



### DATA PROCESSING #######################################################################################

# removing list and matrix variables
tweets <- processtweets(tweetsraw)

#removing language variable (all tweets are in english)

tweets$lang <- NULL

# creating an ID variable
tweets$ID <- seq_along(tweets[,1])


### recoding time

# a new time variable
tweets$time <- tweets$created_at


# convert time into standard format
tweets$time <- gsub(".000Z", "", tweets$time)


# create a new variable by hours and convert it into a factor
tweets$timex <- gsub('.{6}$', '', tweets$time)

tweets$hour <- difftime(ymd_hms("2022-01-01T00:00:00"), ymd_h(tweets$timex), units = "hours")
tweets$hour <- gsub(' hours', '', tweets$hour)
tweets$hour <- gsub('-', '', tweets$hour)
tweets$hour <- as.numeric(tweets$hour)
tweets$hour <- tweets$hour+1

tweets$hour <- as.factor(tweets$hour)
tweets$timex <- NULL



#delete created_at variable
tweets$created_at <- NULL
















##### Filtering (cleaning) ###################


# making lowercase
tweets$text2 <- tolower(tweets$text)

tweets <- filter(tweets, !grepl("prediction", tweets$text2))
tweets <- filter(tweets, !grepl("current", tweets$text2))
tweets <- filter(tweets, !grepl("wallet", tweets$text2))


tweets <- filter(tweets, !grepl("game", tweets$text2))
tweets <- filter(tweets, !grepl("% off", tweets$text2))
tweets <- filter(tweets, !grepl("join", tweets$text2))
tweets <- filter(tweets, !grepl("gift", tweets$text2))
tweets <- filter(tweets, !grepl("offer", tweets$text2))
tweets <- filter(tweets, !grepl("sign up", tweets$text2))
tweets <- filter(tweets, !grepl("faucet", tweets$text2))
tweets <- filter(tweets, !grepl("affiliatemarketing", tweets$text2))
tweets <- filter(tweets, !grepl("earn", tweets$text2))
tweets <- filter(tweets, !grepl("&amp", tweets$text2))
tweets <- filter(tweets, !grepl("impulse", tweets$text2))
tweets <- filter(tweets, !grepl("opensea", tweets$text2))
tweets <- filter(tweets, !grepl("motivation", tweets$text2))





























# creating a variable to manually label relevance
tweets$label <- NA

### selecting and labeling a training subset n=10000


tsid <- sample(tweets$ID, 2000, replace = F)



tweets$training <- ifelse(tweets$ID %in% tsid, 1, 0)

table(tweets$training)



### reordering

head(tweets)

#reorder columns
tweets <- subset(tweets, select=c("ID","text","label","training","hour", "time", "like_count", "retweet_count", "reply_count", "source", "id", "author_id", "conversation_id"))

#reorder rows to have training data on top
tweets <- tweets %>% arrange(desc(training))



### saving


### export as .xlsx
write_xlsx(tweets,"D:/Desktop/dogecoin 3/tweet scraping/dogecoinsixmonths.xlsx")

