
#------------------------------
##Question 6
#------------------------------

## Import data from CSV file, inside "" is the location of your CSV file in your computer. 
Data <- read.csv("singleitemSKU88.csv")

## 1. Data Cleaning

##Test for no price
#Will be an issue with log for price later
test=subset(Data, Price == 0)
#if true then no zero prices
nrow(test)==0

## 2. Feature engineering

## Add seasonal factor to the data 
Data$Week_factor <-  as.factor(rep(rep(seq(1,13),each=4),3))

## Add Trend as % diff from previous week
#Use same logic as price.
#price_1 is previous 1 week 
#price_2 is 2 weeks price lag
#require(dplyr)


## Split Data set into train and test
#First 24 months of data
train_data=Data[1:104,]
test_data=Data[105:nrow(Data),]
#define teest targets to validate
test_data_demand=test_data[,"St"]

## Drop Nas from feature eng


## 3. Modeling

##Question 2.

##Functions
MAPE = function(y_actual,y_predict){
  mean(abs((y_actual-y_predict)/y_actual))*100
}

#2. RSQUARED
RSQ = function(y_actual,y_predict){
  cor(y_actual,y_predict)^2
}

##model a
model_a=lm(log(St)~Week_factor+Week+log(Price),data=train_data)
print('model a')
summary(model_a)

#print('prediction')
model_a_predict=predict(model_a,test_data) #Predictions on Testing data
model_a_predict=exp(model_a_predict)

model_a_R2=RSQ(test_data_demand,model_a_predict)
model_a_MAPE = MAPE(test_data_demand,model_a_predict)
model__a_accuracy = 100 - model_a_MAPE

print("R-Square: ")
print(model_a_R2)

print("MAPE: ")
print(model_a_MAPE)


print('Accuracy of Linear Regression: ')
print(model__a_accuracy)


#model b
model_b=glm(log(St)~Week_factor+Week+log(Price)+log(Price_1)+log(Price_2),data=train_data)

print('model b')
summary(model_b)


#print('prediction')
model_b_predict=predict(model_b,test_data) #Predictions on Testing data
model_b_predict=exp(model_b_predict) #noralizing prediction

model_b_R2=RSQ(test_data_demand,model_b_predict)
model_b_MAPE = MAPE(test_data_demand,model_b_predict)
model__b_accuracy = 100 - model_b_MAPE

print("R-Square: ")
print(model_b_R2)

print("MAPE: ")
print(model_b_MAPE)


print('Accuracy of Linear Regression: ')
print(model__b_accuracy)

## Question 4.
Q4_data=data.frame(Price=1,Price_1=0.8,Price_2=0.8,Week_factor=2,Week=7)
Q4_data$Week_factor<- as.factor(Q4_data$Week_factor)

# Assuming 'Week_factor' is already a factor variable
# Check the current levels of 'Week_factor'
levels(Q4_data$Week_factor)

# Change the factor level to 2
levels(Q4_data$Week_factor) <- c("1", "2")

# Verify the updated factor levels
levels(Q4_data$Week_factor)

a_pred=predict(model_a,Q4_data)
a_pred=exp(a_pred)
a_pred
b_pred=predict(model_b,Q4_data)
b_pred=exp(b_pred)
b_pred


## Read data from CSV file
DATA <- read.csv("multipleitempart1.csv")

## 1. Data Cleaning

##Test for no price
#Will be an issue with log for price later
all(apply(DATA, 2, function(x) x==0))

#no data cleaning required

#------------------------------
## 2. Feature engineering
#------------------------------

## Adding week factor indicator 
DATA$Week_factor <- as.factor(rep(rep(seq(1,13),each=4),3))

## Add Trend as % diff from previous week
#Use same logic as price.
#price_1 is previous 1 week 
#price_2 is 2 weeks price lag

#create 5 copies of the data to then stack
require(tidyverse)
Data_1<-DATA %>%
  mutate(St=S1_t,Prod=1,Prod_1=1,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=0)
Data_2<-DATA %>%
  mutate(St=S2_t,Prod=2,Prod_1=0,Prod_2=1,Prod_3=0,Prod_4=0,Prod_5=0)
Data_3<-DATA %>%
  mutate(St=S3_t,Prod=3,Prod_1=0,Prod_2=0,Prod_3=1,Prod_4=0,Prod_5=0)
Data_4<-DATA %>%
  mutate(St=S4_t,Prod=4,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=1,Prod_5=0)
