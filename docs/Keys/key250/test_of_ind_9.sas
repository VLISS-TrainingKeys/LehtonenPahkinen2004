/* Reference example 7.3: TEST OF INDEPENDENCE OF PHYS AND PSYCH3 IN OHC SURVEY */


/* Data input [change your own libname and path to the OHC data] */
libname u 'u:\VLISS\datat\';

data Ohc;
set u.Ohc;
run;

/* Design-based test of independence with SAS procedure SURVEYFREQ */
title "Design-based test of independence of PHYS and PSYCH3 in OHC survey";
proc surveyfreq data=ohc;
strata stratum;
cluster cluster;
tables Phys*Psych3 / CHISQ CHISQ1 DEFF LRCHISQ LRCHISQ1 WCHISSQ WLLCHISQ;
run;

/* Model-based test of independence with SAS procedure FREQ */
title "Model-based test of independence of PHYS and PSYCH3"; 
proc freq data=Ohc;
tables Phys*Psych3 / chisq;
run;
