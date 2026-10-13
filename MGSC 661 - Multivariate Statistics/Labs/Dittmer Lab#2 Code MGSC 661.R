##Qs
##need to use x for stargazer output?
##need title for graphs?
##d=1 sufficient as legend?

BG=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #2/board_games_2022.csv")
attach(BG)
names(BG)
#install.packages("stargazer")
library(stargazer)
#install.packages("ggpubr")


#####################Question 1
#####A
reg1=lm(average_rating~duration)
reg2=lm(average_rating~players_min) 
reg3=lm(average_rating~players_max) 
mreg=lm(average_rating~duration+players_min+players_max) 

stargazer(reg1, reg2, reg3, mreg, type="html")

####B
summary(mreg)

####C
stargazer(reg1, reg2, reg3, mreg, type="html",dep.var.labels="Board game rating",covariate.labels=c("Average duration","Minimum number of players","Maximum number of players"))

####D
stargazer(reg1, reg2, reg3, mreg, type="html",dep.var.labels="Board game rating",covariate.labels=c("Average duration","Minimum number of players","Maximum number of players"),digits=2)

#####################Question 2
reg2_1=lm(average_rating~poly(num_reviews,1,raw=TRUE))
reg2_2=lm(average_rating~poly(num_reviews,2))
reg2_3=lm(average_rating~poly(num_reviews,3))
reg2_4=lm(average_rating~poly(num_reviews,4))
library(stargazer)
stargazer(reg2_1, reg2_2, reg2_3, reg2_4, type="html")
##B

require(ggplot2)
require(methods)
library(ggpubr)
baseplot2<-ggplot(data=BG,aes(x=num_reviews,y=average_rating))
scatter2=geom_point(color="grey")

bs2=baseplot2+scatter2

line_2d1=bs2+geom_smooth(method="lm",formula=y~poly(x,1,raw=TRUE),aes(color="green"))+ggtitle("1st Order Polynomial Fit")+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=1", guide="legend")
line_2d2=bs2+geom_smooth(method="lm",formula=y~poly(x,2),aes(color="green"))+ggtitle("2nd Order Polynomial Fit")+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=2", guide="legend")
line_2d3=bs2+geom_smooth(method="lm",formula=y~poly(x,3),aes(color="green"))+ggtitle("3rd Order Polynomial Fit")+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=3", guide="legend")
line_2d4=bs2+geom_smooth(method="lm",formula=y~poly(x,4),aes(color="green"))+ggtitle("4th Order Polynomial Fit")+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=4", guide="legend")

#ALT CODE
#line_2d1=bs2+geom_smooth(method="lm",formula=y~poly(x,1,raw=TRUE),aes(color="green"))+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=1", guide="legend")
#line_2d2=bs2+geom_smooth(method="lm",formula=y~poly(x,2),aes(color="green"))+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=2", guide="legend")
#line_2d3=bs2+geom_smooth(method="lm",formula=y~poly(x,3),aes(color="green"))+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=3", guide="legend")
#line_2d4=bs2+geom_smooth(method="lm",formula=y~poly(x,4),aes(color="green"))+ylab("Average Rating")+xlab("Number of Reviews")+scale_color_identity(name = "Legend", labels = "d=4", guide="legend")
#titles2= c("Polynomial Fit", "Polynomial Fit", "Polynomial Fit","Polynomial Fit")

ggarrange(line_2d1,
          line_2d2,
          line_2d3,
          line_2d4,  
          ncol = 1, nrow = 4)
#labels =titles2,

anova(reg2_1,reg2_2,reg2_3,reg2_4)
anova(reg2_1,reg2_3)


#####################Question 3
##A
reg3_1=lm(average_rating~poly(players_max,1,raw=TRUE))
reg3_2=lm(average_rating~poly(players_max,2))
reg3_3=lm(average_rating~poly(players_max,3))
reg3_4=lm(average_rating~poly(players_max,4))
library(stargazer)
stargazer(reg3_1, reg3_2, reg3_3, reg3_4, type="html")


##B
require(ggplot2)
require(methods)
library(ggpubr)

baseplot3<-ggplot(data=BG,aes(x=players_max,y=average_rating))
scatter3=geom_point(colour="gray")

bs3=baseplot3+scatter3

