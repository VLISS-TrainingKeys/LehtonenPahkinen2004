**Reference example 3.13 and interactive SAS use;

**Regression estimation of the total in the Province’91 population. 

(1) Reproduce Example 3.13 results.
	The previously selected SRSWOR sample is used with macro parameter book=1 and the 
	Example 3.13 results are reproduced.  The study variable UE91 is regressed with the 
	auxiliary variable HOU85 and the sample size is n=8. 
	For this SRSWOR design (with constant weights) and the regression model adopted (with an intercept term), 
	a regression estimate of the total of UE91 is obtained by calculating the sum of fitted values 
	over the population. 
	NOTE: This simplification does not hold for cases where the weights vary and/or the model does not include 
	an intercept term. Then, the complete GREG formula (3.32) must be used! 

(2) Generate your personal sample and use variables of your interest.
	Interactive SAS use. Select the sample size and variables of interest for your personal sample 
	by using the macro parameter book=2. Examine the results and compare them with the Example 3.13 results. 
	You can repeat several times this step if desired.
;

data Province91;
input Stratum Cluster Id Municipality $ 10-22 POP91 LAB91 UE91 HOU85 URB85;
datalines;
1  1   1  Jyväskylä    67200 33786  4123 26881	1
1  2   2  Jämsä        12907  6016   666  4663	1
1  2   3  Jämsänkoski   8118  3818   528  3019	1
1  2   4  Keuruu       12707  5919   760  4896	1
1  3   5  Saarijärvi   10774  4930   721  3730	1
1  5   6  Suolahti      6159  3022   457  2389	1
1  3   7  Äänekoski    11595  5823   767  4264	1
2  5   8  Hankasalmi    6080  2594   391  2179	0
2  6   9  Joutsa        4594  2069   194  1823	0
2  7  10  Jyväskmlk    29349 13727  1623  9230	0
2  4  11  Kannonkoski   1919   821   153   726	0
2  4  12  Karstula      5594  2521   341  1868	0
2  8  13  Kinnula       2324   927   129   675	0
2  8  14  Kivijärvi     1972   819   128   634	0
2  3  15  Konginkangas  1636   675   142   556	0
2  5  16  Konnevesi     3453  1557   201  1215	0
2  1  17  Korpilahti    5181  2144   239  1793	0
2  2  18  Kuhmoinen     3357  1448   187  1463	0
2  4  19  Kyyjärvi      1977   831    94   672	0
2  5  20  Laukaa       16042  7218   874  4952	0
2  6  21  Leivonmäki    1370   573    61   545	0
2  6  22  Luhanka       1153   522    54   435	0
2  7  23  Multia        2375  1059   119   925	0
2  1  24  Muurame       6830  3024   296  1853	0
2  7  25  Petäjävesi    3800  1737   262  1352	0
2  8  26  Pihtipudas    5654  2543   331  1946	0
2  4  27  Pylkönmäki    1266   545    98   473	0
2  3  28  Sumiainen     1426   617    79   485	0
2  1  29  Säynätsalo    3628  1615   166  1226	0
2  6  30  Toivakka      2499  1084   127   834	0
2  7  31  Uurainen      3004  1330   219   932	0
2  8  32  Viitasaari    8641  4011   568  3119	0
;
run;
/*
Macro reg parameters:
	data = Input data
	var  = Study variable
	aux  = Auxiliary variable
	n    = Sample size
	seed = Seed for the random number generator
	book = 1 = Use book sample, 2 = select your own SRSWOR sample  
*/

%macro reg(data, var, aux, n, seed, book);

data Population(keep=Id Municipality y z);
set &data;
y= &var;
z= &aux;
run;

proc print data=Population;
title1 "Regression estimation under SRSWOR for Province’91 Population";
title2 "Study variable y=&var";
title3 "Auxiliary variable z=&aux";
title4 "Frame population Province'91 data set";
var Id Municipality y z;
sum y z;
run;

