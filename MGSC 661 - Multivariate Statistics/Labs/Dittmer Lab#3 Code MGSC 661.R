S=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #3/swipe.csv")

library(stargazer)
library(tidyr)
# S=drop_na(S)
#####################Question 1
#####A
#S$swipe=as.factor(S$swipe)
S$swipe=ifelse(S$swipe=="left",0,1)
reg1=lm(swipe~swiperAge+swipeNumber+swiperFemale+selfie, data=S)
summary(reg1)

deplabel="Swipe"
labels=c("Swiper Age","Swipe Number","Swiper Female","Selfie")
stargazer(reg1, type="html",dep.var.labels=deplabel,covariate.labels=labels,digits=2)


#####################Question 2
#####A
reg2=glm(swipe~swiperAge+candidateAge+swipeNumber+swiperFemale+selfie, data=S,family="binomial")
summary(reg2)
labels=c("Swiper Age","Candidate Age","Swipe Number","Swiper Female","Selfie")

stargazer(reg2, type="html",dep.var.labels=deplabel,covariate.labels=labels,digits=2)


#####C
reg2=glm(swipe~swiperAge+candidateAge+swipeNumber+swiperFemale+selfie, data=S,family="binomial")
#intercept
b0=coef(reg2)[1]
#swiper age
b1=coef(reg2)[2]
#cand age
b2=coef(reg2)[3]
#swipe num
b3=coef(reg2)[4]
#female yes=1
b4=coef(reg2)[5]
#selfie Yes =1
b5=coef(reg2)[6]

m=exp(b0+b1*28+b2*31+b3*3+b4*1+b5*1)
m/(1+m)
summary(reg2)


#####D
require(rms)
reg2_D=lrm(swipe~swiperAge+candidateAge+swipeNumber+swiperFemale+selfie, data=S)
reg2_D

#####E
#S$selfie=as.factor(S$selfie)
reg2_E=glm(swipe~selfie+swiperFemale+candidateAge+selfie*swiperFemale, data=S,family="binomial")

values=data.frame(swiperFemale=c(1,0,1,0),selfie=c("YES","YES","NO","NO"),candidateAge=c(20,20,20,20),swiperAge=c(20,20,20,20))
predict(reg2_E,values,type="response")



#####F
reg2_F=glm(swipe~swiperAge + candidateAge + relationshipType + swiperFemale + selfie + selfie * swiperFemale,data=S,family="binomial")
labels2_F=c("Swiper Age","Candidate Age","Relatiponship Type: Long Term","Relatiponship Type: Marrage Term","Relatiponship Type: Short Term","Swiper Female","Selfie","Selfie X Swiper Female")
stargazer(reg2_F, type="html",dep.var.labels=deplabel,covariate.labels=labels2_F,digits=2)
stargazer(reg2_F, type="html",dep.var.labels=deplabel,digits=2)

summary(reg2_F)
#####G
b0=coef(reg2_F)[1]
#swiper age
b1=coef(reg2_F)[2]
#cand age
b2=coef(reg2_F)[3]
#rel type long term
b3=coef(reg2_F)[4]
#rel type marrage
b4=coef(reg2_F)[5]
#rel type short term
b5=coef(reg2_F)[6]
#swiper female
b6=coef(reg2_F)[7]
#selfie Yes =1
b7=coef(reg2_F)[8]
#selfie * swiperFemale
b8=coef(reg2_F)[9]

m1=exp(b0+b1*26+b2*29+b3*0+b4*0+b5*1+b6*0+b7*1+b8*1)
m1/(1+m1)
m2=exp(b0+b1*28+b2*31+b3*3+b4*1+b5*1)
m2/(1+m2)

values2_G=data.frame(swiperAge=c(26,29), candidateAge=c(29,26),relationshipType=c("short_term","long_term"),swiperFemale=c(1,0), selfie=c("NO","YES"))
predict(reg2_F,values2_G,type="response")






#####H
reg2_H=glm(swipe~swiperAge + swipeNumber,data=S,family="binomial")

b0H=-2
b1H=0.1
b2H=0.05

m1H=exp(b0H+b1H*25+b2H*7)
m2H=exp(b0H+b1H*21+b2H*1)
m3H=exp(b0H+b1H*33+b2H*3)
m4H=exp(b0H+b1H*19+b2H*9)

#m1H/(1+m1H)
#(1-(m2H/(1+m2H)))
#(m3H/(1+m3H))
#(1-(m4H/(1+m4H)))

tpH=m1H/(1+m1H)*(1-(m2H/(1+m2H)))*(m3H/(1+m3H))*(1-(m4H/(1+m4H)))
tpH

#####I


b0I=-1
b1I=0.04
b2I=0.2

m1I=exp(b0I+b1I*25+b2I*7)
m2I=exp(b0I+b1I*21+b2I*1)
m3I=exp(b0I+b1I*33+b2I*3)
m4I=exp(b0I+b1I*19+b2I*9)

tpI=m1I/(1+m1I)*(1-(m2I/(1+m2I)))*(m3I/(1+m3I))*(1-(m4I/(1+m4I)))
tpI

#####################Question 3
#####A
R=read.csv("C:/Users/raymo/Documents/Education/McGill/McGill Masters/Semseter F22/MGSC 661/Lab/Lab #3/relationshipType.csv")
R$relationshipType=as.factor(R$relationshipType)
table(R$relationshipType)

#####B
require(ggplot2)
hists3_B=ggplot(R, aes(x=age))+geom_histogram(bins = 50)+labs(y="Number of profiles",x="Age of user")+facet_grid(R$relationshipType)
hists3_B

#####C
hists3_C=ggplot(R, aes(x=swipes))+geom_histogram(bins = 50)+labs(y="Number of profiles",x="Number fo Swipes")+facet_grid(R$relationshipType)
hists3_C


#####E
library(MASS)
library(klaR)
lda3_E=lda(relationshipType~age+swipes,data=R)




lda3_E
partimat(relationshipType~age+swipes, method="lda",data=R,image.colors=c("light grey", "light green", "white","blue"))

#####I
predict(lda3_E,data.frame(age=23, swipes=200))
predict(lda3_E,data.frame(age=23, swipes=200,relationship))


#####################Question 4

#####B
qda4_B=qda(relationshipType~age+swipes,data=R)
qda4_B

#####C
partimat(relationshipType~age+swipes, method="qda",data=R,image.colors=c("light grey", "light green", "white","blue"))

#####D
predict(qda4_B,data.frame(age=23, swipes=200))

