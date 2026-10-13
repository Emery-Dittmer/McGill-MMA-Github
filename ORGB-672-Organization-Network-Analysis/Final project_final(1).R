library(lubridate)
library(wru)
library(gender)
require(dplyr)
library(ggplot2)
library(corrplot)
library(methods)
library(tidyverse)
require(lmtest)
library(caTools)
library(knitr)
library(arrow)

#Read in the data set

data_path <- "C:/Users/nguye/OneDrive/Documents/MMA/Winter 2023/Network analysis/672_project_data/"
data_path2 <- "C:/Users/nguye/OneDrive/Documents/MMA/Winter 2023/Network analysis/672_project_data/"
#data_path <- "Data/"
#data_path2 <- data_path

applications <- read_parquet(paste0(data_path,"app_data_sample.parquet"),as_data_frame=TRUE)
edges <- read_csv(paste0(data_path,"edges_sample.csv"))

#########################################################################################################################
################################################### Data Pre-processing #################################################
#########################################################################################################################

###################### Getting gender, race and tenure for each examiner ################################################

####### Filter out observation

#examin filling dates in dataset
ggplot(applications, aes(x=filing_date))+
  geom_histogram(bins = 30)
#indicates a right filter problem need to remove all past 2017


# Filter out rows with filling_date during 2008 or after 2016
applications <- applications %>% 
  filter(year(filing_date) >= 2008, year(filing_date) <= 2016)

ggplot(applications, aes(x=filing_date))+
  geom_histogram(bins = 30)


# get a list of first names without repetitions
examiner_names <- applications %>% 
  distinct(examiner_name_first)

examiner_names

# get a table of names and gender
examiner_names_gender <- examiner_names %>% 
  do(results = gender(.$examiner_name_first, method = "ssa")) %>% 
  unnest(cols = c(results), keep_empty = TRUE) %>% 
  select(
    examiner_name_first = name,
    gender,
    proportion_female
  )

examiner_names_gender

# remove extra colums from the gender table
examiner_names_gender <- examiner_names_gender %>% 
  select(examiner_name_first, gender)

# joining gender back to the dataset
applications <- applications %>% 
  left_join(examiner_names_gender, by = "examiner_name_first")

# cleaning up
rm(examiner_names)
rm(examiner_names_gender)
gc()

examiner_surnames <- applications %>% 
  select(surname = examiner_name_last) %>% 
  distinct()

examiner_surnames

examiner_race <- predict_race(voter.file = examiner_surnames, surname.only = T) %>% 
  as_tibble()

examiner_race <- examiner_race %>% 
  mutate(max_race_p = pmax(pred.asi, pred.bla, pred.his, pred.oth, pred.whi)) %>% 
  mutate(race = case_when(
    max_race_p == pred.asi ~ "Asian",
    max_race_p == pred.bla ~ "black",
    max_race_p == pred.his ~ "Hispanic",
    max_race_p == pred.oth ~ "other",
    max_race_p == pred.whi ~ "white",
    TRUE ~ NA_character_
  ))

examiner_race

# removing extra columns
examiner_race <- examiner_race %>% 
  select(surname,race)

applications <- applications %>% 
  left_join(examiner_race, by = c("examiner_name_last" = "surname"))

rm(examiner_race)
rm(examiner_surnames)
gc()


#this is total tenure days
examiner_dates <- applications %>% 
  select(examiner_id, filing_date, appl_status_date) 

examiner_dates

examiner_dates <- examiner_dates %>% 
  mutate(start_date = ymd(filing_date), end_date = as_date(dmy_hms(appl_status_date)))

examiner_dates <- examiner_dates %>% 
  group_by(examiner_id) %>% 
  summarise(
    earliest_date = min(start_date, na.rm = TRUE), 
    latest_date = max(end_date, na.rm = TRUE),
    tenure_days = interval(earliest_date, latest_date) %/% days(1)
  ) %>% 
  filter(year(latest_date)<2018)

examiner_dates

applications <- applications %>% 
  left_join(examiner_dates, by = "examiner_id")

rm(examiner_dates)
gc()


######### Create the approx_tenure days

#we will assume that tenure days is roughly equal to the tenure days since the last patent decision
Temp_data <- applications %>% 
  mutate(appl_status_date = as_date(dmy_hms(appl_status_date))) %>%
  group_by(examiner_id) %>% 
  summarise(
    aprox_tenure_start = min(appl_status_date)) %>%
  drop_na(aprox_tenure_start,examiner_id)

