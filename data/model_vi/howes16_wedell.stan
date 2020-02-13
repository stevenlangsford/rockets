functions{
  real ordobs_lpmf(int obs, real feature1, real feature2, int featuretype){
    //pure howes16: uniform errors. No ref to comparison-type yet.
    real tolerance;
    real errprob;

    real correct;
    real wrong;
    
    tolerance = (featuretype == 1 ? 0.011 : 1.1);//pg 374.
    errprob = .1; //ballpark, only matches min RMSE with alpha 1.5. Could vary with featuretype like tolerance does(?)

    correct = log(1-errprob); //ignores the times uniform error accidentally returns the correct obs, (1.0/3.0)*errprob: errprob is free param, can eat this wrinkle.
    wrong = log(errprob);
    
    if(fabs(feature1-feature2) < tolerance && obs == 2) return(correct);
    if(feature1<feature2 && obs == 1) return(correct);
    if(feature1>feature2 && obs ==3) return(correct);
    return(wrong);
  }

  /* real calcobs_lpdf(real obs, real targfeature, real noise){ */
  /*   //Calcobs normally distributed around truth */
  /*   //a little funny to user-defined-fn this, but the rhyme with ordobs is nice. */
  /*   return( */
  /* 	   normal_lpdf(obs | targfeature, noise) */
  /* 	   ); */
  /* } */
}
data{//single trial, single ppnt, can extend if working.
  int n_ordobs;
  int n_calcobs;
  int n_trials;

  int ordobs_trialid[n_ordobs];
  int ordobs_opt1[n_ordobs];//index what's being observed, then observe it.
  int ordobs_opt2[n_ordobs];
  int ordobs_feature[n_ordobs];
  int ordobs_featuretype[n_ordobs]; //1=probfeature, 2 payfeature
  int ordobs_obs[n_ordobs];
  
  int calcobs_trialid[n_calcobs];
  int calcobs_opt[n_calcobs];//index what's being observed, then observe it.
  int calcobs_feature[n_calcobs];
  int calcobs_featuretype[n_calcobs];//1=prob, 2 payoff
  real calcobs_obs[n_calcobs];
  real calcobs_noise[2]; // number of feature types: prob, payoff
}

parameters{
  //dims: feature(1=prob, 2=payoff), option(1:3), trialid(1:n_trials)
  real<lower=0,upper=1> probfeatures[3,n_trials];
  real payfeatures[3, n_trials];
}

model{
  //priors on features
    for(anoption in 1:3){
      probfeatures[anoption]~uniform(0,1);
      payfeatures[anoption]~student_t(100,19.6,8.08);//pg 376
    }
    //calcobs
  for(i in 1:n_calcobs){
    if(calcobs_featuretype[i] == 1) {
      calcobs_obs[i]~normal(probfeatures[calcobs_opt[i], calcobs_trialid[i]],calcobs_noise[1]);
    }
    else {
      calcobs_obs[i]~normal(payfeatures[calcobs_opt[i], calcobs_trialid[i]],calcobs_noise[2]);
    }
  }
  //ordobs
  for(anordobs in 1:n_ordobs){
    if(ordobs_featuretype[anordobs]==1)
      ordobs_obs[anordobs]~ordobs(probfeatures[ordobs_opt1[anordobs],ordobs_trialid[anordobs]],probfeatures[ordobs_opt2[anordobs],ordobs_trialid[anordobs]],1);
    else
      ordobs_obs[anordobs]~ordobs(payfeatures[ordobs_opt1[anordobs],ordobs_trialid[anordobs]],payfeatures[ordobs_opt2[anordobs],ordobs_trialid[anordobs]],2);
  }  
}

generated quantities{
  real optionvalues[3,n_trials];
  int bestoption[n_trials];
  real bestval[n_trials];

  for(atrial in 1:n_trials){
    bestval[atrial] =-1; //better way to init? If default is 0, can use that?
  }
  
  for(atrial in 1:n_trials){
    for(i in 1:3){
      //overall value is product of features. May change to sum or weighted-something?
      optionvalues[i,atrial] = probfeatures[i,atrial] * payfeatures[i,atrial];
      if(optionvalues[i,atrial] > bestval[atrial]){
	bestval[atrial] = optionvalues[i,atrial];
	bestoption[atrial] = i;
      }
    }
  }
}