* Sample selection;
*(1) ****** WIL Sample *****
Uses the same sample that is used in the text book;
%if &book=1 %then %do;
data Sample&book(keep=Id Municipality y z SamplingWeight);
set Population;
SamplingWeight=4;
if id=1 or id=4 or id=5 or id=15 or id=18 or id=26 or id=30 or id=31 then output Sample&book;
run;
%end;

*(2) ***** Selection of a personal Sample *****
You also can select your own SRSWOR Sample from Province91 Population using the
SURVEYSELECT procedure. By changing the macro parameters (data, var, aux, n and seed) you can
create different samples. Change only the seed number to compare different samples of the same size; 
%if &book=2 %then %do;
proc surveyselect data=Population out=Sample&book(keep=Id Municipality y z SamplingWeight) 
	method=srs sampsize=&n stats seed=&seed; 
run;
%end;

data Sample;
set Sample&book;
run;

proc print data=Sample;
title2 "Study variable y=&var";
title3 "Auxiliary variable z=&aux";
%if &book=1 %then %do; title4 "The same SRSWOR sample that is used in the text book (n=8)";%end;
%if &book=2 %then %do; title4 "Sample selected with surveyselect procedure (n=&n)";%end;
sum SamplingWeight;
run;

* Creation of macro parameters Int and Reg for the surveyreg and surveymeans procedures;
**********************************************************************;
proc summary data=Population;
var z;
output out=Reg_par (rename=_FREQ_=N) sum(z)=z_Sum;
run;

data Sample;
if _n_=1 then set Reg_par;
set Sample;
call symput('Int',N);
call symput('Reg',z_Sum);
run;
**********************************************************************;

* NOTE:
This piece of SURVEYMEANS code is adjusted for SAS Version 9.1 (and
later). For Version 8.2 (and earlier) an error message will appear because
of the STACKING option! If you are using SAS version 8.2 or earlier please 
remove the STACKING parameter and the code should work correctly.
;

* HT Estimation of totals for y and z;
proc surveymeans data=Sample stacking all total=&Int;
title4 "HT estimation with SURVEYMEANS";
			var y z ;
            weight SamplingWeight;
			* Variables to be kept in out stats data set;
            ods output statistics=Stats(keep=y_Sum y_Varsum z_Sum); 
run;

* HT estimates of totals of y and z and variance and s.e. for y estimate;
data Stats;
set Stats;
rename 
	y_Sum    = y_HT
	y_Varsum = y_HT_var	
	z_Sum   = z_HT
	;
y_HT_se=sqrt(y_Varsum);
run;

proc print data=Stats;
title4 "HT estimates of totals of y and z and variance and s.e. for y estimate";
var y_HT y_HT_var y_HT_se z_HT;
run;

* Linear Multiple Regression Model / SURVEYREG;
proc surveyreg data=Sample total=&Int;
title4 "Regression estimation with SURVEYREG";
			weight SamplingWeight;
			model y=z /solution;
			* Regression estimation of total of y;
			estimate "y total" Intercept &Int z &Reg /E;	
  			ods output
			ParameterEstimates=Reg_stats(keep=Parameter Estimate)
			FitStatistics=Fit_stats(keep=Label1 nValue1) 
			;
run;

data Reg_b0 Reg_b1;
			set Reg_stats;
			if Parameter="Intercept" then output Reg_b0;
			else if Parameter="z" then output Reg_b1;
run;
data Reg_b0(keep=b0);
			set Reg_b0;
			rename Estimate=b0;
run;
data Reg_b1(keep=b1);
			set Reg_b1;
			rename Estimate=b1;
run;
data R_square;
			set Fit_stats;
			if Label1="R-square" then output R_square;
run;
data R_square(keep=R2);
			set R_square;
			rename nValue1=R2;
run;

* Population level;
data Population(drop=b0 b1);
if _n_ =1 then merge Reg_b0 Reg_b1;
set Population;
* Calculation of fitted y-values for all population elements;
yhat = b0 + b1*z;
run;

