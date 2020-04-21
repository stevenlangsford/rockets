library(patchwork)
source("readData.R")

saveplots <- TRUE

##pair trials
pairsplot <- 
ggplot(pairsdf %>% filter(questiontype !=
                        "Which rocket has the best performance?")) +
    geom_point(aes(x = base1 - base2, y = fuel1 - fuel2,
                   shape = paste(fueltype1, fueltype2),
                   color = as.factor(whichchosen)
                   ), size = 5, alpha = .9
               ) +
    facet_wrap(.~questiontype) +
    geom_vline(data = data.frame(questiontype = "Which rocket has the best launch stage?", xinter = 0),
               aes(xintercept = xinter)) +
    geom_hline(data = data.frame(questiontype = "Which rocket has the best orbital stage?", yinter = 0),
               aes(yintercept = yinter)) +
    guides(color = FALSE, shape = FALSE) +
ggplot(pairsdf %>% filter(questiontype ==
                        "Which rocket has the best performance?")) +
    geom_point(aes(x = base1*fuel1, y = base2 * fuel2,
                   shape = paste(fueltype1, fueltype2),
                   color = as.factor(whichchosen)
                   ), size = 5, alpha = .9
               ) +
    geom_line(aes(x = base1 * fuel1, y = base1 * fuel1 ))+
    ggtitle("Which rocket has best performance")

if (saveplots) {
    ggsave(pairsplot, file = "plots/pairs_by_features.png",
           height = 10, width = 20)
}

pair_performancehist <- 
ggplot(pairsdf %>%
       filter(questiontype == "Which rocket has the best performance?")) +
    geom_histogram(aes(x = choice_performance - alt_performance,
                       fill = comparisontype))+
    facet_grid(comparisontype~.) + guides(fill=FALSE)
if (saveplots) {
    ggsave(pair_performancehist, file = "plots/pairsperformancehist.png", width = 15)
}
#WHY IS THE DISTRIBTION OF COMPARIONSTYPES UNEVEN? WTF?



##slider trials #Meh? not a priority?
sliderattemptsplot <- #wait are with and without guides mixed together here? UGH
    ggplot(sliderdf, aes(x = prevattempts)) +
    geom_histogram() +
    facet_grid(trialtype~.)
       
if (saveplots) {
    ggsave(sliderattemptsplot, file = "plots/sliderattempts.png",
           width = 20, height = 10)
}

##triad trials