line_3d1=bs3+geom_smooth(method="lm",formula=y~poly(x,1,raw=TRUE),aes(color="green"))+ggtitle("1st Order Polynomial Fit")+ylab("Average Rating")+xlab("Maximum Number of Players")+scale_color_identity(name = "Legend", labels = "d=1", guide="legend")
line_3d2=bs3+geom_smooth(method="lm",formula=y~poly(x,2),aes(color="green"))+ggtitle("2nd Order Polynomial Fit")+ylab("Average Rating")+xlab("Maximum Number of Players")+scale_color_identity(name = "Legend", labels = "d=2", guide="legend")
line_3d3=bs3+geom_smooth(method="lm",formula=y~poly(x,3),aes(color="green"))+ggtitle("3rd Order Polynomial Fit")+ylab("Average Rating")+xlab("Maximum Number of Players")+scale_color_identity(name = "Legend", labels = "d=3", guide="legend")
line_3d4=bs3+geom_smooth(method="lm",formula=y~poly(x,4),aes(color="green"))+ggtitle("4th Order Polynomial Fit")+ylab("Average Rating")+xlab("Maximum Number of Players")+scale_color_identity(name = "Legend", labels = "d=4", guide="legend")

#titles3= c("1st Order Polynomial Fit", "2nd Order Polynomial Fit", "3rd Order Polynomial Fit","4th Order Polynomial Fit")
ggarrange(line_3d1,
          line_3d2,
          line_3d3,
          line_3d4,
          ncol = 2, nrow = 2)

anova(reg3_1,reg3_2,reg3_3,reg3_4)


#####################Question 4
reg4_1=lm(average_rating~poly(num_reviews,2)+poly(players_max,4))
summary(reg4_1)
stargazer(reg4_1, type="html",covariate.labels=c("Number of Reviews","Maximum Number of players"))


#####################Question 5

##B
library(splines)

k1=quantile(duration,1/6)
k2=quantile(duration,2/6)
k3=quantile(duration,3/6)
k4=quantile(duration,4/6)
k5=quantile(duration,5/6)

reg5_1= lm(average_rating~bs(duration,knots=c(k1,k2,k3,k4,k5), degree=1))
reg5_2= lm(average_rating~bs(duration,knots=c(k1,k2,k3,k4,k5), degree=2))
reg5_3= lm(average_rating~bs(duration,knots=c(k1,k2,k3,k4,k5), degree=3))
reg5_4= lm(average_rating~bs(duration,knots=c(k1,k2,k3,k4,k5), degree=4))
reg5_5= lm(average_rating~bs(duration,knots=c(k1,k2,k3,k4,k5), degree=5))


stargazer(reg5_1, type="html")
stargazer(reg5_2, type="html")
stargazer(reg5_3, type="html")
stargazer(reg5_4, type="html")
stargazer(reg5_5, type="html")




plot5=ggplot(data=BG, aes(y=average_rating, x=duration))
scatter5= geom_point()
bs5=plot5+scatter5+ylab("Average Rating")+xlab("Duration")

#+geom_vline(aes(xintercept=k5, linetype="dotted"))+ylab("Average Rating")+xlab("Duration")

#Create dummy variable
#bs4=bs4 + scale_linetype_manual(name="Knots",values = c("6 Knots" = "dashed"))
#spline_4d1+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")

spline_5d1=bs5 + geom_smooth(method = "lm", formula = y~bs(x,knots=c(k1,k2,k3,k4,k5), degree=1), aes(color="blue"))+scale_color_identity(name = "5 Spline Fit",breaks = c("blue"),labels = c("d=2"),guide = "legend")+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")+ggtitle("1st Order Polynomial Spline Fit")
spline_5d2=bs5 + geom_smooth(method = "lm", formula = y~bs(x,knots=c(k1,k2,k3,k4,k5), degree=2), aes(color="blue"))+scale_color_identity(name = "5 Spline Fit",breaks = c("blue"),labels = c("d=2"),guide = "legend")+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")+ggtitle("2nd Order Polynomial Spline Fit")
spline_5d3=bs5 + geom_smooth(method = "lm", formula = y~bs(x,knots=c(k1,k2,k3,k4,k5), degree=3), aes(color="blue"))+scale_color_identity(name = "5 Spline Fit",breaks = c("blue"),labels = c("d=3"),guide = "legend")+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")+ggtitle("3nd Order Polynomial Spline Fit")
spline_5d4=bs5 + geom_smooth(method = "lm", formula = y~bs(x,knots=c(k1,k2,k3,k4,k5), degree=4), aes(color="blue"))+scale_color_identity(name = "5 Spline Fit",breaks = c("blue"),labels = c("d=4"),guide = "legend")+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")+ggtitle("4th Order Polynomial Spline Fit")
spline_5d5=bs5 + geom_smooth(method = "lm", formula = y~bs(x,knots=c(k1,k2,k3,k4,k5), degree=5), aes(color="blue"))+scale_color_identity(name = "5 Spline Fit",breaks = c("blue"),labels = c("d=5"),guide = "legend")+geom_vline(xintercept=c(k1,k2,k3,k4,k5), linetype="dotted")+ggtitle("5th Order Polynomial Spline Fit")

