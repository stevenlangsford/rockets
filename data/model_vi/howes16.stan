functions{
  real ordobs_lpmf(int obs, real feature1, real feature2){
    //pure howes16: uniform errors.
    real tolerance;
    real errprob;

    real correct;
    real wrong;
    
    tolerance = .1; //placeholder. pass as arg? Vary with featuretype?
    errprob = .01; //placeholder

    correct = log(1-errprob); //ignores the times uniform error accidentally returns the correct obs, (1.0/3.0)*errprob: errprob is free param, can eat this wrinkle.
    wrong = log(errprob);
    
    if(fabs(feature1-feature2) < tolerance && obs == 2) return(correct);
    if(feature1<feature2 && obs == 1) return(correct);
    if(feature1>feature2 && obs ==3) return(correct);
    return(wrong);
  }

  real calcobs_lpdf(real obs, real targfeature, real noise){
    //Calcobs normally distributed around truth
    //a little funny to user-defined-fn this, but the rhyme with ordobs is nice.
    return(
	   normal_lpdf(obs | targfeature, noise)
	   );
  }
}
data{//single trial, single ppnt, can extend if working.
  int n_ordobs;
  int n_calcobs;
  int n_trials;

  int ordobs_trialid[n_ordobs];
  int ordobs_opt1[n_ordobs];//index what's being observed, then observe it.
  int ordobs_opt2[n_ordobs];
  int ordobs_feature[n_ordobs];
  int ordobs_featuretype[n_ordobs]; //1=base, 2=colorcolor, 3=colorheight, 4=heightheight
  int ordobs_obs[n_ordobs];

  int calcobs_trialid[n_calcobs];
  int calcobs_opt[n_calcobs];//index what's being observed, then observe it.
  int calcobs_feature[n_calcobs];
  int calcobs_featuretype[n_calcobs];//1=base, 2=color, 3=height
  real calcobs_obs[n_calcobs];
}

parameters{
  //dims: feature(1=base, 2=fuel), option(1:3), trialid(1:n_trials)
  real<lower=0,upper=1> featurevalues[2,3,n_trials];
}

model{
  //priors on features
  for(afeature in 1:2){
    for(anoption in 1:3){
      featurevalues[afeature,anoption]~uniform(0,1);//prior dist choice is important (particularly for compromise effect, uniform aint it?)
    }
  }
  for(acalcobs in 1:n_calcobs){
    calcobs_obs[acalcobs] ~ calcobs(featurevalues[calcobs_feature[acalcobs],calcobs_opt[acalcobs],calcobs_trialid[acalcobs]], .1); // the .1 is a placeholder noise value. Should be one for each of the feature types? Pass as data?
  }
  for(anordobs in 1:n_ordobs){
    ordobs_obs[anordobs]~ordobs(featurevalues[ordobs_feature[anordobs],ordobs_opt1[anordobs],ordobs_trialid[anordobs]],
				featurevalues[ordobs_feature[anordobs],ordobs_opt2[anordobs], ordobs_trialid[anordobs]]
				);
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
      optionvalues[i,atrial] = featurevalues[1,i,atrial] * featurevalues[2,i,atrial];
      if(optionvalues[i,atrial] > bestval[atrial]){
	bestval[atrial] = optionvalues[i,atrial];
	bestoption[atrial] = i;
      }
    }
  }
}
