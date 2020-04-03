***************************************
*
* TRAINING KEY 101
* 
* Further Interactive Training with 
* Monte Carlo simulation techniques
*
***************************************

* INSTRUCTIONS:

1) Generate the population data set Province91 by activating the data step (paste and submit).
2) View the data by PROC PRINT (paste and submit).
3) Activate macro "simulate" (paste lines from %MACRO to %MEND and submit).
4) In macro call %SIMULATE(n,k) insert values for the macro parameters:
	- sample size n (default=8). Possible values are from 2 to 32.
	- number of samples generated k (default=10). Try 100, 500 and 1000, for example. 
	- PPS scheme: systematic (sys) or WOR-type sequential (seq).
5) Call the macro with the given macro parameters (paste and submit).
6) Examine numerical and graphical results of simulations for a comparison of  
   SRSWOR_HT, Stratified PPS (with systematic or sequential PPS method) and SRSWOR_REG strategies:
   - Mean (over simulations) of Estimates (Expectation of the estimator) 
   - Bias: Average (over simulations) bias and absolute relative bias (ARB)
   - Precision: Average standard error
   - Accuracy: Average root mean squared error (RMSE)  
;

data Province91;
input STR CLU ID LABEL $ 10-22 POP91 LAB91 UE91 HOU85 JYstrat;
datalines;
1  1   1  Jyvaskyla    67200 33786  4123 26881 1
1  2   2  Jamsa        12907  6016   666  4663 2
1  2   3  Jamsankoski   8118  3818   528  3019 2
1  2   4  Keuruu       12707  5919   760  4896 2
1  3   5  Saarijarvi   10774  4930   721  3730 2
1  5   6  Suolahti      6159  3022   457  2389 2
1  3   7  Aanekoski    11595  5823   767  4264 2
2  5   8  Hankasalmi    6080  2594   391  2179 2
2  6   9  Joutsa        4594  2069   194  1823 2
2  7  10  Jyvaskmlk    29349 13727  1623  9230 2
2  4  11  Kannonkoski   1919   821   153   726 2
2  4  12  Karstula      5594  2521   341  1868 2
2  8  13  Kinnula       2324   927   129   675 2
2  8  14  Kivijarvi     1972   819   128   634 2
2  3  15  Konginkangas  1636   675   142   556 2
2  5  16  Konnevesi     3453  1557   201  1215 2
2  1  17  Korpilahti    5181  2144   239  1793 2
2  2  18  Kuhmoinen     3357  1448   187  1463 2
2  4  19  Kyyjarvi      1977   831    94   672 2
2  5  20  Laukaa       16042  7218   874  4952 2
2  6  21  Leivonmaki    1370   573    61   545 2
2  6  22  Luhanka       1153   522    54   435 2
2  7  23  Multia        2375  1059   119   925 2
2  1  24  Muurame       6830  3024   296  1853 2
2  7  25  Petajavesi    3800  1737   262  1352 2
2  8  26  Pihtipudas    5654  2543   331  1946 2
2  4  27  Pylkonmaki    1266   545    98   473 2
2  3  28  Sumiainen     1426   617    79   485 2
2  1  29  Saynatsalo    3628  1615   166  1226 2
2  6  30  Toivakka      2499  1084   127   834 2
2  7  31  Uurainen      3004  1330   219   932 2
2  8  32  Viitasaari    8641  4011   568  3119 2
;
run;

%MACRO simulate(n,k,pps);

**Frame Population;
proc print data=Province91;
title1 "Simulation Experiments for SRSWOR_HT, Stratified &pps and SRSWOR_REG Strategies";
title2 "Frame Population data set Province'91";
sum UE91 HOU85;
run;

**1) Stratified PPS Strategy;
proc surveyselect data=Province91 out=Sim_Samples1 sampsize=(1,%EVAL(&n-1)) method=&pps
	rep=&k seed=98765432 stats;
	strata JYstrat;
	size HOU85;
	title2 "Sample selections";
run;

