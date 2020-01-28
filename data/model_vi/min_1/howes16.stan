functions{
  real ordobs_lpmf(int obs, real feature1, real feature2){
    //pure howes16: uniform errors.
    real tolerance;
    real errprob;

    real correct;
    real wrong;
    
    tolerance = .1; //placeholder. pass as arg? Vary with featuretype?
    errprob = .01; //placeholder

    correct = log(1-errprob +(1.0/3.0)*errprob);
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

  int ordobs_opt1[n_ordobs];//index what's being observed, then observe it.
  int ordobs_opt2[n_ordobs];
  int ordobs_feature[n_ordobs];
  int ordobs_featuretype[n_ordobs]; //1=base, 2=colorcolor, 3=colorheight, 4=heightheight
  int ordobs_obs[n_ordobs];

  int calcobs_opt[n_calcobs];//index what's being observed, then observe it.
  int calcobs_feature[n_calcobs];
  int calcobs_featuretype[n_calcobs];//1=base, 2=color, 3=height
  real calcobs_obs[n_calcobs];
}

parameters{
  real<lower=0,upper=1> featurevalues[2,3];//row: feature. 1=base, 2=fuel. col: option
}

model{
  //priors on features
  for(afeature in 1:2){
    for(anoption in 1:3){
      featurevalues[afeature,anoption]~uniform(0,1);//prior dist choice is important (particularly for compromise effect, uniform aint it?)
    }
  }

  for(acalcobs in 1:n_calcobs){
    calcobs_obs[acalcobs] ~ calcobs(featurevalues[calcobs_feature[acalcobs],calcobs_opt[acalcobs]], .1); // the .1 is a placeholder noise value. Should be one for each of the feature types? Pass as data?
  }
  for(anordobs in 1:n_ordobs){
    ordobs_obs[anordobs]~ordobs(featurevalues[ordobs_feature[anordobs],ordobs_opt1[anordobs]],featurevalues[ordobs_feature[anordobs],ordobs_opt2[anordobs]]);
  }  
}

generated quantities{
  real optionvalues[3];
  int bestoption;
  real bestval;

  bestval =-1;
  
  for(i in 1:3){
    //overall value is product of features. May change to sum or weighted-sth?
    optionvalues[i] = featurevalues[1,i] * featurevalues[2,i];
    if(optionvalues[i] > bestval){
      bestval = optionvalues[i];
      bestoption = i;
    }
  }
  
}
