library(tidyverse)
library(patchwork)
source("readData.R")

saveplots <- FALSE
deliberation_cutoff <- .9 #quantile to cut deliberation time hists at

##PAIRS
everytriad_plot <- ggplot(triadsdf) +
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

pair_accuracy_byppnt <- ggplot(pairsdf %>%
       group_by(ppntID,questiontype,comparisontype) %>%
       summarize(p_correct = mean(ans_correct)),
       aes(x = p_correct)) +
       geom_histogram() +
    facet_grid(questiontype~comparisontype)

if (saveplots) {
    ggsave(pair_accuracy_byppnt,
           file = "plots/pair_accuracy_byppnt.png", width = 15)
}


pair_rt_hist <- ggplot(pairsdf %>%
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

triad_rt_hist <- ggplot(triadsdf %>%
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
    ggplot(triadsdf %>% filter(startsWith(triadtype,"dominated")),
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



## ggplot(arbrocket_triads) +
##     geom_point(aes(x = base1,y = fuel1, shape = fueltype1, color = "targ")) +
##     geom_point(aes(x = base2,y = fuel2, shape = fueltype2, color = "comp")) +
##     geom_point(aes(x = base3,y = fuel3, shape = fueltype3, color = "decoy")) +
##     geom_point(aes(x = .3, y = .7), color = "black")