proc sort data=Sim_Samples1 out=Sim_Samples1;
by replicate;
run;

* NOTE:
This piece of SURVEYMEANS code is adjusted for SAS Version 9.1 (and
later). For Version 8.2 (and earlier) an error message will appear because
of the STACKING option! If you are using SAS version 8.2 or earlier please 
remove the STACKING parameter and the code should work correctly.
;
ods select none;
proc surveymeans data=Sim_Samples1 all stacking;
			by replicate;
            var UE91;
            weight SamplingWeight;
			strata JYstrat;
            ods output statistics=Stats_Sim_PPS(keep=UE91_Sumwgt UE91_Sum);
            run;

**2) SRSWOR_REG Strategy;
ods select all;
proc surveyselect data=Province91 out=Sim_Samples2 sampsize=&n method=srs rep=&k seed=98765432 stats;
run;

proc sort data=Sim_Samples2 out=Sim_Samples2;
by replicate;
run;

* NOTE:
This piece of SURVEYMEANS code is adjusted for SAS Version 9.1 (and
later). For Version 8.2 (and earlier) an error message will appear because
of the STACKING option! If you are using SAS version 8.2 or earlier please 
remove the STACKING parameter and the code should work correctly.
;
ods select none;
proc surveymeans data=Sim_Samples2 all stacking;
			by replicate;
            var UE91;
            weight SamplingWeight;
            ods output statistics=Stats_Sim_HT(keep=UE91_Sumwgt UE91_Sum);
            run;


proc surveyreg data=Sim_Samples2 total=32;
			by replicate;
			model UE91=HOU85 / solution covb;
			weight SamplingWeight;
			Estimate "UE91 Total" Intercept 32 HOU85 91753 / E;
			ods output 
			Estimates=Stats_Sim_REG(keep=Estimate);
			run;


data Stats_Sim_HT;
set Stats_Sim_HT;
Strategy=1;
data Stats_Sim_PPS;
set Stats_Sim_PPS;
Strategy=2;
data Stats_Sim_REG;
set Stats_Sim_REG;
Strategy=3;
run;

data Stats_Sim_Samples;
set Stats_Sim_HT Stats_Sim_PPS Stats_Sim_REG(rename=(Estimate=UE91_Sum));
run;

proc summary data=Stats_Sim_Samples nway;
var UE91_Sum;
class strategy;
output out=All(drop=_type_ _freq_)
		n(UE91_Sum)=Simulated_Samples
		mean(UE91_Sum)=Mean_of_Estimates
        var(UE91_Sum)=Variance
        std(UE91_Sum)=Std_error
;

data All;
set All;
Population_Total=15098;
Bias=Mean_of_Estimates-Population_Total;
ARB=100*(abs(Mean_of_Estimates-Population_Total)/Population_Total);
MSE=Variance+Bias**2;
Root_MSE=sqrt(MSE);
run;

proc format;
value stratf
1="SRSWOR_HT"
2="STR_&pps"
3="SRSWOR_REG"
;

ods select all;
title2 'Descriptive statistics';
title3 "Sample size &n, Simulations &k";
proc print data=All noobs;
var Strategy Population_Total Mean_of_Estimates Bias ARB Std_error Root_MSE;
format strategy stratf. Mean_of_Estimates Bias Std_error Root_MSE 8.1 ARB 8.2;
run;

goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=6 htext=2
		 hsize=13cm vsize=13cm;

proc gchart data=Stats_Sim_Samples gout=graph;
title1 "Simulation Experiments for SRSWOR_HT, Stratified &pps and SRSWOR_REG Strategies";
title2 "Distribution of Estimates";
title3 "Sample size &n, Simulations &k";
hbar UE91_Sum / midpoints=4000 to 32000 by 1000 freq cfreq;
by Strategy;
format Strategy stratf.;
run;
quit;

%mend;

* Stratified systematic PPS;
%simulate(8,10,pps_sys);

* Stratified sequential (WOR-type) PPS;
%simulate(8,10,pps_seq);
