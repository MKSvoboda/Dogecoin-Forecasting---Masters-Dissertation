##### VADER DATA PROCESSING #####

import pandas as pd
from nltk.sentiment.vader import SentimentIntensityAnalyzer
analyzer = SentimentIntensityAnalyzer()


rawtweets = pd.read_excel("D:/Desktop/dogecoin 3/NLP analysis/python/fully labeled data/dogecoin3svmlabeled.xlsx", index_col=0) 

tweets = rawtweets
#tweets = rawtweets[0:2000]
tweets = tweets.rename(columns={"label":"svmlabel"})

tweets["text"] = tweets["text"].astype(str)

##### text cleaning #############################################################################
tweets["text2"] = tweets["text"].str.lower()

tweets["text2"] = tweets["text2"].str.replace('#','')
tweets["text2"] = tweets["text2"].str.replace('$','')
tweets["text2"] = tweets["text2"].str.replace('-','')
tweets["text2"] = tweets["text2"].str.replace('"','')
tweets["text2"] = tweets["text2"].str.replace(':','')
tweets["text2"] = tweets["text2"].str.replace('!',' ! ')
tweets["text2"] = tweets["text2"].str.replace('?',' ? ')
tweets["text2"] = tweets["text2"].str.replace('&',' ')
tweets["text2"] = tweets["text2"].str.replace("'",' ')
tweets["text2"] = tweets["text2"].str.replace(',',' ')
tweets["text2"] = tweets["text2"].str.replace('@',' ')
tweets["text2"] = tweets["text2"].str.replace('','')
tweets["text2"] = tweets["text2"].str.replace('','')






##### text niche vocabulary conversion ###########################################################

analyzer.polarity_scores("!")




tweets["text2"] = tweets["text2"].str.replace('bull',' great ')
tweets["text2"] = tweets["text2"].str.replace('moon',' great ')
tweets["text2"] = tweets["text2"].str.replace('pump',' great ')
tweets["text2"] = tweets["text2"].str.replace('fire',' great ')
tweets["text2"] = tweets["text2"].str.replace('🚀',' great ')
tweets["text2"] = tweets["text2"].str.replace('🔥',' great ')
tweets["text2"] = tweets["text2"].str.replace('⬆️',' great ')
tweets["text2"] = tweets["text2"].str.replace('💛',' love ')
tweets["text2"] = tweets["text2"].str.replace('❤️',' love ')
tweets["text2"] = tweets["text2"].str.replace('','')


tweets["text2"] = tweets["text2"].str.replace('bear',' bad ')
tweets["text2"] = tweets["text2"].str.replace('red',' bad ')





x = tweets["text2"]
print(x[0:100])

##### vader analysis #####################################################################





tweets["vaderlabel"] = [analyzer.polarity_scores(i)["compound"] for i in tweets["text2"]]


##### saving #################################################################################

tweets = tweets.drop('text2', axis=1)

from pathlib import Path  

filepath = Path("D:/Desktop/dogecoin 3/NLP analysis/python/fully labeled data/dogecoin3fullylabeled.csv")  
filepath.parent.mkdir(parents=True, exist_ok=True)  
tweets.to_csv(filepath, index=False) 