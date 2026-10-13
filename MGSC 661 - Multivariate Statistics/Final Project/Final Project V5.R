# Import ----------------------------------------------------------


##### Library Import
library(dplyr)
library(tidyr)
library(ggplot2)
library(GGally)
library(ggfortify)
library(tree)
library(rpart)
library(rpart.plot)

##### Data import
O=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Final Project/Dataset 2 — Olympic events data.csv")


##delete later
#test athlete
#O_test_athlete=subset(O, ID == 455)

#sorting ascending by ID and Year
O=O[order(O$Year,O$ID),]

#sorting descending by ID and Year
#=O[order(-O$Year,O$ID),]

#remove later
#O=O[1:25000,]




# Pre-Processing ----------------------------------------------------------



##### Global variables
Medal_types=c("Bronze","Silver","Gold","NA")

##### Data Pre-processing
### Cleansing
#drop the NAs
#O %>% drop_na()


# Pre-Investigation ----------------------------------------------------------
# 




# Feature Engineering ----------------------------------------------------------

#add index number
O=mutate(O, Index = row_number())

#number of events within the same year
O$Num_events_same_yr=with(O, ave(seq(O$Year), O$ID, O$Year, FUN = function(x) length(x)))

#Detects number of previous olympics person competed at using a new data frame
O_prev=summarise(group_by(O, ID,Year))
# function to add count of nth appearance based on criteria
O_prev$prev_olypics=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))-1))
O <- merge(O,O_prev,by=c('ID','Year')) 
rm(O_prev)

#New sport?
O_new=summarise(group_by(O,ID,Sport))
O_new$new_Sport=with(O_new, ave(seq(O_new$ID), O_new$ID, FUN = function(x) seq(length(x))))
O <- merge(O,O_new,by=c('ID','Sport')) 
rm(O_new)

#new event?
O_new=summarise(group_by(O,ID,Event))
O_new$new_Event=with(O_new, ave(seq(O_new$ID), O_new$ID, FUN = function(x) seq(length(x))))
O <- merge(O,O_new,by=c('ID','Event')) 
rm(O_new)

#Number of medals up to this point
O_new=summarise(group_by(O,ID,Medal,Index))
O_new=O_new %>% drop_na(Medal)
O_new$Medal_win_num=with(O_new, ave(seq(O_new$ID), O_new$ID, FUN = function(x) seq(length(x))))
O_new=O_new[,names(O_new) %in% c("ID", "Index", "Medal_win_num")]
O <- merge(O,O_new,by=c('ID','Index'),all=T) 
rm(O_new)


##Number of medals in same sport after bronze
#set up recieving variable
set_column_name=c()
O_merge_set=data.frame(matrix(nrow=0,ncol=4))
for (i in Medal_types){
  set_column_name=append(set_column_name,paste("Years_since_last_win_",i))
  }
colnames(O_merge_set)=set_column_name

O_merge_set=data.frame()


#for loop to handle the number of medals won after first of type
for (i in unique(O$ID)){
  #i=977
  #i=133
  #set each smaller dataframe to be per athlete
  O_subset=subset(O, ID == i )

  O_ssubset=summarise(group_by(O_subset,ID,Sport,Year,Medal))
  
  #will return all rows with bronze medals
  Row_starts= O_ssubset[match(unique(O_ssubset$Medal), O_ssubset$Medal),]
  
  for (j in 1:nrow(Row_starts)){
    #j=1
    #print(j)
    Medal_type=Row_starts[[j,4]]
    First_medal_year=Row_starts[[j,3]]
    O_sssubset=subset(O_ssubset, Year>First_medal_year)
    O_sssubset=summarise(group_by(O_sssubset,Year))
    
    #numbering lenght)
    O_sssubset$temp=with(O_sssubset, ave((O_sssubset$Year),  FUN = function(x) seq(length(x))))
    colnames(O_sssubset)[colnames(O_sssubset) == "temp"] =paste("Years_since_last_win",Medal_type,sep="_")
    #meging
    O_subset <- merge(O_subset,O_sssubset,by=c('Year'),all=T)
  }
  rm(O_ssubset)
  rm(O_sssubset)
  
  O_subset = O_subset[ , -which(names(O_subset) %in% c("Year","ID","Event","Sport","Name","Sex","Age","Height","Weight","Team","NOC","Games","Season","City","Medal","Num_events_same_yr","prev_olypics","new_Sport","new_Event","Medal_win_num"))]
  #building dataset for all merge
  O_merge_set=bind_rows(O_merge_set,O_subset)
  #O_merge_set = rbind.fill(O_merge_set,O_subset)
  print(i)
}
rm(O_subset)
rm(Row_starts)
O <- merge(O,O_merge_set,by=c('Index'),all=T) 
rm(O_merge_set)
#View(O)

write.csv(O, "C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Final Project/Dataset 2 checkpoint.csv", row.names=FALSE)


# Checkpoint #1 ----------------------------------------------------------

Original=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Final Project/Dataset 2 checkpoint.csv")


require("randomForest")
library(gbm)
library(ggfortify)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggplot2)
library(GGally)
library(ggfortify)
library(tree)
library(rpart)
library(rpart.plot)
library(MASS)
library(klaR)

# Data Triage ----------------------------------------------------------
#recipies
Original$Medal=as.factor(Original$Medal)
Original$Medal=relevel(Original$Medal, ref="Gold")



