*EXAMPLE 5.3. Variance estimation by the Jackknife technique.

INTRODUCTION: This SAS code produces variance estimates by the jackknife, or JRR (Jackknife Repeated 
Replications),technique for CHRON proportion and SYSBP mean in the MFH Survey dataset. 

The sampling design assumption is a paired Clusters design, that is, a design where exactly two Clusters
have been drawn from each stratum. The number of strata is 24 and there are 48 sample Clusters.

Note that an aggregated MFH dataset is used such that there are 48 observations (Clusters) in the dataset.
Therefore, variance estimation by JRR technique is based on the between-Clusters variation. 

INSTRUCTIONS:

1) Submit first two data steps and first two proc steps for the MFH Survey.
2) Activate MACRO JRR (Jackknife Repeated Replications).
3) Insert macro parameters DATA (default=mhf), Clu (Cluster ID, default=Clu), STR (stratum ID, default=str),
   Y (response variable, default=chron),X (number of sample elements in the Clusters run, default=x),
   S (number of strata in the paired Clusters design, default=24).
4) Activate the line %JRR to run the macro. 
5) Use the macro for your own purposes or modify it if needed. 

FURTHER EXCERCISES:

1)There are 7 different JRR variance estimators introduced in Lehtonen & Pahkinen (1996, 157-161). 
Please try to calculate all of them for the MFH design by appropriately modifying the macro JRR.

You may practice also with the OHC Survey data set. 
Feel free to download the OHC dataset from Index of SAS codes.
; 

/*MFH Survey data*/
data MFH;
input STR Clu CHRON SYSBP X;
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

/*Preparation of the data set for the JRR technique*/ 
proc sort data=MFH out=MFH;
by Clu;
run;

data MFH;
set MFH;
label
STR="Stratum ID"
Clu="Cluster ID"
CHRON="Cluster sample sum of Chronic morbidity (CHRON)"
SYSBP="Cluster sample sum for Systolic blood pressure (SYSBP)"
X="Number of sample elements in the Clusters"
;
run;

/*Viewing the MFH survey dataset contents*/
proc contents data=MFH position;
title1 "EXAMPLE 5.3. Variance estimation in the Mini-Finland Health Survey data";
title2 "Subpopulation of persons aged 30-64 years";
title3 "Variance approximation by the JRR method";
title4 "Contents of the dataset MFH";
run;

proc print data=MFH;
title4 "The dataset MFH";
sum x;
run;

/*SAS macro JRR*/
%macro jrr(data,str,clu,y,x,s);

title4 "&data Survey data, Response variable &y";

* Step 1. Creation of the weight matrix;

%let m=%eval(2*&s);
proc iml;

w1=diag(j(&s,1,-1))+1;
w2=diag(j(&s,1,1))+1;
w=w1//w2;
create w from w;
append from w;
close w;
run;

b=j(&m,&s,1);
a=shape({-1 1},2,1);
%do t=2 %to &s;
   a&t=shape({-1 1},2,1);
   a=block(a,a&t);
   %end;
w=b+a;
create a from a;
append from a;
create b from b;
append from b;
close b;
run;

quit;

data abw;
merge a b w;
run;


data sumw;
merge &data abw;
if &y=. then &y=0;
if &x=. then &x=0;
run;

proc print data=sumw;
title5 "Step 1. Weight matrix (10 first weight vectors are printed)";
title6 "Data SUMW";
var &str &Clu &y &x col1-col10;
sum &y &x col1-col10;
run;
 
proc summary data=sumw nway;
var &y &x;
output out=tsum(drop=_type_ _freq_) sum=sumy sumx;
run;
data tsum(keep=rhat);
set tsum;
rhat=sumy/sumx;
run;
data sumw;
if _n_=1 then set tsum;
set sumw;
run;

* Step 2. Creation of pseudo samples and calculation of ratio estimates from pseudo samples;
 
data Jrr(keep=r rhat);
retain y1-y&s 0;
retain x1-x&s 0;
set sumw end=end;
array w{&s} col1-col&s;
array sumx{&s} x1-x&s;
array sumy{&s} y1-y&s;
do i=1 to &s;
   sumy{i}+w{i}*&y;
   sumx{i}+w{i}*&x;
   end;
if end then do;
   do i=1 to &s;
      r=sumy{i}/sumx{i};
      output jrr;
      end;
   end;
run;

proc print data=Jrr;
title5 "Step 2. Creation of pseudo samples and calculation of ratio estimates from pseudo samples";
title6 "Data JRR";
run;

* Step 3: Variance approximation by the JRR technique;

data Jrr;
set Jrr;
vjrr=(r-rhat)**2;
run;
proc print data=Jrr;
title5 "Step 3. JRR-variances by stratum";
title6 "Data JRR";
title7 "NOTE: vjrr=(r-rhat)**2";
sum vjrr;
run;

proc summary data=Jrr nway;
var vjrr;
id rhat;
output out=Jrrest(drop=_type_ _freq_) sum=var_jrr;
run;

proc summary data=&data nway;
var &x;
output out=Nn(drop=_type_ _freq_) sum=nobs;
run;
data Jrrest;
if _n_=1 then set Nn;
set Jrrest;
se_Jrr=sqrt(var_Jrr);
run;
proc print data=Jrrest;
title5 "Step 3. JRR variance estimate, SRS variance estimate and the corresponding DEFF estimate";
title6 "Data JRREST";
title5;
run;

%mend;

*EXAMPLE CALLS;

%jrr(MFH,str,Clu,chron,x,24);

%jrr(MFH,str,Clu,sysbp,x,24);