applications <- merge(applications, Temp_data, by = 'examiner_id',all=T)

applications<-applications %>%
  mutate(appl_status_date = as_date(dmy_hms(appl_status_date)),
         aprox_tenure_start = as_date((aprox_tenure_start)))

applications$Approx_Tenue_Days=difftime(applications$appl_status_date, applications$aprox_tenure_start, units = "days")

rm(Temp_data)
gc()


######### Calculate application processing time
applications$app_proc_time <- ifelse(!is.na(applications$patent_issue_date), 
                                     difftime(applications$patent_issue_date, applications$filing_date, units = "days"),
                                     difftime(applications$abandon_date, applications$filing_date, units = "days"))
# Filter out observations with NA application processing time
applications <- applications %>% 
  filter(!is.na(app_proc_time))

######### Create the nodes dataframe
nodes <- applications %>%
  distinct(examiner_id) %>%
  select(examiner_id) %>%
  drop_na()

######### Create the edges dataframe

# create a vector of all unique examiner IDs in the applications dataset
unique_examiner_ids <- unique(applications$examiner_id)
edge_filtered <- edges[edges$alter_examiner_id %in% unique_examiner_ids & 
                         edges$ego_examiner_id %in% unique_examiner_ids,]

# filter out those edges that repeated itself 
edges_1 <- edge_filtered %>%
  distinct(ego_examiner_id, alter_examiner_id) %>%
  select(ego_examiner_id, alter_examiner_id) %>%
  drop_na()


rm(edge_filtered)





####################### Create network graph and calculate different types of centrality scores ##################################

library(igraph)

# Create network graph
g <- graph_from_data_frame(d = edges_1, directed = FALSE, vertices = nodes)


# Calculate the degree centrality of each node (examiner ID)
degree <- degree(g, mode = "all", normalized = FALSE)

# Calculate the betweeness centrality of each node
betweenness <- betweenness(g)

#Calculate the closeness centrality of each node
closeness <- closeness(g)

# Combine the degree centrality scores and node IDs into a table
degree_table <- data.frame(examiner_id = V(g)$name, centrality = as.vector(degree))
degree_table$examiner_id <- as.numeric(degree_table$examiner_id)
applications <- left_join(applications, degree_table, by = "examiner_id")

#Combine the betweenness centrality scores and node IDs into a table
betweenness_table <- data.frame(examiner_id = V(g)$name, betweenness_centrality = as.vector(betweenness))
betweenness_table$examiner_id <- as.numeric(betweenness_table$examiner_id)
applications <- left_join(applications, betweenness_table, by = "examiner_id")

#Combine the closeness centrality scores and node IDs into a table
closeness_table <- data.frame(examiner_id = V(g)$name, closeness_centrality = as.vector(closeness))
closeness_table$examiner_id <- as.numeric(closeness_table$examiner_id)
applications <- left_join(applications, closeness_table, by = "examiner_id")


#########################################################################################################################
################################################### Analysis ############################################################
#########################################################################################################################

####################### Examine the impact of application times based on centrality scores for point in time ##################################
library(data.table)
library(igraph)
library(tidygraph)
library(tidyverse)

edges <- edges %>%
  mutate(from=ego_examiner_id,to=alter_examiner_id) %>%
  drop_na()

edges_ts <- edges %>%
  filter(!duplicated(from, to)) %>%
  group_by(from, advice_date) %>%
  summarize(
    degree=n())

### Create a dataframe where the average application processing time per examiner and average application processing time and degree is measured

#dataframe of unique IDs
All_Exams_comb<-data.table(unique_examiner_ids)

#get unique values 
unique_appl_status_date = unique(applications$appl_status_date)
#Dataframe of unique status dates
DT_Count<-data.table(unique_appl_status_date)

All_Exams_comb=All_Exams_comb[,as.list(DT_Count),by=All_Exams_comb]

#Join Data
All_Exams_comb <- All_Exams_comb %>%
  left_join(edges_ts,
            by=c('unique_examiner_ids'='from',
                 'unique_appl_status_date'='advice_date'))

All_Exams_comb <- All_Exams_comb %>%
  mutate(degree=replace_na(degree,0)) %>%
  select(unique_examiner_ids,degree,unique_appl_status_date) %>%
  arrange(unique_appl_status_date)

#
All_Exams_comb <- All_Exams_comb %>%
  group_by(unique_examiner_ids) %>%
  mutate(Degree_Over_Time = cumsum(degree))

