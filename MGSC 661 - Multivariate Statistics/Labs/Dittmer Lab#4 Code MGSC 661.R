e=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #4/election2016.csv")
library(tree)
library(rpart)
library(rpart.plot)



#####################Question 2
#####A
Tree1=rpart(mostVotes~popChange+under5+over65+female+black+hispanic+undergrad,control=rpart.control(cp=0.1),data=e)
rpart.plot(Tree1)

Tree2=rpart(mostVotes~popChange+under5+over65+female+black+hispanic+undergrad,control=rpart.control(cp=0.01),data=e)
rpart.plot(Tree2)

Tree3=rpart(mostVotes~popChange+under5+over65+female+black+hispanic+undergrad,control=rpart.control(cp=0.001),data=e)
rpart.plot(Tree3)

#####C
#printcp(Tree3)
plotcp(Tree3)

#####D
opt_cp=Tree3$cptable[which.min(Tree3$cptable[,"xerror"]),"CP"]
opt_cp

#####E
Tree4=rpart(mostVotes~popChange+under5+over65+female+black+hispanic+undergrad,control=rpart.control(cp=opt_cp),data=e)
rpart.plot(Tree4)






#####################Question 3
#####D
library(randomForest)
R_Forest1=randomForest(as.factor(mostVotes)~popChange+under5+over65+female+black+hispanic+undergrad+density,
                       ntree=1000,
                       data=e,
                       importance=TRUE,
                       na.action = na.omit)
R_Forest1

#####F
#varImpPlot(R_Forest1)
R_Forest1=randomForest(as.factor(mostVotes)~popChange+under5+over65+female+black+hispanic+undergrad+density,
                       ntree=1000,
                       data=e,
                       importance=TRUE,
                       na.action = na.omit,
                       do.trace=100)


#####H
varImpPlot(R_Forest1)

#####################Question 4

#####A
R_Forest2=randomForest(as.factor(mostVotes)~popChange+under5+over65+female+black+hispanic+undergrad+density,
                       ntree=10000,
                       data=e,
                       importance=TRUE,
                       na.action = na.omit)



e$predictedWinner=with(e,predict(R_Forest2,data.frame(popChange=popChange,under5=under5,over65=over65,female=female,black=black,hispanic=hispanic,undergrad=undergrad,density=density)))
y = predict(R_Forest2,e)
e$predictedWinner <- y


#e$predictedWinner=ifelse(e$predictedWinner=="Trump","1","0")                                                        

e$check=ifelse(e$predictedWinner==e$mostVotes,0,1)
sum(e$check)
#####B
#install.packages("usmap")
library(usmap)
library(ggplot2)


plot_usmap(regions = "counties",  data = e , values = "predictedWinner") +
  scale_fill_manual(values = c("blue","red"))+
  labs(title = "Elections 2016 (Predictions)",subtitle = "This is a  map of predicted 2016 election results in the United States.") + 
  theme(legend.position = "right")+
  theme(panel.background = element_rect(color = "black"))
  

#####C
plot_usmap(regions = "counties",  data = e , values = "mostVotes") +
  scale_fill_manual(values = c("blue","red"))+
  labs(title = "Elections 2016 (Actuals)",subtitle = "This is a  map of the actual outcome of the 2016 election results in the United States.") + 
  theme(legend.position = "right")+
  theme(panel.background = element_rect(color = "black"))

#####D



#####################Question 5
#####A

c=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #4/cancerDiagnoses.csv")
c_vars=c[,c(2:9)]
c_diag=c[,c(1)]
pca=prcomp(c_vars, scale=TRUE)
pca
summary(pca)
library(ggfortify)
autoplot(pca, data = c_vars, loadings = TRUE, col=ifelse(c_diag=="M","red","green"),loadings.label = TRUE )

#####I
pve=(pca$sdev^2)/sum(pca$sdev^2)
par(mfrow=c(1,2))
plot(pve, ylim=c(0,1))
plot(cumsum(pve), ylim=c(0,1))


#####J
c$diagnosis=as.factor(c$diagnosis)
c$diagnosisscore=ifelse(c$diagnosis=="M",1,0)
logreg=glm(diagnosisscore~perimeter+symmetry+curvature,data=c)
summary(logreg)


#####K
require(rms)
logreg2 =lrm(diagnosisscore~perimeter+texture+curvature,data=c)
logreg2