* NOTE:
This piece of SURVEYMEANS code is adjusted for SAS Version 9.1 (and
later). For Version 8.2 (and earlier) an error message will appear because
of the STACKING option! If you are using SAS version 8.2 or earlier please 
remove the STACKING parameter and the code should work correctly.
;
proc surveymeans data=Population stacking all;
title4 "Intermediate calculation / Data Stats_Pop";
			var y z yhat;
			ods output statistics=Stats_pop(keep=y_n y_Sum z_Sum yhat_Sum);
run;

proc summary data=Population nway;
var z;
output out=Resp(drop=_type_ _freq_) 
			mean(z)= z_Mean  
			css(z) = z_css
;
run;

data Stats_pop;
			merge Stats_pop Resp;
			rename
			y_n      = Pop_y_n
			y_Sum    = Pop_y_Sum
			z_Sum   = Pop_z_Sum
			z_Mean  = Pop_z_Mean
			yhat_Sum = Pop_yhat_Sum
			z_css   = Pop_z_css
;
run;
proc print data=Stats_pop;
title4 "Intermediate calculation / Data Stats_pop";
run;

* Sample revisited;
proc summary data=Sample nway;
var z;
output out=Res(drop=_type_ _freq_) 
			sum(z) = z_Sum
			mean(z)= z_Mean  
			css(z) = z_css
;
run;
proc print data=Res;
title4 "Intermediate calculation / Data Res";
run;

data Sample; 
if _n_=1 then merge Reg_b0 Reg_b1 Res Stats_pop;
set Sample;

* Calculation of fitted y-values for Sample elements;
yhat = b0 + b1*z;
* Calculation of residuals for Sample elements;
e    = y - yhat;
* Calculation of g-weights for Sample elements;
g = 1+(Pop_z_Mean-z_Mean)/((&n-1)/&n*z_css/(&n-1))*(z-z_Mean);
* Calculation of g-weighted residuals for Sample elements;
e_g  = e*g;
* Calculation of weighted residuals for Sample elements;
res = SamplingWeight*e;
run;

proc summary data=Sample nway;
* Calculation of HT estimate of the total of residuals 
and variance estimate of g-weighted residuals;
output out=Resid(drop=_type_ _freq_) 
			sum(res)= Res_Sum
			var(e_g)= Var_e_g
;
run;
proc print data=Resid;
title4 "Intermediate calculation / Data Resid";
run;

data Population;
merge Population(drop=y) Sample(keep=Id y SamplingWeight e g e_g);
by Id;
run;

proc print data=Population;
title4 "e = y - yhat";
title5 "g = 1 + (Pop_z_Mean-z_Mean)/((&n-1)/&n*z_css/(&n-1))*(z-z_Mean)";
title6 "e_g = e * g ";
var Id Municipality z yhat SamplingWeight y e g e_g; 
sum z yhat SamplingWeight e g;
run;

* Calculation of two variants of GREG estimate and variance estimate;
data Statsx;
		merge Stats_Pop Resid Stats Reg_b1;

		* Regression estimation of the total of y using Formula (3.27);
		y_Greg     = y_HT + b1*(Pop_z_Sum-z_HT);

		* Regression estimation of the total of y using Formula (3.32);
		y_Greg2    = Pop_yhat_Sum + Res_Sum;		

		* Variance estimate using Formula (3.29);
		y_Greg_var = Pop_y_n**2 * (1-&n/Pop_y_n) * 1/&n * (&n-1)/(&n-2) * Var_e_g; 
		y_Greg_se  = sqrt(y_Greg_var); 
run;

proc print data=Statsx;
title4 "Regression estimates and standard error";
var Pop_y_N y_Greg y_Greg2 y_Greg_var y_Greg_se;
run;

%mend;


* Reproduce Example 3.13 results;
%reg(Province91, UE91, HOU85, 8,, 1);

* Select your personal sample and variables of interest;
%reg(Province91, UE91, URB85, 10, 98765432, 2);
