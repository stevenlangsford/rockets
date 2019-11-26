library(tidyverse)
theme_set(theme_light())

demographics <- read.csv("raw/demographicsdata.csv")
pairs.df <- read.csv("raw/pairresponsedata.csv")
triads.df <- read.csv("raw/triadresponsedata.csv")


ggplot(triads.df) +
    geom_point(aes(x = base1,y = fuel1, shape = fueltype1, color = "targ")) +
    geom_point(aes(x = base2,y = fuel2, shape = fueltype2, color = "comp")) +
    geom_point(aes(x = base3,y = fuel3, shape = fueltype3, color = "decoy"))
