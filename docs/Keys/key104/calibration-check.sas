**Calibration example;

**An SRSWOR Sample (n=8) selected from the Province’91 population is made to verify the calibration property. 
The Results are shown first for poststratification, then for ratio estimation and finally for regRession 
estimation. In addition, model-assisted estimates of the total of UE91 are calculated by using the calibrated Weights;

data Province91;
input Str Clu Id LABEL $ 10-22 POP91 LAB91 UE91 HOU85 URB85;
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

data Sample;
set Province91;
SW=4;
if id=18 or id=30 or id=26 or id=31 or id=15 or id=1 or id=4 or id=5 then output Sample;
run;

proc summary data=Sample;
var SW HOU85;
class Str;
output out=g  sum= mean(HOU85)=mHOU85;
run;
proc summary data=Province91;
var URB85 HOU85;
class Str;
output out=n (rename= HOU85=sumHOU85) sum=;
run;

data calibration (keep=SW _FREQ_ sumHOU85 mHOU85);
merge g n;
run;

proc iml;
use calibration;
read all into Sample;
p1=Sample[2,1]/Sample[2,2];
p2=Sample[3,1]/Sample[3,2];
rat=Sample[1,4]/(Sample[1,3]*Sample[1,1]);

use Sample var{URB85};
read all into Sample2;
g_Post=J(8,1,0);
g_Rat=J(8,1,0);
do i=1 to nrow(Sample2);
	if Sample2[i,1]=1 then g_Post[i,1]=p1;
	else if Sample2[i,1]=0 then g_Post[i,1]=p2;
	g_Rat[i,1]=rat;
end;
create Weights var{g_Post,g_Rat};
append;
close Weights;
run;
quit;

data Sample;
merge Sample Weights;
wstar_Post=SW*g_Post;
wstar_Rat=SW*g_Rat;
run;

proc summary data=Province91 nway;
var HOU85;
output out=Resp(drop=_type_ _freq_) 
		mean(HOU85)= HOU85_Mean;
run;

data Stats_Pop;
merge Resp;
rename
		HOU85_Mean  = Pop_HOU85_Mean;
run;

* Sample revisited;
proc summary data=Sample nway;
var HOU85;
output out=Res(drop=_type_ _freq_) 
		mean(HOU85)= HOU85_Mean  
        css(HOU85) = HOU85_css
;
run;

data Sample; 
if _n_=1 then merge Res Stats_Pop;
set Sample;
t_y_Post= wstar_Post*UE91;
t_z_Post= wstar_Post*URB85;

t_y_Rat= wstar_Rat*UE91;
t_z_Rat= wstar_Rat*HOU85;

g_Reg = 1+(Pop_HOU85_Mean-HOU85_Mean)/((8-1)/8*HOU85_css/(8-1))*(HOU85-HOU85_Mean);
wstar_Reg=SW*g_Reg;
t_y_Reg= wstar_Reg*UE91;
t_z_Reg= wstar_Reg*HOU85;

run;

proc print data=Sample;
title1 "Calibration check";
title2 "In the case of Poststratification";
var Id Label UE91 URB85 SW g_Post wstar_Post t_y_Post t_z_Post;
sum UE91 URB85 SW g_Post wstar_Post t_y_Post t_z_Post;
format _numeric_ 6.0 
		g_Post wstar_Post 5.4 
		t_y_Post 9.3
		t_z_Post 5.4
;
run;

proc print data=Sample;
title2 "In the case of Ratio estimation";
var Id Label UE91 HOU85 SW g_Rat wstar_Rat t_y_Rat t_z_Rat;
sum UE91 HOU85 SW g_Rat wstar_Rat t_y_Rat t_z_Rat;
format _numeric_ 6.0 
		g_Rat wstar_Rat 5.4 
		t_y_Rat 8.2
		t_z_Rat 8.2
;
run;

proc print data=Sample;
title2 "In the case of RegRession estimation";
var Id Label UE91 HOU85 SW g_Reg wstar_Reg t_y_Reg t_z_Reg;
sum UE91 HOU85 SW g_Reg wstar_Reg t_y_reg t_z_reg;
format _numeric_ 6.0 
		g_Reg wstar_Reg 5.4 
		t_y_Reg 8.2
		t_z_Reg 8.2
;
run;