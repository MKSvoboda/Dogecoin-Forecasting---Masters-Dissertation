##### visualization script #####

##### non-function #####


##### function ############################################################################################

bsviz <- function(data, min, max){
  
  df <- data.frame(seq(min, max, 0.01))
  df <- rename(df, threshold = "seq.min..max..0.01." )

  #######################################################
  
  for (threshold in df$threshold){
    
    data2 <- ts
    
    data2 <- data2 %>%
      mutate(ssbin = case_when(
        sentimentshift > threshold ~ 1,
        sentimentshift >= -threshold & sentimentshift <= threshold ~ 0,
        sentimentshift < -threshold ~ -1))
    
    data2 <- data2 %>%
      mutate(csbin = case_when(
        closeshift > 0 ~ 1,
        closeshift < -0 ~ -1))
    
    
 
    
    data3 <- filter(data2, ssbin != 0)
    df$accuracyshift0[df$threshold == threshold] <- sum(data3$csbin == data3$ssbin, na.rm = TRUE)/length(data3$csbin == data3$ssbin)
    #######################################################
    
    data2 <- data2 %>% mutate(csbin=lag(csbin))
  
    data3 <- filter(data2, ssbin != 0)
    df$accuracyshift1[df$threshold == threshold] <- sum(data3$csbin == data3$ssbin, na.rm = TRUE)/length(data3$csbin == data3$ssbin)
    #######################################################
    
    data2 <- data2 %>% mutate(csbin=lag(csbin))
    
    data3 <- filter(data2, ssbin != 0)
    df$accuracyshift2[df$threshold == threshold] <- sum(data3$csbin == data3$ssbin, na.rm = TRUE)/length(data3$csbin == data3$ssbin)
    #######################################################
    
    data2 <- data2 %>% mutate(csbin=lag(csbin))
    
    data3 <- filter(data2, ssbin != 0)
    df$accuracyshift3[df$threshold == threshold] <- sum(data3$csbin == data3$ssbin, na.rm = TRUE)/length(data3$csbin == data3$ssbin)
    df$numberofpredictions[df$threshold == threshold] <- nrow(data3)
    #######################################################
  }
  df
  
  
  
}

#################################################################################################################################################






df <- bsviz(ts, 0.01, 0.5)





ggplot(data = filter(df, numberofpredictions >= 10), aes(x = threshold)) + 
  geom_line(aes(y = accuracyshift0*100, color = "#F8766D"), size = 1) +
  geom_line(aes(y = accuracyshift1*100, color = "#D39200"), size = 1) +
  geom_line(aes(y = accuracyshift2*100, color = "#00B9E3"), size = 1) +
  geom_line(aes(y = accuracyshift3*100, color = "#93AA00"), size = 1) +
  geom_hline(yintercept = 50) +
  
  theme(text = element_text(size = 15),plot.title = element_text(hjust = 0.5), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+ 
  
  labs(title = "",x = "Signal Threshold", y = "Prediction Accuracy") + ylim(0,100) +
  
  scale_color_identity(name = "Time Shift", breaks = c("#F8766D", "#D39200", "#00B9E3", "#93AA00"),
                       labels = c("Present", "1 Period", "2 Periods", "3 Periods"),guide = "legend")



