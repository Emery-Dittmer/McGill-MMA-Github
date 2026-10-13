## INSTALLING AND LOADING PACKAGES

##install.packages('dplyr')
##install.packages('psych')
##install.packages('lubridate')
##install.packages('vtable')

require(dlnm)
require(car)
require(dplyr)
require(psych)
require(plm)
require(boot)
require(vtable)
require(methods)
require(ggplot2)
require(corrplot)
require(splines)
require(lubridate)
require(stargazer)
require(lmtest)
require(caTools)
require(Boruta)

## READING CSV FILES FOR RAW DATA 
movies_data <- read.csv("IMDB_data_raw.csv")
data_copy <- data.frame(movies_data) %>% select(-c ('movieID','movieBudget_old','movieTitle','imdbLink'))

## Show summary stats for all data
sumtable(data_copy)

## CHECK FOR COLLINEARITY
checkForCollinearity <- function(regModel){
  vif(regModel)
}

## Checking correlation between numerical parameters
num_cols <- unlist(lapply(data_copy, is.numeric))       
quanvars <- data_copy[ , num_cols]           
corr_matrix <- cor(quanvars)
corrplot(corr_matrix)

rm(num_cols)  # disposing variable
rm(quanvars)  # disposing variable
rm(corr_matrix)  # disposing variable


attach(data_copy)
checkForCollinearity(lm(imdbScore~movieBudget + duration + nbNewsArticles 
                        + actor1_starMeter + actor2_starMeter + actor3_starMeter + nbFaces))
detach(data_copy)

## OUTLIERS
## Numerical test: Bonferroni outlier test
attach(data_copy)
findoutliers <- function(regModel, plot=FALSE){
  outlier = outlierTest(regModel)
  if(plot){
    qqPlot(regModel,envelope=list(style='none'),main  = " Standardized", ylab = 'Stars',xlab = 'duration' )
  }
  return(outlier) 
}
outliers <- c()
outliers <- append(outliers,findoutliers(lm(imdbScore~duration)))
outliers <- append(outliers,findoutliers(lm(imdbScore~nbNewsArticles)))
outliers <- append(outliers,findoutliers(lm(imdbScore~actor1_starMeter)))
outliers <- append(outliers,findoutliers(lm(imdbScore~actor2_starMeter)))
outliers <- append(outliers,findoutliers(lm(imdbScore~actor3_starMeter)))
outliers <- append(outliers,findoutliers(lm(imdbScore~nbFaces)))
outliers <- append(outliers,findoutliers(lm(imdbScore~movieBudget + duration 
                                              + nbNewsArticles + actor1_starMeter + actor2_starMeter 
                                              + actor3_starMeter + nbFaces), TRUE))

## Remove outliers from dataset
list_out <- list()
for (i in outliers){
  set <- names(i)
  for (x in set){
    list_out <- append(list_out,as.integer(x))
  }
  list_out <- unique(list_out)
}

data_copy <- data_copy[!(row.names(data_copy) %in% list_out),]
rm(outliers)
rm(quanvars)
rm(list_out)


## EXECUTING SIMPLE REGRESSIONS
simpleReg <- function(target, source, plot=FALSE){
  lm.fit <- lm(target~source)
  if(plot){
    plot(source, target)
    abline(lm.fit)
  }
  print(summary(lm.fit))
  rm(lm.fit)
}

attach(data_copy)
simpleReg(imdbScore, movieBudget, TRUE)
simpleReg(imdbScore, duration, TRUE)
simpleReg(imdbScore, releaseYear, TRUE)
simpleReg(imdbScore, nbNewsArticles, TRUE)
simpleReg(imdbScore, country, FALSE)
simpleReg(imdbScore, maturityRating, FALSE)
simpleReg(imdbScore, language, FALSE)
simpleReg(imdbScore, nbFaces, TRUE)
simpleReg(imdbScore, movieMeter_IMDBpro, TRUE)
detach(data_asFactor)