Data_5<-DATA %>%
  mutate(St=S5_t,Prod=5,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=1)

#data frame has all the pertinante data. 
#note inverse binary

Data <- bind_rows(Data_1, Data_2, Data_3, Data_4, Data_5)

rm(Data_1, Data_2, Data_3, Data_4, Data_5)
rm(DATA)

Data$Prod <- as.factor(Data$Prod)
Data$Trend <- Data$Week

## Split Data set into train and test
#First 24 months of data 52*2 =104. R indexing includes the last number
train_data=Data[Data$Week<=104,]
test_data=Data[Data$Week>104,]

#define teest targets to validate
test_data_demand=test_data[,c("St")]

#------------------------------
## 3. Modeling
#------------------------------

##Functions
MAPE = function(y_actual,y_predict){
  mean(abs((y_actual-y_predict)/y_actual))*100
}

#2. RSQUARED
RSQ = function(y_actual,y_predict){
  cor(y_actual,y_predict)^2
}


##models
Model6<-lm(log(St)~Week_factor+Week+
             Prod_1*log(PriceB1)+Prod_1*log(PriceB1_1)+Prod_1*log(PriceB1_2)+
             Prod_1*PriceB2+Prod_1*PriceB3+Prod_1*PriceB4+Prod_1*PriceB5
           -Prod_1 - log(PriceB1) - log(PriceB1_1) -log(PriceB1_2) - PriceB2 - PriceB3 - PriceB4 - PriceB5 +
             
             Prod_2*log(PriceB2)+Prod_2*log(PriceB2_1)+Prod_2*log(PriceB2_2)+
             Prod_2*PriceB1+Prod_2*PriceB3+Prod_2*PriceB4+Prod_2*PriceB5
           - log(PriceB2) - log(PriceB2_1) -log(PriceB2_2) - PriceB1 - PriceB3 - PriceB4 - PriceB5 +
             
             Prod_3*log(PriceB3)+Prod_3*log(PriceB3_1)+Prod_3*log(PriceB3_2)+
             Prod_3*PriceB2+Prod_3*PriceB1+Prod_3*PriceB4+Prod_3*PriceB5
           - log(PriceB3) - log(PriceB3_1) -log(PriceB3_2) - PriceB1 - PriceB2 - PriceB4 - PriceB5 +
             
             
             Prod_4*log(PriceB4)+Prod_4*log(PriceB4_1)+Prod_4*log(PriceB4_2)+
             Prod_4*PriceB1+Prod_4*PriceB2+Prod_4*PriceB3+Prod_4*PriceB5
           - log(PriceB4) - log(PriceB4_1) -log(PriceB4_2) - PriceB1 - PriceB3 - PriceB2 - PriceB5 +
             
             
             Prod_5*log(PriceB5)+Prod_5*log(PriceB5_1)+Prod_5*log(PriceB5_2)+
             Prod_5*PriceB1+Prod_5*PriceB2+Prod_5*PriceB3+Prod_5*PriceB4
           - log(PriceB5) - log(PriceB5_1) -log(PriceB5_2) - PriceB1 - PriceB3 - PriceB2 - PriceB4
           
           ,data=train_data)



#idea 1 justification
print('Multi_model ')
summary(Model6)

#predictions
Multi_model_predict=predict(Model6,test_data) #Predictions on Testing data
Multi_model_predict=exp(Multi_model_predict)

#r scores
Multi_model_R2=RSQ(test_data_demand,Multi_model_predict)

#MAPEs
Multi_model_MAPE = MAPE(test_data_demand,Multi_model_predict)

print("R-Square: ")
print(Multi_model_R2)

print("MAPE: ")
print(Multi_model_MAPE)










#------------------------------
###### Question 7 
#------------------------------

## Read data from CSV file
DATA <- read.csv("multipleitempart2.csv")

## 1. Data Cleaning

##Test for no price
#Will be an issue with log for price later
all(apply(DATA, 2, function(x) x==0))

#no data cleaning required

#------------------------------
## 2. Feature engineering
#------------------------------

## Adding week factor indicator 
DATA$Week_factor <- as.factor(rep(rep(seq(1,13),each=4),3))

## Add Trend as % diff from previous week
#Use same logic as price.
#price_1 is previous 1 week 
#price_2 is 2 weeks price lag

#create 5 copies of the data to then stack
require(tidyverse)
Data_1<-DATA %>%
  mutate(St=S1_t,Prod=1,Prod_1=1,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=0)
