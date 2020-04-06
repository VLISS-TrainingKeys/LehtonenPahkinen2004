*EXAMPLE 5.4. Variance estimation by the Bootstrap method.

INTRODUCTION: This SAS code produces variance estimates for CHRON proportion and SYSBP mean 
by the Bootstrap method. 

INSTRUCTIONS:

1) Submit first two data steps and first two proc steps
2) Activate the MACRO BOOT
3) Insert macro parameters DSNAME (default=mfh), resp (response variable, default=chron),
   seed (seed for the random number generator, default=98765432),clusters (number of clusters, default=2),
   strata (number of stratums, default=24) and k=times (default=1)
4) Activate the line %BOOT to run the macro

; 
data MFH;
input STR CLU CHRON SYSBP X;
datalines;
 1 1 70 29056 204 
 1 2 74 29417 210
 2 1 12  3692  26
 2 2 14  4564  30
 3 1 15  7741  59
 3 2 16  8585  63
 4 1  9  6277  45
 4 2 14  5668  43
 5 1 10  2322  17
 5 2 16  3960  30
 6 1 10  3080  21
 6 2  6  3252  22
 7 1 10  3966  27
 7 2  4  3261  24
 8 1 12  4156  28
 8 2  6  2852  20
 9 1 15  6617  46
 9 2 23  6616  48
10 1 37 10552  73
10 2 25 11032  77
11 1 11  8759  60
11 2 25  9876  72
12 1 33  9901  69
12 2 24  6828  47
13 1 31  8624  61
13 2 27  9390  66
14 1 22  6960  48
14 2 20  7130  49
15 1 18  6646  49
15 2 22  7094  49
16 1 24  9841  69
16 2 37 11786  83
17 1 19  6910  48
17 2 23  6446  45
18 1 25 10742  73
18 2 29  9026  61
19 1 36  9350  65
19 2 34  8912  62
20 1  9  3810  26
20 2 22  7098  51
21 1 18  6998  53
21 2 34  9970  69
22 1 29 11146  79
22 2 41 13215  94
23 1 22  6596  48
23 2 18  6002  41
24 1 15  3808  27
24 2  7  3148  22
;
run;

data MFH;
set MFH;
label
STR="Stratum ID"
CLU="Cluster ID"
CHRON="Cluster sample sum of Chronic morbidity (CHRON)"
SYSBP="Cluster sample sum for Systolic blood pressure (SYSBP)"
X="Number of sample elements in the clusters"
run;

/*Viewing the MFH survey dataset contents*/
proc contents data=MFH position;
title1 "EXAMPLE 5.4. Variance estimation in the Mini-Finland Health Survey data";
title2 "Subpopulation of persons aged 30-64 years";
title3 "Response variables Chron (Chronic morbidity) and Sysbp (Systolic blood pressure)";
title4 "Variance approximation of a combined ratio estimator by the Bootstrap method";
title5 "Contents of the dataset MFH";
run;

/*Viewing the MFH population*/
proc print data=MFH;
title5 "The dataset MFH";
run;


/*MACRO BOOT: Calculation of estimates and their variances by using the Bootstrap method.
  Print procedures are used to view the intermediate and final results*/

%macro Boot(dsname,resp,seed,clusters,strata,k);

data Psusum;
set &dsname(rename=(&resp=y) keep=Str Clu &resp x);
proc means data=Psusum noprint sum;
var y x;
output out=rhat sum=Sumy Sumx;
data rhat(keep=rhat);
set rhat;
rhat=Sumy/Sumx;
run;

data Wgt(keep=h i j w1-w&clusters);
length seed 8;
array w(&clusters) w1-w&clusters;
seed=symget('seed');
do i=1 to &k;
  do h=1 to &strata;
     do j=1 to &clusters;
     w(j)=0;
     end;
     do j=1 to &clusters;
     call ranuni(seed,u);
     ii=int(&clusters*u)+1;
     w(ii)+1;
     end;
  output;
  end;
end;
call symput('seed',seed);
run;

proc sort data=Wgt;
by h i j;
run;
proc transpose data=Wgt out=w prefix=w;
by h;
var w1-w&clusters;
run;

data Psusumw;
merge Psusum w(drop=_name_ h);
run;

proc print data=Psusumw;
title1 "EXAMPLE 5.4. Variance estimation in the Mini-Finland Health Survey data";
title2 "Subpopulation of persons aged 30-64 years";
title3 "Response variables Chron (Chronic morbidity) and Sysbp (Systolic blood pressure)";
title4 "Variance approximation of a combined ratio estimator by the Bootstrap method";
title5 "Contents of the dataset MFH";
title5 "The first 10 weight variables w1-w10";
var Str Clu y x w1-w10;
run;

data Boot(keep=r);
retain y1-y&k 0;
retain x1-x&k 0;
set Psusumw end=end;
array w(&k) w1-w&k;
array Sumx(&k) x1-x&k;
array Sumy(&k) y1-y&k;
do i=1 to &k;
Sumx(i) + w(i)*x;
Sumy(i)+ w(i)*y;
end;
if end then do;
do i=1 to &k;
r=Sumy(i)/Sumx(i);
output;
end;
end;
run;
proc means data=Boot noprint mean;
var r;
output out=b(drop=_type_ _freq_) mean=rBoot;
run;
data Boot;
if _n_=1 then merge b rhat;
set Boot;
sr1=(r-rBoot)**2;
sr2=(r-rhat)**2;
run;

title5 "Bootstrap variance approximation from &k bootstrap samples, first 10 elements";
proc print data=Boot(obs=10);
run;

proc means data=Boot noprint sum;
var Sr1 Sr2;
id rhat rBoot;
output out=Bootest sum=Var1 Var2;
run;
data Bootest;
set Bootest;
Var1=&clusters/(&clusters-1)*Var1/(&k);
se1=sqrt(Var1);
Var2=&clusters/(&clusters-1)*Var2/(&k);
se2=sqrt(Var2);
run;

title5 "Bootstrap estimates, K=&k bootstrap samples";
proc print data=Bootest(drop=_type_ _freq_) noobs;
format _all_ 12.7;
run;
goptions reset=global gunit=pct border cback=white
         ctext=black colors=(blue green red)
         ftext=swiss ftitle=swissb
		 htitle=6 htext=2
		 hsize=13cm vsize=13cm;

title5 "Distribution of bootstrap estimates, K=&k bootstrap samples";
proc gchart data=Boot;
hbar r /cfreq levels=25;
run;
quit;

%mend boot;

%Boot(mfh,chron,987654,2,24,10);
*%Boot(mfh,sysbp,987654,2,24,1000);