## NON LINEAR RELATIONSHIPS
## Checking for non-linear patterns
# Tukey test for non linearity, if less than 0.05 then it doesn't satisfy linearity assumption
checkForNonLinear <- function(regModel){
  residualPlots(regModel)
}
attach(data_copy)
checkForNonLinear(lm(imdbScore ~ movieBudget))
checkForNonLinear(lm(imdbScore ~ duration))
checkForNonLinear(lm(imdbScore ~ releaseYear))
checkForNonLinear(lm(imdbScore ~ nbNewsArticles))
checkForNonLinear(lm(imdbScore ~ country))
checkForNonLinear(lm(imdbScore ~ maturityRating))
checkForNonLinear(lm(imdbScore ~ language))
checkForNonLinear(lm(imdbScore ~ nbFaces))
checkForNonLinear(lm(imdbScore ~ movieMeter_IMDBpro))
detach(data_copy)


## HETEROSCKEDASCITY
# If p-value <0.05: heteroskedasticity
# If p-value >0.05: no heteroskedasticity
checkForHeterosckedascity <- function(regModel){
  print('-----------------------------------------------')
  print('NCV TEST')
  print(ncvTest(regModel))
  print('')
  print('-----------------------------------------------')
  print('COEF TEST WITH SANDWICH CORRECTION')
  print(coeftest(regModel, vcov=vcovHC(regModel, type="HC1")))
  print('-----------------------------------------------')
}
attach(data_copy)
checkForHeterosckedascity(lm(imdbScore ~ movieBudget))
checkForHeterosckedascity(lm(imdbScore ~ duration))
checkForHeterosckedascity(lm(imdbScore ~ releaseYear))
checkForHeterosckedascity(lm(imdbScore ~ nbNewsArticles))
checkForHeterosckedascity(lm(imdbScore ~ country))
checkForHeterosckedascity(lm(imdbScore ~ maturityRating))
checkForHeterosckedascity(lm(imdbScore ~ language))
checkForHeterosckedascity(lm(imdbScore ~ nbFaces))
checkForHeterosckedascity(lm(imdbScore ~ movieMeter_IMDBpro))
detach(data_copy)


## HANDLING CATEGORICAL PROPERTIES
attach(data_copy)

# country
by_country <- data_copy  %>% group_by(country) %>% summarise(n = n()) %>% arrange(desc(n))
by_country <- by_country %>%  filter(n>=40) %>% data.frame

for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"country"] %in% by_country$country)
  {
    data_copy[i,"country"] <- 'Others'
  }
}

# Language
by_lang <- data_copy  %>% group_by(language) %>% summarise(n = n()) %>% arrange(desc(n))
by_lang <- by_lang %>%  filter(n>2) %>% data.frame

for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"language"] %in% by_lang$language)
  {
    data_copy[i,"language"] <- 'Others'
  }
}

# maturity rating
by_matRate <- data_copy  %>% group_by(maturityRating) %>% summarise(n = n()) %>% arrange(desc(n))
by_matRate <- by_matRate %>%  filter(n>20) %>% data.frame
for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"maturityRating"] %in% by_matRate$maturityRating)
  {
    data_copy[i,"maturityRating"] <- 'Others'
  }
}

# Director
by_dir <- data_copy  %>% group_by(director) %>% summarise(n = n()) %>% arrange(desc(n))
by_dir <- by_dir  %>%  filter(n>10) %>% data.frame
for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"director"] %in% by_dir$director)
  {
    data_copy[i,"director"] <- 'Others'
  }
}

# Cinematographer
by_cinemato <- data_copy  %>% group_by(cinematographer) %>% summarise(n = n()) %>% arrange(desc(n))
by_cinemato <- by_cinemato %>%  filter(n>12) %>% data.frame

for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"cinematographer"] %in% by_cinemato$cinematographer)
  {
    data_copy[i,"cinematographer"] <- 'Others'
  }
}

# Production company
by_prod <- data_copy  %>% group_by(productionCompany) %>% summarise(n = n()) %>% arrange(desc(n))
by_prod <- by_prod %>%  filter(n>20) %>% data.frame

for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"productionCompany"] %in% by_prod$productionCompany)
  {
    data_copy[i,"productionCompany"] <- 'Others'
  }
}

# Distributors company
by_dist <- data_copy  %>% group_by(distributor) %>% summarise(n = n()) %>% arrange(desc(n))
by_dist <- by_dist  %>%  filter(n>50) %>% data.frame
for( i in 1:nrow(data_copy))
{
  if(!data_copy[i,"distributor"] %in% by_dist$distributor)
  {
    data_copy[i,"distributor"] <- 'Others'
  }
}

