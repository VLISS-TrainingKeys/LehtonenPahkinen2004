/* Reference example 7.3: TEST OF INDEPENDENCE OF PHYS AND PSYCH3 IN OHC SURVEY */

/* Data input */
libname [your libname] 'path to OHC data in your computer';

data Ohc;
set [your libname].Ohc;
run;

/* Design-based test of independence with SUDAAN procedure CROSSTAB */
proc crosstab data=Ohc design=wr;
nest Stratum Cluster;
weight _one_;
recode Phys=(0,1);
subgroup Phys Psych3;
levels 2 3;
tables Phys*Psych3;
test llchisq;
run;

/* Model-based test of independence with SAS procedure FREQ */
proc freq data=Ohc;
tables Phys*Psych3 / chisq;
run;


