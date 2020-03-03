##continues on from wedelltosimobs.R

testtrials <- triadsdf[1, ]

mytrial <- data.frame()
for (i in 1:100) {
    mytrial <- rbind(mytrial, testtrials)
}


myordobs <- data.frame()
mycalcobs <- data.frame()


    
##Get some sim obs
for (i in 1:nrow(mytrial)) {
    myordobs <- rbind(myordobs, ordobs_set(mytrial[i, ], i))
    mycalcobs <- rbind(mycalcobs, perfect_calcobs_set(mytrial[i, ], i))
}

ordobs_profile <- myordobs %>%
    group_by(trialid) %>%
    summarize(ordobs_set = paste0(ordobs, collapse = "")) %>%
    ungroup() %>%
    left_join(myordobs)

ordobs_included_trialid <- sample(1:max(myordobs$trialid),
                          max(myordobs$trialid) / 2,
                          replace = FALSE)

my_included_ordobs <- filter(myordobs, trialid %in% ordobs_included_trialid)

##get some inferred option values:
mydatalist <- list(
    n_ordobs = nrow(my_included_ordobs),
    n_calcobs = nrow(mycalcobs),
    n_trials = max(c(myordobs$trialid, mycalcobs$trialid)),

    ordobs_trialid = my_included_ordobs$trialid,
    ordobs_opt1 = my_included_ordobs$option1,
    ordobs_opt2 = my_included_ordobs$option2,
    ordobs_feature = my_included_ordobs$feature,
    ordobs_featuretype = as.numeric(my_included_ordobs$featuretype),
    ordobs_obs = my_included_ordobs$ordobs,
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

source("vis.R")

double_trial_vis(4,5) #arg order is : back, front. ordobs_included_trialid says 4 is without, 5 with.