## Creating copy of dataset
detach(data_copy)
data_asFactor <- data.frame(data_copy)

attach(data_asFactor)
## Converting into categorical attributes
data_asFactor$matRating        <- (as.factor(data_asFactor$maturityRating))
data_asFactor$lang             <- (as.factor(data_asFactor$language))
data_asFactor$cty              <- (as.factor(data_asFactor$country))
data_asFactor$dir              <- (as.factor(data_asFactor$director) )
data_asFactor$prod             <- (as.factor(data_asFactor$productionCompany))
data_asFactor$cinema           <- (as.factor(data_asFactor$cinematographer))
data_asFactor$dist             <- (as.factor(data_asFactor$distributor))
data_asFactor$avg_actor_rating <- with(data_asFactor, (actor1_starMeter + actor2_starMeter + actor3_starMeter)/3)


## Relevel catergorical parameters
data_asFactor$cinema    <- relevel(data_asFactor$cinema,ref="Others")
data_asFactor$prod      <- relevel(data_asFactor$prod,ref="Others")
data_asFactor$dir       <- relevel(data_asFactor$dir,ref="Others")
data_asFactor$cty       <- relevel(data_asFactor$cty,ref="USA")
data_asFactor$lang      <- relevel(data_asFactor$lang,ref="English")
data_asFactor$matRating <- relevel(data_asFactor$matRating,ref="G")

## CHECKING FOR FEATURE IMPORTANCE 
`%notin%` <- Negate(`%in%`)
boruta_output <- Boruta(imdbScore ~ ., data=na.omit(data_asFactor), doTrace=2)
boruta_signif <- names(boruta_output$finalDecision[boruta_output$finalDecision %in% c("Confirmed", "Tentative")])
boruta_not_signif <- names(boruta_output$finalDecision[boruta_output$finalDecision %notin% c("Confirmed", "Tentative")])
print(boruta_signif)
print(boruta_not_signif)
plot(boruta_output, cex.axis=.7, las=2, xlab="", main="Variable Importance")
rm(boruta_not_signif)
rm(boruta_signif)
rm(boruta_output)


## DROPPING UNNECESSARY DATA COLUMNS

data_asFactor <- data_asFactor %>% select(-c(actor1_starMeter, actor2_starMeter, actor3_starMeter, actor1, actor2, actor3,
                                             aspectRatio,  maturityRating, language, country,
                                             director, cinematographer, distributor, releaseDay, plotKeywords,
                                             musical, western, sport, productionCompany, genres))
data_asFactor$release_month_num <- match(data_asFactor$releaseMonth,month.abb)

detach(data_asFactor)


## RUN SIMPLE LINEAR REGRESSION FOR NUMERICAL PROPERTIES 
## Check for different degrees of polynomial relationships for non-linear parameters
attach(data_asFactor)

a = c(1:9)
b = c(1:9)
c = c(1:9)
d = c(1:9)

y = expand.grid(a, b, c, d)
y <- matrix(unlist(y), nrow=6561, ncol=4)

mse = matrix(rep(NA), nrow = nrow(y), ncol=7)
for(i in 1:nrow(y)){
  check_s <- Sys.time()
  fit = lm(imdbScore~poly(movieBudget,y[i,1])
           + poly(releaseYear,y[i,2])
           + poly(nbNewsArticles,y[i,3])
           + poly(duration,y[i,4])
           + matRating
           + dir
           + ( drama + romance)
           + (horror + thriller ) +  (action * adventure )
           + avg_actor_rating
           + animation 
           + lang
           + scifi
           + nbFaces
           + ( war + crime)
           , data=data_asFactor)
  mse[i,1] = round(mean(fit$residuals^2),4)
  mse[i,2] = check_s
  mse[i,3] = Sys.time()
  mse[i,4] = y[i,1]
  mse[i,5] = y[i,2]
  mse[i,6] = y[i,3]
  mse[i,7] = y[i,4]
  print(paste('ran for ', i, 'at -> ',y[i,1], y[i,2], y[i,3], y[i,4] , sep='-'))
}
plot(mse[,1])
lines(mse[,1],col='red')
which.min(mse[,1])
min(mse[,1])