# adds a column that determines whether or not an athlete competes in the fuuter
O_new=summarise(group_by(Original,ID,Year))
O_new$Comp_num=with(O_new, ave(seq(O_new$ID), O_new$ID, FUN = function(x) seq(length(x))))
Last_Event=aggregate(Comp_num~ID, O_new, max)
Last_Event$Max_Evnt=Last_Event$Comp_num
Last_Event=Last_Event[,names(Last_Event) %in% c("Max_Evnt","ID")]
O_new <- merge(Last_Event,O_new,by=c('ID'),all=T) 
O_new$Will_Compete_Again = ifelse(O_new$Max_Evnt == O_new$Comp_num, 'False', 'True')
Original <- merge(Original,O_new,by=c('ID','Year'),all=T) 
Original$Will_Compete_Again=as.factor(Original$Will_Compete_Again)
rm(O_new)
rm(Last_Event)

Original$Nums_in_career=with(Original,Original$prev_olypics+1)

# represents athlets who have won at least one medals
O_new=subset(Original, !is.na(Medal))
O_new=aggregate(Comp_num~ID, O_new, max)
O_new$Indicator="True"
O_new = O_new[,names(O_new) %in% c("Indicator","ID")]
Spicy <- merge(Original,O_new,by=c('ID'),all=T) 
Spicy=subset(Spicy, !is.na(Indicator))
Spicy = Spicy[ , -which(names(Spicy) %in% c("Indicator"))]
rm(O_new)



#Spicy=subset(Original, prev_olypics>0)
##SpiceyN replaces the NAs with 0s and limits the data to only the years since last olympic win
#SpicyN=Spicy[ , which(names(Spicy) %in% c("prev_olypics","Years_since_last_win_Gold","Years_since_last_win_NA","Years_since_last_win_Silver","Years_since_last_win_Bronze"))]
#SpicyN[is.na(SpicyN)]<-0

#represents athletes who only compete in one category
Specialist_ID=aggregate(new_Event~ID, Original, max)
Specialist_ID=subset(Specialist_ID, new_Event>2)
avector <- Specialist_ID[['ID']]
Specialist=subset(Original,!(Original$ID %in% avector))
rm(Specialist_ID)
rm(avector)


# Test Athletes ----------------------------------------------------------

T_Athlete1=subset(Original,Index==214051)
T_Athlete2=T_Athlete1
T_Athlete1$Medal[T_Athlete1$Medal=="Silver"]<-"Gold"
T_Athlete3=T_Athlete1
T_Athlete3$Medal[T_Athlete3$Medal=="Silver"]<-"Bronze"

# Tree Model to Determine num of olympics ----------------------------------------------------------

#Original

tree1=rpart(Nums_in_career~Year+
               +Sport+
               Sex+Age+
               Height+Weight+
               NOC+
               Medal+Num_events_same_yr+
               new_Sport+new_Event+
               Medal_win_num,
             control=rpart.control(cp=0.004),data=Original)
rpart.plot(tree1)
summary(tree1)

tree2=rpart(Nums_in_career~+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,
             control=rpart.control(cp=0.001),data=Original)
rpart.plot(tree2)
summary(tree2)

tree3=rpart(Will_Compete_Again~Year+
              Sport+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.004),data=Original)
rpart.plot(tree3, box.palette=c("mediumpurple1","orange"))
summary(tree3)

tree4=rpart(Will_Compete_Again~Medal+Age,control=rpart.control(cp=0.00000000000000000000000000000000000000000000000000000000000000000000000000001),data=Original)
rpart.plot(tree4)
summary(tree4)

tree5=rpart(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.000025),data=Original)
rpart.plot(tree5)
summary(tree5)

##Spicy
tree1=rpart(Nums_in_career~Year+
              Sport+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.01),data=Spicy)
rpart.plot(tree1)
summary(tree1)

tree2=rpart(Nums_in_career~+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.01),data=Spicy)
rpart.plot(tree2)
summary(tree2)

tree3=rpart(Will_Compete_Again~Year+
              Sport+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.01),data=Spicy)
rpart.plot(tree3)
summary(tree3)

tree4=rpart(Will_Compete_Again~Medal+Age+Sex,control=rpart.control(cp=0.001),data=Spicy)
rpart.plot(tree4, box.palette=c("mediumpurple1","orange"))
plotcp(tree4)

tree5=rpart(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.0001),data=Spicy)
rpart.plot(tree5)
summary(tree5)

tree4=rpart(Will_Compete_Again~Medal,control=rpart.control(cp=0.00000000000000000000000000001),data=Spicy)
rpart.plot(tree4)
plotcp(tree4)

##Specialist

tree1=rpart(Nums_in_career~Year+
              Sport+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.01),data=Specialist)
rpart.plot(tree1)
summary(tree1)

tree2=rpart(Nums_in_career~+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.01),data=Specialist)
rpart.plot(tree2)
summary(tree2)

tree3=rpart(Will_Compete_Again~Year+
              Sport+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.002),data=Specialist)
rpart.plot(tree3)
summary(tree3)

tree4=rpart(Will_Compete_Again~Medal+Age,control=rpart.control(cp=0.0000001),data=Specialist)
rpart.plot(tree4)
summary(tree4)

tree5=rpart(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,
            control=rpart.control(cp=0.000000000025),data=Specialist)
