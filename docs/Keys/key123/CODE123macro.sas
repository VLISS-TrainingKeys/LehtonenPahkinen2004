**Reference example 4.3: Single Imputation;
**
(1)
	  Uses the Same SRSWOR Sample as in the book is used (use macro parameter book=1 to 
      obtain this). From the study variable UE91 is missing two municipalities (Kuhmoinen and Toivakka).Auxiliary
      infoRmation HOU85 with no missing values is used in calculation of Imputed values.
	  Notice that n must be set to 8 to obtain right variance estimation Results.

(2)
      Interactive SAS use. Select your own Sample size and variables of inteRest (use macro parameter book=2). Then 
      look at the obtained Results and make the interpretations.
;

data Province91;
input Stratum Cluster Id Municipality $ 10-22 Pop91 LAB91 UE91 HOU85 URB85;
datalines;
1  1   1  Jyväskylä    67200 33786  4123 26881  1
1  2   2  Jämsä        12907  6016   666  4663  1
1  2   3  Jämsänkoski   8118  3818   528  3019  1
1  2   4  Keuruu       12707  5919   760  4896  1
1  3   5  Saarijärvi   10774  4930   721  3730  1
1  5   6  Suolahti      6159  3022   457  2389  1
1  3   7  Äänekoski    11595  5823   767  4264  1
2  5   8  Hankasalmi    6080  2594   391  2179  0
2  6   9  Joutsa        4594  2069   194  1823  0
2  7  10  Jyväskmlk    29349 13727  1623  9230  0
2  4  11  Kannonkoski   1919   821   153   726  0
2  4  12  Karstula      5594  2521   341  1868  0
2  8  13  Kinnula       2324   927   129   675  0
2  8  14  Kivijärvi     1972   819   128   634  0
2  3  15  Konginkangas  1636   675   142   556  0
2  5  16  Konnevesi     3453  1557   201  1215  0
2  1  17  Korpilahti    5181  2144   239  1793  0
2  2  18  Kuhmoinen     3357  1448   187  1463  0
2  4  19  Kyyjärvi      1977   831    94   672  0
2  5  20  Laukaa       16042  7218   874  4952  0
2  6  21  Leivonmäki    1370   573    61   545  0
2  6  22  Luhanka       1153   522    54   435  0
2  7  23  Multia        2375  1059   119   925  0
2  1  24  Muurame       6830  3024   296  1853  0
2  7  25  Petäjävesi    3800  1737   262  1352  0
2  8  26  Pihtipudas    5654  2543   331  1946  0
2  4  27  Pylkönmäki    1266   545    98   473  0
2  3  28  Sumiainen     1426   617    79   485  0
2  1  29  Säynätsalo    3628  1615   166  1226  0
2  6  30  Toivakka      2499  1084   127   834  0
2  7  31  Uurainen      3004  1330   219   932  0
2  8  32  Viitasaari    8641  4011   568  3119  0
;
run;
data Province91;
set Province91;
Res_Pop=1;
if id=18 or id=9 or id=22 or id=21 or id=30 then Res_Pop=2;
run;

/*
Use this macro to calculate Mean Imputation, Nearest neighbour and Ratio Impitation
values for a SRSWOR Sample. Macro parameters: data is the data user wants to Imputate,
n is the Sample size, seed is seed number, var is the variable with missing value(s),
aux is the auxiliary variable to calculate Imputation values.
*/
%macro rew(data, n, seed, var, aux, book);

proc print data=&data;
title1 "Handling NonSampling Errors";
title2 "Frame Population Province'91 data set";
sum &var &aux;
run;

* Sample selection;
*(1) ****** WIL Sample *****
Uses the Same Sample that is used in the text book;
%if &book=1 %then %do;
data Sample;
set &data;
if id=18 or id=30 or id=26 or id=31 or id=15 or id=1 or id=4 or id=5 then output Sample;
run;
%end; 

*(2) ***** Selection of a personal Sample *****
You also can select your own SRSWOR Sample From Province91 Population using the
SURVEYSELECT procedure. By changing the macro parameters (data, var, aux, n and seed) you can
create different Samples. Change only the seed number to compare different Samples of the Same size; 
%if &book=2 %then %do;
proc surveyselect data=&data out=Sample method=SRS n=&n seed=&seed stats;
title2 "Select of Sample with survey select procedure";
run;
%end;
/*
proc surveyselect data=&data out=Sample n=&n method=SRS seed=&seed;
run;*/

