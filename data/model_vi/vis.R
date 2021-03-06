##NOT STANDALONE!
##Taken from wedelltosimobs.R,
##assumes mytrial,triadsdf,visamples

##inference done: visualize the results.
barestim_vis <- function(targtrial) {
    ##assumes mytrial and triadsdf
    dotsize <- 7
    ggplot(mytrial[targtrial, ]) +
        geom_point(aes(x = base1, y = fuel1, shape = fueltype1),
                   size = dotsize, color = "red") +
        geom_point(aes(x = base2, y = fuel2, shape = fueltype2),
                   size = dotsize, color = "green") +
        geom_point(aes(x = base3, y = fuel3, shape = fueltype3),
                   size = dotsize, color = "blue") +
        theme(legend.position = "none") +
        xlim(c(0, 1)) +
        ylim(c(with(triadsdf, min(c(fuel1, fuel2, fuel3))) - 5,
               with(triadsdf, max(c(fuel1, fuel2, fuel3))) + 5)
             )
}

trial_vis <- function(targtrial) {
    vidf <- visamples %>%
        select(matches(
            paste0("features.*\\.", targtrial, "$")
        ))  %>%
        rename(base1 = 1, fuel1 = 4, #UGHHH
               base2 = 2, fuel2 = 5,
               base3 = 3, fuel3 = 6)

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
                   size = 5, color = "blue")        +
        ## xlim(c(0, 1)) +
        ## ylim(c(0, 1)) +
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

double_trial_vis <- function(backtrial, fronttrial) {
    vidf <- visamples %>%
        select(matches(
            paste0("features.*\\.", backtrial, "$")
        ))  %>%
        rename(base1 = 1, fuel1 = 4, #UGHHH
               base2 = 2, fuel2 = 5,
               base3 = 3, fuel3 = 6)

    vidf_front <- visamples %>%
        select(matches(
            paste0("features.*\\.", fronttrial, "$")
        ))  %>%
        rename(base1 = 1, fuel1 = 4, #UGHHH x2
               base2 = 2, fuel2 = 5,
               base3 = 3, fuel3 = 6)
    retplot <-
        ggplot(mytrial[backtrial, ]) +
                                        #back
        geom_point(data = vidf,
                   aes(x = base1, y = fuel1), color = "grey", alpha = .2) +
        geom_point(data = vidf,
                   aes(x = base2, y = fuel2), color = "grey", alpha = .2) +
        geom_point(data = vidf,
                   aes(x = base3, y = fuel3), color = "grey", alpha = .2) +
                                        #front
        geom_point(data = vidf_front,
                   aes(x = base1, y = fuel1), color = "red", alpha = .01) +
        geom_point(data = vidf_front,
                   aes(x = base2, y = fuel2), color = "green", alpha = .01) +
        geom_point(data = vidf_front,
                   aes(x = base3, y = fuel3), color = "blue", alpha = .01) +
        geom_point(aes(x = base1, y = fuel1, shape = fueltype1),
                   size = 5, color = "red") +
        geom_point(aes(x = base2, y = fuel2, shape = fueltype2),
                   size = 5, color = "green") +
        geom_point(aes(x = base3, y = fuel3, shape = fueltype3),
                   size = 5, color = "blue")        +
        ## xlim(c(0, 1)) +
        ## ylim(c(0, 1)) +
        xlab("base") + ylab("fuel") +
        ggtitle(mytrial[backtrial, "triadtype"]) +
        guides(shape = FALSE) +
        (ggplot(
                  visamples %>% #this whole rigmarole is just to get control over bar fill :-(
                  select(matches(paste0("bestoption.", backtrial))) %>%
                  rename(choice = 1) %>%
                  summarize(one = sum(choice == 1),
                            two = sum(choice == 2),
                            three = sum(choice == 3)
                            )) +
         geom_bar(stat = "identity", aes(x = "1_one", y = one), fill = "grey") +
         geom_bar(stat = "identity", aes(x = "2_two", y = two), fill = "grey") +
         geom_bar(stat = "identity", aes(x = "3_three", y = three), fill = "grey") + xlab("") + ylab("")) /
        (ggplot(
            visamples %>% 
            select(matches(paste0("bestoption.", fronttrial))) %>%
            rename(choice = 1) %>%
            summarize(one = sum(choice == 1),
                      two = sum(choice == 2),
                      three = sum(choice == 3)
                      )) +
         geom_bar(stat = "identity", aes(x = "1_one", y = one, fill = "1")) +
         geom_bar(stat = "identity", aes(x = "2_two", y = two, fill = "2")) +
         geom_bar(stat = "identity", aes(x = "3_three", y = three, fill = "3")) +
         guides(fill = FALSE) + xlab("") + ylab("")
        )
    return(retplot)
}
