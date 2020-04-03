**Reference example 4.2: Reweighting;
**
(1)
	Uses the Same SRSWOR Sample as in the book is used (use macro parameter book=1 to 
    obtain this). From the study variable UE91 is missing two municipalities (Kuhmoinen and Toivakka).Auxiliary
	information HOU85 and URB85 are used in calculation of Reweights. 

(2)
    Interactive SAS use. Select your own Sample size and variables of interest (use macro parameter book=2). Then 
    look at the obtained results and make the interpretations.
;

data Province91;
input Str Clu Id LABEL $ 10-22 Pop91 LAB91 UE91 HOU85 URB85;
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
*Macro paramaters:
	data 		= Input data
	n 			= Sample size
	seed 		= Seed for the random number generator
	var			= Study variable
	aux			= Auxiliary variable
	book 		= 1 = Use book Sample, 2 = select your own SRSWOR Sample 
;

%MACRO MAC(data, n, seed, var, aux, book);
*Print of data;
proc print data=&data;
title1 "Handling NonSampling Errors";
title2 "Frame Population Province'91 with the Same 5 nonRESPONSE cases";
var Id Label &var &aux RESPONSE;
sum &var &aux;
run;

* Sample selection;
*(1) ****** WIL Sample *****
Uses the Same Sample that is used in the text book;
%if &book=1 %then %do;
data Sample;
set &data;
SamplingWeight=4;
if id=18 or id=30 or id=26 or id=31 or id=15 or id=1 or id=4 or id=5 then output Sample;
run;
%end; 

*(2) ***** Selection of a personal Sample *****
You also can select your own SRSWOR Sample from Province91 Population using the
SURVEYSELECT procedure. By changing the macro parameters (data, var, aux, n and seed) you can
create different Samples. Change only the seed number to compare different Samples of the Same size; 
%if &book=2 %then %do;
proc surveyselect data=&data out=Sample method=SRS n=&n seed=&seed stats;
run;
data Sample;
set Sample;
SamplingWeight=32/&n; *32 Population total!;
run;
%end;

proc sort data=Sample;
by descending RHG descending RESPONSE descending &aux;
run;

proc print data=Sample;
title2 "Selected Sample data set";
var ID LABEL &var &aux RESPONSE RHG SamplingWeight;
sum &aux SamplingWeight;
run;

***************************************************
	Calculation of weights
***************************************************;

proc summary data=Sample;
var &aux;
class RESPONSE RHG;
output out=Summa sum(&aux)=Sum;
run;

proc iml;
edit Summa var{RESPONSE RHG _FREQ_ Sum};
read all into help;

do i=1 to nrow(help);
if (help[i,1]=1 & help[i,2]=.) then Theta_hat=help[i,3]/help[1,3];
else if (help[i,1]=1 & help[i,2]=1) then Theta1_hat=help[i,3]/help[2,3];
else if (help[i,1]=1 & help[i,2]=2) then Theta2_hat=help[i,3]/help[3,3];
if (help[i,1]=1 & help[i,2]=.) then beta=help[1,4]/help[i,4];
end;

create Param var{Theta_hat Theta1_hat Theta2_hat Beta};
append;
close Param;
run;
quit;

data Sample;
if _n_=1 then set Param;
set Sample;
if &var ne . then Rew_HT=(1/Theta_hat)*SamplingWeight;
if &var ne . and RHG=1 then Rew_RHG=(1/Theta1_hat)*SamplingWeight;
if &var ne . and RHG=2 then Rew_RHG=(1/Theta2_hat)*SamplingWeight;
if &var ne . then Rew_RAT=(Beta)*SamplingWeight;  
run;
***************************************************;
*Print of Reweights;

proc print data=Sample;
title2 "Calculated Reweights (HT Reweights, RHG Reweights and Ratio Reweights)";
var Id SamplingWeight Label &var &aux RHG Rew_HT Rew_RHG Rew_RAT;
sum Rew_HT Rew_RHG Rew_RAT;
run;

***************************************************
	Calculation of total Estimates
***************************************************;

proc summary data =Sample ;
var fr;
output out=t_HT mean=Mean std=Std;
run;

data t_HT;
set t_HT;
Pop_n=32;
t_HT=Pop_n*Mean;
Var=Pop_n**2*(1-&n/Pop_n)*Std**2/&n;
Std=sqrt(Var);
run;

data Total_Estimates;
set Sample;
t_HT_r=&var*Rew_HT;
t_RHG=&var*Rew_RHG;
t_Rat=&var*Rew_RAT;
run;

proc summary data=Total_Estimates;
var t_HT_r t_RHG t_Rat;
output out=New (drop=_type_) sum= ;
run;

