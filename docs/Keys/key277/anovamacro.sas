* TRAINING KEY 277: Logistic ANOVA with the PML method;

* INSTRUCTIONS FOR THE USE OF MACRO ANOVA:

0) In the macro we use SAS-callable SUDAAN procedure RLOGIST and to work properly
   it needs SUDAAN version 9 to be installed on your computer.

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to Ohc data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
3) Activate MACRO ANOVA (paste from %MACRO statement to %MEND statement and submit).
4) Input in %ANOVA statement the interaction terms you want to be included in the model. 
   See examples: Full model, several reduced models, main effects model.
5) Call macro %ANOVA (paste and submit). Check LOG window. Everything went fine?
6) Examine results (Output window and Graphics window). 
7) Select another model or close SAS system.
; 

libname [your libname] "path to Ohc data folder";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example:  set a.ohc;
run;

%MACRO ANOVA(m1,m2,m3,m4);

title1 "Ohc Survey data";

/* SAS-Callable SUDAAN Procedure RLOGIST */
proc rlogist data=Ohc design=wr deft1 r=independent;
title2 "Logit-ANOVA / PML-estimation / Model terms: Intercept Sex Age2 Phys &m1 &m2 &m3 &m4";
title3 "SUDAAN / LOGISTIC";
nest Stratum Cluster;
weight _one_;
class Sex Age2 Phys;
model Psych2=Sex Age2 Phys &m1 &m2 &m3 &m4;
reflevel Sex=1 Age2=1 Phys=0;
setenv decwidth=4;
print / style=nchs;
output expected idvar / filename=SUDput3 filetype=sas replace;
idvar Sex Age2 Phys;
run;

proc format;
value Sexf
1="Males"
2="Females"
;
value Age2f
1="-44"
2="45-"
;
run;

proc sort data=SUDput3;
by Phys; 
run;

data SUDput3;
set SUDput3;
if Sex=1 then do;
Sex1=expected;
label Sex1="Males";
end;
if Sex=2 then do;
Sex2=expected;
label Sex2="Females";
end;


goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=8 htext=4
		 hsize=7cm vsize=7cm
		 i=join;

proc gplot data=SUDput3 gout=sasgraph;
title2 "Logit(PSYCH2)=Intercept Sex Age2 Phys &m1 &m2 &m3 &m4";
plot (Sex1 Sex2)*Age2=Phys / vaxis=0.3 to 0.8 by 0.1 haxis=1 to 2 by 1;
format Sex Sexf. Age2 Age2f.;
run;
quit;

%MEND;

*EXAMPLE MODELS;

* Full model;
%ANOVA(Sex*Age2,Sex*Phys,Age2*Phys,Sex*Age2*Phys);

*Reduced model 1;
%ANOVA(Sex*Age2,Sex*Phys,Age2*Phys,);

*Reduced model 2;
%ANOVA(Sex*Phys,Age2*Phys,,);

*Reduced model 3;

%ANOVA(Sex*Phys,,,);

* Main effects model;

%ANOVA(,,,);