applications_ts <- applications %>%
  left_join(All_Exams_comb,
            by=c('examiner_id'='unique_examiner_ids',
                 'appl_status_date'='unique_appl_status_date')) %>%
  filter(examiner_id %in% edges_ts$from)

applications_ts_exam <- applications_ts %>%
  filter(year(appl_status_date)<=2013) %>%
  group_by(examiner_id) %>%
  summarize(avg_proc_time=mean(app_proc_time),
            avg_degree_time=mean(Degree_Over_Time),
            avg_degree=mean(degree),
            num_apps=n())
 


rm(All_Exams_comb)




library(gt)
#let's make a table to visualize the data
ggplot(aes(x=app_proc_time),data=applications_ts)+
  geom_histogram(bins=100)

ggplot(data = applications_ts ,aes(x=app_proc_time,y=Degree_Over_Time ))+
  geom_point(alpha=0.1)+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+
  xlab("Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")

ggplot(data = applications_ts_exam ,aes(x=avg_proc_time,y=avg_degree_time ))+
  geom_point(alpha=0.1)+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+
  xlab("Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")


PD_avg = applications_ts %>%
  group_by(Degree_Over_Time) %>%
  summarise(n = n(),
            average_proc_time=mean(app_proc_time)
            ) %>%
  arrange(average_proc_time)
#table of results
PD_avg %>% gt()
ggplot(data = PD_avg ,aes(x=average_proc_time,y= Degree_Over_Time))+
  geom_point()+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+  
  xlab("Average Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")

corr_matrix1 <- cor(PD_avg)

#let's make a quick pie chart to visualize the data
PD = applications_ts %>%
  group_by(Degree_Over_Time, app_proc_time) %>%
  summarise(n = n())

#Now lets look at the correlation plots
library(GGally)
applications_ts_ggally <- applications_ts %>%
  mutate(Approx_Tenue_Days=as.numeric(Approx_Tenue_Days)) %>%
  select(Degree_Over_Time,app_proc_time,Approx_Tenue_Days,centrality) %>%
  drop_na()

ggpairs(applications_ts_ggally)


num_cols <- unlist(lapply(applications_ts, is.numeric))       
quanvars <- applications_ts[ , num_cols] 
drop <- c("tenure_days","examiner_id","examiner_art_unit","appl_status_code","tc","degree")
quanvars = quanvars[,!(names(quanvars) %in% drop)]
corr_matrix <- cor(quanvars)

corr_matrix2 <- cor(applications_ts_exam[,!(names(applications_ts_exam) %in% c("examiner_id","avg_degree"))])
corrplot(corr_matrix1)
corrplot(corr_matrix)
corrplot(corr_matrix2)

#Count request by application number
request_counts <- edges %>%
  group_by(application_number) %>%
  summarize(request_counts = n()) %>%
  select(application_number, request_counts)


selected_applications <- applications %>%
  semi_join(request_counts, by = "application_number")


applications_request_counts <- selected_applications %>%
  left_join(request_counts, by = "application_number")


applications_request_counts$gender <- factor(applications_request_counts$gender)
applications_request_counts$race <- factor(applications_request_counts$race)
applications_request_counts$request_counts = as.numeric(applications_request_counts$request_counts)




####################### Testing ##################################

######linear regression
install.packages("jtools")
library(jtools)
library(kableExtra)

summ(lm(app_proc_time~Degree_Over_Time,data=applications_ts))
summary(lm(app_proc_time~Degree_Over_Time,data=applications_ts))

summ(lm(app_proc_time~centrality+betweenness_centrality+closeness_centrality,data=applications_ts))
summary(lm(app_proc_time~centrality+betweenness_centrality+closeness_centrality,data=applications_ts))

summ(lm(app_proc_time~Degree_Over_Time+centrality+betweenness_centrality+closeness_centrality,data=applications_ts))
summary(lm(app_proc_time~Degree_Over_Time+centrality+betweenness_centrality+closeness_centrality,data=applications_ts))

summ(lm(app_proc_time~Approx_Tenue_Days,data=applications_ts))
summary(lm(app_proc_time~Approx_Tenue_Days,data=applications_ts))

summ(lm(app_proc_time~Degree_Over_Time+Approx_Tenue_Days,data=applications_ts))
summary(lm(app_proc_time~Degree_Over_Time+Approx_Tenue_Days,data=applications_ts))


summ(lm(app_proc_time~Degree_Over_Time,data=applications_ts))
summary(lm(app_proc_time~Degree_Over_Time,data=applications_ts))

