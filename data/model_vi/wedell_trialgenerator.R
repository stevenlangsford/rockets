library(tidyverse)

rm(list = ls()) #fix your emacs so you can stop commenting how bad this is!
theme_set(theme_light())

##convention: an option is c(prob, payoff)
##a trial is c(option1, option2, option3)

wedellgetter <- function(A, # in 1:4
                         B, # in 1:4
                         whichdecoy, #in c("A","B")
                         decoytype #in c("R","F","RF")
                         ) {


options_A <- list(
    c(.4, 25),
    c(.5, 20),
    c(.67, 15),
    c(.83, 12)
)
    my_A <- options_A[[A]]
    
options_B <- list(
    c(.3, 33),
    c(.4, 25),
    c(.5, 20),
    c(.67, 15)
)
    my_B <- options_B[[B]]

    if (whichdecoy == "A"){
        my_decoy <- list(switch(decoytype,
                           "R" = c(.4, 20),
                           "F" = c(.35, 25),
                           "RF" = c(.35, 20)),
                         switch(decoytype,
                           "R" = c(.5, 18),
                           "F" = c(.45, 20),
                           "RF" = c(.45, 18)),
                         switch(decoytype,
                           "R" = c(.67, 13),
                           "F" = c(.62, 15),
                           "RF" = c(.62, 13)),
                         switch(decoytype,
                           "R" = c(.83, 10),
                           "F" = c(.78, 12),
                           "RF" = c(.78, 10))
                         )[[A]]
                         
                         
    }else{#whichdecoy=="B"
        my_decoy <- list(switch(decoytype,
                           "R" = c(.25, 33),
                           "F" = c(.3, 30),
                           "RF" = c(.25, 30)),
                         switch(decoytype,
                           "R" = c(.35, 25),
                           "F" = c(.4, 20),
                           "RF" = c(.35, 20)),
                         switch(decoytype,
                           "R" = c(.45, 20),
                           "F" = c(.5, 18),
                           "RF" = c(.45, 18)),
                         switch(decoytype,
                           "R" = c(.62, 15),
                           "F" = c(.67, 13),
                           "RF" = c(.62, 13))
                         )[[B]]
    }#end set decoy
    ## my_A
    ## my_B
    ## my_decoy
return(
    data.frame(
        ppntID = 1,
        triadtype = "wedell",
        presentation = NA,
        base1 = my_A[1],
        base2 = my_B[1],
        base3 = my_decoy[1],
        fuel1 = my_A[2],
        fuel2 = my_B[2],
        fuel3 = my_decoy[2],
        fueltype1 = "height",
        fueltype2 = "height",
        fueltype3 = "height",
        choice_base = NA,
        choice_fuel = NA,
        choice_fueltype = "height",
        drawtime = NA,
        responsetime = NA
    )
    )
}#end wedellgetter



opt_value <- function(anoption) {
    return(anoption[1] * anoption[2])
}


##rockets data df format is:
##ppntID	triadtype	presentation	base1	base2	base3	fuel1	fuel2	fuel3	fueltype1	fueltype2	fueltype3	choice_base	choice_fuel	choice_fueltype	drawtime	responsetime

wedell_allcombo_df <- data.frame()

for (anA in 1:4) {
    for (aB in 1:4) {
        for (adecoy in c("A", "B")) {
            for (decoytype in c("R", "F", "RF")) {
                wedell_allcombo_df <- rbind(wedell_allcombo_df,
                                            wedellgetter(anA,
                                                         aB,
                                                         adecoy,
                                                         decoytype)
                                            )
            }
        }
    }
}

##simworld
##The probabilities p were Beta(a= 1, b=1)
##The values v were normal (mu= 100, sigma= 5)
howes_simtrials_df <- data.frame()
ntrials = 10 #10^7 in paper

rnd_option <- function() {
    return(c(rbeta(1, 1, 1), rnorm(1, 100, 5)))
    }

rnd_simtrial <- function() {
    return(list(rnd_option(), rnd_option(), rnd_option()))
}

for (i in 1:ntrials) {
    mytrial <- rnd_simtrial()
    
    howes_simtrials_df <- rbind(howes_simtrials_df,
                                  data.frame(
                                      ppntID = 1,
                                      triadtype = "hsim",
                                      presentation = NA,
                                      base1 = mytrial[[1]][1],
                                      base2 = mytrial[[2]][1],
                                      base3 = mytrial[[3]][1],
                                      fuel1 = mytrial[[1]][2],
                                      fuel2 = mytrial[[2]][2],
                                      fuel3 = mytrial[[3]][2],
                                      fueltype1 = "height",
                                      fueltype2 = "height",
                                      fueltype3 = "height",
                                      choice_base = NA,
                                      choice_fuel = NA,
                                      choice_fueltype = "height",
                                      drawtime = NA,
                                      responsetime = NA
                                  )
                                  )
}

##output:
write.csv(wedell_allcombo_df, file = "miniwedell.csv")

