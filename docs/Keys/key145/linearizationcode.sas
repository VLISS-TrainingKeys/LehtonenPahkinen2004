* EXAMPLE 5.1. Variance estimation by the linearization method.

INTRODUCTION: This SAS code produces variance estimates for Chron proportion and Sysbp mean 
by the linearization method. 

EXERCISE: By the information produced this piece of program code, it is possible to estimate 
the design effect of the Chron proportion estimate. Please try to do this. Hint: recall that 
the design effect is defined as the ratio of the variance estimate of Chron proportion estimate and
the corresponding variance estimate assuming Simple Random Sampling. For SRS, the variance estimate 
is phat(1-phat)/n.
;

data MFH;
input STR CLU1 Chron1 Sysbp1 n1 CLU2 Chron2 Sysbp2 n2;
datalines;
 1 1 70 29056 204 2 74 29417 210
 2 1 12  3692  26 2 14  4564  30
 3 1 15  7741  59 2 16  8585  63
 4 1  9  6277  45 2 14  5668  43
 5 1 10  2322  17 2 16  3960  30
 6 1 10  3080  21 2  6  3252  22
 7 1 10  3966  27 2  4  3261  24
 8 1 12  4156  28 2  6  2852  20
 9 1 15  6617  46 2 23  6616  48
10 1 37 10552  73 2 25 11032  77
11 1 11  8759  60 2 25  9876  72
12 1 33  9901  69 2 24  6828  47
13 1 31  8624  61 2 27  9390  66
14 1 22  6960  48 2 20  7130  49
15 1 18  6646  49 2 22  7094  49
16 1 24  9841  69 2 37 11786  83
17 1 19  6910  48 2 23  6446  45
18 1 25 10742  73 2 29  9026  61
19 1 36  9350  65 2 34  8912  62
20 1  9  3810  26 2 22  7098  51
21 1 18  6998  53 2 34  9970  69
22 1 29 11146  79 2 41 13215  94
23 1 22  6596  48 2 18  6002  41
24 1 15  3808  27 2  7  3148  22
;
run;
data MFH;
set MFH;
label
STR="Stratum ID"
CLU1="Cluster ID for the 1st cluster"
Chron1="Sample sum of Chronic morbidity (Chron) for 1st cluster"
Sysbp1="Sample sum for Systolic blood pressure (Sysbp) for 1st cluster"
n1="Number of sample elements in 1st cluster"
CLU2="Cluster ID for 2nd cluster"
Chron2="Sample sum of Chronic morbidity (Chron) for 2nd cluster"
Sysbp2="Sample sum for Systolic blood pressure (Sysbp) for 2nd cluster"
n2="Number of sample elements 2nd cluster";
run;

/*Viewing the MFH survey contents*/
proc contents data=MFH position;
title1 "EXAMPLE 5.1. Variance estimation in the Mini-Finland Health Survey data";
title2 "Subpopulation of males aged 30-64 years";
title3 "Response variables Chron (Chronic morbidity) and Sysbp (Systolic blood pressure)";
title4 "Variance approximation of a combined ratio estimator by the linearization method";
run;

/*Viewing the MFH population*/
proc print data=MFH;
run;

/*Calculation of estimates and their variances by using linearization method.
  Calculations are done in two data steps and in one procedure summary step.
  Print procedures are used to view the results*/

data MFH(keep=Chr_Sum Sys_Sum n_Sum Chr_Var Sys_Var n_Var Chr_n_Cov Sys_n_Cov);
set MFH;
Chr_Sum=Chron1+Chron2;
Sys_Sum=Sysbp1+Sysbp2;
n_Sum=n1+n2;
Chr_Var=(Chron1-Chron2)**2;
Sys_Var=(Sysbp1-Sysbp2)**2;
n_Var=(n1-n2)**2;
Chr_n_Cov=(Chron1-Chron2)*(n1-n2);
Sys_n_Cov=(Sysbp1-Sysbp2)*(n1-n2);
run;

proc summary data=MFH nway;
var Chr_Sum Sys_Sum n_Sum Chr_Var Sys_Var n_Var Chr_n_Cov Sys_n_Cov;
output out=Sumall(drop=_type_ _freq_)
sum=Chr_Sum Sys_Sum n_Sum Chr_Var Sys_Var n_Var Chr_n_Cov Sys_n_Cov;
run;

proc print data=Sumall;
run;

data All (keep= phat yhat V_des_phat V_des_yhat Deff_phat);
set Sumall;
phat=Chr_Sum/n_Sum;
V_des_phat=(phat**2)*(Chr_Sum**-2*Chr_Var + n_Sum**-2*n_Var-2*(Chr_Sum*n_Sum)**-1*Chr_n_Cov);
yhat=Sys_Sum/n_Sum;
V_des_yhat=(yhat**2)*(Sys_Sum**-2*Sys_Var + n_Sum**-2*n_Var-2*(Sys_Sum*n_Sum)**-1*Sys_n_Cov);
Deff_phat=V_des_phat/(phat*(1-phat)/n_Sum);
run;
proc print data=All; 
run;

