source("readData.R")

table(pairsdf$comparisontype, pairsdf$questiontype)

table(triadsdf$triadtype)

table(triadsdf %>% filter(triadtype == "dominated_decoy") %>%
      select(decoydist)
      )

table(triadsdf$comparisontype,triadsdf$triadtype)