Data_2<-DATA %>%
  mutate(St=S2_t,Prod=2,Prod_1=0,Prod_2=1,Prod_3=0,Prod_4=0,Prod_5=0)
Data_3<-DATA %>%
  mutate(St=S3_t,Prod=3,Prod_1=0,Prod_2=0,Prod_3=1,Prod_4=0,Prod_5=0)
Data_4<-DATA %>%
  mutate(St=S4_t,Prod=4,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=1,Prod_5=0)
Data_5<-DATA %>%
  mutate(St=S5_t,Prod=5,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=1)

#data frame has all the pertinante data. 
#note inverse binary

Data <- bind_rows(Data_1, Data_2, Data_3, Data_4, Data_5)

rm(Data_1, Data_2, Data_3, Data_4, Data_5)
rm(DATA)

Data$Prod <- as.factor(Data$Prod)
Data$Trend <- Data$Week

## Split Data set into train and test
#First 24 months of data 52*2 =104. R indexing includes the last number
train_data=Data[Data$Week<=104,]
test_data=Data[Data$Week>104,]

#define teest targets to validate
test_data_demand=test_data[,c("St")]

#------------------------------
## 3. Modeling
#------------------------------

##Functions
MAPE = function(y_actual,y_predict){
  mean(abs((y_actual-y_predict)/y_actual))*100
}

#2. RSQUARED
RSQ = function(y_actual,y_predict){
  cor(y_actual,y_predict)^2
}


##models
Model7<-lm(log(St)~Week_factor+Week+
             Prod_1*log(PriceB1)+Prod_1*log(PriceB1_1)+Prod_1*log(PriceB1_2)+
             Prod_1*PriceB2+Prod_1*PriceB3+Prod_1*PriceB4+Prod_1*PriceB5
           -Prod_1 - log(PriceB1) - log(PriceB1_1) -log(PriceB1_2) - PriceB2 - PriceB3 - PriceB4 - PriceB5 +
             
             Prod_2*log(PriceB2)+Prod_2*log(PriceB2_1)+Prod_2*log(PriceB2_2)+
             Prod_2*PriceB1+Prod_2*PriceB3+Prod_2*PriceB4+Prod_2*PriceB5
           - log(PriceB2) - log(PriceB2_1) -log(PriceB2_2) - PriceB1 - PriceB3 - PriceB4 - PriceB5 +
             
             Prod_3*log(PriceB3)+Prod_3*log(PriceB3_1)+Prod_3*log(PriceB3_2)+
             Prod_3*PriceB2+Prod_3*PriceB1+Prod_3*PriceB4+Prod_3*PriceB5
           - log(PriceB3) - log(PriceB3_1) -log(PriceB3_2) - PriceB1 - PriceB2 - PriceB4 - PriceB5 +
             
             
             Prod_4*log(PriceB4)+Prod_4*log(PriceB4_1)+Prod_4*log(PriceB4_2)+
             Prod_4*PriceB1+Prod_4*PriceB2+Prod_4*PriceB3+Prod_4*PriceB5
           - log(PriceB4) - log(PriceB4_1) -log(PriceB4_2) - PriceB1 - PriceB3 - PriceB2 - PriceB5 +
             
             
             Prod_5*log(PriceB5)+Prod_5*log(PriceB5_1)+Prod_5*log(PriceB5_2)+
             Prod_5*PriceB1+Prod_5*PriceB2+Prod_5*PriceB3+Prod_5*PriceB4
           - log(PriceB5) - log(PriceB5_1) -log(PriceB5_2) - PriceB1 - PriceB3 - PriceB2 - PriceB4
           
           ,data=train_data)



#idea 1 justification
print('Multi_model ')
summary(Model7)

#predictions
Multi_model_predict=predict(Model7,test_data) #Predictions on Testing data
Multi_model_predict=exp(Multi_model_predict)

#r scores
Multi_model_R2=RSQ(test_data_demand,Multi_model_predict)

#MAPEs
Multi_model_MAPE = MAPE(test_data_demand,Multi_model_predict)

print("R-Square: ")
print(Multi_model_R2)

print("MAPE: ")
print(Multi_model_MAPE)



#------------------------------
###### Question 8
#------------------------------

Q8_data_1_1=data.frame(Week=7,PriceB1=1,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=1,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=0)
Q8_data_1_1$Week_factor<- as.factor(Q8_data_1_1$Week_factor)
levels(Q8_data_1_1$Week_factor) <- c("2","2")

