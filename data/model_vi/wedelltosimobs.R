library(tidyverse)
library(rstan)
library(shinystan)
library(patchwork)

set.seed(4);#chosen by fair die roll
##init
theme_set(theme_light())
rm(list = ls()) #Todo, remap C-c C-b to new R session, stop doing this.
triadsdf <- read.csv("miniwedell.csv", stringsAsFactors = FALSE)

##SET PARAMS
prob_est_noise <- .01
pay_est_noise <- .5
##check this puts the effective calc-obs noise in the right ballpark?
k <-  (1 / (prob_est_noise^2) - 4) / 8 #sd(beta(k,k)) is prob_est_noise
hackcheck_n <- 10000
#option calcsd
sd(rbeta(hackcheck_n, k, k) * rnorm(hackcheck_n, 19.6, pay_est_noise))
##RMSE is .35 (note alpha 1.5) pg 377

prob_tolerance <- 0.011
pay_tolerance <- 1.1

ordobs_error <- .01 #with this prob, ordobs drawn from sample(c(1,2,3),1)
##implementation in `ordobs' fn. Appears as a constant in .stan, should match.

##END PARAMS

## .stan refers to these noise settings via copy-paste of magic numbers!
featurenoise <- function(featuretype) {
    if (featuretype == "prob") return(prob_est_noise)
    if (featuretype == "pay") return(pay_est_noise)
}

comparison_noise <- function(feature1, feature2) {
    return(.1)
}
comparison_tolerance <- function(feature1, feature2) {
    if (feature1 == "prob") return(prob_tolerance)
    else return(pay_tolerance)
}

ordobs <- function(f1_value, f2_value, f1_type, f2_type){
    ##currently faithful howes16:
    sansnoise <- function() {
        if (abs(f1_value - f2_value) < comparison_tolerance(f1_type, f2_type)) {
            return(2)
        }
        if (f1_value < f2_value) {
            return(1)
        }
        return(3)
    }
    myobs <- if (rbinom(1, 1, (1 - ordobs_error))) {
                 sansnoise()
             }else {
                 sample(c(1, 2, 3), 1)
             }
    return(myobs)
}

gettype <- function(row, feature, option) {
    if (feature == 1) {
        return("prob")
    } else return("pay")
}

calcobs_set <- function(arow, trialid) {
    myobs <- data.frame(
        ppntid = arow$ppntID,
        trialid = trialid,
        option = rep(c(1, 2, 3), 2),
        feature = rep(c(1, 2), each = 3),
        featuretype = factor(c("prob",
                        "prob",
                        "prob",
                        "pay",
                        "pay",
                        "pay"), levels = c("prob", "pay")),
        calcobs = c(rnorm(1, arow$base1, featurenoise("prob")),
                    rnorm(1, arow$base2, featurenoise("prob")),
                    rnorm(1, arow$base3, featurenoise("prob")),
                    rnorm(1, arow$fuel1, featurenoise("pay")),
                    rnorm(1, arow$fuel2, featurenoise("pay")),
                    rnorm(1, arow$fuel3, featurenoise("pay"))
                    )
    )
    levels(myobs$featuretype) <- c("prob", "pay");#factor levels passed as integers to stan with as.numeric, so please be explicit.
    return(myobs)
}

ordobs_set <- function(arow, trialid){
    myobs <- data.frame()
    
    for (afeature in c(1, 2)) {
        for (anoption1 in c(2, 3)) {
            for (anoption2 in c(1, 2, 3)) {
                if (anoption2 >= anoption1) next;
                myobs <- rbind(myobs, data.frame(
                                          ppntid = arow$ppntID,
                                          trialid = trialid,
                                          option1 = anoption1,
                                          option2 = anoption2,
                                          feature = afeature,
                                          featuretype = afeature,
                                          ordobs = ordobs(
                                              arow[
                                                  paste0(
                                                      c("base", "fuel")[afeature],
                                                      anoption1)
                                              ],
                                              arow[
                                                  paste0(
                                                      c("base", "fuel")[afeature],
                                                      anoption2)
                                              ],
                                              (if (afeature == 1) {
                                                   "prob"
                                               } else{
                                                   "pay"
                                               }),
                                              (if (afeature == 1) {
                                                   "prob"
                                               } else{
                                                   "pay"
                                               })
                                          )#ordobs call
                                      )#data frame
                               )#rbind
            }#opt2
        }#opt1
    }#feature
    return(myobs)
}

##MAIN: trial setup
testtrials <- triadsdf

mytrial <- data.frame()
for (i in 1:150) {
    mytrial <- rbind(mytrial, testtrials)
}


myordobs <- data.frame()
mycalcobs <- data.frame()
##Get some sim obs
for (i in 1:nrow(mytrial)) {
    myordobs <- rbind(myordobs, ordobs_set(mytrial[i, ], i))
    mycalcobs <- rbind(mycalcobs, calcobs_set(mytrial[i, ], i))
}


