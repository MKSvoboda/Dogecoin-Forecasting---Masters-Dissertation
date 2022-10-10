############## LABELING ALL DATA CV SVC Weighted ###################################



clf = LinearSVC(class_weight=cwd)

# Fit the model using the training data
# generated above.
clf_fit = clf.fit(X,y)


X_unlabeled = vectorizer.transform(texts_unlabeled)


y_predictunlabeled = clf_fit.predict(X_unlabeled)
print(y_predictunlabeled[0:10])




#### saving data

ydf = pd.DataFrame(y)
y_predictdf = pd.DataFrame(y_predict)

alllabels = np.append(y,y_predictunlabeled)
len(alllabels)


tweetslabeled = rawtweets
tweetslabeled['label'] = alllabels.tolist()







tweetslabeled.to_excel("D:/Desktop/dogecoin 3/NLP analysis/python/fully labeled data/dogecoin3svmlabeled.xlsx")


