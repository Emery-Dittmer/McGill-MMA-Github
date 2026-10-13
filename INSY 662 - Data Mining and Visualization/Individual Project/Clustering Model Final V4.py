## Developing the model ###

# Load Libraries
from sklearn.tree import DecisionTreeClassifier
import pandas as pd
import numpy as np

# Import data
kickstarter_df = pd.read_excel("Kickstarter.xlsx")

#%% Pre-Processing
'''
Clean all the data in this section
'''
def data_cleaner(df):
    df = df.dropna()
    
    #define states to keep
    states = ["successful", "failed"]
    
    #drop rows that contain any value in the list
    df = df[df.state.isin(states) == True]
    
    #convert goal to usd
    df["goal_inUS"]=df["goal"]*df["static_usd_rate"]
    
    df=feature_eng(df)
    
    # Setup the variables
    #list(kickstarter_df.columns)
    df = df[[#'id',
#    # 'name',
#     'goal',
#     'pledged',
     'state',
#     'disable_communication',
     'country',
#     'currency',
     #'deadline',
     #'state_changed_at',
     #'created_at',
     #'launched_at',
     'staff_pick',
     'backers_count',
#     'static_usd_rate',
#     'usd_pledged',
     'category',
     'spotlight',
     'name_len',
#    'name_len_clean',
     'blurb_len',
#    'blurb_len_clean',
#    'deadline_weekday',
#    'state_changed_at_weekday',
#     'created_at_weekday',
#     'launched_at_weekday',
     'deadline_month',
     'deadline_day',
     'deadline_yr',
     'deadline_hr',
#     'state_changed_at_month',
#     'state_changed_at_day',
#     'state_changed_at_yr',
#     'state_changed_at_hr',
#     'created_at_month',
#     'created_at_day',
#     'created_at_yr',#>
     'created_at_hr',#>
    'launched_at_month',
     'launched_at_day',
     'launched_at_yr',
#>     'launched_at_hr',
    'create_to_launch_days',
#    'launch_to_state_change_days',
     'launch_to_deadline_days',
#     'goal_inUS',
    'Relative_Goal'
]]
    
    df=get_dummies(df)
    #df=standardize(df)
    return df

def get_dummies(df):
    df=pd.get_dummies(df)
    return df

def standardize(df):
    #standardize inputs
    from sklearn.preprocessing import StandardScaler
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(df)
    df=pd.DataFrame(scaled_features, index=df.index, columns=df.columns)
    return(df)

def feature_eng(df):
    df['Relative_Goal'] = np.floor(np.log10(df['goal_inUS']))
    #df['Count_Release'] = np.power(df.groupby('Dummy1')['Dummy1'].transform('count'),4)
    #df=df.drop('Dummy1',axis=1)
    return df

X = data_cleaner(kickstarter_df)


#%% Model
from sklearn.metrics import silhouette_score
from sklearn.cluster import KMeans

#sklearn clustering model
for i in range (2,8): 
    Kmeans=KMeans(n_clusters=i)
    model=Kmeans.fit(X)
    labels2 = model.labels_
    if i==6:
      knn_table=pd.DataFrame(model.cluster_centers_,columns=X.columns.tolist())
      sc=silhouette_score(X,labels2)
      print("This is a table of the cluster centers used to gleam insights from")
      with pd.option_context('display.max_rows', None, 'display.max_columns', None):
          print(knn_table)

#%% All research 
# ## Developing the model ###

# # Load Libraries
# from sklearn.tree import DecisionTreeClassifier
# import pandas as pd
# import numpy as np
#from sklearn.model_selection import GridSearchCV

# # Import data
# kickstarter_df = pd.read_excel("Kickstarter.xlsx")

# #%% Pre-Processing
# '''
# Clean all the data in this section
# '''
# def data_cleaner(df):
#     df = df.dropna()
    
#     #define states to keep
#     states = ["successful", "failed"]
    
#     #drop rows that contain any value in the list
#     df = df[df.state.isin(states) == True]
    
#     #convert goal to usd
#     df["goal_inUS"]=df["goal"]*df["static_usd_rate"]
    
#     df=feature_eng(df)
    