#need number of knots as well
ggarrange(spline_5d1,
          spline_5d2,
          spline_5d3,
          spline_5d4,
          spline_5d5,
          ncol = 2, nrow = 3)


#####################Question 6
reg6_1=lm(average_rating~weight)
#install.packages("caTools")
library(caTools)
sample=sample.split(average_rating,SplitRatio=0.5)
train_set=subset(BG,sample==TRUE)
test_set=subset(BG,sample==FALSE)

fit=lm(average_rating~weight,data=train_set)

fit=lm(average_rating~poly(weight,2),data=train_set)

actual=test_set$average_rating
prediction=predict(fit, test_set)
squared_error=(actual-prediction)
mse=mean(squared_error)
print(mse)

library(caTools)
for (i in 1:10){
  X6=c()
  for (j in 1:30){
  sample=sample.split(average_rating,SplitRatio=0.5)
  train_set=subset(BG,sample==TRUE)
  test_set=subset(BG,sample==FALSE)
  fit=lm(average_rating~poly(weight,i),data=train_set)
  actual=test_set$average_rating
  prediction=predict(fit, test_set)
  squared_error=(actual-prediction)^2
  mse=mean(squared_error)
  #cat("d=",i,":",round(mse,4),"\n")
  #print(i)
  X6<-append(X6,mse)
  }
  cat("d=",i,":",round(mean(X6),3),"\n")
}

#####################Question 7
library(boot)
fit7=glm(average_rating~weight, data=BG)
start_time <- Sys.time()
mse=cv.glm(BG, fit7)$delta[1]
end_time <- Sys.time()
timer7=end_time - start_time
mse
timer7

fit7=glm(average_rating~poly(weight,1), data=BG)
start_time <- Sys.time()
mse=cv.glm(BG, fit7)$delta[1]
end_time <- Sys.time()
timer7=end_time - start_time
mse
timer7


##E
start_time <- Sys.time()
mse7_E=rep(NA,10)
for (i in 1:10) {
  fit7_E=glm(average_rating~poly(weight,i), data=BG)
  mse7_E[i]=cv.glm(BG, fit7_E)$delta[1]
  cat("d=",i,":",round(mse7_E[i],3),"\n")
}
end_time <- Sys.time()
timer7_E=end_time - start_time
mse7_E
timer7_E

plot(mse7_E)
lines(mse7_E,col="red")
which.min(mse7_E)


#####################Question 8
mse8=rep(NA,10)

for (i in 1:10) {
    fit8=glm(average_rating~poly(num_reviews,i), data=BG)
    mse8[i]=cv.glm(BG,fit8,K=10)$delta[1]
    cat("d=",i,":",round(mse8[i],3),"\n")
}
mse8
which.min(mse8)

#####################Question 9
library(splines)
library(boot)

k9_11=quantile(BG$weight,1/3)
k9_12=quantile(BG$weight,2/3)
k9_21=quantile(BG$year_of_release,1/3)
k9_22=quantile(BG$year_of_release,2/3)
k9_31=quantile(BG$num_reviews,1/3)
k9_32=quantile(BG$num_reviews,2/3)
k9_41=quantile(BG$duration,1/3)
k9_42=quantile(BG$duration,2/3)



################
start_time <- Sys.time()

i=0
mse9=rep(NA,256)

tlist9=c()

for (a in 2:5){
  for (b in 2:5){
    for (c in 2:5){
      for (d in 2:5){
          list_factors=c()
          fit9= glm(average_rating~bs(weight,knots=c(k9_11,k9_12), degree=a)
                       +bs(year_of_release,knots=c(k9_21,k9_22), degree=b)
                       +bs(num_reviews,knots=c(k9_31,k9_32), degree=c)
                       +bs(duration,knots=c(k9_41,k9_42), degree=d),data=BG)
          mse9[i]=cv.glm(BG,fit9,K=10)$delta[1]
          tlist9=append(tlist9,c(a,b,c,d))
      }
    }
  }
}
end_time <- Sys.time()
timer9=end_time - start_time
timer9
tlist9=matrix(tlist9,ncol=4,byrow=TRUE)
tlist9[which.min(mse9),]
which.min(mse9)
mse9[which.min(mse9)]

###########