rpart.plot(tree5)
summary(tree5)


# Random Forest Model to Determine num of olympics ----------------------------------------------------------

##Original
myforest=randomForest(Nums_in_career~Year+
                        Sport+
                        Sex+Age+
                        Height+Weight+
                        NOC+
                        Medal+Num_events_same_yr+
                        new_Sport+new_Event+
                        Medal_win_num+Years_since_last_win_Gold+
                        Years_since_last_win_NA+Years_since_last_win_Silver+
                        Years_since_last_win_Bronze, ntree=500, data=Original, importance=TRUE, na.action = na.omit)
myforest
importance(myforest)
varImpPlot(myforest)

myforest2=randomForest(Nums_in_career~+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Original, importance=TRUE, na.action = na.omit)
myforest2
importance(myforest2)
varImpPlot(myforest2)

myforest3=randomForest(Will_Compete_Again~
                         Sport+
                         Sex+Age+
                         Height+Weight+
                         +NOC+
                         Medal+Num_events_same_yr+
                         new_Sport+new_Event+
                         Medal_win_num+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Original, importance=TRUE, na.action = na.omit)
myforest3
importance(myforest3)
varImpPlot(myforest3)
predict(myforest3,T_Athlete1)
predict(myforest3,T_Athlete2)
predict(myforest3,T_Athlete3)



myforest4=randomForest(Will_Compete_Again~Medal+Age, ntree=500, data=Original, importance=TRUE, na.action = na.omit)

myforest4
importance(myforest4)
varImpPlot(myforest4)
myforest5=randomForest(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Original, importance=TRUE, na.action = na.omit)
myforest5
importance(myforest5)
varImpPlot(myforest5)

##Spicy
myforest=randomForest(Nums_in_career~Year+
                        Sport+
                        Sex+Age+
                        Height+Weight+
                        NOC+
                        Medal+Num_events_same_yr+
                        new_Sport+new_Event+
                        Medal_win_num+Years_since_last_win_Gold+
                        Years_since_last_win_NA+Years_since_last_win_Silver+
                        Years_since_last_win_Bronze, ntree=500, data=Spicy, importance=TRUE, na.action = na.omit)
myforest
importance(myforest)
varImpPlot(myforest)

myforest2=randomForest(Nums_in_career~Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Spicy, importance=TRUE, na.action = na.omit)
myforest2
importance(myforest2)
varImpPlot(myforest2)

myforest3=randomForest(Will_Compete_Again~Year+
                         Sport+
                         Sex+Age+
                         Height+Weight+
                         NOC+
                         Medal+Num_events_same_yr+
                         new_Sport+new_Event+
                         Medal_win_num+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Spicy, importance=TRUE, na.action = na.omit)
myforest3
importance(myforest3)
varImpPlot(myforest3)
predict(myforest3,T_Athlete1)
predict(myforest3,T_Athlete2)


myforest4=randomForest(Will_Compete_Again~Medal+Age, ntree=500, data=Spicy, importance=TRUE, na.action = na.omit)

myforest4
importance(myforest4)
varImpPlot(myforest4)
myforest5=randomForest(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Spicy, importance=TRUE, na.action = na.omit)
myforest5
importance(myforest5)
varImpPlot(myforest5)

##Specialist
myforest=randomForest(Nums_in_career~Year+
                        Sport+
                        Sex+Age+
                        Height+Weight+
                        NOC+
                        Medal+Num_events_same_yr+
                        new_Sport+new_Event+
                        Medal_win_num+Years_since_last_win_Gold+
                        Years_since_last_win_NA+Years_since_last_win_Silver+
                        Years_since_last_win_Bronze, ntree=500, data=Specialist, importance=TRUE, na.action = na.omit)
myforest
importance(myforest)
varImpPlot(myforest)

myforest2=randomForest(Nums_in_career~+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Specialist, importance=TRUE, na.action = na.omit)
myforest2
importance(myforest2)
varImpPlot(myforest2)

myforest3=randomForest(Will_Compete_Again~Year+
                         Sport+
                         Sex+Age+
                         Height+Weight+
                         NOC+
                         Medal+Num_events_same_yr+
                         new_Sport+new_Event+
                         Medal_win_num+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Specialist, importance=TRUE, na.action = na.omit)
myforest3
importance(myforest3)
varImpPlot(myforest3)

myforest4=randomForest(Will_Compete_Again~Medal+Age, ntree=500, data=Specialist, importance=TRUE, na.action = na.omit)
myforest4
importance(myforest4)
varImpPlot(myforest4)

myforest5=randomForest(Will_Compete_Again~Medal+Nums_in_career+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=Specialist, importance=TRUE, na.action = na.omit)
myforest5
importance(myforest5)
varImpPlot(myforest5)

#Boosting ----------------------------------------------------------

##Original
set.seed (1)
Original$Sex=as.factor(Original$Sex)
Original$NOC=as.factor(Original$NOC)

boosted=gbm(Nums_in_career~Year+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Original)
summary(boosted)

boosted2=gbm(Nums_in_career~+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Original)
summary(boosted2)

boosted3=gbm(Will_Compete_Again~
               Sex+Age+
               Height+Weight+
               NOC+
               Medal+Num_events_same_yr+
               new_Sport+new_Event+
               Medal_win_num+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000,cv.folds=3, interaction.depth=4, data=Original)
