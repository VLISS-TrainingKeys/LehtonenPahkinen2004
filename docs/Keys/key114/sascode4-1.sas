**Reference example 4.1:Nonresponse;

**Investigation of nonresponse bias in the Province’91 population in a hypotetical case by assuming 
that all the southern municipalities were unable to complete in time the records for the unemployed. 
These municipalities are Kuhmoinen, Joutsa, Luhanka, Leivonmäki and Toivakka. In the data set, a variable 
RES_POP has been included to indicate that a valid response has been received (RES_POP = 1) or has not received 
(RES_POP = 0), from a municipality;

data Province91;
input STR CLU ID LABEL $ 10-22 UE91 HOU85;
datalines;
1  1   1  Jyväskylä    4123 26881
1  2   2  Jämsä        	666  4663
1  2   3  Jämsänkoski  	528  3019
1  2   4  Keuruu       	760  4896
1  3   5  Saarijärvi   	721  3730
1  5   6  Suolahti     	457  2389
1  3   7  Äänekoski    	767  4264
2  5   8  Hankasalmi   	391  2179
2  6   9  Joutsa       	194  1823
2  7  10  Jyväskmlk    	1623 9230
2  4  11  Kannonkoski  	153   726
2  4  12  Karstula     	341  1868
2  8  13  Kinnula      	129   675
2  8  14  Kivijärvi    	128   634
2  3  15  Konginkangas 	142   556
2  5  16  Konnevesi    	201  1215
2  1  17  Korpilahti   	239  1793
2  2  18  Kuhmoinen    	187  1463
2  4  19  Kyyjärvi     	94    672
2  5  20  Laukaa       	874  4952
2  6  21  Leivonmäki   	61    545
2  6  22  Luhanka      	54    435
2  7  23  Multia       	119   925
2  1  24  Muurame      	296  1853
2  7  25  Petäjävesi   	262  1352
2  8  26  Pihtipudas   	331  1946
2  4  27  Pylkönmäki   	98    473
2  3  28  Sumiainen    	79    485
2  1  29  Säynätsalo   	166  1226
2  6  30  Toivakka     	127   834
2  7  31  Uurainen     	219   932
2  8  32  Viitasaari   	568  3119

;
run;
data Province91;
set Province91;
RES_POP=1;
if id=18 or id=9 or id=22 or id=21 or id=30 then RES_POP=2;
run;

proc print data=Province91;
title1 "Handling Nonsampling Errors";
title2 "Frame population Province'91 data set";
var ID LABEL UE91 HOU85 RES_POP;
sum UE91 HOU85;
run;

proc summary data=Province91;
var UE91;
class RES_POP;
output out=Stats(rename= _FREQ_=N) sum=UE91_Sum mean=UE91_Mean;
run;

data Res;
set Stats(keep=RES_POP UE91_Mean);
if RES_POP=. then delete;
if RES_POP=2 then delete;
rename UE91_Mean=UE91_m1;
run;
data nRes;
set Stats(keep=RES_POP UE91_Mean);
if RES_POP=. then delete;
if RES_POP=1 then delete;
rename UE91_Mean=UE91_m2;
run;

data Stat;
if _n_=1 then set Res (keep=UE91_m1);
if _n_=1 then set nRes (keep=UE91_m2);
EXPECTED=32*UE91_m1;		*32 = Population total;
BIAS=5*(UE91_m1-UE91_m2);  	*5  = Number of nonrespondents;
run;

proc sort data=Stats;
by N ;
run;

proc print data=Stats;
title2 "N = number of muncipalities, UE91_sum = number of unemployed";
title3 "and UE91_mean = mean of unemployed in each group";
var N UE91_Sum UE91_Mean;
run;

proc print data=Stat;
title2 "Expected number of unemployed and";
title3 "nonresponse bias";
var EXPECTED BIAS;
run;

