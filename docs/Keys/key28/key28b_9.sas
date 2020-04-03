**Reference example 2.1 
**Examination of SRSWOR estimation of the total of UE91 (number of unemployed in the province) 
and LAB91 (size of labour force in the province) and of the ratio UE91/LAB91 by using different size SRSWOR 
Samples. The purpose is to examine how Sample size (n) affects to the total estimate and to the ratio estimate 
and their corresponding standard errors. We use Province'91 data set as the frame population;

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

%MACRO srs(n, seed);

title "SRSWOR estimation for the total of UE91 and LAB91 and for the ratio UE91/LAB91 with different Sample sizes";
title2 "Province91 Population, Sample size = &n";

ods select all;
proc surveyselect data=Province91 out=Sample sampsize=&n method=srs seed=&seed stats;
run;

data Sample;
set Sample;
N=32;
proc print data=Sample;
title2 "Selected sample data set";
run;

title2 "Estimates for the total of UE91 and LAB91 while Sample size is &n";

proc surveymeans data=Sample sum std clsum total=32;
      var UE91 LAB91;
      wgt SamplingWeight;
run;

title2 "Estimates for the ratio UE91/LAB91 while Sample size is &n";

proc surveymeans data=Sample N=32;
	ratio UE91/LAB91;
	stratum STR;
	weight SamplingWeight;
	ods output ratio=Ratio;
run;


%MEND;

%srs(8, 98765432);