plot_data_boosted3=summary(boosted3)

summary(boosted3,shade.col=c("mediumpurple1","orange"))
best.iter <- gbm.perf(boosted3, method = "cv")
summary(boosted3,n.trees = best.iter)
T_Athlete1=subset(Original,Index==214051)
T_Athlete3=T_Athlete2=T_Athlete1
T_Athlete3$Medal[T_Athlete3$Medal=="Silver"]<-"Bronze"
T_Athlete1$Medal[T_Athlete1$Medal=="Silver"]<-"Gold"
predict(boosted3,T_Athlete1)
predict(boosted3,T_Athlete2)
predict(boosted3,T_Athlete3)

boosted4=gbm(Will_Compete_Again~Medal+Age, distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Original)
summary(boosted4)

boosted5=gbm(Will_Compete_Again~Medal+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Original)
summary(boosted5)

##Spicy
Spicy$Sex=as.factor(Spicy$Sex)
Spicy$NOC=as.factor(Spicy$NOC)

boosted=gbm(Nums_in_career~Year+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Spicy)
summary(boosted)

boosted2=gbm(Nums_in_career~+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Spicy)
summary(boosted2)

boosted3=gbm(Will_Compete_Again~
               Sex+Age+
               Height+Weight+
               NOC+
               Medal+Num_events_same_yr+
               new_Sport+new_Event+
               Medal_win_num+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Spicy)
summary(boosted3)
T_Athlete1=subset(Original,Index==214051)
T_Athlete3=T_Athlete2=T_Athlete1
T_Athlete3$Medal[T_Athlete3$Medal=="Silver"]<-"Bronze"
T_Athlete1$Medal[T_Athlete1$Medal=="Silver"]<-"Gold"
predict(boosted3,T_Athlete1)
predict(boosted3,T_Athlete2)
predict(boosted3,T_Athlete3)

boosted4=gbm(Will_Compete_Again~Medal+Age, distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Spicy)
summary(boosted4)

boosted5=gbm(Will_Compete_Again~Medal+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Spicy)
summary(boosted5)

##Specialist
Specialist$Sex=as.factor(Specialist$Sex)
Specialist$NOC=as.factor(Specialist$NOC)

boosted=gbm(Nums_in_career~Year+
              Sex+Age+
              Height+Weight+
              NOC+
              Medal+Num_events_same_yr+
              new_Sport+new_Event+
              Medal_win_num+Years_since_last_win_Gold+
              Years_since_last_win_NA+Years_since_last_win_Silver+
              Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Specialist)
summary(boosted)

boosted2=gbm(Nums_in_career~+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Specialist)
summary(boosted2,colors="blue")

boosted3=gbm(Will_Compete_Again~
               
               Sex+Age+
               Height+Weight+
               NOC+
               Medal+Num_events_same_yr+
               new_Sport+new_Event+
               Medal_win_num+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Specialist)
summary(boosted3)
T_Athlete1=subset(Original,Index==214051)
T_Athlete3=T_Athlete2=T_Athlete1
T_Athlete3$Medal[T_Athlete3$Medal=="Silver"]<-"Bronze"
T_Athlete1$Medal[T_Athlete1$Medal=="Silver"]<-"Gold"
predict(boosted3,T_Athlete1)
predict(boosted3,T_Athlete2)
predict(boosted3,T_Athlete3)

boosted4=gbm(Will_Compete_Again~Medal+Age, distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Specialist)
summary(boosted4)

boosted5=gbm(Will_Compete_Again~Medal+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=Specialist)
summary(boosted5)

#predicted_score=predict(boosted, newdata=IMDB, n.trees=10000)

rm(boosted)
rm(boosted2)
rm(boosted3)
rm(boosted4)
rm(boosted5)

#LDA ----------------------------------------------------------
##Original
Original_lda_df=Original
Original_lda_df=Original_lda_df[!is.na(Original_lda_df$Medal),]
Original_lda_df$Medal=as.factor(Original_lda_df$Medal)
Original_lda_df$Will_Compete_Again=as.factor(Original_lda_df$Will_Compete_Again)
Original_lda=lda(Medal~Will_Compete_Again,data=Original_lda_df)
Original_lda
Original_lda2=lda(Will_Compete_Again~Medal,data=Original_lda_df)
Original_lda2
Original_qda=qda(Will_Compete_Again~Medal,data=Original_lda_df)
Original_qda
partimat(Will_Compete_Again~Age+Medal_win_num, method="lda",data=Original_lda_df)
partimat(Will_Compete_Again~Weight+Height, method="lda",data=Original_lda_df)
partimat(Will_Compete_Again~Age+Year, method="lda",data=Original_lda_df)
partimat(Medal~Weight+Height, method="lda",data=Original_lda_df)
partimat(Medal~Age+Height, method="lda",data=Original_lda_df)
partimat(Medal~Medal_win_num+prev_olypics, method="lda",data=Original_lda_df,image.colors=c( "darkorange","gold","light grey" ))
partimat(Medal~Medal_win_num+prev_olypics, method="qda",data=Original_lda_df,image.colors=c( "gold","darkorange","light grey" ))
partimat(Will_Compete_Again~Height+Weight, method="qda",data=Original_lda_df)
partimat(Will_Compete_Again~Medal_win_num+prev_olypics, method="qda",data=Original_lda_df)