*****************************************************
* Calculation of auxiliary data
*****************************************************;

proc summary data=Sample; 
where RESPONSE ne 2;
var &var &aux Rew_HT;
class RHG;
output out=Sample_Apu (drop= _type_) mean(&var)=Var_m mean(&aux)=Aux_m std(&var)=Sample_std sum(Rew_ht)=Pop_n;
run;

data Error;
if _n_=1 then set Sample_Apu(keep=Var_m Aux_m);
set Sample;
e_hat=&var-(Var_m/Aux_m)*&aux;
run;
proc summary data=Error ; 
var e_hat;
class RHG;
output out=Sample_Error (drop= _type_) std=Std_e;
run;

*********************************************************
* Calculation of Variance Estimates.
*********************************************************;

data Help;
merge summa Sample_Apu Sample_Error New;
run;

proc iml;
edit help;
read all into Sample;

Pop_N=Sample[1,9];;
n_r=Sample[4,4];
Sample_Std=Sample[1,8];
n=Sample[1,4];
Std_1r=Sample[2,8];
Std_2r=Sample[3,8];
Std_e=Sample[1,10];

do i=1 to nrow(Sample);
if (Sample[i,1]=. & Sample[i,2]=1) then n1=Sample[i,4];
if (Sample[i,1]=. & Sample[i,2]=2) then n2=Sample[i,4];
if (Sample[i,1]=1 & Sample[i,2]=1) then n1_r=Sample[i,4];
if (Sample[i,1]=1 & Sample[i,2]=2) then n2_r=Sample[i,4];
end;
Std_Tot={0,0,0,0,0};
Std_Sam={0,0,0,0,0};
Std_Rew={0,0,0,0,0};
Estimate={0,0,0,0,0};

use t_HT; 
read all into HT;

*Respondent data;
Var_Sam=(Pop_N**2)*(1-n_r/Pop_N)*(Sample_Std**2)/n_r;
Std_Sam[1]=sqrt(Var_Sam);

Var_Rew=0;
Std_Rew[1]=0;

Std_Tot[1]=sqrt(Var_Sam+Var_Rew);

*Rew_HT;
Var_Sam_HT=(Pop_N**2)*(1-n/Pop_N)*(Sample_Std**2)/n;
Std_Sam[2]=sqrt(Var_Sam_HT);

Var_Rew_HT=(Pop_N**2)*(1-n_r/n)*(Sample_Std**2)/n_r;
Std_Rew[2]=sqrt(Var_Rew_HT);

Std_Tot[2]=sqrt(Var_Sam_HT+Var_Rew_HT);

*Rew_RHG;
Var_Sam_RHG=Var_Sam_HT;
Std_Sam[3]=sqrt(Var_Sam_RHG);

Pop_N1=(n1/n)*Pop_N;   *Estimates for the sizes of the corresponding subPopulations;
Pop_N2=(n2/n)*Pop_N;

Var_Rew_RHG=(Pop_N1**2)*(1-n1_r/n1)*Std_1r**2/n1_r + (Pop_N2**2)*(1-n2_r/n2)*Std_2r**2/n2_r;
Std_Rew[3]=sqrt(Var_Rew_RHG);

Std_Tot[3]=sqrt(Var_Sam_RHG+Var_Rew_RHG);

*Rew_RAT;
Var_Sam_Rat=Var_Sam_HT;
Std_Sam[4]=sqrt(Var_Sam_Rat);

Var_Rew_Rat=Pop_N**2*(1-n_r/n)*Std_e**2/n_r;
Std_Rew[4]=sqrt(Var_Rew_Rat);

Std_Tot[4]=sqrt(Var_Sam_Rat+Var_Rew_Rat);

name={Respondent_data, Rew_HT, RHG, Ratio, Full_RESPONSE};
Estimate[1]=Sample[1,11];
Estimate[2]=Sample[1,11];
Estimate[3]=Sample[1,12];
Estimate[4]=Sample[1,13];
Estimate[5]=ht[1,6];
Std_Tot[5]=ht[1,4];
Std_Sam[5]=ht[1,4];
Std_Rew[5]=0;

create All var{name Estimate Std_Tot Std_Sam Std_Rew};
append;
close All;
run;
quit;

proc print data=All;
title2 "Estimates and their standard error components";
run;

%MEND;

data Province91;
set province91;
RESPONSE=1;
if id=18 or id=9 or id=22 or id=21 or id=30 then RESPONSE=2;
fr=UE91;
if RESPONSE = 2 then UE91=.;
RHG=Str;
run;

%MAC(Province91,8,53543,UE91,HOU85,1);