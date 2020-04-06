* TRAINING KEY 288: Logistic ANCOVA by SAS/SURVEYLOGISTIC;

* INSTRUCTIONS FOR THE USE OF THIS PIECE OF SAS CODE:

0) This program will fit a logistic ancova model for binary variable PSYCH2 
   in OHC dataset using SEX, AGE, CHRON, PHYS and one interaction term SEX*AGE 
   as model covariates.

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Run the surveylogistic procedure with one interaction term. Check LOG window.
   Everything went fine?
4) Examine results (Output window). 

; 

libname ["your libname"] "path to OHC file in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set ["your libname"].Ohc;
*Example:  set a.ohc;
run;



title1 "OHC Survey data";


proc surveylogistic data=Ohc;
title2 "Logit-ANCOVA / PML estimation / Model terms: Intercept Sex Age Chron Phys Sex*Age";
title3 "SAS / SURVEYLOGISTIC";
strata Stratum;
cluster Cluster;
class Sex / param=reference;
model psych2(event='1')=Sex Age Chron Phys Sex*Age / link=logit rsquare;
ods output Surveylogistic.ParameterEstimates=SASput3;
run;

data SASput3;
set SASput3;
OR=exp(estimate);
LCLOR=exp(estimate-1.96*StdErr);
UCLOR=exp(estimate+1.96*StdErr);
run;

proc print data=SASput3;
run;