Q8_data_1_2=data.frame(Week=7,PriceB1=1,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=1,Prod_3=0,Prod_4=0,Prod_5=0)
Q8_data_1_2$Week_factor<- as.factor(Q8_data_1_2$Week_factor)
levels(Q8_data_1_2$Week_factor) <- c("2","2")

Q8_data_1_3=data.frame(Week=7,PriceB1=1,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=1,Prod_4=0,Prod_5=0)
Q8_data_1_3$Week_factor<- as.factor(Q8_data_1_3$Week_factor)
levels(Q8_data_1_3$Week_factor) <- c("2","2")

Q8_data_1_4=data.frame(Week=7,PriceB1=1,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=1,Prod_5=0)
Q8_data_1_4$Week_factor<- as.factor(Q8_data_1_4$Week_factor)
levels(Q8_data_1_4$Week_factor) <- c("2","2")

Q8_data_1_5=data.frame(Week=7,PriceB1=1,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=1)
Q8_data_1_5$Week_factor<- as.factor(Q8_data_1_5$Week_factor)
levels(Q8_data_1_5$Week_factor) <- c("2","2")


pred_1_1=predict(Model6,Q8_data_1_1)
pred_1_1=exp(pred_1_1)

pred_1_2=predict(Model6,Q8_data_1_2)
pred_1_2=exp(pred_1_2)

pred_1_3=predict(Model6,Q8_data_1_3)
pred_1_3=exp(pred_1_3)

pred_1_4=predict(Model6,Q8_data_1_4)
pred_1_4=exp(pred_1_4)

pred_1_5=predict(Model6,Q8_data_1_5)
pred_1_5=exp(pred_1_5)




Q8_data_7_1=data.frame(Week=7,PriceB1=0.7,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=1,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=0)
Q8_data_7_1$Week_factor<- as.factor(Q8_data_7_1$Week_factor)
levels(Q8_data_7_1$Week_factor) <- c("2","2")

Q8_data_7_2=data.frame(Week=7,PriceB1=0.7,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=1,Prod_3=0,Prod_4=0,Prod_5=0)
Q8_data_7_2$Week_factor<- as.factor(Q8_data_7_2$Week_factor)
levels(Q8_data_7_2$Week_factor) <- c("2","2")

Q8_data_7_3=data.frame(Week=7,PriceB1=0.7,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=1,Prod_4=0,Prod_5=0)
Q8_data_7_3$Week_factor<- as.factor(Q8_data_7_3$Week_factor)
levels(Q8_data_7_3$Week_factor) <- c("2","2")

Q8_data_7_4=data.frame(Week=7,PriceB1=0.7,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=1,Prod_5=0)
Q8_data_7_4$Week_factor<- as.factor(Q8_data_7_4$Week_factor)
levels(Q8_data_7_4$Week_factor) <- c("2","2")

Q8_data_7_5=data.frame(Week=7,PriceB1=0.7,PriceB1_1=1,PriceB1_2=1,
                       PriceB2=1,PriceB2_1=1,PriceB2_2=1,
                       PriceB3=1,PriceB3_1=1,PriceB3_2=1,
                       PriceB4=1,PriceB4_1=1,PriceB4_2=1,
                       PriceB5=1,PriceB5_1=1,PriceB5_2=1,
                       Week_factor=2,Prod_1=0,Prod_2=0,Prod_3=0,Prod_4=0,Prod_5=1)
Q8_data_7_5$Week_factor<- as.factor(Q8_data_7_5$Week_factor)
levels(Q8_data_7_5$Week_factor) <- c("2","2")


pred_7_1=predict(Model6,Q8_data_7_1)
pred_7_1=exp(pred_7_1)

pred_7_2=predict(Model6,Q8_data_7_2)
pred_7_2=exp(pred_7_2)

pred_7_3=predict(Model6,Q8_data_7_3)
pred_7_3=exp(pred_7_3)

pred_7_4=predict(Model6,Q8_data_7_4)
pred_7_4=exp(pred_7_4)

pred_7_5=predict(Model6,Q8_data_7_5)
pred_7_5=exp(pred_7_5)

print("Model Predictions:")
pred_1_1
pred_1_2
pred_1_3
pred_1_4
pred_1_5


pred_7_1
pred_7_2
pred_7_3
pred_7_4
pred_7_5


