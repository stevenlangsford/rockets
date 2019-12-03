library(tidyverse)
rm(list = ls()) #JB will come set fire to your computer...
theme_set(theme_light())

demographicsdf <- read.csv("raw/demographicsdata.csv")
pairsdf <- read.csv("raw/pairresponsedata.csv")
triadsdf <- read.csv("raw/triadresponsedata.csv")

##TODO. Exclusion criteria: accuracy on trials-with-an-answer?


##adding some derived info to the dfs:

##pairs
for (i in 1:nrow(pairsdf)) {
pairsdf[i,"comparisontype"] <- paste0(
    sort(
        c(as.character(pairsdf[i,"fueltype1"]),
          as.character(pairsdf[i,"fueltype2"])
          )
    ),
    collapse = ":")
}

##rename for convenience:
##levels(pairsdf$questiontype) #base, distance, fuel
levels(pairsdf$questiontype) <- c("base", "distance", "fuel")

for (i in 1:nrow(pairsdf)) {
    if (pairsdf$questiontype[i] == "base") {
        pairsdf[i, "targfeature_diff"] <-
            with(pairsdf[i, ], abs(base1 - base2))
        pairsdf[i, "ans_correct"] <- with(pairsdf[i, ],
                                         choice_base == max(base1, base2))
    }
    if (pairsdf$questiontype[i] == "fuel") {
        pairsdf[i, "targfeature_diff"] <-
            with(pairsdf[i, ], abs(fuel1 - fuel2))
                pairsdf[i, "ans_correct"] <- with(pairsdf[i, ],
                                         choice_base == max(fuel1, fuel2))
    }
    if (pairsdf$questiontype[i] == "distance") {
        pairsdf[i, "targfeature_diff"] <-
            with(pairsdf[i, ], abs((fuel1 * base1) - (fuel2 * base2)))

        pairsdf[i, "ans_correct"] <- with(pairsdf[i, ],
                                          (choice_base * choice_fuel) ==
                                          max(c(base1 * fuel1, base2 * fuel2)))
    }
}

rolechosen <- function(rowid) {
    ##seems terribly byzantine?
    ##location of each role was randomized but 1,2,3 is targ comp decoy (see js)
    mychoice <- paste0(triadsdf[rowid,
                                c("choice_base",
                                  "choice_fuel",
                                  "choice_fueltype")],
                       collapse = ""
                       )

    targ <- paste0(triadsdf[rowid,
                            c("base1",
                              "fuel1",
                              "fueltype1")],
                   collapse = ""
                   )
    comp <- paste0(triadsdf[rowid,
                            c("base2",
                              "fuel2",
                              "fueltype2")],
                   collapse = ""
                   )
    
    decoy <- paste0(triadsdf[rowid,
                             c("base3",
                               "fuel3",
                               "fueltype3")],
                    collapse = ""
                    )
    if (mychoice == targ)return("targ")
    if (mychoice == comp)return("comp")
    if (mychoice == decoy)return("decoy")
}

triadsdf$rolechosen <- sapply(1:nrow(triadsdf), rolechosen)
triadsdf$decoydist <- sapply(1:nrow(triadsdf), function(i) {
    return(sqrt((triadsdf[i,"base1"] - triadsdf[i, "base3"])^2 +
          (triadsdf[i, "fuel1"] - triadsdf[i, "fuel3"])^2
         ))#go learn some purrr ffs.
})


##namespace cleanup
rm("rolechosen")