#     # Setup the variables
#     #list(kickstarter_df.columns)
#     df = df[[#'id',
# #    # 'name',
# #     'goal',
# #     'pledged',
#      'state',
# #     'disable_communication',
#      'country',
# #     'currency',
#      #'deadline',
#      #'state_changed_at',
#      #'created_at',
#      #'launched_at',
#      'staff_pick',
#      'backers_count',
# #     'static_usd_rate',
# #     'usd_pledged',
#      'category',
#      'spotlight',
#      'name_len',
# #    'name_len_clean',
#      'blurb_len',
# #    'blurb_len_clean',
# #    'deadline_weekday',
# #    'state_changed_at_weekday',
# #     'created_at_weekday',
# #     'launched_at_weekday',
#      'deadline_month',
#      'deadline_day',
#      'deadline_yr',
#      'deadline_hr',
# #     'state_changed_at_month',
# #     'state_changed_at_day',
# #     'state_changed_at_yr',
# #     'state_changed_at_hr',
# #     'created_at_month',
# #     'created_at_day',
# #     'created_at_yr',#>
#      'created_at_hr',#>
#     'launched_at_month',
#      'launched_at_day',
#      'launched_at_yr',
# #>     'launched_at_hr',
#     'create_to_launch_days',
# #    'launch_to_state_change_days',
#      'launch_to_deadline_days',
# #     'goal_inUS',
#     'Relative_Goal'
# ]]
    
#     df=get_dummies(df)
#     #df=standardize(df)
#     return df

# def get_dummies(df):
#     df=pd.get_dummies(df)
#     return df

# def standardize(df):
#     #standardize inputs
#     from sklearn.preprocessing import StandardScaler
#     scaler = StandardScaler()
#     scaled_features = scaler.fit_transform(df)
#     df=pd.DataFrame(scaled_features, index=df.index, columns=df.columns)
#     return(df)

# def feature_eng(df):
#     df['Relative_Goal'] = np.floor(np.log10(df['goal_inUS']))
#     #df['Count_Release'] = np.power(df.groupby('Dummy1')['Dummy1'].transform('count'),4)
#     #df=df.drop('Dummy1',axis=1)
#     return df

# X = data_cleaner(kickstarter_df)


# #%% Model


# from sklearn.cluster import KMeans
# from sklearn.metrics import calinski_harabasz_score
# from scipy.stats import f
# df1 = 1 # df1 = k-1
# df2 = 20 # df2 = n-k

# # # Finding optimal K
# # for i in range (2,60):    
# #     kmeans = KMeans(n_clusters=i)
# #     model = kmeans.fit(X)
# #     labels = model.labels_
# #     score = calinski_harabasz_score(X, labels)
# #     df1=i-1
# #     df2=len(X)-i
# #     print(i,':',1-f.cdf(score, df1, df2))

# from sklearn.metrics import silhouette_score
# # for i in range (2,60):    
# #     kmeans = KMeans(n_clusters=i)
# #     model = kmeans.fit(X)
# #     labels = model.labels_
# #     print("kmeans",i,':',silhouette_score(X,labels))
    
# from sklearn.cluster import AgglomerativeClustering
# from scipy.cluster.hierarchy import dendrogram, linkage
# from sklearn.cluster import KMeans
# pss=0
# #sklearn
# for i in range (2,8): 
#     #aglom=AgglomerativeClustering(n_clusters=i,affinity='euclidean', linkage='complete')
#     #aglom.fit_predict(X)
#     #labels=aglom.labels_
#     ##print("The Number of clusters in the first cluster is:",len(cluster.labels_)-sum(cluster.labels_))
#     ##print("The number of clusters in the second cluster is:",sum(cluster.labels_))
#     Kmeans=KMeans(n_clusters=i)
#     model=Kmeans.fit(X)
#     labels2 = model.labels_
#     # print("The Number of data points in the first cluster is:",len(labels)-sum(labels))
#     # print("The number of data points in the second cluster is:",sum(labels))
    
#     #print("Agglomerative",i,':',silhouette_score(X,labels))
#     print("kmeans",i,':',silhouette_score(X,labels2))
    
#     sc=silhouette_score(X,labels2)
#     if i==6:
#       pss=sc
#       knn_table=pd.DataFrame(model.cluster_centers_,columns=X.columns.tolist())
#       #with pd.option_context('display.max_rows', None, 'display.max_columns', None):
#           #print(knn_table)
# #      aglom_table=pd.DataFrame(aglom.cluster_centers_,columns=X.columns.tolist()
# from sklearn.neighbors import KNeighborsClassifier
# parameters = {'n_neighbors':[50,75,100,125,150,175,200,225,250,275,300,325,350],
#               'weights': ['uniform', 'distance']}