data Sample;
set Sample;
RHG=Stratum;
Full_Resp=&var;
if Res_Pop=2 then &var=.;
Mean_Imp=&var;
Nearest_n=&var;
Ratio=&var;
run;

proc sort data=Sample;
by descending Res_Pop ;
run;
proc print data=Sample;
title2 "Selected Sample data set";
var Id Municipality &var &aux;
sum &aux;
run;

* Mean Imputation values;
proc summary data=Sample;
where Res_Pop ne 2;
var &var;
output out=Mean_Imp (drop= _type_) Mean=Mean_i ;
run;

data Sample;
if _n_=1 then set Mean_Imp;
set Sample;
if Mean_Imp=. then Mean_Imp=Mean_i;
run;

* Ratio Imputation;

proc summary data = Sample;
where &var ne .;
var &var &aux;
output out=Res_Mean (drop= _type_) Mean=;
run; 
data Res_Ratio;
set Res_Mean;
r=&var/&aux;
run;
data Sample;
if _n_=1 then set Res_Ratio (keep=r);
set Sample;
if &var=. then Ratio=r*HOU85;
run;

* Nearest neighbour;

data Sample;
set Sample;
apu=.;
run;

proc iml;
edit Sample var{id &var &aux apu Res_Pop};
read all into Sample;

do i=1 to nrow(Sample);
if Sample[i,4] = . then do; 
	apu=Sample[i,3];
	dist=0;
	index=0;
	do j=1 to nrow(Sample);
		if( (Sample[j,2]^=.) & (abs(apu-Sample[j,3]) < dist | dist=0) & (i ^= j)  ) then do; 
			dist=abs(apu-Sample[j,3]); 
			index=j; 
			end;		
	end;
	find next where(apu={.}) into d;
	apu=Sample[index,2];
	replace;
end;	
end;
run;
quit;

data Sample;
set Sample;
if Nearest_n=. then Nearest_n=apu;
run;

proc print data=Sample;
title2 "Imputed data set";
var Id Municipality &var &aux Mean_Imp Nearest_n Ratio Full_Resp;
run;

*************************************
 Variance Estimation
*************************************;
proc summary data=Sample; 
where UE91 ne .;
var UE91 HOU85;
output out=Sample_m (drop= _type_) Mean(UE91)=UE91_m Mean(HOU85)=HOU85_m;
run;

proc summary data=Sample; 
var Full_Resp Mean_Imp Nearest_n Ratio;
output out=Mean_1 (drop= _type_) Mean(Ratio)=mRatio Mean(Full_Resp)=Fr_m Std(Full_Resp)=Fr_Std Mean(Nearest_n)=nn_m Mean(Mean_Imp)=Rm_m;
run;

data Error;
if _n_=1 then set Sample_m(keep=UE91_m HOU85_m);
set Sample;
where UE91 ne .;
e_hat1=UE91-UE91_m;
e_hat2=UE91-apu;
e_hat3=UE91-(UE91_m/HOU85_m)*HOU85;
run;
proc summary data=Error ; 
var  e_hat1 e_hat2 e_hat3;
output out=Sample_Error (drop= _type_) Std(e_hat1)=Std_e1 Std(e_hat2)=Std_e2 Std(e_hat3)=Std_e3;
run;

data Var;
merge Sample_Error Mean_1(keep=nn_m Rm_m mRatio);
Pop_N=32;
n_r=_FREQ_;
n=&n;

Var_Sam=Pop_N**2*(1-n/Pop_N)*Std_e1**2/n;
Std_Sam=sqrt(Var_Sam);
run;

data Rm;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e1**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=Rm_m*Pop_N;

run;

data Nn;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e2**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=Nn_m*Pop_N;
run;

data Ra;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e3**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=mRatio*Pop_N;
run;

data Rd;
set Var;
Estimate=Rm_m*Pop_N;
Std_Imp=0;
Var_Sam=Pop_N**2*(1-n_r/Pop_N)*Std_e1**2/n_r;
Std_Sam=sqrt(Var_Sam);
Std_Tot=Std_Sam;
run;

data Fr;
set Mean_1(keep=Fr_m Fr_Std);
Std_Tot=sqrt(32**2*(1-&n/32)*(1/&n)*Fr_Std**2);
Std_Sam=Std_Tot;
Std_Imp=0;
Estimate=Fr_m*32;
run;

data All;
set Rd Rm Nn Ra Fr;
run;

proc print data=All;
title2 "Total Estimates and their corResponding standard Error components";
var Estimate Std_Tot Std_Sam Std_Imp; 
run;

%mend;

%rew(Province91,8,98765432,UE91,HOU85,2);

