R=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #1/montreal_restaurants_2223_lab1.csv")
attach(R)
names(R)

##Question 1
print(summary(R$rating))
#box plot
boxplot(R$rating,col='green')
#histogram of plot
hist(R$rating,breaks=20,border='green',main="Hisogram w/ 20 breaks")
print(summary(R$meal_cost))
#box plot
boxplot(R$meal_cost,col='orange')
#histogram of plot
hist(R$meal_cost,breaks=25,border='orange',main="Hisogram w/ 25 breaks")
print(summary(R$nb_days_open))
#box plot
boxplot(R$nb_days_open,col='purple')
#histogram of plot
hist(R$nb_days_open,breaks=10,border='purple',main="Hisogram w/ 10 breaks")

##Question 2
#####i
#linear ordinary least squares
lm.fit=lm(rating~meal_cost)
lm.fit

##Making prediction 
# meal cost
#step 1: Retrieve values b0 b1
b0=coef(lm.fit)[1]
b1=coef(lm.fit)[2]

##Coef
summary(lm.fit)
confint(lm.fit,level=0.9)

#plot
#install.packages("visreg")
require(visreg)
plot(rating,meal_cost)
abline(lm.fit,col="blue")
visreg(lm.fit,alpha=0.05)

####ii nb reviews
#linear ordinary least squares
lmii.fit=lm(rating~nb_reviews)
lmii.fit

##Making prediction
#step 1: Retrieve values b0 b1
b0ii=coef(lmii.fit)[1]
b1ii=coef(lmii.fit)[2]

##Coef
summary(lmii.fit)
confint(lmii.fit,level=0.9)

#plot
require(visreg)
plot(rating,nb_reviews)
abline(lmii.fit,col="blue")
visreg(lmii.fit,alpha=0.05)


####iii nb days open
#linear ordinary least squares
lmiii.fit=lm(rating~nb_days_open)
lmiii.fit

##Making prediction
#step 1: Retrieve values b0 b1
b0iii=coef(lmiii.fit)[1]
b1iii=coef(lmiii.fit)[2]

##Coef
summary(lmiii.fit)
confint(lmiii.fit,level=0.9)

#plot
require(visreg)
plot(rating,nb_days_open)
abline(lmiii.fit,col="blue")
visreg(lmiii.fit,alpha=0.05)

#meal cost
#nb rating
#nb days
###Problem 3
b0ii+b1ii*50 #Prediction for prop with 2 bedrooms
b0ii+b1ii*500#b0+b1*3 #
b0iii+b1iii*5 #

##Question #4
R$photos_to_reviews <- R$photos/R$nb_reviews
#attach(R$photos_to_reviews)


####iv photos_to_reviews
#linear ordinary least squares
lmiv.fit=lm(R$rating~R$photos_to_reviews)
lmiv.fit

##Making prediction
b0iv=coef(lmiv.fit)[1]
b1iv=coef(lmiv.fit)[2]

##Coef
summary(lmiv.fit)
confint(lmiv.fit,level=0.95)


##Question #5
####iv photos_to_reviews
#linear ordinary least squares
lmv.fit=lm(rating~page_views+meal_cost+nb_days_open)
lmv.fit
summary(lmv.fit)
##Making prediction
b0v=coef(lmv.fit)[1]
b1v=coef(lmv.fit)[2]
b2v=coef(lmv.fit)[3]
b3v=coef(lmv.fit)[4]

pred=b0v+2000*b1v+15*b2v+5*b3v
print(pred)


####Question 6
##include dummy variable
R$delivery=as.factor(R$delivery)
typeof(R$delivery)
#attach(R$delivery)
levels(delivery)
lmvi.fit=lm(rating~meal_cost+delivery)
summary(lmvi.fit)
b0vi=coef(lmvi.fit)[1]
b1vi=coef(lmvi.fit)[2]
b2vi=coef(lmvi.fit)[3]
summary(lmvi.fit)


plot(meal_cost,R$rating,col=ifelse(delivery=="yes","blue","green"),pch=22)
abline(b0vi,b1vi,col="blue")
abline(b0vi+b2vi,b1vi,col="green")

legend("bottomright", legend=c("Restaurant with delivery", "Restaurants without delivery"),
       col=c("blue", "green"), pch=22, cex=0.8)



####pb 7
##include dummy variable

R$plateau=ifelse(area=="Plateau-Mont-Royal",1,0)
attach(R)
lmvii.fit=lm(rating~meal_cost+plateau)
summary(lmvii.fit)
b0vii=coef(lmvii.fit)[1]
b1vii=coef(lmvii.fit)[2]
b2vii=coef(lmvii.fit)[3]
summary(lmvii.fit)


##7.c
levels(R$area)
R1=R
R1$area=as.factor(R1$area)
R1$area=relevel(R1$area, ref="Plateau-Mont-Royal")
attach(R1)
lmviii.fit=lm(rating~area)
plot(R1$area,R1$rating)
levels(R1$area)

summary(lmviii.fit)


##8.a
lmix.fit=lm(R$rating~R$delivery+R$plateau+R$plateau*R$delivery)
summary(lmix.fit)


##8.c
lmx.fit=lm(R$rating~R$meal_cost+R$delivery+R$meal_cost*R$delivery)
summary(lmx.fit)

b0x=coef(lmx.fit)[1]
b1x=coef(lmx.fit)[2]
b2x=coef(lmx.fit)[3]

plot(R$meal_cost,R$rating,col=ifelse(delivery=="yes","blue","green"),pch=2)
abline(b0x,b1x,col="blue",lty=2)
abline(b0x+b2x,b1x,col="green",lty=2)
legend("bottomright", legend=c("Restaurant with delivery", "Restaurants without delivery"),
       col=c("blue", "green") , pch=2, cex=0.8)




##9
lmxi.fit=lm(R$rating~R$meal_cost+R$photos+R$nb_reviews+R$nb_days_open)
require(car)
require(collapse)
require(lmtest)
require(plm)
residualPlots(lmxi.fit)
par(mfrow=c(1,1))

##10
lmxii.fit=lm(R$rating~R$page_views)
summary(lmxii.fit)
residualPlot(lmxii.fit,quadratic=FALSE)
ncvTest(lmxii.fit)
require(collapse)
require(lmtest)
require(plm)
coeftest(lmxii.fit, vcov=vcovHC(lmxii.fit, type="HC1"))



##11
lmxiii.fit=lm(R$rating~R$nb_days_open+R$area)
require(car)
outlierTest(lmxiii.fit)
#install.packages("car")
RO=R[c(66,3,83),]
print(RO)
RWO=R[-c(66,3,83),]
lmxiv.fit=lm(RWO$rating~RWO$nb_days_open+RWO$area)
outlierTest(lmxiv.fit)
summary(lmxiv.fit)
summary(lmxiii.fit)


##12 
quanvars=RWO[,c(2,8,9,10,11,12,13)]

corr_matrix=cor(quanvars)
round(corr_matrix,3)
#install.packages("psych")
require(psych)
pairs.panels(quanvars)
lmxv.fit=lm(RWO$rating~RWO$delivery+RWO$plateau+RWO$nb_reviews+RWO$page_views)

vif(lmxv.fit)
lmxvi.fit=lm(RWO$rating~RWO$delivery+RWO$plateau+RWO$nb_reviews)
vif(lmxvi.fit)

summary(lmxv.fit)
summary(lmxvi.fit)




######################################################,b1vi#####
##########################################################