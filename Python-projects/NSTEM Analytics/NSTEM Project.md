# Predicting NSTEM's LinkedIn Post-Performace


```python
# import packages
import numpy as np
import pandas as pd
import datetime
import re
import nltk
from nltk.stem import PorterStemmer
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from nltk.stem.snowball import SnowballStemmer
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import GridSearchCV

# upload & read data file
xls = pd.ExcelFile('nstem_yr_data.xls')
df1 = pd.read_excel(xls, 'All posts')
```

### Extract hashtags from post titles


```python
# split post titles at '#' to divide hashtags
df1['Hashtags'] = df1['Post title'].str.split("#")

print(df1['Hashtags'])
```

    0      [Which of your students is going to be recogni...
    1      [Learn more about Dr. Patricia Bath.\nAre you ...
    2      [Meet Dorothy Lavinia Brown, the first African...
    3      [Meet Aisha Bowe, a mission engineer at NASA.\...
    4      [This is excellent news because even though it...
                                 ...                        
    218    [As students of all ages make their way throug...
    219    [Meet Gwynne Shotwell, a Mechanical and Aerosp...
    220    [The same tools our retinas use have been foun...
    221    ["Having more women climate scientists could a...
    222    [Meet Estefania Olaiz, Senior Director at NSTE...
    Name: Hashtags, Length: 223, dtype: object
    


```python
# e.g. of what each post looks like
df1['Post title'][0]
```




    "Which of your students is going to be recognized for their STEM efforts this May/June? Membership in NSTEM is a prestigious honor and can open up countless opportunities for your students' future. Don't miss out on this chance to showcase their hard work and dedication. Celebrate your students' achievements with a National STEM Honor Society (NSTEM) Chapter! \n\nStart an NSTEM Chapter today: https://lnkd.in/grn4g36S\n\n#nstem #honorsociety #awards"




```python
# create new column & slice to remove non-hashtag words
df1['Hashtags'] = df1['Hashtags'].str[1:]

# clean df by removing irrelevant columns
df1 = df1.drop(['Post link', 'Campaign name', 'Posted by', 'Campaign end date',
              'Audience', 'Views', 'Clicks', 'Comments', 'Reposts', 'Follows',
             'Content Type', 'Campaign start date', 'Post type', 'Impressions', 'Likes'], axis=1)

df1
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Post title</th>
      <th>Created date</th>
      <th>Click through rate (CTR)</th>
      <th>Engagement rate</th>
      <th>Hashtags</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Which of your students is going to be recogniz...</td>
      <td>03/15/2023</td>
      <td>0.023077</td>
      <td>0.050000</td>
      <td>[nstem , honorsociety , awards]</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Learn more about Dr. Patricia Bath.\nAre you i...</td>
      <td>03/01/2023</td>
      <td>0.024129</td>
      <td>0.050938</td>
      <td>[nstem , nstemhs , Dr.PatriciaBath  , womenins...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Meet Dorothy Lavinia Brown, the first African ...</td>
      <td>03/01/2023</td>
      <td>0.022814</td>
      <td>0.049430</td>
      <td>[nstem , nstemhs , women , womeninstem , minor...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Meet Aisha Bowe, a mission engineer at NASA.\n...</td>
      <td>02/28/2023</td>
      <td>0.061611</td>
      <td>0.097156</td>
      <td>[nstem , nstemhs , science , stem , nasa , spa...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>This is excellent news because even though it ...</td>
      <td>02/08/2023</td>
      <td>0.021552</td>
      <td>0.047414</td>
      <td>[nstem , nstemhs , science , climate , change ...</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>218</th>
      <td>As students of all ages make their way through...</td>
      <td>04/20/2022</td>
      <td>0.030612</td>
      <td>0.061224</td>
      <td>[nstem , nstemhs , inspirationalstemquote , st...</td>
    </tr>
    <tr>
      <th>219</th>
      <td>Meet Gwynne Shotwell, a Mechanical and Aerospa...</td>
      <td>04/19/2022</td>
      <td>0.029630</td>
      <td>0.066667</td>
      <td>[nstem , nstemhs , spaceX , mars , Engineer , ...</td>
    </tr>
    <tr>
      <th>220</th>
      <td>The same tools our retinas use have been found...</td>
      <td>04/18/2022</td>
      <td>0.000000</td>
      <td>0.025641</td>
      <td>[nstem , nstemhs , stem , robotics , automatic...</td>
    </tr>
    <tr>
      <th>221</th>
      <td>"Having more women climate scientists could al...</td>
      <td>04/18/2022</td>
      <td>0.022727</td>
      <td>0.045455</td>
      <td>[nstem , nstemhs , WomenInSTEM , sustainabilit...</td>
    </tr>
    <tr>
      <th>222</th>
      <td>Meet Estefania Olaiz, Senior Director at NSTEM...</td>
      <td>04/18/2022</td>
      <td>0.171429</td>
      <td>0.206593</td>
      <td>[stemhs , nstemhs , stemeducation , stemintern...</td>
    </tr>
  </tbody>
</table>
<p>223 rows × 5 columns</p>
</div>



### Clean hashtag data


```python
# combine hashtag column data to create one list of hashtags
word_list = df1.Hashtags.explode().unique().tolist()

# remove whitespace characters 
word_list = [str(word).strip() for word in word_list]

# remove duplicate words after whitespace character removal
word_list = list(set(word_list))

# remove hashtag words with quotations and links
word_list = [word for word in word_list if word != '' and
             '\n' not in word and 'https' not in word]

# remove other characters within a word
word_list = [word.split('\n')[0] if '\n' in word else word for word in word_list]

# print number of hashtag terms in list
print("No. of hashtags: " + str(len(word_list)))

# print the first few elements of the list
print(word_list[:10])
```

    No. of hashtags: 858
    ['Technology', 'savetheearth', 'green', 'CampInvention', 'womeninste', 'teach', 'england', 'inclusion', 'snapchat', 'Edison']
    

### Stem hashtag terms


```python
# create an instance of the PorterStemmer class
porter = PorterStemmer()

# define a list of words to stem
words = word_list

# stem each word in the list
stemmed_words = [porter.stem(word) for word in words]

# print first few elements of the stemmed words
print(stemmed_words[:10])
```

    ['technolog', 'savetheearth', 'green', 'campinvent', 'womeninst', 'teach', 'england', 'inclus', 'snapchat', 'edison']
    

### Feature Engineering


```python
# define the stemmer and the list of words
stemmer = SnowballStemmer('english')

# define the custom analyzer
class StemmedCountVectorizer(CountVectorizer):
    def __init__(self, stemmer=None, **kwargs):
        if stemmer is None:
            stemmer = SnowballStemmer('english')
        self.stemmer = stemmer
        super().__init__(**kwargs)
    
    def build_analyzer(self):
        analyzer = super().build_analyzer()
        return lambda doc: [self.stemmer.stem(w) for w in analyzer(doc)]

# create the vectorizer and the matrix of word counts
vectorizer = StemmedCountVectorizer(binary=True, vocabulary=word_list, stemmer=stemmer)
matrix = vectorizer.fit_transform(df1["Post title"])
words_df = pd.DataFrame(matrix.toarray(), columns=vectorizer.get_feature_names())

# print the first few columns
print(words_df.iloc[:, :4])
```

         Technology  savetheearth  green  CampInvention
    0             0             0      0              0
    1             0             0      0              0
    2             0             0      0              0
    3             0             0      0              0
    4             0             0      0              0
    ..          ...           ...    ...            ...
    218           0             0      0              0
    219           0             0      0              0
    220           0             0      0              0
    221           0             0      0              0
    222           0             0      0              0
    
    [223 rows x 4 columns]
    

    C:\ProgramData\Anaconda3\lib\site-packages\sklearn\feature_extraction\text.py:1322: UserWarning: Upper case characters found in vocabulary while 'lowercase' is True. These entries will not be matched with any documents
      warnings.warn(
    C:\ProgramData\Anaconda3\lib\site-packages\sklearn\utils\deprecation.py:87: FutureWarning: Function get_feature_names is deprecated; get_feature_names is deprecated in 1.0 and will be removed in 1.2. Please use get_feature_names_out instead.
      warnings.warn(msg, category=FutureWarning)
    


```python
# combine the actual df & the words_df together
df_final = pd.concat([df1, words_df], axis=1)

# remove hashtags column
df_final = df_final.drop(['Hashtags', 'Click through rate (CTR)'], axis=1)

# rename target column
df_final = df_final.rename(columns={'Engagement rate': 'Target'})

df_final
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Post title</th>
      <th>Created date</th>
      <th>Target</th>
      <th>Technology</th>
      <th>savetheearth</th>
      <th>green</th>
      <th>CampInvention</th>
      <th>womeninste</th>
      <th>teach</th>
      <th>england</th>
      <th>...</th>
      <th>day</th>
      <th>bodyfluids</th>
      <th>female</th>
      <th>pridemoth</th>
      <th>SirIsaacNewton</th>
      <th>pollution</th>
      <th>ruralconnectivity</th>
      <th>Wateraccess</th>
      <th>elementarystemteachers</th>
      <th>seniorsenvironment</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Which of your students is going to be recogniz...</td>
      <td>03/15/2023</td>
      <td>0.050000</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Learn more about Dr. Patricia Bath.\nAre you i...</td>
      <td>03/01/2023</td>
      <td>0.050938</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Meet Dorothy Lavinia Brown, the first African ...</td>
      <td>03/01/2023</td>
      <td>0.049430</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Meet Aisha Bowe, a mission engineer at NASA.\n...</td>
      <td>02/28/2023</td>
      <td>0.097156</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>This is excellent news because even though it ...</td>
      <td>02/08/2023</td>
      <td>0.047414</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>218</th>
      <td>As students of all ages make their way through...</td>
      <td>04/20/2022</td>
      <td>0.061224</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>219</th>
      <td>Meet Gwynne Shotwell, a Mechanical and Aerospa...</td>
      <td>04/19/2022</td>
      <td>0.066667</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>220</th>
      <td>The same tools our retinas use have been found...</td>
      <td>04/18/2022</td>
      <td>0.025641</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>221</th>
      <td>"Having more women climate scientists could al...</td>
      <td>04/18/2022</td>
      <td>0.045455</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>222</th>
      <td>Meet Estefania Olaiz, Senior Director at NSTEM...</td>
      <td>04/18/2022</td>
      <td>0.206593</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>...</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
<p>223 rows × 861 columns</p>
</div>



### Create Train/Test Sets


```python
# set the X as features & y as the target variable
X = words_df
y = df_final['Target']

# split the features & Target into training & testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
```

### Feature Selection


```python
# perform feature selection using SelectKBest and f_regression
selector = SelectKBest(f_regression, k=10)
X_train_best = selector.fit_transform(X_train, y_train)

# Transform the test set using the same feature selection
X_test_best = selector.transform(X_test)

# print selected features
print(X_train.columns[selector.get_support()])
```

    Index(['intern', 'steminternship', 'savetheplanet', 'importancestem',
           'gogreen', 'collegeinternship', 'focus', 'highschoolinternship',
           'springseason', 'research'],
          dtype='object')
    

    C:\ProgramData\Anaconda3\lib\site-packages\sklearn\feature_selection\_univariate_selection.py:289: RuntimeWarning: invalid value encountered in true_divide
      correlation_coefficient /= X_norms
    

### Train & Evaluate Selected Features


```python
# training model on selected features
model = LinearRegression()
model.fit(X_train_best, y_train)

# evaluate the model performance
y_pred = model.predict(X_test_best)
r2 = r2_score(y_test, y_pred)
mae = mean_absolute_error(y_test, y_pred)
mse = mean_squared_error(y_test, y_pred)
rmse = mean_squared_error(y_test, y_pred, squared=False)
```


```python
# print evaluation metrics
print("R-squared:", r2)
print("Mean Absolute Error:", mae)
print("Mean Squared Error:", mse)
print("Root Mean Squared Error:", rmse)
```

    R-squared: 0.038796547966931993
    Mean Absolute Error: 0.02996878719104211
    Mean Squared Error: 0.0014978205080900672
    Root Mean Squared Error: 0.038701686114303434
    


```python
# print the feature importance scores
feature_names = X_train.columns
feature_scores = abs(model.coef_)

# get top n features
n = 5
top_n_idxs = feature_scores.argsort()[::-1][:n]
top_n_features = [feature_names[idx] for idx in top_n_idxs]

# Print the top n features
print(f"The top {n} types of posts that are better Indicators of engagement rate include:")
print(", ".join(top_n_features))
```

    The top 5 types of posts that are better Indicators of engagement rate include:
    snapchat, CampInvention, green, womeninste, inclusion
    

### Hyperparameter Selection


```python
# define hyperparameters
param_grid = {
    'n_estimators': [10, 50, 100, 200],
    'max_depth': [2, 4, 6, 8, 10],
    'min_samples_split': [2, 4, 6, 8],
    'min_samples_leaf': [1, 2, 4]
}

# create a random forest regression model
random_f = RandomForestRegressor(random_state=42)

# perform grid search to tune hyperparameters
grid_search = GridSearchCV(random_f, param_grid, cv=5, n_jobs=-1, verbose=2)
grid_search.fit(X_train, y_train)

# print best hyperparameters & corresponding performance
print("Best hyperparameters:", grid_search.best_params_)
print("Best score:", grid_search.best_score_)

# evaluate model performance on test set
test_score = grid_search.score(X_test, y_test)
print("Test score:", test_score)
```

    Fitting 5 folds for each of 240 candidates, totalling 1200 fits
    Best hyperparameters: {'max_depth': 6, 'min_samples_leaf': 4, 'min_samples_split': 2, 'n_estimators': 10}
    Best score: 0.0633389614869275
    Test score: 0.14641361834111666
    
