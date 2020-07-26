library(tidyverse)
library(patchwork)
source("readData.R")

saveplots <- TRUE
deliberation_cutoff <- .9 #quantile to cut deliberation time hists at

timespent_hist <-
    ggplot(participation_time,
           aes(x = (lastresponse - firstdraw) / 1000 / 60)) +
    geom_histogram(binwidth=.5)
if (saveplots) {
ggsave(timespent_hist, file = "plots/timespenthist.png")
}

##PAIRS
pair_stimgapsetup <-
    ggplot(pairsdf,
           aes(x = targfeature_diff)) +
    geom_histogram(binwidth = .01) +
    facet_grid(questiontype~.)

if (saveplots) {
    ggsave(pair_stimgapsetup, file = "plots/pair_stimgapsetup.png")
}

everytriad_plot <-
    ggplot(triadsdf) +
    geom_point(aes(x = base1, y = fuel1, shape = fueltype1, color = "targ")) +
    geom_point(aes(x = base2, y = fuel2, shape = fueltype2, color = "comp")) +
    geom_point(aes(x = base3, y = fuel3, shape = fueltype3, color = "decoy"))

pair_accuracy_bydistance <- ggplot()
for (q in unique(pairsdf$questiontype)) {
    pair_accuracy_bydistance <- pair_accuracy_bydistance +
        ggplot(pairsdf %>% filter(questiontype == q),
               aes(x = targfeature_diff, fill = comparisontype)) +
        geom_histogram() +
        facet_grid(ans_correct~comparisontype) +
        ggtitle(q) +
        guides(fill = FALSE)
}
if (saveplots) {
    ggsave(pair_accuracy_bydistance,
           file = "plots/pair_accuracy_bydistance.png", width = 15)
}

pair_accuracy_byppnt <-
    ggplot(pairsdf %>%
       group_by(ppntID,questiontype,comparisontype) %>%
       summarize(p_correct = mean(ans_correct)),
       aes(x = p_correct)) +
       geom_histogram() +
    facet_grid(questiontype~comparisontype)

if (saveplots) {
    ggsave(pair_accuracy_byppnt,
           file = "plots/pair_accuracy_byppnt.png", width = 15)
}


pair_rt_hist <-
    ggplot(pairsdf %>%
           filter(deliberationtime <
                  quantile(pairsdf$deliberationtime,
                           deliberation_cutoff)),
           aes(x = deliberationtime)) +
    geom_histogram() +
    ggtitle(paste0("Pair response times (<", deliberation_cutoff, " quantile)"))

if (saveplots) {
    ggsave(pair_rt_hist, file = "plots/pair_RT_hist.png", width = 15)
}



##TRIADS

triad_rt_hist <-
    ggplot(triadsdf %>%
           filter(deliberationtime < quantile(triadsdf$deliberationtime,
                                              deliberation_cutoff)),
           aes(x = deliberationtime)) +
    geom_histogram() +
    ggtitle(paste0("Triad response times (<", deliberation_cutoff, " quantile)"))
if (saveplots) {
ggsave(triad_rt_hist, file = "plots/triad_RT_hist.png", width = 15)
}


single_triad_plot <- function(rowid) {
    pointsize <- 5;

    ggplot(triadsdf[rowid, ]) +
        geom_point(aes(x = choice_base,
                       y = choice_fuel,
                       shape = fueltype1,
                       color = "chosen"),
                   size = pointsize + 2) +
        geom_point(aes(x = base1,
                       y = fuel1,
                       shape = fueltype1,
                       color = "targ"),
                   size = pointsize) +
        geom_point(aes(x = base2,
                       y = fuel2,
                       shape = fueltype2,
                       color = "comp"),
                   size = pointsize) +
        geom_point(aes(x = base3,
                       y = fuel3,
                       shape = fueltype3,
                       color = "decoy"),
                   size = pointsize) +
        ggtitle(
            paste(
                paste0("targ=", with(triadsdf[rowid, ],
                                     signif(base1 * fuel1, 3))),
                paste0("comp=", with(triadsdf[rowid, ],
                                     signif(base2 * fuel2, 3))),
                paste0("decoy=", with(triadsdf[rowid, ],
                                      signif(base3 * fuel3, 3)))
    )
    )
}


arbrocket_triads <- triadsdf
for (i in 1:nrow(triadsdf)) {
#    print(i / nrow(triadsdf)*100);    
    ##arbitrary target point base=.3 .fuel=.7
    arb_base <- .3;
    arb_fuel <- .7
    ##escape df frame
    base1 <- triadsdf[i, "base1"]
    base2 <- triadsdf[i, "base2"]
    base3 <- triadsdf[i, "base3"]
    fuel1 <- triadsdf[i, "fuel1"]
    fuel2 <- triadsdf[i, "fuel2"]
    fuel3 <- triadsdf[i, "fuel3"]
    ##which rocket is closest to the arb point?
    dist1 = sqrt((base1 - arb_base)^2 + (fuel1 - arb_fuel)^2)
    dist2 = sqrt((base2 - arb_base)^2 + (fuel2 - arb_fuel)^2)
    dist3 = sqrt((base3 - arb_base)^2 + (fuel3 - arb_fuel)^2)

    ##Get the base and fuel translations needed to put a rocket on arb.
    if (dist1 <= dist2 && dist1 <= dist3) {
        baseshift <- arb_base - base1
        fuelshift <- arb_fuel - fuel1
    }
    if (dist2 <= dist1 && dist2 <= dist3) {
        baseshift <- arb_base - base2
        fuelshift <- arb_fuel - fuel2
    }
    if (dist3 <= dist1 && dist3 <= dist2) {
        baseshift <- arb_base - base3
        fuelshift <- arb_fuel - fuel3
    }

    arbrocket_triads[i, "base1"] <- arbrocket_triads[i, "base1"] + baseshift
    arbrocket_triads[i, "base2"] <- arbrocket_triads[i, "base2"] + baseshift
    arbrocket_triads[i, "base3"] <- arbrocket_triads[i, "base3"] + baseshift
    arbrocket_triads[i, "fuel1"] <- arbrocket_triads[i, "fuel1"] + fuelshift
    arbrocket_triads[i, "fuel2"] <- arbrocket_triads[i, "fuel2"] + fuelshift
    arbrocket_triads[i, "fuel3"] <- arbrocket_triads[i, "fuel3"] + fuelshift
}#end for each row in triadsdf


