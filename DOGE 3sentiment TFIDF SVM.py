############## TFIDF SVC noise #################################


# Initialize vectorizer
vectorizer = TfidfVectorizer(min_df=1, max_df=100)

# Generate TF-IDF weights
X = vectorizer.fit_transform(texts_labeled)

print(X.shape)




# Get our labels in a format that sklearn likes
y = np.array(positive_labeled) # sklearn wants numpy arrays!

# Split data into training and testing sets. 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=1234)











####### Computing class weights
from sklearn.utils import compute_class_weight

def compute_class_weight_dictionary(y):
    # helper for returning a dictionary instead of an array
    classes = np.unique(y)
    class_weight = compute_class_weight("balanced", classes, y)
    class_weight_dict = dict(zip(classes, class_weight))
    return class_weight_dict 



cwd = compute_class_weight_dictionary(y)
print(cwd)










# Initialize the classifer
clf = LinearSVC(class_weight=cwd)

# Fit the model using the training data
# generated above.
clf_fit = clf.fit(X_train, y_train)

# Generate predictions
y_predict = clf_fit.predict(X_test)

# Output performance metrics
print("Accuracy score = %s" % accuracy_score(y_test, y_predict))
print('Precision score = %s' % precision_score(y_test, y_predict, average='macro'))
print('Recall score = %s' % recall_score(y_test, y_predict, average='macro'))
print('F1 score = %s' % f1_score(y_test, y_predict, average='macro'))









#### CROSS VALIDATION ######################################################

clf = LinearSVC(class_weight=cwd, loss = "squared_hinge")



# Get the k folds
kf = KFold(n_splits=30, shuffle = True, random_state=50)

# Loop over folds and calculate performance measure
results = []
for k, (train_idx, test_idx) in enumerate(kf.split(X)):
    # Fit model
    cfit = clf.fit(X[train_idx], y[train_idx])
    
    # Get predictions
    y_pred = cfit.predict(X[test_idx])
    
    # Write results
    result = {'fold': k,
              'accuracy': accuracy_score(y[test_idx], y_pred),
              'precision': precision_score(y[test_idx], y_pred, average = "macro"),
              'recall': recall_score(y[test_idx], y_pred, average = "macro"),
              'f1': f1_score(y[test_idx], y_pred, average = "macro")}
              
    results.append(result)
    
    
print(results)





# Get the average scores
mean_accuracy = np.mean(np.array([row['accuracy'] for row in results]))
mean_f1 = np.mean(np.array([row['f1'] for row in results]))
mean_precision = np.mean(np.array([row['precision'] for row in results]))
mean_recall = np.mean(np.array([row['recall'] for row in results]))


print("Average, cross-validated accuracy score = %s" % mean_accuracy)
print("Average, cross-validated precision score = %s" % mean_precision)
print("Average, cross-validated recall score = %s" % mean_recall)
print("Average, cross-validated F1 score = %s" % mean_f1)




from sklearn.metrics import confusion_matrix

confusion_matrix(y_test, y_predict, labels=[1, 0, -1])/10



