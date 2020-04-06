* TRAINING KEY 277 Part A: Logit ANOVA with SAS SURVEYLOGISTIC;

* INSTRUCTIONS FOR THE USE OF THIS PIECE OF SAS PROGRAM:

0) This program will fit a main effects logit ANOVA model in the Ohc survey 
   setting using SAS procedure SURVEYLOGISTIC. It will need SAS version 9 to 
   work properly.

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to Ohc data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Activate and run the SURVEYLOGISTIC procedure, the DATA STEP and the PRINT procedure.
   Check LOG window. Everything went fine?
4) Examine results (Output window). 
; 

libname [your libname] "path to Ohc data folder";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example:  set a.ohc;
run;

proc surveylogistic data=Ohc;
title2 "Logit-ANOVA / PML-estimation / Model terms: Intercept Sex Age2 Phys";
title3 "SAS / SURVEYLOGISTIC";
class Sex Age2 Phys / param=reference ref=first;
strata Stratum;
cluster Cluster;
model Psych2(event='1')=Sex Age2 Phys / link=logit rsquare;
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

