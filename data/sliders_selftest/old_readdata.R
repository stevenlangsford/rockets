##pairs
levels(pairsdf$questiontype) <- c("base", "distance", "fuel")

for (i in 1:nrow(pairsdf)) {
pairsdf[i,"comparisontype"] <- paste0(
    sort(
        c(as.character(pairsdf[i,"fueltype1"]),
          as.character(pairsdf[i,"fueltype2"])
          )
    ),
    collapse = ":")

pairsdf[i, "deliberationtime"] <-
    pairsdf[i, "responsetime"] - pairsdf[i, "drawtime"]

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
                                         choice_fuel == max(fuel1, fuel2))
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
triadsdf$comparisontype <- paste0(triadsdf$fueltype1,
                                  triadsdf$fueltype2,
                                  triadsdf$fueltype3)


for (i in 1:nrow(triadsdf)) {
triadsdf[i, "deliberationtime"] <-
    triadsdf[i, "responsetime"] - triadsdf[i, "drawtime"]
if (triadsdf[i, "triadtype"] == "dominated_decoy"){
    triadsdf[i, "triadtype"] <- paste("dominated_decoy",
                                      signif(triadsdf[i, "decoydist"],4),
                                      sep = "_")
}

triadsdf[i, "best_base_role"] <- with(triadsdf[i, ],
                                     c("targ", "comp", "decoy")[
                                         which(c(base1, base2, base3) ==
                                               max(c(base1, base2, base3)))])
triadsdf[i, "best_fuel_role"] <- with(triadsdf[i, ],
                                     c("targ", "comp", "decoy")[
                                         which(c(fuel1, fuel2, fuel3) ==
                                               max(c(fuel1, fuel2, fuel3)))])

}#end for each row in triads


triadsdf <- triadsdf %>%
    group_by(ppntID) %>%
    mutate(std_time = (deliberationtime - mean(deliberationtime)) /
               sd(deliberationtime)
           ) %>%
    ungroup

pairsdf <- pairsdf %>%
    group_by(ppntID) %>%
    mutate(std_time = (deliberationtime - mean(deliberationtime)) /
               sd(deliberationtime)
           ) %>%
    ungroup

comparisonclass_map <- function(comptype) {
    if (comptype == "colorcolorcolor")return("allsame")
    if (comptype == "colorcolorheight")return("decoy_odd")
    if (comptype == "colorheightcolor")return("comp_odd")
    if (comptype == "colorheightheight")return("targ_odd")
    if (comptype == "heightcolorcolor")return("targ_odd")
    if (comptype == "heightcolorheight")return("comp_odd")
    if (comptype == "heightheightcolor")return("decoy_odd")
    if (comptype == "heightheightheight")return("allsame")
    stop(paste("comptype washout in comparison class map", comptype))
    }
triadsdf$comparisonclass <- sapply(triadsdf$comparisontype, comparisonclass_map)

triadsdf$rolechosen <- factor(triadsdf$rolechosen,
                              #ordered = TRUE,
                              levels = c("targ", "comp", "decoy")
                              )




##EXCLUSION CRITERIA
toofast_cutoff <- 6 #min, set from inspection of 1st pilot hist of times.
baseaccuracy_cutoff <- .6

toofast <- participation_time %>%
    filter((lastresponse - firstdraw) / 1000 / 60 < toofast_cutoff) %>%
    select(ppntID)

bad_base_accuracy <-
    pairsdf %>%
    group_by(ppntID, questiontype) %>%
    summarize(p_correct = mean(ans_correct)) %>%
    filter(questiontype == "base", p_correct < baseaccuracy_cutoff) %>%
    select(ppntID)

colblind <- demographicsdf %>% filter(colblind == "yes") %>% select(ppntID)

badID <- unique(c(toofast$ppntID,
                  bad_base_accuracy$ppntID,
                  colblind$ppntID))
#in pilot_1: 7 exclusions, 4 too fast, 1 bad accuracy, 2 colblind. Not bad!


pairsdf <- pairsdf %>% filter(!ppntID %in% badID)
triadsdf <- triadsdf %>% filter(!ppntID %in% badID)
##namespace cleanup
rm(list = setdiff(ls(), c("pairsdf",
                          "triadsdf",
                          "demographicsdf",
                          "participation_time")))
