* INSTRUCTIONS for SAS MACRO REG: Sample selection and regression estimation:

  1) Submit first data step and two first proc steps (proc print & proc corr) to see sampling frame
     and population correlations.
  2) Activate the SAS MACRO REG
  3) Insert n = Sample size, default n=8 (you can choose 1<n<32 elements in the Sample
     Insert seed = seed for random number generator, default seed =01234567 to %REG(n,seed)
  4) Activate the line to run the MACRO
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

**CODE 1: Frame Population";
proc print data=Province91;
title1 "Use of auxiliary information in estimation for Simple Random Sample";
title2 "Regression Estimation of Totals";
title3 "TABLE 2.1. Frame Population dataset Province91";
sum UE91 HOU85;
run;

**CODE 2: Population Correlation;
proc corr data=Province91;
title3 "Population correlation of UE91 with HOU85";
var UE91 HOU85;
run;


%MACRO REG(n,seed);

**CODE 3: Sample Selection: SRS sampling;
proc surveyselect data=Province91 out=Sample sampsize=&n method=srs seed=&seed stats;
run;

proc print data=Sample;
title3 "SRS Sample from Province91 population";
title4 "n=&n, seed=&seed";
run;

**CODE 4: Sample Correlation;
proc corr data=Sample;
title3 "Sample correlation of UE91 with HOU85";
title4 "n=&n, seed=&seed";
var UE91 HOU85;
run;

**CODE 5: HT Estimation;
proc surveymeans data=Sample all total=32;
title3 "Reference HT estimation for the total of UE91";
title4 " n=&n, seed=&seed";
var UE91;
weight SamplingWeight;
run;

**CODE 6: Regression Estimation;
proc surveyreg data=Sample total=32;
title3 "Regression estimation for the total of UE91, auxiliary variable HOU85";
title4 " n=&n, seed=&seed";
model UE91=HOU85 / solution;
weight SamplingWeight;
estimate "UE91 Total" Intercept 32 HOU85 91753 / E;
run;

%MEND;

%REG(8,01234567);