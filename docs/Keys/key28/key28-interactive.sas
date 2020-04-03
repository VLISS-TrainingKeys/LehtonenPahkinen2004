/*Macro simSRS for examining the relative behaviour of SRS estimator for the total of 
  UE91 and LAB91. Macro parameters: var (variable under study), n (sample size, n=1-32), 
  k (number of simulations) and seed (seed for the random number generator). */

data Province91;
input Stratum Cluster Id Municipality $ 10-22 POP91 LAB91 UE91 HOU85 URB85;
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
 
%MACRO simSRS(var, n, k, seed);

title1 "Simulation Experiments for SRSWOR estimator for the total of &var";
options pageno=1;

data Frame(keep=Id Label Respvar);
set Province91;
Respvar=&var;
run; 

ods select all;
proc surveyselect data=Frame out=Sim_Samples sampsize=&n method=srs rep=&k seed=&seed stats;
run;

proc sort data=Sim_Samples out=Sim_Samples;
by replicate;
run;

* NOTE:
This piece of SURVEYMEANS code is adjusted for SAS Version 9.1 (and
later). For Version 8.2 (and earlier) an error message will appear because
of the STACKING option! If you are using SAS version 8.2 or earlier please 
remove the STACKING parameter and the code should work correctly.
;
ods select none;
proc surveymeans data=Sim_Samples stacking all;
			by replicate;
            var Respvar;
            weight SamplingWeight;
            ods output statistics=Stats_Sim(keep=Respvar_SumWgt Respvar_Sum);
            run;

proc summary data=Stats_Sim nway;
var Respvar_Sum;
output out=All(drop=_type_ _freq_)
		n(Respvar_Sum)=Simulated_Samples
		mean(Respvar_Sum)=Mean_of_Estimates
        var(Respvar_Sum)=Variance
        std(Respvar_Sum)=Std_error
;

proc summary data=Frame nway;
var Respvar;
output out=Pop(keep=Population_Total) sum=Population_Total;
run;

data All;
merge All Pop;
Bias=Mean_of_Estimates-Population_Total;
ARB=100*(abs(Mean_of_Estimates-Population_Total)/Population_Total);
MSE=Variance+Bias**2;
Root_MSE=sqrt(MSE);
run;

ods select all;
title2 "Descriptive statistics for &var";
title3 "Sample size &n, Simulations &k";
proc print data=All noobs;
var Population_Total Mean_of_Estimates Bias ARB Std_error Root_MSE;
run;

goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=3 htext=2
		 hsize=13cm vsize=13cm;
         
title2 "Distribution of SRS estimates for &var";
proc gchart data=Stats_Sim gout=graph;
hbar Respvar_sum / levels=25 freq cfreq;
run;
quit;

%MEND;

%simSRS(UE91,8,10,98765432);

%simSRS(LAB91,8,10,98765432);
