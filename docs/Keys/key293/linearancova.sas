* TRAINING KEY 293: Linear ANCOVA;

* INSTRUCTIONS FOR THE USE OF MACRO LINEARANCOVA:

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Activate MACRO LINEARANCOVA (paste from %MACRO statement to %MEND statement and submit).
4) Input in %LINEARANCOVA statement the interaction terms you want to be included in the model. 
   See examples.
5) Call macro %LINEARANCOVA (paste and submit). Check LOG window. Everything went fine?
6) Examine results (Output window). 
7) Select another model.
; 

*EXERCISES:

1) Fit the various models by using the macro and interpret the results.
2) In SUDAAN procedure REGRESS the inferential approach is design-based. However, you may perfrom linear ANCOVA by
   using model-based inferential approach. This is due by SAS procedures GENMOD and MIXED. Please try to fit the linear
   ANCOVA models by using the previously mentioned techniques. Compare the results.;

libname [your libname] "path to Ohc data in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example:  set a.ohc;
run;


%macro Linearancova(m1,m2,m3);
proc regress data=Ohc design=wr deft1;
nest Stratum Cluster;
subgroup Sex;
levels 2;
weight _one_;
model psych=Sex Age Phys Chron &m1 &m2 &m3;
setenv decwidth=4;
print /style=nchs;
output  Beta seBeta t_Beta p_Beta / 
            Betas=All 
            filename=SUDput
            filetype=sas
			replace;
idvar Sex Age Phys Chron;
run;

proc format;
value modelf
1="Intercept"
2="MALES"
3="FEMALES"
4="Age"
5="Chron"
6="Phys"
7="MALES * Age"
8="FEMALES * Age"
9="MALES * Phys"
10="FEMALES * Phys"
11="MALES * Chron"
12="FEMALES * Chron"
; 
run;

proc print data=SUDput(drop=Procnum);
title "Design-based linear ANCOVA on overall psychic strain";
format modelrhs modelf. ;
run;
quit;

%mend;

*SOME EXAMPLE CALLS;

*main effects model;
%Linearancova(,,);

*model with one interaction term;
%Linearancova(Sex*Age,,);