dominated_decoy_roleprefs <-
    ggplot(triadsdf %>% filter(startsWith(triadtype, "dominated")),
       aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(comparisontype~triadtype)

if (saveplots) {
    ggsave(dominated_decoy_roleprefs,
           file = "plots/dominated_decoy_roleprefs.png",
           width = 15, height = 20)
}

compromise_roleprefs <-
    ggplot(triadsdf %>% filter(startsWith(triadtype,"compromise")),
       aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(comparisontype~triadtype)

if (saveplots) {
    ggsave(compromise_roleprefs,
           file = "plots/compromise_roleprefs.png",
           width = 15, height = 20)
}


pairs_timingbydifficulty <-
    ggplot(pairsdf %>%
       filter(deliberationtime <
              quantile(pairsdf$deliberationtime, deliberation_cutoff)),
       aes(x = targfeature_diff,
           y = std_time,
#           color = questiontype,
           color = paste0(fueltype1, fueltype2))) +
    geom_point() +
    facet_grid(questiontype~.)+
    geom_smooth(se = FALSE)

triad_timingbycomparisontype <-
    ggplot(triadsdf,
           aes(x = std_time, fill = comparisontype)) +
    geom_density(alpha = 0.3) +
    facet_grid(comparisontype~.)

if (saveplots) {
    ggsave(triad_timingbycomparisontype,
           file = "plots/triad_timingbycomparisontype.png",
           width = 15)
}

if (saveplots) {
    ggsave(pairs_timingbydifficulty,
           file = "plots/pairs_timingbydifficulty.png",
           width = 15)
}


prefdiff_bycomparisontype <- function(comptype = c("colorcolorcolor",
                                                   "colorcolorheight",
                                                   "colorheightcolor",
                                                   "colorheightheight",
                                                   "heightcolorcolor",
                                                   "heightcolorheight",
                                                   "heightheightcolor",
                                                   "heightheightheight")[1]) {
    
prefdiffs <- triadsdf %>% filter(startsWith(triadtype, "dominated"),
                                 comparisontype == comptype) %>%
    group_by(as.factor(decoydist)) %>%
    summarize(chose_targ = sum(rolechosen == "targ"),
              chose_comp = sum(rolechosen == "comp"),
              chose_decoy = sum(rolechosen == "decoy")) %>%
    mutate(tcdiff = chose_targ - chose_comp) %>%
    ungroup
names(prefdiffs)[1] <- "decoydist"
prefdiffs$decoydist <- as.numeric(as.character(prefdiffs$decoydist))
return(
    ggplot(prefdiffs, aes(x = decoydist, y = tcdiff)) +
    geom_bar(stat = "identity") +
    ylim(c(-73, 73))
)
}


everything_rolebars <-
    ggplot(triadsdf, aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(triadtype~comparisontype)
if (saveplots) {
    ggsave(everything_rolebars, file = "plots/everything_rolebars.png",
           height = 20,width = 15)
    }


everything_classbars <-
    ggplot(triadsdf, aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(triadtype~comparisonclass)

if (saveplots) {
    ggsave(everything_classbars, file = "plots/everything_classbars.png")
    }

dominated_allsamevsodddecoy_classbars <-
    ggplot(triadsdf %>%
           filter(startsWith(triadtype,"dom"),
                  comparisonclass %in% c("allsame", "decoy_odd")),
           aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(triadtype~comparisonclass)

if (saveplots) {
    ggsave(dominated_allsamevsodddecoy_classbars,
           file = "plots/dominated_allsamevsodddecoy_classbars.png"
           )
    }


compromise_allsamevsodddecoy_classbars <-
    ggplot(triadsdf %>% filter(triadtype == "compromise",
                               comparisonclass %in% c("allsame", "decoy_odd")),
           aes(x = rolechosen, fill = rolechosen)) +
    geom_bar() +
    facet_grid(triadtype~comparisonclass)

if (saveplots) {
    ggsave(compromise_allsamevsodddecoy_classbars,
           file = "plots/compromise_allsamevsodddecoy_classbars.png"
           )
    }   

featureprefs <- 
ggplot(
triadsdf %>%
    group_by(ppntID) %>%
    summarize(chosebybase = sum(rolechosen == best_base_role),
              chosebyfuel = sum(rolechosen == best_fuel_role),
              other = n() - chosebybase - chosebyfuel
              ) %>%
    ungroup) +
    geom_histogram(aes(x = chosebybase, fill = "launcher"), alpha=.3) +
    geom_histogram(aes(x = chosebyfuel, fill = "orbital"), alpha=.3) +
    xlab("")


if (saveplots) {
    ggsave(featureprefs,
           file = "plots/featureprefs.png"
           )
    }