##Spicy
Spicy_lda_df=Spicy
Spicy_lda_df=Spicy_lda_df[!is.na(Spicy_lda_df$Medal),]
Spicy_lda_df$Medal=as.factor(Spicy_lda_df$Medal)
Spicy_lda_df$Will_Compete_Again=as.factor(Spicy_lda_df$Will_Compete_Again)
Spicy_lda=lda(Medal~Will_Compete_Again,data=Spicy_lda_df)
Spicy_lda
Spicy_lda2=lda(Will_Compete_Again~Medal,data=Spicy_lda_df)
Spicy_lda2
Spicy_qda=qda(Will_Compete_Again~Medal,data=Spicy_lda_df)
Spicy_qda
partimat(Medal~Will_Compete_Again+Year, method="lda",data=Spicy_lda_df,image.colors=c( "darkorange","gold","light grey" ))
partimat(Medal~Medal_win_num+prev_olypics, method="qda",data=Original_lda_df,image.colors=c( "darkorange","gold","light grey" ))

##Specialist
Specialist_lda_df=Specialist
Specialist_lda_df=Specialist_lda_df[!is.na(Specialist_lda_df$Medal),]
Specialist_lda_df$Will_Compete_Again=as.factor(Specialist_lda_df$Will_Compete_Again)
Specialist_lda=lda(Medal~Will_Compete_Again,data=Specialist_lda_df)
Specialist_lda=lda(Will_Compete_Again~Medal,data=Specialist_lda_df)
Specialist_lda
Specialist_qda=qda(Will_Compete_Again~Medal,data=Specialist_lda_df)
Specialist_qda
partimat(Will_Compete_Again~Medal+Year, method="lda",data=Specialist_lda_df)
partimat(Medal~Medal_win_num+prev_olypics, method="qda",data=Original_lda_df,image.colors=c( "darkorange","gold","light grey" ))

myqda=qda(cause~age+income)
partimat(cause~income+age, method="lda",data=C,image.colors=c("light grey", "light green", "white"))


rm(Original_lda)
rm(Original_lda2)
rm(Original_lda_df)

rm(Spicy_lda)
rm(Spicy_lda2)
rm(Spicy_lda_df)

rm(Specialist_lda)
rm(Specialist_lda2)
rm(Specialist_lda_df)

#PCA Feature Engineering ----------------------------------------------------------

##Original
Original$Numeric_Will_Compete=ifelse(Original$Will_Compete_Again=="True",1,0)

##spicy
Spicy$Numeric_Will_Compete=ifelse(Spicy$Will_Compete_Again=="True",1,0)
#Spicy$Numeric_Bronze=ifelse(Spicy$Medal=="Bronze",1,0)
#Spicy$Numeric_Silver=ifelse(Spicy$Medal=="Silver",1,0)
#Spicy$Numeric_Gold=ifelse(Spicy$Medal=="Gold",1,0)


