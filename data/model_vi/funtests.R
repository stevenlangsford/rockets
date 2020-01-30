calcobs_demoplot <- function(){

calcdemodf <- data.frame();
for (i in 1:100)calcdemodf <- rbind(calcdemodf,calcobs_set(mytrial,1))
    return(
        
    ggplot(calcdemodf, aes(x = featurevalue)) +
    geom_density() +
    facet_grid(option~feature) +
    geom_vline(data = mytrial %>% mutate(feature = 1, option = 1),
               aes(xintercept = base1)) +
        geom_vline(data = mytrial %>% mutate(feature = 1, option = 2),
                   aes(xintercept = base2)) +
        geom_vline(data = mytrial %>% mutate(feature = 1, option = 3),
                   aes(xintercept = base3)) +
        geom_vline(data = mytrial %>% mutate(feature = 2, option = 1),
               aes(xintercept = fuel1)) +
        geom_vline(data = mytrial %>% mutate(feature = 2, option = 2),
                   aes(xintercept = fuel2)) +
        geom_vline(data = mytrial %>% mutate(feature = 2, option = 3),
              aes(xintercept = fuel3))

    )#end return
    
}