rm(fit, y, mse, a, b, c, d, i)
detach(data_asFactor)



## RUN SPLINE REGRESSION FOR MODEL TO EVALUATE BETTER FITS
attach(data_asFactor)
a = c(2:8) #2
b = c(2:8) #2
c = c(2:8) #6 
d = c(2:8) #3 


knots_w = c(quantile(data_asFactor$movieBudget,1/2))
knots_yor = c(quantile(data_asFactor$releaseYear,1/4),quantile(data_asFactor$releaseYear,2/4),quantile(data_asFactor$releaseYear,3/4))
knots_nr = c(quantile(data_asFactor$nbNewsArticles,1/4),quantile(data_asFactor$nbNewsArticles,2/4),quantile(data_asFactor$nbNewsArticles,3/4))
knots_d = c(quantile(data_asFactor$duration,1/4),quantile(data_asFactor$duration,2/4),quantile(data_asFactor$duration,3/4))

y = expand.grid(a, b, c, d)
y <- matrix(unlist(y),nrow=2401, ncol=4)

mse = matrix(rep(NA), nrow = nrow(y), ncol=7)
for(i in 1:nrow(y)){
  check_s <- Sys.time()
  fit = glm(imdbScore~
              bs(movieBudget,knots=knots_w,degree= y[i,1])
            + bs(releaseYear,knots=knots_yor,degree= y[i,2])
            + bs(nbNewsArticles,knots=knots_nr,degree= y[i,3])
            + bs(duration,knots=knots_d,degree= y[i,4])
            , data=data_asFactor)
  mse[i,1] = round(cv.glm(data_asFactor,fit, K=10)$delta[1],4)
  mse[i,2] = check_s
  mse[i,3] = Sys.time()
  mse[i,4] = y[i,1]
  mse[i,5] = y[i,2]
  mse[i,6] = y[i,3]
  mse[i,7] = y[i,4]
  print(paste('ran for ', i, 'at -> ',y[i,1], y[i,2], y[i,3], y[i,4] , sep='-'))
}
end <- Sys.time()
mse
#print(end-start)
plot(mse[,1])
lines(mse[,1],col='red')
which.min(mse[,1])
min(mse[,1])
detach(data_asFactor)


##  RUN SPLINE REGRESSION WITH ADDING MORE PREDICTORS AND BETTER QUANTILE SPLIT
attach(data_asFactor)
a = 2
b = 2
c = 6
d = 3
e = 3

knots_w = c(quantile(data_asFactor$movieBudget,1/3),quantile(data_asFactor$movieBudget,2/3))
knots_yor = c(quantile(data_asFactor$releaseYear,1/4),quantile(data_asFactor$releaseYear,2/4),quantile(data_asFactor$releaseYear,3/4))
knots_nr = c(quantile(data_asFactor$nbNewsArticles,1/4),quantile(data_asFactor$nbNewsArticles,2/4),quantile(data_asFactor$nbNewsArticles,3/4))
knots_d = c(quantile(data_asFactor$duration,1/4),quantile(data_asFactor$duration,2/4),quantile(data_asFactor$duration,3/4))
knots_m = c(quantile(data_asFactor$movieMeter_IMDBpro,1/5),quantile(data_asFactor$movieMeter_IMDBpro,2/5),quantile(data_asFactor$movieMeter_IMDBpro,3/5), quantile(data_asFactor$movieMeter_IMDBpro,4/5))
knots_month = c(quantile(data_asFactor$release_month_num,1/4),quantile(data_asFactor$release_month_num,2/4),quantile(data_asFactor$release_month_num,3/4))

y = expand.grid(a, b, c, d, e)
y <- matrix(unlist(y),nrow=1, ncol=5)

check_s <- Sys.time()
fit1 = glm(imdbScore~
            bs(movieBudget,knots=knots_w,degree= y[1,1])
          + bs(releaseYear,knots=knots_yor,degree= y[1,2])
          + bs(nbNewsArticles,knots=knots_nr,degree= y[1,1])
          + bs(duration,knots=knots_d,degree= y[1,4])
          + bs(movieMeter_IMDBpro,knots=knots_m,degree= y[1,5])
          + bs(release_month_num,knots=knots_month,degree= 1)
          + matRating
          + dir 
          + cty
          + drama 
          + romance
          + horror 
          + thriller  
          + (action * adventure )
          + avg_actor_rating * nbFaces
          + animation 
          + lang
          + scifi
          + ( war * crime)
          , data=data_asFactor)