#setting the fields to be number of medals won
O_prev=summarise(group_by(Spicy, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Bronze")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Bronze=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Spicy <- merge(Spicy,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)

O_prev=summarise(group_by(Spicy, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Silver")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Silver=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Spicy <- merge(Spicy,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)

O_prev=summarise(group_by(Spicy, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Gold")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Gold=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Spicy <- merge(Spicy,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)

##Specialist
Specialist$Numeric_Will_Compete=ifelse(Specialist$Will_Compete_Again=="True",1,0)

O_prev=summarise(group_by(Specialist, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Bronze")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Bronze=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Specialist <- merge(Specialist,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)

O_prev=summarise(group_by(Specialist, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Silver")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Silver=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Specialist <- merge(Specialist,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)

O_prev=summarise(group_by(Specialist, ID,Medal,Year))
O_prev=subset(O_prev,Medal=="Gold")
#O_prev = O_prev[ , -which(names(O_prev) %in% c('ID','Year','Medal' ))]
# function to add count of nth appearance based on criteria
O_prev$Numeric_Gold=with(O_prev, ave(seq(O_prev$ID), O_prev$ID, FUN = function(x) seq(length(x))))
Specialist <- merge(Specialist,O_prev,by=c('ID','Year','Medal'),all=T) 
rm(O_prev)


#PCA ----------------------------------------------------------
##Original

O_Vars=select_if(Original,is.numeric)
O_Vars[is.na(O_Vars)]<-0
O_Vars=O_Vars %>% drop_na()
O_Vars = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID"))]
pca=prcomp(O_Vars, scale=TRUE)
autoplot(pca, data = O_Vars, loadings = TRUE,  loadings.label = TRUE, colour='mediumpurple1')

O_Vars2 = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID","Height","Weight","Year","new_Sport","Age","Num_events_same_yr","new_Event","Medal_win_num","Max_Evnt","Comp_num" ))]
pca=prcomp(O_Vars2, scale=TRUE)
autoplot(pca, data = O_Vars2, loadings = TRUE,  loadings.label = TRUE,colour='purple' )

#comparin all factors including medals as factors
O_Vars3=select_if(Original,is.numeric)
O_Vars3 = O_Vars3[ , -which(names(O_Vars3) %in% c("Index","ID","Numeric_Will_Compete"))]
O_Vars3[is.na(O_Vars3)]<-0
pca=prcomp(O_Vars3, scale=TRUE)
autoplot(pca, data = O_Vars3, loadings = TRUE,  loadings.label = TRUE )


##Spicey

O_Vars=select_if(Spicy,is.numeric)
O_Vars[is.na(O_Vars)]<-0
O_Vars=O_Vars %>% drop_na()
O_Vars = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID"))]
pca=prcomp(O_Vars, scale=TRUE)
autoplot(pca, data = O_Vars, loadings = TRUE,  loadings.label = TRUE )

O_Vars2 = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID","Height","Weight","Year","new_Sport","Age","Num_events_same_yr","new_Event","Medal_win_num","Max_Evnt","Comp_num" ))]
pca=prcomp(O_Vars2, scale=TRUE)
autoplot(pca, data = O_Vars2, loadings = TRUE,  loadings.label = TRUE )

#comparin all factors including medals as factors
O_Vars3=select_if(Spicy,is.numeric)
O_Vars3 = O_Vars3[ , -which(names(O_Vars3) %in% c("Index","ID","Numeric_Will_Compete"))]
O_Vars3[is.na(O_Vars3)]<-0
pca=prcomp(O_Vars3, scale=TRUE)
autoplot(pca, data = O_Vars3, loadings = TRUE,  loadings.label = TRUE )


O_Vars4=select_if(Spicy,is.numeric)
O_Vars4 = O_Vars4[ , which(names(O_Vars4) %in% c("Numeric_Will_Compete","Numeric_Bronze","Numeric_Silver","Numeric_Gold"))]
O_Vars4[is.na(O_Vars4)]<-0
pca=prcomp(O_Vars4, scale=TRUE)
autoplot(pca, data = O_Vars4, loadings = TRUE,  loadings.label = TRUE )


##Specialist
Specialist$Numeric_Will_Compete=ifelse(Specialist$Will_Compete_Again=="True",1,0)
O_Vars=select_if(Specialist,is.numeric)
O_Vars[is.na(O_Vars)]<-0
O_Vars=O_Vars %>% drop_na()
O_Vars = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID"))]
pca=prcomp(O_Vars, scale=TRUE)
autoplot(pca, data = O_Vars, loadings = TRUE,  loadings.label = TRUE )

O_Vars2 = O_Vars[ , -which(names(O_Vars) %in% c("Index","ID","Height","Weight","Year","new_Sport","Age","Num_events_same_yr","new_Event","Medal_win_num","Max_Evnt","Comp_num" ))]
pca=prcomp(O_Vars2, scale=TRUE)
autoplot(pca, data = O_Vars2, loadings = TRUE,  loadings.label = TRUE )

#comparin all factors including medals as factors
O_Vars3=select_if(Specialist,is.numeric)
O_Vars3 = O_Vars3[ , -which(names(O_Vars3) %in% c("Index","ID","Numeric_Will_Compete"))]
O_Vars3[is.na(O_Vars3)]<-0
pca=prcomp(O_Vars3, scale=TRUE)
autoplot(pca, data = O_Vars3, loadings = TRUE,  loadings.label = TRUE )

O_Vars5=select_if(Specialist,is.numeric)
#O_Vars5=subset(O_Vars5,Age>25 & Age<40)
O_Vars5 = O_Vars5[ , which(names(O_Vars5) %in% c("Numeric_Will_Compete","Numeric_Bronze","Numeric_Silver","Numeric_Gold"))]
O_Vars5[is.na(O_Vars5)]<-0
pca=prcomp(O_Vars5, scale=TRUE)
autoplot(pca, data = O_Vars5, loadings = TRUE,  loadings.label = TRUE,  main="PCA Analysis of Number of Medals on Spcialist Dataset",,colour='darkorchid2')



rm(O_Vars)
rm(O_Vars2)
rm(O_Vars3)
rm(O_Vars4)
rm(O_Vars5)
#KNN ----------------------------------------------------------

##Original
Original_knn_C=select_if(Original,is.numeric)
Original_knn_C = Original_knn_C[ , -which(names(Original_knn_C) %in% c("Index","ID","Numeric_Will_Compete"))]
#set number of clusters
n=8

Original_knn_C[is.na(Original_knn_C)]<-0

Original_knn=subset(Original_knn_C,Years_since_last_win_Bronze>0)
km=kmeans(Original_knn, n) #2 clusters
Original_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Original_knn,aes(x=Nums_in_career, y=Years_since_last_win_Bronze,colour=cluster))
base_plot_Bronze=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Bronze Medal")+
  ggtitle("6 Clusters-Original") 
base_plot_Bronze


Original_knn=subset(Original_knn_C,Years_since_last_win_Silver>0)
km=kmeans(Original_knn, n)
Original_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Original_knn,aes(x=Nums_in_career, y=Years_since_last_win_Silver,colour=cluster))
base_plot_Silver=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Silver Medal")+
  ggtitle("6 Clusters-Original") 
base_plot_Silver

Original_knn=subset(Original_knn_C,Years_since_last_win_Gold>0)
km=kmeans(Original_knn, n)
Original_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Original_knn,aes(x=Nums_in_career, y=Years_since_last_win_Gold,colour=cluster))
base_plot_Gold=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Gold Medal")+
  ggtitle("6 Clusters-Original") 
base_plot_Gold

km

#total variance of clusters
km$tot.withinss


##Spicy
Spicy_knn_C=select_if(Spicy,is.numeric)
Spicy_knn_C = Spicy_knn_C[ , -which(names(Spicy_knn_C) %in% c("Index","ID","Numeric_Will_Compete"))]

Spicy_knn_C[is.na(Spicy_knn_C)]<-0



Spicy_knn=subset(Spicy_knn_C,Years_since_last_win_Bronze>0)
km=kmeans(Spicy_knn, n)
Spicy_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Spicy_knn,aes(x=Nums_in_career, y=Years_since_last_win_Bronze,colour=cluster))
base_plot_Bronze=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Bronze Medal")+
  ggtitle("6 Clusters-Spicy") 
base_plot_Bronze

Spicy_knn=subset(Spicy_knn_C,Years_since_last_win_Silver>0)
km=kmeans(Spicy_knn, n)
Spicy_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Spicy_knn,aes(x=Nums_in_career, y=Years_since_last_win_Silver,colour=cluster))
base_plot_Silver=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Silver Medal")+
  ggtitle("6 Clusters-Spicy") 
base_plot_Silver

Spicy_knn=subset(Spicy_knn_C,Years_since_last_win_Gold>0)
km=kmeans(Spicy_knn, n)
Spicy_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Spicy_knn,aes(x=Nums_in_career, y=Years_since_last_win_Gold,colour=cluster))
base_plot_Gold=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Gold Medal")+
  ggtitle("6 Clusters-Spicy") 
base_plot_Gold

km

#total variance of clusters
km$tot.withinss


##Specialist
Specialist_knn_C=select_if(Specialist,is.numeric)
Specialist_knn_C[is.na(Specialist_knn_C)]<-0



Specialist_knn=subset(Specialist_knn_C,Years_since_last_win_Bronze>0)
km=kmeans(Specialist_knn, n)
Specialist_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Specialist_knn,aes(x=Nums_in_career, y=Years_since_last_win_Bronze,colour=cluster))
base_plot_Bronze=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Bronze Medal")+
  ggtitle("6 Clusters-Specialist") 
base_plot_Bronze

Specialist_knn=subset(Specialist_knn_C,Years_since_last_win_Silver>0)
km=kmeans(Specialist_knn, n)
Specialist_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Specialist_knn,aes(x=Nums_in_career, y=Years_since_last_win_Silver,colour=cluster))
base_plot_Silver=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Silver Medal")+
  ggtitle("6 Clusters-Specialist") 
base_plot_Silver

Specialist_knn=subset(Specialist_knn_C,Years_since_last_win_Gold>0)
km=kmeans(Specialist_knn, n)
Specialist_knn$cluster=as.factor(km$cluster)
plot=ggplot(data=Specialist_knn,aes(x=Nums_in_career, y=Years_since_last_win_Gold,colour=cluster))
base_plot_Gold=plot+geom_count()+
  labs(x = "Number of Olympics in Career", y = "Years Since First Gold Medal")+
  ggtitle("6 Clusters-Specialist") 
base_plot_Gold

km

#total variance of clusters
km$tot.withinss



rm(Original_knn)
rm(Original_knn_C)

rm(Spicy_knn)
rm(Spicy_knn_C)

rm(Specialist_knn)
rm(Specialist_knn_C)

rm(km)
#Graphics ----------------------------------------------------------

Unique_List=aggregate(Age~ID+Sex, Original, min)
ggplot(Unique_List, aes(x=Age)) + geom_histogram(fill="purple",color="orange") + labs(title="Age Distribution of Olympic Athletes 1896-2016")+ylab("Count of Athlets")
ggplot(Unique_List, aes(x=Age,fill=Sex)) + geom_histogram()+ scale_fill_manual(values=c("#A020F0", "#FFA500")) + labs(title="Age Distribution of Olympic Athletes by Gender 1896-2016")+ylab("Count of Athlets")





Original_numeric=select_if(Original,is.numeric)
Original_numeric[is.na(Original_numeric)]<-0
Original_numeric = Original_numeric[ , -which(names(Original_numeric) %in% c("Index","Year","ID","Name","Sex","Team","Games","Season","City","Years_since_last_win_Bronze","Years_since_last_win_Silver","Years_since_last_win_Gold","Years_since_last_win_NA","new_Event","new_Sport"))]

Spicy_numeric=select_if(Spicy,is.numeric)
Spicy_numeric[is.na(Spicy_numeric)]<-0

Specialist_numeric=select_if(Specialist,is.numeric)
Specialist_numeric[is.na(Specialist_numeric)]<-0



set.seed(1)
n=500
library(clusterGeneration)
library(mnormt)
S=genPositiveDefMat("eigen",dim=15)
S=genPositiveDefMat("unifcorrmat",dim=15)
X=rmnorm(n,varcov=S$Sigma)
library(corrplot)



corrplot(cor(Original_numeric), order = "hclust",col = COL2('PuOr', n),sig.level =.8,addrect = 4)
corrplot(cor(Spicy_numeric), order = "hclust",col = COL2('PuOr', n),sig.level = 0.10,addrect = 2)
corrplot(cor(Specialist_numeric), order = "hclust",col = COL2('PuOr', n),sig.level = 0.10,addrect = 2)


#feature importance
ggplot(plot_data_boosted3,aes(y=rel.inf,x=reorder(var,rel.inf),fill="Relative Importance"))+geom_col()+coord_flip()+ scale_fill_manual(values=c("mediumpurple1", "#FFA500"))









rm(Original_numeric)
rm(Spicy_numeric)
rm(Specialist_knn)

#Predictions ----------------------------------------------------------

train=subset(Original,Year<2012)
test =subset(Original,Year==2012)
test$Will_Compete_Again = ifelse(test$Will_Compete_Again == 'False',0,1)
train$Will_Compete_Again = ifelse(train$Will_Compete_Again == 'False',0,1)

myforest3=randomForest(Will_Compete_Again~
                         Sex+Age+
                         Height+Weight+
                         NOC+
                         Medal+Num_events_same_yr+
                         new_Sport+new_Event+
                         Medal_win_num+Years_since_last_win_Gold+
                         Years_since_last_win_NA+Years_since_last_win_Silver+
                         Years_since_last_win_Bronze, ntree=500, data=train, importance=TRUE, na.action = na.omit)

test$pred=(predict(myforest3,test))
test$pred = ifelse(test$pred == 'True',1,0)
test$Will_Compete_Again = ifelse(test$Will_Compete_Again == 'False',0,1)
test$mse=with(test,(Will_Compete_Again-pred)**2)
sum(test$mse)*1/nrow(test)

train$Sex=as.factor(train$Sex)
train$NOC=as.factor(train$NOC)
test$Sex=as.factor(test$Sex)
test$NOC=as.factor(test$NOC)


boosted3=gbm(Will_Compete_Again~
               Sex+Age+
               Height+Weight+
               NOC+
               Medal+Num_events_same_yr+
               new_Sport+new_Event+
               Medal_win_num+Years_since_last_win_Gold+
               Years_since_last_win_NA+Years_since_last_win_Silver+
               Years_since_last_win_Bronze,distribution= "gaussian",n.trees=1000, interaction.depth=4, data=train)
summary(boosted3)

test$pred=round(predict(boosted3,test))
test$mse=with(test,(Will_Compete_Again-pred)**2)
sum(test$mse)*1/nrow(test)
#mean((predicted_score - IMDB$imdb_score)^2)

boosted4=gbm(Will_Compete_Again~Medal+Sex, distribution= "gaussian",n.trees=1000, interaction.depth=4, data=train)
test2=subset(Original,Year==2012)
test2$Sex=as.factor(test2$Sex)
test2$NOC=as.factor(test2$NOC)
test2$Will_Compete_Again = ifelse(test2$Will_Compete_Again == 'False',0,1)
test2$pred=round(predict(boosted4,test2))
test2$mse=with(test2,(Will_Compete_Again-pred)**2)
sum(test2$mse)*1/nrow(test2)

rm(test)
rm(train)
rm(test2)
rm(myforest3)
rm(boosted3)
rm(boosted4)


#Boosting ----------------------------------------------------------





#Boosting ----------------------------------------------------------


# #Create scatter plSpicys
# ggpairs(O_Vars)
# #Running  principal component analysis  (PCA) on the tSpicyal dataset
# pca=prcomp(O_Vars, scale=TRUE)
# pca
# #Visualizing principal components
# #Closer the redlines are the more highly correlated they are
# autoplot(pca, data = O_Vars, loadings = TRUE,  loadings.label = TRUE )
# 
# #same process with only years since last 
# ggpairs(O_Vars2)
# #PCA
# pca2=prcomp(O_Vars2, scale=TRUE)
# pca2
# #plSpicy second PCA
# autoplot(pca2, data = O_Vars2, loadings = TRUE,  loadings.label = TRUE )
# 
# #same process with only years since last 
# ggpairs(O_Vars3)
# pca3=prcomp(O_Vars3, scale=TRUE)
# pca3
# #plSpicy PCA3
# autoplot(pca3, data = O_Vars3, loadings = TRUE,  loadings.label = TRUE )
# 
# #same process with some variabeles removed
# ggpairs(O_Vars4)
# pca4=prcomp(O_Vars4, scale=TRUE)
# pca4
# #plSpicy PCA4
# autoplot(pca4, data = O_Vars4, loadings = TRUE,  loadings.label = TRUE )



#O$test=with(O, ave(seq(O$ID),O$ID, O$Sport, FUN = function(x) seq(length(x)))-1)

#seq(O$ID)


#e$predictedWinner=with(e,predict(R_Forest2,data.frame(popChange=popChange,under5=under5,over65=over65,female=female,black=black,hispanic=hispanic,undergrad=undergrad,density=density)))


#Prev_apperance1 <- function(df,Name,G1){
  # print(df[G1])
  # df_new=summarise(group_by(df, df$G1))
  # print(df_new)
  #df_new$Name=with(df_new, ave(seq(df_new$G1), df_new$G1, FUN = function(x) seq(length(x))))
  #df <- merge(df,df_new,by=c(G1)) 
  
  #mytree=rpart(prev_olypics~Year+
               #   Event+Sport+
               #   Name+Sex+Age+
               #   Height+Weight+Team+
               #   NOC+Games+Season+
               #   City+Medal+Num_events_same_yr+
               #   new_Sport+new_Event+
               #   Medal_win_num+Years_since_last_win_Gold+
               #   Years_since_last_win_NA+Years_since_last_win_Silver+
               #   Years_since_last_win_Bronze,
               # control=rpart.control(cp=0.01),data=OT)
  
  