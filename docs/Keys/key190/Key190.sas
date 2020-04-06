**Reference Example 6.1;
** HT estimation of Domain Totals for Planned and UnPlanned Domains.
Problems may be encountered when working with an UnPlanned Domain structure, because 
small Domain samples can be obtained for Domains with a small Population size, if the overall 
sample size is not large, involving imprecise estimation;


libname a "u:\VLISS\datat\";

data Sae;
set a.Saem;
run;

/*
* Exploratory analysis;

proc Means data=Sae n sum Mean Std;
Var Chron;
*class Domain;
run;
*/

%MACRO MAC(n);

title1 "Chapter 6 / Example 6.1";
title2 "Horvitz-Thompson estimation for Domain Totals of Chron";
title3 "UnPlanned Domains (SRSWOR) and Planned Domains (STRWOR_POWER)";
title4 "Overall sample size n=&n";

proc summary data=Sae nway;
Var Chron;
class Domain;
output out=Sae2(drop=_type_ rename=(_freq_=n_Pop)) sum=t_Chron Mean=Mean_Chron Std=Std_Chron;
run;

proc sort data=Sae2;
by n_Pop;
run;

proc summary data=Sae;
output out=n_Tot(rename=(_FREQ_=n_Tot));
run;

* n_UnPlanned Calculation;

data Sae2;
if _n_=1 then set n_Tot;
set Sae2;
if Domain ne . then do;
	n_UnPlanned = &n*(n_Pop/n_Tot);
	cv_Chron=Std_Chron/Mean_Chron;
	end;
run;

proc summary data=Sae2;
Var cv_Chron;
output out=cv sum=cv_Tot;
run;

* n_Planned Calculation;

data Sad;
if _n_=1 then set cv(keep=cv_Tot);
set Sae2 ;
n_Planned=&n*cv_Chron/cv_Tot;
run;

**********************************************************
 Calculation of Coefficients of Variation
**********************************************************;

data Var;
set Sad;

pd = n_Pop/n_Tot;
qd = 1-pd;

* Planned Domains (STRWOR_POWER);
Var_Planned = n_Pop**2*(1-n_Planned/n_Pop)*(1/n_Planned)*Std_Chron**2;  
se_Planned  = sqrt(Var_Planned);
cv_Planned  = se_Planned/t_Chron;

* UnPlanned Domains (SRSWOR);
Var_UnPlanned = n_Tot**2*(1-&n/n_Tot)*(1/&n)*pd*Std_Chron**2*(1+qd/cv_Chron**2);
se_UnPlanned  = sqrt(Var_UnPlanned);
cv_UnPlanned  = se_UnPlanned/t_Chron;

* UnPlanned Domains (SRSWOR) / Conservative approximation;
Var2_UnPlanned = n_Pop**2/n_UnPlanned*Std_Chron**2*(1+qd/cv_Chron**2);
se2_UnPlanned  = sqrt(Var2_UnPlanned);
cv2_UnPlanned  = se2_UnPlanned/t_Chron;

run;

**********************************
  Print of results
**********************************;

proc print data=Sad;
Var Domain n_Pop t_Chron n_UnPlanned n_Planned;
sum n_Pop t_Chron n_UnPlanned n_Planned;
format _numeric_ 5.0
	n_UnPlanned n_Planned 5.0;
run;

proc print data =Var;
Var Domain cv_Planned se_Planned cv_UnPlanned se_UnPlanned;
run;

proc print data =Var;
Var Domain n_UnPlanned n_Planned cv2_UnPlanned se2_UnPlanned;
sum n_UnPlanned n_Planned;
run;

* Grafiikka;

goptions reset=global gunit=pct cback=white
	ctext=black colors=(blue red green)
	hsize=25cm vsize=25cm htitle=3 htext=2
	interpol=join
;

legend1 label=none
	shape=symbol(4,2)
	position=(top center inside)
	mode=share;

symbol1 
	cv=blue
	width=6;
symbol2 
	cv=red
	width=6;

symbol3
	cv=green
	width=6;

proc gplot data=Var;
	plot cv_Planned * n_Pop
	cv_UnPlanned * n_Pop cv2_UnPlanned *n_Pop /overlay vaxis= 0 to 1.2 by .1 haxis=80 to 520 by 20 legend=legend1;

title1 "Chapter 6 / Example 6.1";
title2 "Horvitz-Thompson estimation for Domain Totals of Chron";
title3 "UnPlanned Domains (SRSWOR) and Planned Domains (STRWOR_POWER)";
title4 " Coefficients of Variation of HT estimates";
title5 "Overall sample size n=&n";

run;
quit;

%MEND;



* Default sample size n = 392;

%MAC(392); 

* NOTE: You can invoke the macro with different overall sample sizes (see FURTHER TRAINING);

********************************************************************************************************

FURTHER TRAINING

(a)
Please make trials with different sample sizes and examine the change in coefficients of Variation (C.V)
for both Planned and UnPlanned cases. Choices are e.g. n = 200, n = 1000, n = 2000 and n = 2500. 
Study both the numerical results and the graphs. What are your conclusions?

(b)
Please examine in more detail the results for the Planned Domain case for n = 3000 or larger. 
You will find out that in the Planned Domains case, C.V:s are not displayed for a number of Domains. 
Why this happens?

(c)
Further, what might be the largest possible sample size n for which C.V:s for all Domains are obtained?

Hint for (b) and (c): 
Examine the increase in Domain sample sizes relative to the sizes of Domains in the Population 
when increasing the overall sample size n.

*******************************************************************************************************;