mse = round(cv.glm(data_asFactor,fit1, K=10)$delta[1],4)
#summary(fit1)
mse


## RUN A CROSS VALIDATION TEST 
mse = matrix(rep(NA), nrow = 100, ncol=1)
for(j in 1:100){
  sample = sample.split(data_asFactor, SplitRatio = 0.7)
  train=subset(data_asFactor, sample==TRUE)
  test=subset(data_asFactor, sample==FALSE)
  
  test$pred=predict(fit1, test) 
  test$res=(test$imdbScore - test$pred)
  test$res_sq=(test$res)^2 
  MSE_1=mean(test$res_sq)
    
  mse[j] = MSE_1
    
  print(paste('ran for ', j))
}

min(mse)
max(mse)
hist(mse)




### PREDICTING MOVIE RATINGS
test_data = read.csv("D:/CourseContent/Fall_22/MGSC-661/MidTerm/test_data_IMDB.csv")
data_copy_test <- data.frame(test_data)

# Maturity Rating
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"maturityRating"] %in% by_matRate$maturityRating)
  {
    data_copy_test[i,"maturityRating"] <- 'Others'
  }
}

# Country
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"country"] %in% by_country$country)
  {
    data_copy_test[i,"country"] <- 'Others'
  }
}

# Language
by_lang
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"language"] %in% by_lang$language)
  {
    data_copy_test[i,"language"] <- 'Others'
  }
}

# Director
by_dir
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"director"] %in% by_dir$director)
  {
    data_copy_test[i,"director"] <- 'Others'
  }
}

# Cinematographer
by_cinemato
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"cinematographer"] %in% by_cinemato$cinematographer)
  {
    data_copy_test[i,"cinematographer"] <- 'Others'
  }
}

# Production company
by_prod
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"productionCompany"] %in% by_prod$productionCompany)
  {
    data_copy_test[i,"productionCompany"] <- 'Others'
  }
}

# Distributors company
by_dist
for( i in 1:nrow(data_copy_test))
{
  if(!data_copy_test[i,"distributor"] %in% by_dist$distributor)
  {
    data_copy_test[i,"distributor"] <- 'Others'
  }
}

data_copy_test$release_month_num <- match(data_copy_test$releaseMonth,month.abb)

data_copy_test$matRating <- (as.factor(data_copy_test$maturityRating))
data_copy_test$lang <- (as.factor(data_copy_test$language))
data_copy_test$cty <- (as.factor(data_copy_test$country))
data_copy_test$avg_actor_rating <- with(data_copy_test, (actor1_starMeter + actor2_starMeter + actor3_starMeter)/3)
data_copy_test$dir <- (as.factor(data_copy_test$director) )
data_copy_test$prod <-(as.factor(data_copy_test$productionCompany))
data_copy_test$cinema <- (as.factor(data_copy_test$cinematographer))
data_copy_test$dist <- (as.factor(data_copy_test$distributor))


data_copy_test$cinema<- relevel(data_copy_test$cinema,ref="Others")
data_copy_test$prod<- relevel(data_copy_test$prod,ref="Others")
data_copy_test$dir<- relevel(data_copy_test$dir,ref="Others")
data_copy_test$cty<- relevel(data_copy_test$cty,ref="USA")
data_copy_test$lang<- relevel(data_copy_test$lang,ref="English")
data_copy_test$matRating <- relevel(data_copy_test$matRating,ref="G")


# droping columns indivisual star meters, movie title and links
data_copy_test <- data_copy_test %>% select(-c(actor1_starMeter, actor2_starMeter, actor3_starMeter,actor1, actor2, actor3,
                                             aspectRatio, movieID, movieTitle, imdbLink, maturityRating, language, country,
                                             director, cinematographer, distributor, releaseDay, plotKeywords,
                                             musical, western, sport, productionCompany, genres))


predictions = data.frame(predict(fit1,data_copy_test))
predictions

