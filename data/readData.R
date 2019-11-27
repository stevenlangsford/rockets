library(tidyverse)
rm(list=ls())
theme_set(theme_light())

##TODO. Exclusion criteria: accuracy on trials-with-an-answer?


demographics <- read.csv("raw/demographicsdata.csv")
pairsdf <- read.csv("raw/pairresponsedata.csv")
triadsdf <- read.csv("raw/triadresponsedata.csv")


rolechosen <- function(rowid) {
    ##seems terribly byzantine?
    ##location of each role was randomized, looks like you're blind to location? should save that info!
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
