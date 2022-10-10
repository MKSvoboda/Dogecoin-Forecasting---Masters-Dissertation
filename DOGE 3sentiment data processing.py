### noise filtering data processing ###




##### Importing modules ##############################################################################

import pickle       # Load movie_review.pkl
import re           # Remove number function uses a RegEx
import numpy as np  # Numpy is used in various places
import pandas as pd
import json


# Tokenization, stopword removal, and lemmatization
import nltk
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.stem.porter import PorterStemmer

# Vectorization
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer

# Load classifiers
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import LinearSVC
from sklearn.svm import SVC

# Load functions for model selection and performance
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold, StratifiedKFold
from sklearn.metrics import precision_score, recall_score, f1_score, accuracy_score
from sklearn.model_selection import GridSearchCV

############################################################################################################

### Loading data


rawtweets = pd.read_excel("D:/Desktop/dogecoin 3/tweet scraping/labeling/dogecoinsixmonths.xlsx", index_col=0) 



#### Processing data ######################################################################################

# recoding nan in the "label" variable to 0
rawtweets["label"] = rawtweets["label"].fillna(0)

#rawtweets["label"] = rawtweets["label"].replace(-1,0)

# transforming from df to list
rawtweets["text"] = rawtweets["text"].astype(str)
tweets = rawtweets.values.tolist()

# keeping only the training dataset for easier computation
tweets = tweets[0:2000]


print(tweets[201])




def remove_url(text):
    return re.sub(r'http\S+', '', text)

tokens = [remove_url(row[0]) for row in tweets]
print(tokens[201])






def remove_hashtag(text):
    return re.sub('#', '', text)

tokens = [remove_hashtag(row) for row in tokens]
print(tokens[0:100])




# Tokenize entire corpus of reviews and make lowercase
from nltk.tokenize.casual import TweetTokenizer

def tokenize(text):
    return TweetTokenizer(r'\w+').tokenize(text)

tokens = [tokenize(row.lower()) for row in tokens]
print(tokens[0:100])







def remove_number(text):
    '''Takes a token and removes the token if it is a number.'''
    # Note that we need to strip whitespace from our tokens. Otherwise, the 
    # numbers proceeded or followed by a space will not be removed.
    return [token for token in text if re.search(r"[+-]?\d+(?:\.\d+)?", token.strip()) == None]

tokens = [remove_number(doc) for doc in tokens]
print(tokens[0:100])













# Load common English stopwords
stops = stopwords.words('english')

# add extra stopwords
print(tokens[0:100])
stops_to_add = [" ","£", "$", ",", ".", "/", ":", "=", "-",'"', "'","’","*", "%","-","“","”",
                ">", "<",")","(","...","","…","#", "@", "$", "u",  "doge", "dogecoin"]
stops = stops + stops_to_add

# Define a function that removes stopwords
def remove_stops(text, stops):
    return [token for token in text if token not in set(stops)]

tokens = [remove_stops(doc, stops) for doc in tokens]

print(tokens[0:100])







# Instantiate an NLTK lemmatizer object
lemmatizer =  WordNetLemmatizer()

def lemmatize(text, lemmatizer):
    return [lemmatizer.lemmatize(token) for token in text]

tokens = [lemmatize(doc, lemmatizer) for doc in tokens]
print(tokens[201])


def stem(text):
    return [PorterStemmer().stem(token) for token in text]

tokens = [stem(token) for token in tokens]
print(tokens[201])





# Prepare data for sklearn. First, get the text
texts = [' '.join(doc) for doc in tokens]

# And then get the "class" variable
positive = [row[1] for row in tweets]






# Split texts
texts_labeled = texts[0:2000]
texts_unlabeled = texts[2000:]

# Split class
positive_labeled = positive[0:2000]
