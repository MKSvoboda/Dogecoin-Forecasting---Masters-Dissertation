##### dogecoin  DATA ANALYSIS 2 hours #####


library(tidyverse)
library(lubridate)
library(lmtest)
library(DataCombine)
library(NlinTS)

rawtweets <- read.csv('D:/Desktop/dogecoin 3/NLP analysis/python/fully labeled data/dogecoin3fullylabeled.csv')
rawdogecoin <- read.csv('D:/Desktop/dogecoin 3/forecasting/Gemini_DOGEUSD_1h.csv')






##### DATA PREP ####################################################################################################################
####################################################################################################################################

##### processing tweets 

tweets <- rawtweets

# checking the proportion of label classes between human and machine labeled data
prop.table(table(filter(tweets,training == 1)$label))
prop.table(table(filter(tweets,training == 0)$label))

##### assigning 4 hour intervals

tweets$twohours <- cut(tweets$hour, breaks = 2172)




##### processing dogecoin price data
dogecoin <- filter(rawdogecoin, ymd_hms(date) %in% c(ymd_hms("2022-01-01 00:00:00"): ymd_hms("2022-06-30 23:59:59")))

# assigning "hour" variable
dogecoin$timex <- gsub('.{6}$', '', dogecoin$date)

dogecoin$hour <- difftime(ymd_hms("2022-01-01T00:00:00"), ymd_h(dogecoin$timex), units = "hours")
dogecoin$hour <- gsub(' hours', '', dogecoin$hour)
dogecoin$hour <- gsub('-', '', dogecoin$hour)
dogecoin$hour <- as.numeric(dogecoin$hour)
dogecoin$hour <- dogecoin$hour+1

dogecoin$hour <- as.factor(dogecoin$hour)
dogecoin$timex <- NULL

# cutting into twohours sections


dogecoin$twohours <- cut(as.numeric(dogecoin$hour), breaks = 2172)
dogecoin$twohours <- as.numeric(dogecoin$twohours)

dogecoin <- dogecoin %>%
  group_by(twohours) %>%
  summarise_at(vars(close), list(frequency = mean))
dogecoin <- rename(dogecoin, close = frequency)




###### creating an hourly timeseries twitter sentiment and dogecoin price dataset
x <- tweets %>%
  group_by(twohours) %>%
  summarise_at(vars(svmlabel), list(frequency = sum))
x$twohours <- c(1:2172)

y <- tweets %>%
  group_by(twohours) %>%
  summarise_at(vars(svmlabel), list(frequency = mean))
y$twohours <- c(1:2172)



tstwitter <- full_join(x,y, by = "twohours")
tstwitter <- rename(tstwitter, frequency = "frequency.x")
tstwitter <- rename(tstwitter, meansentiment = "frequency.y")

ts <- full_join(tstwitter, dogecoin, by = "twohours")

# converting to dataframe
ts <- data.frame(ts)

ts$period <- c(1:2172)




# adding 1 period (hour) shift variables for sentiment and price
#ts <- PercChange(ts, Var = "meansentiment", type = "percent", NewVar = "sentimentshift", slideBy = -1)
#ts <- PercChange(ts, Var = "close", type = "percent", NewVar = "closeshift", slideBy = -1)
ts$sentimentshift <- append(c(NA), diff(ts$meansentiment, lag = 1, differences = 1))
ts$closeshift <- append(c(NA), diff(ts$close, lag = 1, differences = 1))



#####  outlier removal (optional)




##### ANALYSIS #####################################################################################################################
####################################################################################################################################
summary(lm(closeshift~meansentiment, data = ts))
summary(lm(closeshift~sentimentshift, data = ts))

##### GRANGER TESTS ################################################################################################################



# granger of %closing price change ~ %mean sentiment change with 1 hour lag
grangertest(closeshift ~ sentimentshift, order = 1, data = ts)



a <- na.omit(ts$sentimentshift)
b <- na.omit(ts$closeshift)

nlin_causality.test (b, a, 2, LayersUniv = c(10), LayersBiv = c(20), iters = 20, 0.01, seed = 1432, "sgd", 30, TRUE, 5)$summary ()








coeff <- 10

ggplot(data = ts, aes(x = period)) +
  
  geom_line(aes(y = closeshift),  color = "blue") + 
  geom_line(aes(y = sentimentshift/coeff), color = "red") +
  
  scale_y_continuous(name = "First Axis", sec.axis = sec_axis(~.*coeff, name="Second Axis")) +
  
  xlim(0,30)


##### buy sel model 

threshold <- 0.35

ts2 <- ts

ts2 <- ts2 %>%
  mutate(ssbin = case_when(
    sentimentshift > threshold ~ 1,
    sentimentshift >= -threshold & sentimentshift <= threshold ~ 0,
    sentimentshift < -threshold ~ -1))

ts2 <- ts2 %>%
  mutate(csbin = case_when(
    closeshift > 0.00001 ~ 1,
    closeshift >= -0.00001 & closeshift <= 0.00001 ~ 0,
    closeshift < -0.00001 ~ -1))


ts2 <- ts2 %>% mutate(csbin=lag(csbin))





ts3 <- filter(ts2, ssbin != 0)
prop.table(table(ts3$csbin == ts3$ssbin))

