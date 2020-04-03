**Reference example 2.6: Estimation under systematic PPS sampling;

**A Sample of eight (n=8) municipalities is drawn with systematic PPS sampling from 
the Province'91 population such that the number of households (HOU85) is used as the 
size measure z;

**Under systematic PPS sampling the sampling interval would be q=91753/8=11469. However, the largest 
element 'Jyvaskyla' has the value 26881 for the variable, which is more than twice the sampling interval. 
Therefore, the element would be drawn twice and the remaining 6 elements would be drawn from the remaining 
population elements. In this case, therefore, we first take the largest element 'Jyväskylä' with certainty 
and then draw 7 elements from the remaining population elements by systematic PPS sampling;

**PPSSYS estimate and the corresponding standard error estimate are calculated from the selected Sample. 
The results are compared to estimation under SRSWOR sampling;

data Province91;
input STR CLU ID LABEL $ 10-22 POP91 LAB91 UE91 HOU85;
datalines;
1  1   1  Jyvaskyla    67200 33786  4123 26881
1  2   2  Jamsa        12907  6016   666  4663
1  2   3  Jamsankoski   8118  3818   528  3019
1  2   4  Keuruu       12707  5919   760  4896
1  3   5  Saarijarvi   10774  4930   721  3730
1  5   6  Suolahti      6159  3022   457  2389
1  3   7  Aanekoski    11595  5823   767  4264
2  5   8  Hankasalmi    6080  2594   391  2179
2  6   9  Joutsa        4594  2069   194  1823
2  7  10  Jyvaskmlk    29349 13727  1623  9230
2  4  11  Kannonkoski   1919   821   153   726
2  4  12  Karstula      5594  2521   341  1868
2  8  13  Kinnula       2324   927   129   675
2  8  14  Kivijarvi     1972   819   128   634
2  3  15  Konginkangas  1636   675   142   556
2  5  16  Konnevesi     3453  1557   201  1215
2  1  17  Korpilahti    5181  2144   239  1793
2  2  18  Kuhmoinen     3357  1448   187  1463
2  4  19  Kyyjarvi      1977   831    94   672
2  5  20  Laukaa       16042  7218   874  4952
2  6  21  Leivonmaki    1370   573    61   545
2  6  22  Luhanka       1153   522    54   435
2  7  23  Multia        2375  1059   119   925
2  1  24  Muurame       6830  3024   296  1853
2  7  25  Petajavesi    3800  1737   262  1352
2  8  26  Pihtipudas    5654  2543   331  1946
2  4  27  Pylkonmaki    1266   545    98   473
2  3  28  Sumiainen     1426   617    79   485
2  1  29  Saynatsalo    3628  1615   166  1226
2  6  30  Toivakka      2499  1084   127   834
2  7  31  Uurainen      3004  1330   219   932
2  8  32  Viitasaari    8641  4011   568  3119
;
run; 
title1 "Estimation under systematic PPS sampling";
title2 "Province'91 data set";

data Province91;
set Province91;
Jystrat=2;
if Id=1 then Jystrat=1;
run;

proc print data=Province91;
sum UE91 HOU85;
run;

title2 "Correlation between UE91 and auxiliary variable HOU85";
proc corr data=Province91;
var UE91 HOU85;
run;

**Sample Selection;
data Sample;
set Province91;
SamplingWeight=4;
if id=1 or id=4 or id=7 or id=10 or id=13 or id=18 or id=26 or id=32 then output Sample;
run;

title2 "SRSWOR estimation for the total of UE91 and its' corresponding variance";
proc surveymeans data=Sample sum varsum total=32;
weight SamplingWeight;
var UE91;
ods output statistics=SRS_WOR_STATS;
run;

**Sampling weight calculation for PPS;
data Sample;
set Sample;
SamplingWeight= (91753-26881)/(HOU85*7);
if id=1 then SamplingWeight=1;
run;

proc print data=Sample;
title2 "Calculated SamplingWeights and their sum";
var Id Label UE91 HOU85 Jystrat SamplingWeight;
sum SamplingWeight;
run;

title2 "PPS_SYS_STR estimatation for the total of UE91 and its' corresponding variance. HOU85 is used as auxiliary information.";
proc surveymeans data=Sample sum std varsum;
weight SamplingWeight;
strata Jystrat;
var UE91;
ods output statistics=PPS_SYS_STATS;
run;

/*
**************************************************************
Sample selection can be done with surveyselect procedure also.
**************************************************************
title2 "SRSWOR Sample (n=8)";
proc surveyselect data=province91 out=SRS_WOR_Sample sampsize=8 method=srs stats noprint;
run;

title2 "PPS_SYS_STR Sample (n=8)";

proc surveyselect data=province91 out=PPS_SYS_Sample sampsize=(1,%eval(7)) method=pps_sys;
strata jystrat;
size HOU85;
run;
*/

title2 "Comparison of SRSWOR and PPS_SYS_STR strategies";

data PPS_SYS_STATS;
set PPS_SYS_STATS;
strategy='PPS_SYS_STR';
run;
data SRS_WOR_STATS;
set SRS_WOR_STATS;
strategy='SRS_WOR';
run;

data Comparison;
set SRS_WOR_STATS PPS_SYS_STATS;
run;

proc print data=Comparison;
run;

