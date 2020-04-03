**Reference example 2.1 from Lehtonen & Pahkinen (2004);
**Calculation of SRSWOR (simple random sampling without replacement) estimates for the total of 
UE91(number of unemployed in the province) and LAB91 (size of labour force in the province) and 
for the RATIO UE91/LAB91 with their standard errors using (SAS) SURVEYMEANS procedure. 
We use Province'91 data set as the frame population;

data Province91;
input STR ID LABEL $ 7-18 POP91 LAB91 UE91 HOU85;
datalines;
1  1  Jyvaskyla    67200 33786  4123 26881
1  2  Jamsa        12907  6016   666  4663
1  3  Jamsankoski   8118  3818   528  3019
1  4  Keuruu       12707  5919   760  4896
1  5  Saarijarvi   10774  4930   721  3730
1  6  Suolahti      6159  3022   457  2389
1  7  Aanekoski    11595  5823   767  4264
1  8  Hankasalmi    6080  2594   391  2179
1  9  Joutsa        4594  2069   194  1823
1 10  Jyvaskmlk    29349 13727  1623  9230
1 11  Kannonkoski   1919   821   153   726
1 12  Karstula      5594  2521   341  1868
1 13  Kinnula       2324   927   129   675
1 14  Kivijarvi     1972   819   128   634
1 15  Konginkangas  1636   675   142   556
1 16  Konnevesi     3453  1557   201  1215
1 17  Korpilahti    5181  2144   239  1793
1 18  Kuhmoinen     3357  1448   187  1463
1 19  Kyyjarvi      1977   831    94   672
1 20  Laukaa       16042  7218   874  4952
1 21  Leivonmaki    1370   573    61   545
1 22  Luhanka       1153   522    54   435
1 23  Multia        2375  1059   119   925
1 24  Muurame       6830  3024   296  1853
1 25  Petajavesi    3800  1737   262  1352
1 26  Pihtipudas    5654  2543   331  1946
1 27  Pylkonmaki    1266   545    98   473
1 28  Sumiainen     1426   617    79   485
1 29  Saynatsalo    3628  1615   166  1226
1 30  Toivakka      2499  1084   127   834
1 31  Uurainen      3004  1330   219   932
1 32  Viitasaari    8641  4011   568  3119
;
run;
ods html;
title 'EXAMPLE 2.1 Analysing an SRSWOR sample from the Province91 population';
title2 "Frame Population data set Province'91";
ods html;
proc print data=Province91;
var STR ID LABEL LAB91 UE91;
sum UE91 LAB91;
run;

data Sample;
set Province91;
SamplingWeight=4;
N=32;
if id=1 or id=4 or id=5 or id=15 or id=18 or id=26 or id=30 or id=31 then output Sample;
run;

title2 'SRSWOR sample (see Table 2.3)';

proc print data=Sample;
var STR ID LABEL LAB91 UE91 SamplingWeight;
run;

title2 'Estimates for the total of UE91 and LAB91 under'; 
title3 'simple random sampling without replacement (SRSWOR)';
title4 'Table 2.4 results';

proc surveymeans data=Sample N=32 sum;
	stratum STR;
	weight SamplingWeight;
	var UE91 LAB91;
	ods output statistics=Total;
run;

title2 'Estimates for the ratio of UE91/LAB91 under'; 
title3 'simple random sampling without replacement (SRSWOR)';
title4 'Table 2.4 results';

proc surveymeans data=Sample N=32;
	ratio UE91/LAB91;
	stratum STR;
	weight SamplingWeight;
	ods output ratio=Ratio(keep=NumeratorName DenominatorName ratio StdErr);
run;

ods html close;