##get some inferred option values:
mydatalist <- list(
    n_ordobs = nrow(myordobs),
    n_calcobs = nrow(mycalcobs),
    n_trials = max(c(myordobs$trialid, mycalcobs$trialid)),

    ordobs_trialid = myordobs$trialid,
    ordobs_opt1 = myordobs$option1,
    ordobs_opt2 = myordobs$option2,
    ordobs_feature = myordobs$feature,
    ordobs_featuretype = as.numeric(myordobs$featuretype),
    ordobs_obs = myordobs$ordobs,
    calcobs_trialid = mycalcobs$trialid,
    calcobs_opt = mycalcobs$option,
    calcobs_feature = mycalcobs$feature,
    calcobs_featuretype = as.numeric(mycalcobs$featuretype),
    calcobs_obs = mycalcobs$calcobs,
    calcobs_noise = c(prob_est_noise, pay_est_noise)
)



mod <-  stan_model(file = "howes16_wedell.stan")
vbfit <- vb(mod, data = mydatalist, output_samples = 4000, seed = 1)#4000

visamples <- as.data.frame(extract(vbfit, permuted = TRUE))


##inference done: visualize the results
barestim_vis <- function(targtrial) {
    dotsize <- 7
    ggplot(mytrial[targtrial, ]) +
        geom_point(aes(x = base1, y = fuel1, shape = fueltype1),
                   size = dotsize, color = "red") +
        geom_point(aes(x = base2, y = fuel2, shape = fueltype2),
                   size = dotsize, color = "green") +
        geom_point(aes(x = base3, y = fuel3, shape = fueltype3),
                   size = dotsize, color = "blue") +
        theme(legend.position = "none")
}

trial_vis <- function(targtrial){
    vidf <- visamples %>%
        select(matches(
            paste0("features.*\\.", targtrial, "$")
        ))  %>%
    rename(base1 = 1, fuel1 = 4,#UGHHH
           base2 = 2, fuel2 = 5,
           base3 = 3, fuel3 = 6)

    return(
        ggplot(mytrial[targtrial, ]) +
        geom_point(data = vidf,
                   aes(x = base1, y = fuel1), color = "red", alpha = .1) +
        geom_point(data = vidf,
                   aes(x = base2, y = fuel2), color = "green", alpha = .1) +
        geom_point(data = vidf,
                   aes(x = base3, y = fuel3), color = "blue", alpha = .1) +
        geom_point(aes(x = base1, y = fuel1, shape = fueltype1),
                   size = 5, color = "red") +
        geom_point(aes(x = base2, y = fuel2, shape = fueltype2),
                   size = 5, color = "green") +
        geom_point(aes(x = base3, y = fuel3, shape = fueltype3),
                   size = 5, color = "blue")        +
        ## xlim(c(0, 1)) +
        ## ylim(c(0, 1)) +
        xlab("base") + ylab("fuel") +
        ggtitle(mytrial[targtrial, "triadtype"]) +
        guides(shape = FALSE) +
        ggplot(
            visamples %>% #this whole rigmarole is just to get control over bar fill :-(
            select(matches(paste0("bestoption.", targtrial))) %>%
            rename(choice = 1) %>%
            summarize(one = sum(choice == 1),
                      two = sum(choice == 2),
                      three = sum(choice == 3)
                      )) +
        geom_bar(stat = "identity", aes(x = "1_one", y = one, fill = "1")) +
        geom_bar(stat = "identity", aes(x = "2_two", y = two, fill = "2")) +
        geom_bar(stat = "identity", aes(x = "3_three", y = three, fill = "3"))
    )
}

## for (i in 1:nrow(mytrial)){
##     ggsave(trial_vis(i),
##            file = paste0("trial_flipbook/trial", i, ".png"), width = 10)
## }

##single trials are at the mercy of rnd generated obs: check aggregate prefs
effectdf <- visamples %>%
    select(starts_with("bestoption")) %>%
    gather(trial, choice) %>%
    group_by(trial) %>%
    summarize(one = sum(choice == 1),
              two = sum(choice == 2),
              three = sum(choice == 3)
              )

for (i in 1:nrow(effectdf)) {
    effectdf[i, "bestchoice"] <- which(effectdf[i, 2:4] == max(effectdf[i, 2:4]))[1]
    effectdf[i, "seqno"] <- as.numeric(strsplit(effectdf$trial[i],"\\.")[[1]][2])
}

effectdf <- effectdf %>% arrange(seqno)
effectdf$trialtype <- 1:nrow(testtrials)

##ok effectdf seems to mean what you want it to.
##but these plots following are shite. Effectrow needs to be col coded.
##and the wedellesque stim are not the wedell ones you want.

effectrow <- ggplot(effectdf, aes(x = bestchoice)) +
    geom_bar(position = "dodge") +
    facet_grid(.~trialtype)

stimrow <- ggplot()
for (i in 1:nrow(testtrials)) {
    stimrow <- stimrow + barestim_vis(i)
}

effectrow/stimrow
