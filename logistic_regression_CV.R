
## ═════════════════════════════════

## Logistic regression
## ───────────────────────

##   Load the National Health Interview Survey data:

##NH11 <- readRDS("dataSets/NatHealth2011.rds")
## Read RDS file and put into data frame.
NH11 <- readRDS("..\NatHealth2011.rds")

labs <- attributes(NH11)$labels

##   [CDC website] http://www.cdc.gov/nchs/nhis.htm

## Logistic regression example
## ───────────────────────────────

##   predict the probability of being diagnosed with hypertension
##   based on age, sex, sleep, and bmi

str(NH11$hypev) # check stucture of hypev
levels(NH11$hypev) # check levels of hypev
# collapse all missing values to NA
NH11$hypev <- factor(NH11$hypev, levels=c("2 No", "1 Yes"))
# run our regression model
hyp.out <- glm(hypev~age_p+sex+sleep+bmi,
              data=NH11, family="binomial")
coef(summary(hyp.out))

## Logistic regression coefficients
## ────────────────────────────────────

##   transform the coefficients to make them easier to
##   interpret

hyp.out.tab <- coef(summary(hyp.out))
hyp.out.tab[, "Estimate"] <- exp(coef(hyp.out))
hyp.out.tab

## Generating predicted values
## ───────────────────────────────

# Create a dataset with predictors set at desired levels
predDat <- with(NH11,
                expand.grid(age_p = c(33, 63),
                            sex = "2 Female",
                            bmi = mean(bmi, na.rm = TRUE),
                            sleep = mean(sleep, na.rm = TRUE)))
# predict hypertension at those levels
cbind(predDat, predict(hyp.out, type = "response",
                       se.fit = TRUE, interval="confidence",
                       newdata = predDat))

## Packages for  computing and graphing predicted values
## ─────────────────────────────────────────────────────────
## use the effects package to
##   compute quantities of interest (cf. the Zelig package).
install.packages("effects")
library(effects)
plot(allEffects(hyp.out))

## Exercise: logistic regression
## ───────────────────────────────────

##   1. Use glm to conduct a logistic regression to predict ever worked
##      (everwrk) using age (age_p) and marital status (r_maritl).

##subsume all subsequently referenced variables within the dataframe NH11
attach(NH11)

##examine the structure, levels (where applicable), and frequencies of the variables to be included in the analysis
str(age_p)
mean(age_p)
str(everwrk)
levels(everwrk)
table(everwrk)
str(r_maritl)
levels(r_maritl)
table(r_maritl)

library(dplyr)
View(NH11)
library(car)

# collapse all missing values in everwrk to NA
everwrk1 <- factor(everwrk, levels=c("1 Yes","2 No"))
# recode categories so that "2 No" is "0"
everwrk2<-recode(everwrk1, "'1 Yes'=1;'2 No'=0")
levels(everwrk2)
#convert everwrk from factor to numeric variable
everwrk3<-as.numeric(as.character(everwrk2))
str(everwrk)
table(everwrk3)
summary(everwrk)



# collapse r_maritl to create a new variable, r_maritl1: recode those in "unknown" category to "NA" and limit it to the 7 categories with at least 1 nonmissing value
r_maritl1 <- factor(r_maritl, levels=c("1 Married - spouse in household","2 Married - spouse not in household","4 Widowed","5 Divorced",
                                      "6 Separated","7 Never married","8 Living with partner"))
#check new collapsed variable r_maritl1
str(r_maritl1)
levels(r_maritl1)

# run regression model predicting everwrk from marital status and age
work.out <- glm(everwrk3~age_p+r_maritl1,
               data=NH11, family="binomial")
coef(summary(work.out))


##   exponentiate the coefficients to convert them to odds ratios and make them easier to interpret

work.out.tab <- coef(summary(work.out))
work.out.tab[, "Estimate"] <- exp(coef(work.out))
work.out.tab

##After estimating a multivariate logistic regression model to predict the odds of ever having worked from
##age and marital status, we find that those of older age have a significantly higher odds of ever having worked 
##than their younger counterparts (OR = 1.03, p < .001). In addition, controlling for age, we find that, 
##relative to those who are married and cohabiting with their spouse, the odds of ever having worked 
##is significantly higher among those who are divorced (OR = 2.07, p < .001) or living with their partner (OR = 1.56, p < .01) 
##and significantly lower among those who are widowed (OR = .50, p < .001) or never married (OR = 0.71, p < .001). 
##In contrast, those who are married and not cohabiting their spouse or who are separated did not differ significantly
##from those who are married and cohabiting with their spouse in their odds of ever having worked.

##   2. Predict the probability of working for each level of marital
##      status.


levels(r_maritl1)
# Create a dataset with predictors set at desired levels
predDat2 <- with(NH11,
                expand.grid(age_p = mean(age_p, na.rm = TRUE),
                            r_maritl1=c("1 Married - spouse in household",
                                        "2 Married - spouse not in household",
                                        "4 Widowed","5 Divorced",
                                        "6 Separated", "7 Never married",
                                        "8 Living with partner"
                                        )
                           ))
# predict everwrk3 at those levels
cbind(predDat2, predict(work.out, type = "response",
                       se.fit = TRUE, interval="confidence",
                       newdata = predDat2))


##Predicting the probability of ever having worked for each level of marital status with age held constant at the sample mean (M = 48.11 years old)
##indicated that the probability of ever having worked was .93 for divorced participants, .91 for participants who were
##living with their partner, .88 for separated participants, .87 for married participants who were cohabiting with their spouses, 
##.86 for married participants who were not cohabiting with their spouse, .82 for never married participants, and .77 for widowed participants.
