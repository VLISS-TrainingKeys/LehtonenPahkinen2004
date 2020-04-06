* TRAINING KEY 288: Logistic ANCOVA;

* INSTRUCTIONS FOR THE USE OF MACRO ANCOVA:

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Activate MACRO ANCOVA (paste from %MACRO statement to %MEND statement and submit).
4) Input in %ANCOVA statement the interaction terms you want to be included in the model. 
   See examples: Full model, reduced model, main effects model.
5) Call macro %ANCOVA (paste and submit). Check LOG window. Everything went fine?
6) Examine results (Output window and Graphics window). 
7) Select another model or close SAS system.
; 

libname ["your libname"] "path to OHC file in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set ["your libname"].Ohc;
*Example:  set a.ohc;
run;

%MACRO ANCOVA(m1,m2,m3);

title1 "OHC Survey data";

proc rlogist data=Ohc design=wr deft1;
title2 "Logit-ANCOVA / PML estimation / Model terms: Intercept Sex Age Chron Phys &m1 &m2 &m3";
title3 "SUDAAN / LOGISTIC";
nest Stratum Cluster;
weight _one_;
subgroup Sex;
levels 2;
model psych2=Sex Age Chron Phys &m1 &m2 &m3;
setenv decwidth=4;
print / style=nchs;
output Expected 
		idvar/
		filename=SUDput3
		filetype=sas;
idvar Sex Age Phys Chron;
run;

proc format;
value Sexf
1="Males"
2="Females"
;
value Phchf
0="0"
1="1"
;
run;

proc sort data=SUDput3;
by Phys Chron;
run;
goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=5 htext=3
		 hsize=15cm vsize=15cm;

symbol1 height=1
		value=dot;
		
proc gplot data=SUDput3 gout=Ancovagr;
plot Expected*Age=Sex/vaxis=0.2 to 0.8 by 0.2 haxis=15 to 65 by 10;
by Phys Chron;
title2 "Logit(PSYCH2)=Intercept Sex Age Chron Phys &m1 &m2 &m3";
format Sex Sexf. Phys Chron phchf.;
run;
quit;

%MEND;

* Example models;

* Full model;
%ANCOVA(Sex*Age,Sex*Phys,Sex*Chron);

* Reduced model;
%ANCOVA(Sex*Age,,);

* Main effects model;
%ANCOVA(,,);


