**Reference example 3.13 (Two auxiliary variables (HOU85 and URB85));

**Multiple regression estimation of the total in the Province�91 population. The study variable UE91 is 
regressed with two auxiliary variables, HOU85 and URB85 (value 1 for urban municipalities and zero for rural 
municipalities). Calculation of the regression estimated total by summing up the fitted values over the population;

data Province91;
input Stratum Cluster Id Municipality $ 10-22 POP91 LAB91 UE91 HOU85 URB85;
datalines;
1  1   1  Jyv�skyl�    67200 33786  4123 26881	1
1  2   2  J�ms�        12907  6016   666  4663	1
1  2   3  J�ms�nkoski   8118  3818   528  3019	1
1  2   4  Keuruu       12707  5919   760  4896	1
1  3   5  Saarij�rvi   10774  4930   721  3730	1
1  5   6  Suolahti      6159  3022   457  2389	1
1  3   7  ��nekoski    11595  5823   767  4264	1
2  5   8  Hankasalmi    6080  2594   391  2179	0
2  6   9  Joutsa        4594  2069   194  1823	0
2  7  10  Jyv�skmlk    29349 13727  1623  9230	0
2  4  11  Kannonkoski   1919   821   153   726	0
2  4  12  Karstula      5594  2521   341  1868	0
2  8  13  Kinnula       2324   927   129   675	0
2  8  14  Kivij�rvi     1972   819   128   634	0
2  3  15  Konginkangas  1636   675   142   556	0
2  5  16  Konnevesi     3453  1557   201  1215	0
2  1  17  Korpilahti    5181  2144   239  1793	0
2  2  18  Kuhmoinen     3357  1448   187  1463	0
2  4  19  Kyyj�rvi      1977   831    94   672	0
2  5  20  Laukaa       16042  7218   874  4952	0
2  6  21  Leivonm�ki    1370   573    61   545	0
2  6  22  Luhanka       1153   522    54   435	0
2  7  23  Multia        2375  1059   119   925	0
2  1  24  Muurame       6830  3024   296  1853	0
2  7  25  Pet�j�vesi    3800  1737   262  1352	0
2  8  26  Pihtipudas    5654  2543   331  1946	0
2  4  27  Pylk�nm�ki    1266   545    98   473	0
2  3  28  Sumiainen     1426   617    79   485	0
2  1  29  S�yn�tsalo    3628  1615   166  1226	0
2  6  30  Toivakka      2499  1084   127   834	0
2  7  31  Uurainen      3004  1330   219   932	0
2  8  32  Viitasaari    8641  4011   568  3119	0
;
run;

proc print data=Province91;
title1 "Regression Estimation of Totals with fitted values";
title2 "TABLE 2.1. Frame Population dataset Province91";
sum UE91 HOU85 URB85;
run;

data Sample;
set Province91;
SamplingWeight=4;
if id=1 or id=4 or id=5 or id=15 or id=18 or id=26 or id=30 or id=31 then output Sample;
run;

proc print data=Sample;
title2 "Selected sample data set";
sum SamplingWeight;
run;

proc surveyreg data=Sample total=32;
title2 "Estimated Regression Coefficients";
			weight SamplingWeight;
			model UE91=HOU85 URB85 /solution;
  			ods output
			ParameterEstimates=Reg_stats(keep=Parameter Estimate)
			FitStatistics=Fit_stats(keep=Label1 nValue1) 
			;
run;

data Reg_b0 Reg_b1 Reg_b2;
			set Reg_stats;
			if parameter="Intercept" then output Reg_b0;
			else if parameter="HOU85" then output Reg_b1;
			else if parameter="URB85" then output Reg_b2;
run;

data Reg_b0(keep=b0);
			set Reg_b0;
			rename Estimate=b0;
run;
data Reg_b1(keep=b1);
			set Reg_b1;
			rename Estimate=b1;
run;
data Reg_b2(keep=b2);
			set Reg_b2;
			rename Estimate=b2;
run;
data r_square;
			set Fit_stats;
			if Label1="R-square" then output r_square;
run;
data r_square(keep=r2);
			set r_square;
			rename nValue1=r2;
run;

data Fitted;
if _n_ =1 then merge Reg_b0 Reg_b1 Reg_b2;
set Province91;
UE91hat = b0 + b1*HOU85 + b2*URB85;  *fitted values to every municipality;
run;

proc print data=Fitted;
title2 "The sum of the fitted values over the population provides the desired regression estimate"; 
var UE91hat; 
sum UE91hat;
run;
