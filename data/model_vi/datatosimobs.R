library(tidyverse)
library(rstan)
library(shinystan)
library(patchwork)

set.seed(4);#chosen by fair die roll
##init
theme_set(theme_light())
rm(list = ls()) #Todo, remap C-c C-b to new R session, stop doing this.
triadsdf <- read.csv("triadresponsedata.csv", stringsAsFactors = FALSE)

##SET PARAMS
color_est_noise <- .1
height_est_noise <- .1
base_est_noise <- .1

colorheight_comparison_noise <- 0.1 #Not used at the moment: future target.
colorcolor_comparison_noise <- .1
heightheight_comparison_noise <- .1
base_comparison_noise <- .1

##tolerance: fixed, or some JSD based on comparison noise, or what? Important.
colorheight_tolerance <- colorheight_comparison_noise / 2
colorcolor_tolerance <- colorcolor_comparison_noise / 2
heightheight_tolerance <- heightheight_comparison_noise / 2
base_tolerance <- base_comparison_noise / 2

ordobs_error <- .01 #with this prob, ordobs drawn from sample(c(1,2,3),1)
##implementation in `ordobs' fn. Appears as a constant in .stan, should match.

##END PARAMS

##helper fns
featurenoise <- function(featuretype) {
    if (featuretype == "color") return(color_est_noise)
    if (featuretype == "height") return(height_est_noise)
    if (featuretype == "base") return(base_est_noise)
}

comparison_noise <- function(feature1, feature2) {
    if (feature1 == "base" || feature2 == "base") {
        return(base_comparison_noise)
    }
    if ("color" %in% c(feature1, feature2) &&
        "height" %in% c(feature1, feature2)) {
        return(colorheight_comparison_noise)
    }
    if (feature1 == "color" && feature2 == "color") {
        return(colorcolor_comparison_noise)
    }
    if (feature1 == "height" && feature2 == "height") {
        return(heightheight_comparison_noise)
    }
}
comparison_tolerance <- function(feature1, feature2) {
    if (feature1 == "base" || feature2 == "base") {
        return(base_tolerance)
    }
    if ("color" %in% c(feature1, feature2) &&
        "height" %in% c(feature1, feature2)) {
        return(colorheight_tolerance)
    }
    if (feature1 == "color" && feature2 == "color") {
        return(colorcolor_tolerance)
    }
    if (feature1 == "height" && feature2 == "height") {
        return(heightheight_tolerance)
    }
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
        return("base")
    }
    return(row[, paste0("fueltype", option)])
}

calcobs_set <- function(arow, trialid) {
    myobs <- data.frame(
        ppntid = arow$ppntID,
        trialid = trialid,
        option = rep(c(1, 2, 3), 2),
        feature = rep(c(1, 2), each = 3),
        featuretype = c("base",
                        "base",
                        "base",
                        arow$fueltype1,
                        arow$fueltype2,
                        arow$fueltype3),
        calcobs = c(rnorm(1, arow$base1, featurenoise("base")),
                    rnorm(1, arow$base2, featurenoise("base")),
                    rnorm(1, arow$base3, featurenoise("base")),
                    rnorm(1, arow$fuel1, featurenoise(arow$fueltype1)),
                    rnorm(1, arow$fuel2, featurenoise(arow$fueltype2)),
                    rnorm(1, arow$fuel3, featurenoise(arow$fueltype3))
                    )
    )#end data frame

    levels(myobs$featuretype) <- c("base", "color", "height")
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
                                          featuretype = paste0(sort(c(gettype(arow,afeature,anoption1),gettype(arow,afeature,anoption2))),collapse=""),
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
                                                   "base"
                                               } else{
                                                   arow[paste0("fueltype", anoption1)]
                                               }),
                                              (if (afeature == 1) {
                                                   "base"
                                               } else{
                                                   arow[paste0("fueltype", anoption2)]
                                               })
                                          )#ordobs call
                                      )#data frame
                               )#rbind
            }#opt2
        }#opt1
    }#feature

    ##If not all levels are present, as.numeric() might be inconsistent in how it encodes these! Stan sees them as index-integers.
    levels(myobs$featuretype) <- c("basebase",
                                   "colorcolor",
                                   "colorheight",
                                   "heightheight")
    return(myobs)
}

##MAIN: trial setup
testtrials <- triadsdf %>%
    filter(triadtype == "dominated_decoy") %>%
    head(3)
                                        #sample_n(50)
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
    ordobs_noise = c(colorheight_comparison_noise,
                     colorcolor_comparison_noise,
                     heightheight_comparison_noise,
                     base_comparison_noise),

    calcobs_trialid = mycalcobs$trialid,
    calcobs_opt = mycalcobs$option,
    calcobs_feature = mycalcobs$feature,
    calcobs_featuretype = as.numeric(mycalcobs$featuretype),
    calcobs_obs = mycalcobs$calcobs,
    calcobs_noise = c(color_est_noise, height_est_noise, base_est_noise)
)


mod <-  stan_model(file = "howes16.stan")
vbfit <- vb(mod, data = mydatalist, output_samples = 4000, seed = 1)

visamples <- as.data.frame(extract(vbfit, permuted = TRUE))

##inference done: visualize the results
trial_vis <- function(targtrial){
    vidf <- visamples %>%
        select(matches(paste0("featurevalues.*\\.", targtrial, "$"))) %>%
    rename(base1 = 1, fuel1 = 2,
           base2 = 3, fuel2 = 4,
           base3 = 5, fuel3 = 6)

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
                   size = 5, color = "blue") +
        xlim(c(0, 1)) +
        ylim(c(0, 1)) +
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

for (i in 1:nrow(mytrial)){
    ggsave(trial_vis(i),
           file = paste0("trial_flipbook/trial", i, ".png"), width = 10)
}

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
    effectdf[i, "bestchoice"] <- which(effectdf[i, 2:4] == max(effectdf[i, 2:4]))
    effectdf[i, "seqno"] <- as.numeric(strsplit(effectdf$trial[i],"\\.")[[1]][2])
}

effectdf <- effectdf %>% arrange(seqno)
effectdf$trialtype <- 1:3

effects_plot <- ggplot(effectdf, aes(x=bestchoice)) + geom_bar() + facet_grid(.~trialtype)

ggsave(effects_plot, file = "effects.png", width = 10)
