* TRAINING KEY 293: Linear ANCOVA by SAS/SURVEYREG;

* INSTRUCTIONS FOR THE USE OF LINEARANCOVA BY SURVEYREG:

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Submit PROC SURVEYREG statement. Check LOG window. Everything went fine?
4) Examine results (Output window). 
5) Select another model by adding or removing terms from the model statement if nesessary.
; 

*EXERCISES:

1) Fit the various models by adding and removing model terms and interpret the results.;


libname [your libname] "path to Ohc data in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example:  set a.ohc;
run;

title "Design-based linear ANCOVA on overall psychic strain";
proc surveyreg data=Ohc;
cluster Cluster;
strata Stratum;
class Sex;
model psych=Sex Age Phys Chron sex*age / solution deff;
run;
quit;