model1 = lm(app_proc_time ~ request_counts + centrality + betweenness_centrality + closeness_centrality + race + gender + tenure_days, data = applications_request_counts)
summary(model1)

model2 = lm(app_proc_time ~ request_counts, data = applications_request_counts)
summary(model2)

###### Survival analysis
install.packages("survival")
install.packages("ggsurvfit")
install.packages("gtsummary")
install.packages("tidycmprsk")
library(survival)
library(lubridate)
library(ggsurvfit)
library(gtsummary)
library(tidycmprsk)

applications_ts <- applications_ts %>% 
  mutate(
    status = recode(disposal_type, `ABN` = 0, `ISS` = 1)
  )


survfit(Surv(app_proc_time) ~ 1, data = applications_ts) %>% 
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability"
  ) + 
  add_confidence_interval()+
  add_risktable()

survfit(Surv(app_proc_time) ~ Degree_Over_Time, data = applications_ts) %>% 
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability"
  ) + 
  add_confidence_interval()

survfit(Surv(app_proc_time) ~ centrality, data = applications_ts) %>% 
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability"
  ) + 
  add_confidence_interval()




survfit(Surv(avg_proc_time) ~ avg_degree_time, data = applications_ts_exam) %>% 
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability"
  ) + 
  add_confidence_interval()



##### Tree Analysis
library(tree)
library(rpart)
library(rpart.plot)


myoverfittedtree=rpart(app_proc_time~disposal_type+tc+gender+race+Approx_Tenue_Days+Degree_Over_Time,data = applications_ts, control=rpart.control(cp=0.0001))

#this will generate a plot of the decision tree
rpart.plot(myoverfittedtree)
plotcp(myoverfittedtree)
opt_cp=myoverfittedtree$cptable[which.min(myoverfittedtree$cptable[,"xerror"]),"CP"]


tree=rpart(app_proc_time~disposal_type+tc+gender+race+Approx_Tenue_Days+Degree_Over_Time,data = applications_ts, control=rpart.control(cp=0.001))

rpart.plot(tree)

tree2=rpart(avg_proc_time~avg_degree_time+num_apps,data = applications_ts_exam, control=rpart.control(cp=0.003))

rpart.plot(tree2)

#####cluster analysis


#install.packages("factoextra")
library(factoextra)
#fviz_nbclust(quanvars,kmeans,method="wss")

fviz_nbclust(PD_avg,kmeans,method="wss")
fviz_nbclust(PD_avg,kmeans,method="silhouette")
cluster=kmeans(PD_avg,5,nstart=20)

fviz_cluster(cluster, data = PD_avg,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800","#000000","#2F2291"), 
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw()
)

PD_avg$cluster=cluster$cluster

ggplot(data = PD_avg ,aes(x=average_proc_time,y= Degree_Over_Time,color=cluster))+
  geom_point()+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+  
  xlab("Average Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")+
  theme_classic() +
  scale_color_gradient(low = "blue", high = "green")

##
fviz_nbclust(applications_ts_exam,kmeans,method="wss")
fviz_nbclust(applications_ts_exam,kmeans,method="silhouette")
cluster=kmeans(applications_ts_exam,3,nstart=20)

fviz_cluster(cluster, data = PD_avg,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800","#000000","#2F2291"), 
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw()
)

applications_ts_exam$cluster=cluster$cluster

ggplot(data = applications_ts_exam ,aes(x=avg_proc_time,y= avg_degree_time,color=cluster))+
  geom_point()+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+  
  xlab("Average Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")+
  theme_classic() +
  scale_color_gradient(low = "blue", high = "green")

fviz_cluster(cluster, data = PD_avg,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800","#000000","#2F2291"), 
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw()
)

###
applications_ts_clean <- applications_ts %>%
  select(app_proc_time,Degree_Over_Time,gender,race,Approx_Tenue_Days) %>%
  mutate(gender= as.factor(gender),race=as.factor(race)) %>%
  drop_na()

applications_ts_clean=na.omit(applications_ts_clean)

cluster=kmeans(applications_ts_clean,3,nstart=20)
applications_ts_clean$cluster=cluster$cluster

ggplot(data = applications_ts_clean ,aes(x=app_proc_time,y= Degree_Over_Time,color=cluster))+
  geom_point()+
  labs(title="Distribution of Average processing Time vs. Cumulative Centrality Degree ")+  
  xlab("Average Application Processing Time (days)")+
  ylab("Cumulative Centrality Degree")+
  theme_classic() +
  scale_color_gradient(low = "blue", high = "green")