# knn = KNeighborsClassifier(p=2)
# kmeans = KMeans(n_clusters=i)
# # #     model = kmeans.fit(X)
# model = GridSearchCV(knn, parameters, cv=5)
# model.fit(X,y)
# model.best_params_ #n_neighbors: 250; weights: distance

# #%% visualize
# from sklearn.decomposition import PCA
# pca = PCA(n_components=2)
# #from sklearn.preprocessing import StandardScaler
# #scaler = StandardScaler()
# #X = scaler.fit_transform(X)
# principalComponents = pca.fit_transform(X)
# principalDf = pd.DataFrame(data = principalComponents, columns = ['principal component 1', 'principal component 2'])
# finalDf = pd.concat([principalDf,pd.DataFrame(labels2,columns=['cluster'])], axis = 1)

# import matplotlib.pyplot as plt

# fig = plt.figure(figsize = (8,8))
# ax = fig.add_subplot(1,1,1) 
# ax.set_xlabel('Principal Component 1', fontsize = 15)
# ax.set_ylabel('Principal Component 2', fontsize = 15)
# ax.set_title('2 Component PCA Graph', fontsize = 20)

# targets = np.unique(labels2)
# colors = ['r', 'g', 'b','c','m','y','k','crimson','skyblue']

# for target, color in zip(targets,colors):
#     indicesToKeep = finalDf['cluster'] == target
#     ax.scatter(finalDf.loc[indicesToKeep, 'principal component 1']
#                , finalDf.loc[indicesToKeep, 'principal component 2']
#                , c = color
#                , s = 50)
# plt.xlim([-1000, 15000])
# plt.ylim([-150, 1500])
# ax.legend(targets)
# ax.grid()

# pca.explained_variance_ratio_

    
# #%%
# # Load libraries
# # from sklearn.linear_model import LogisticRegression
# # X1=X['staff_pick']
# # y1=X['state_successful']
# # X1.reshape(-1,1)
# # y1.reshape(-1,1)
# # lr=LogisticRegression(max_iter=500)
# # model=lr.fit(X1,y1)
# # # View results
# # model.intercept_
# # model.coef_






#     #print(cluster_table)
#     # match  the prediction to the cluster centers
#     #labels=model.predict(X)
#     #X["kmeans"]=labels

#     #print(model.cluster_centers_)
   
#     # for i in range(9):
#     #     print(abs(model.cluster_centers_[0][i]-model.cluster_centers_[1][i]))
        
#     # col = list(X.columns)
#     # for i in range(len(col)):
#     #     print(col[i], abs(model.cluster_centers_[0][i]-model.cluster_centers_[1][i]))

# '''
#     df = df[[#'id',
# #    # 'name',
# #     'goal',
# #      'pledged',
# #     'state',
# #     'disable_communication',
#      'country',
#      'currency',
#      #'deadline',
#      #'state_changed_at',
#      #'created_at',
#      #'launched_at',
#      'staff_pick',
#      'backers_count',
# #     'static_usd_rate',
# #     'usd_pledged',
#      'category',
#      'spotlight',
#      'name_len',
# #    'name_len_clean',
#      'blurb_len',
# #    'blurb_len_clean',
#     'deadline_weekday',
#     'state_changed_at_weekday',
# #     'created_at_weekday',
#      'launched_at_weekday',
#      'deadline_month',
#      'deadline_day',
#      'deadline_yr',
#      'deadline_hr',
# #     'state_changed_at_month',
# #     'state_changed_at_day',
# #     'state_changed_at_yr',
# #     'state_changed_at_hr',
# #     'created_at_month',
# #     'created_at_day',
# #     'created_at_yr',#>
#      'created_at_hr',#>
#     'launched_at_month',
# #>     'launched_at_day',
#      'launched_at_yr',
# #>     'launched_at_hr',
#     'create_to_launch_days',
# #    'launch_to_state_change_days',
#      'launch_to_deadline_days',
# #     'goal_inUS',
#     'Relative_Goal'
# ]]
# '''