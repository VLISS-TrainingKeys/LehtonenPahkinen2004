/* KEY54: In option for interactive analysis, we provide a SAS macro for further training in PPS sampling.
The macro PPSWOR_STR can be used to examine properties of stratified PPSWOR sampling when different types 
of size measure variables are used.

Instructions:

(1) Submit the required data steps to read the frame population Province91 data set. 
Three new artificial size measure variables are created:
	Constant (=1) 
	X (location transformation for study variable to be created within the macro)
	Z (Normal distribution)

(2) Examine the contents and macro PPSWOR_STR.
Macro parameters in %macro PPSWOR_STR(data,n,k,y,auxvar,strata,seed) are: 
	data (frame population data set),
	n (sample size for each simulated sample), 
	k (number of simulated samples),
	y (study variable)
	auxvar (size measure variable),
	strata (stratum variable), and
	seed (seed for random number generator in sampling procedure).

(3) Set values for macro parameters in macro call %PPSWOR_STR(data,n,k,y,auxvar,strata,seed);
*
(4) Invoke the macro for your training by activating %PPSWOR_STR(<your macro parameters>);

* Example:

%PPSWOR_STR(province91,8,100,UE91,HOU85,Jystrat,9876543);
*
Frame population data: Province91
Sample size n: 8
Number of simulated samples k: 100
Study variable y: UE91 (the number of unemployed in a municipality in 1991)
Size measure variable auxvar: HOU85 (the number of households in a municipality in 1985)
Strata variable strata: Jystrat
Seed: 9876543.

5) Modify the macro for your own purposes if needed. 

*/

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

* Generation of the strata variable JYSTRAT and two artifical size measure variables;
data Province91;
set Province91;
Jystrat=2;
if id=1 then Jystrat=1;
* Size measure Constant=1;
Constant=1;
* Size measure z (normal distribution);
z=500+150*rannor(12345);
run;

*MACRO PPSWOR_STR;

%macro PPSWOR_STR(data,n,k,y,auxvar,strata,seed);

data Population(drop=&y);
set &data(keep=&y &auxvar &strata);
y=&y;
* Generation of size measure x (location transformation for study variable);
x=3000+y;
run;

proc corr data=Population;
title1 "Stratified PPSWOR sampling";
title2 "Frame population=&data, Study variable y=&y, Size measure=&auxvar";
title3 "Population correlations for &y with &auxvar";
var y &auxvar;
run;

goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=6 htext=2
		 hsize=13cm vsize=13cm;

proc gplot data=Population;
title3 "Scatterplot of &y against &auxvar in &data frame population";
plot y*&auxvar;
run;
quit;

proc surveyselect data=Population out=Sim_Samples sampsize=(1,%eval(&n-1)) method=pps  
	rep=&k seed=&seed stats;
	strata &strata;
	size &auxvar;
title3 "Stratified PPSWOR sample generation from &data frame population";
title4 "Sample size n=&n, Strata=&strata, independent replications k=&k";
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
            var y;
			strata &strata;
			weight SamplingWeight;
			ods output statistics=Stats_Sim_PPS(keep=y_Sumwgt y_Sum);
            run;

proc summary data=Stats_Sim_PPS nway;
var y_Sum;
output out=All(drop=_type_ _freq_)
		n(y_Sum)=Simulated_Samples
		mean(y_Sum)=Mean_of_Estimates
        var(y_Sum)=Variance
        std(y_Sum)=Std_Error
;

proc summary data=Population nway;
var y;
output out=Total(keep=Population_Total) sum=Population_Total;
run;

data All;
if _n_=1 then set Total;
set All;
Bias=Mean_of_Estimates-Population_Total;
Absolute_Relative_Bias=100*(abs(Mean_of_Estimates-Population_Total)/Population_Total);
MSE=Variance+Bias**2;
Root_MSE=sqrt(MSE);
Relative_RMSE=Root_MSE/Population_Total;
run;

ods select all;

proc print data=All;
title3 "PPSWOR_STR design, population=&data, strata=&strata, n=&n, y=&y, size measure=&auxvar";
title4 "Mean, Bias, ARB, S.E, RMSE and RRMSE of &k Monte Carlo estimates of total of &y";
var population_Total Mean_of_Estimates Bias Absolute_Relative_Bias Std_Error Root_MSE Relative_RMSE; 
run;

proc gchart data=Stats_Sim_PPS;
title3 "PPSWOR_STR design, population=&data, strata=&strata, n=&n, y=&y, size measure=&auxvar";
title4 "Distribution of Monte Carlo estimates of total for &y";
hbar y_Sum / midpoints=4000 to 30000 by 1000 freq cfreq;

*if LAB91 is used instead of UE91 then use the configuration below.
*hbar y_Sum / midpoints=50000 to 200000 by 10000 freq cfreq;
run;
quit;

%mend;

* Examples;

* Invoke with HOU85 as size measure for UE91;
%PPSWOR_STR(Province91,8,100,UE91,HOU85,Jystrat,9876543);

* Invoke with x as size measure for UE91;
%PPSWOR_STR(Province91,8,100,UE91,x,Jystrat,9876543);

* Invoke with z as size measure for UE91;
%PPSWOR_STR(Province91,8,100,UE91,z,Jystrat,9876543);

* Invoke with Constant=1 as size measure for UE91 (reproduces SRSWOR_STR);
%PPSWOR_STR(Province91,8,100,UE91,Constant,Jystrat,9876543);
