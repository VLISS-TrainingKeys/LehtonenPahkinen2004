												*GWLS MACRO*

INTRODUCTION

This exercise refers to Example 8.1.

The macro can be used for fitting logit ANOVA models for the Ohc survey setting with the GWLS method. 
The macro is written by using SAS/IML. Comments are given in the code for help. 
References to the formulas presented in Lehtonen and Pahkinen (2004) are in the code as well.

INSTRUCTIONS

1) Fill in the neccessary fields in the first libname statement and data step.
2) Submit the proc and data steps until the macro begins.
3) Submit the macro. Macro parameter is X, the model matrix.
4) Call the macro. Example call is given.
5) Modify the macro for your own purposes.

EXERCISE

The model you are fitting is defined by the data xb (model matrix). Datas c,c1,c2,c3,c4 define the model matrixes 
for the calculation of Wald statistics. Please do the following: Modify the data xb and datas c. to fit the saturated
model and all the reduced models and calculate the Wald statistics for the terms.
;

libname [your libname] "location of your OHC data";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc(keep=Stratum Cluster Psych2 Sex Age2 Phys);
*Example:  set a.ohc(keep=Stratum Cluster Psych2 Sex Age2 Phys);
run;

ods select none;

/* Calculates and saves the observed Psych proportions (estimates of the Regression coefficients)*/
proc Regress data=Ohc design=wr deft1;
nest Stratum Cluster;
weight _one_;
recode Phys=(0,1);
subgroup Sex Age2 Phys;
levels 2 2 2;
model Psych2=Sex*Age2*Phys/noint;
setenv decwidth=8; 
output  Beta /
		filename=work.Reg1
		filetype=sas;
run;

/* Calculates and saves the covariance matrix of the Regression coefficients 
under the specified sampling design */
proc Regress data=Ohc design=wr deft1;
nest Stratum Cluster;
weight _one_;
recode Phys=(0,1);
subgroup Sex Age2 Phys;
levels 2 2 2;
model Psych2=Sex*Age2*Phys/noint;
setenv decwidth=8; 
output  covar  /
		filename=work.Reg2
		filetype=sas;
run;

data Reg201;
set Reg201(obs=8);
run;

/*Calculates and saves the SRS covariance matrix of the estimated Regression coefficients*/
proc Regress data=Ohc design=wr deft1;
nest Stratum Cluster;
weight _one_;
recode Phys=(0,1);
subgroup Sex Age2 Phys;
levels 2 2 2;
model Psych2=Sex*Age2*Phys/noint;
setenv decwidth=8; 
output  SRScov  /
		filename=work.Reg3
		filetype=sas;
run;
/* Standard data steps*/
data Reg301;
set Reg301(obs=8);
run;

data Reg1;
set Reg1(keep=Beta);
run;
data Reg201;
set Reg201(keep=b01-b08);
run;
data Reg301;
set Reg301(keep=b01-b08);
run;

/*
Input the model matrixes for the main effects model, Psych2 = Intercept + Sex + Age + Phys 
NOTE! The first column is for the Intercept term and the remaining three columns are for the Sex, Age and Phys
corRES_Pondingly.
NOTE; In model matrix XA, the reference group (with a value 0) is the last class in each predictor.
NOTE: Model matrix XB reproduces the results in Table 8.4.
*/

data xa;
input x1 x2 x3 x4;
datalines;
1 1 1 1
1 1 1 0
1 1 0 1
1 1 0 0
1 0 1 1
1 0 1 0
1 0 0 1
1 0 0 0
;
run;

data xb;
input x1 x2 x3 x4;
datalines;
1 0 0 0
1 0 0 1
1 0 1 0
1 0 1 1
1 1 0 0
1 1 0 1
1 1 1 0
1 1 1 1
;
run;

/*Model matrix for the calculation of F-corrected Wald test statistics for the overall model*/
data c;
input c1-c4;
datalines;
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1
;
/*Model matrix for the calculation of F-corrected Wald test statistic for the Interaction term*/
data c1;
input c1-c4;
datalines;
1 0 0 0
;

/*Model matrix for the calculation of F-corrected Wald test statistic for Sex*/

data c2;
input c1-c4;
datalines;
0 1 0 0
;
/*Model matrix for the calculation of F-corrected Wald test statistic for Age*/

data c3;
input c1-c4;
datalines;
0 0 1 0
;
/*Model matrix for the calculation of F-corrected Wald test statistic for Phys*/

data c4;
input c1-c4;
datalines;
0 0 0 1
;
run;

ods select all;

/*GWLS estimation with SAS/IML*/

%Macro gwls(x);

proc iml;

*reset details printall;

* 1) DATA INPUT for SAS/IML;

use Reg1; *reading the proportion esitmates into a vector;
read all into p;
u=nrow(p); 
use Reg201; *reading the covariance matrix for the proportions into a matrix;
read all into vdesp;
vdesv=vecdiag(vdesp); *getting the variances of proportions;
SE_P=sqrt(vdesv); *and the corresponding standard errors;
use Reg301; *reading SRS covariance matrix of the proportions into a matrix;
read all into vbin; 

use &x; *reading the model matrix in to a matrix format;
read all into x;

/*reading the model matrixes for calculation of F-corrected Wald test statistics in to a vector*/
use c;
read all into c;
use c1;
read all into c1;
use c2;
read all into c2;
use c3;
read all into c3;
use c4;
read all into c4;

vbinv=vecdiag(vbin); *SRS variances of the proportions;
SE_Bin=sqrt(vbinv); * and the corresponding standard errors;
n=p#(1-p)/vbinv; *Calculating the sample size;
deff=vdesv/vbinv; *Deffs;

* 2) DESIGN-BASED GWLS ESTIMATION;

h=diag(1/(p#(1-p))); *Calculation of derivatives;
logitp=log(p/(1-p)); *Logits;

b=ginv(x`*ginv(h*vdesp*h)*x)*x`*ginv(h*vdesp*h)*logitp; *GWLS estimates of the Regression coefficients / FORMULA (8.5);
s=nrow(b);
vdesb=ginv(x`*ginv(h*vdesp*h)*x); *Covariance matrix for the Regression coefficients / FORMULA (8.6);
vbv=vecdiag(vdesb); *variances of the Regression coefficients;
SE_B=sqrt(vbv); *and their corresponding standard errors;
t=b/SE_B; *Standard t-value for the hypothesis Beta=0;
PVAL_T=1-probf(t#t,1,242); *t-test p-value for the hypothesis Beta=0;
* note df2=f-c+1 where f=245 and c=4;

* OR and CLI;

or=exp(b); *Calculation of ODDS ratios / FORMULA (8.7);
lcli=exp(b-1.96*SE_B); *lower confidence limit for the OR;
ucli=exp(b+1.96*SE_B); * upper confidence limit for the OR;

* Predicted values and residuals;

PRED_P=exp(x*b)/(1+exp(x*b)); *calculation of fitted proportions / FORMULA (8.10);
vPRED_P=ginv(h)*x*vdesb*x`*ginv(h); *and their corresponding variances;
SE_PRED_P=sqrt(vecdiag(vPRED_P)); * and standard errors;
RES_P=p-PRED_P; *calculation of raw residuals (observed proportion-fitted proportion);
vRES_P=ginv(h)*(h*vdesp*h-x*vdesb*x`)*ginv(h); *calculation of variance for the raw residuals; 
SE_RES_P=sqrt(vecdiag(vRES_P)); *and their corresponding standard errors;
STRES_P=RES_P/SE_RES_P; *calculation of standardized residuals;


* Design-based tests;

wald0=logitp`*ginv(h*vdesp*h)*logitp; 
wald=(logitp-x*b)`*ginv(h*vdesp*h)*(logitp-x*b); * Wald goodness of fit test / FORMULA (8.11);
df=u-s; * df for g-o-f test;
pvalwald=1-probchi(wald,df); * p-value of the test; 
waldover=wald0-wald;* Wald test statistics for the overall model / FORMULA (8.12);
dfo=s; *degrees of freedom of the Wald test statistics for the overall model;
pvaldo=1-probchi(waldover,dfo); *p-value of the Wald test statistics for the overall model;

*Calculation of F-corrected Wald test statistics and p-values for the overall model, intercept,
Sex, Age and Phys terms;

waldb=(c*b)`*ginv(c*vdesb*c`)*c*b; * FORMULA (8.13);
dfb=nrow(c);
pvalb=1-probchi(waldb,dfb);
waldb1=(c1*b)`*ginv(c1*vdesb*c1`)*c1*b; * FORMULA (8.13) for testing single parameters;
pvalb1=1-probchi(waldb1,1);
waldB_BIN=(c2*b)`*ginv(c2*vdesb*c2`)*c2*b;
pvalB_BIN=1-probchi(waldB_BIN,1);
waldb3=(c3*b)`*ginv(c3*vdesb*c3`)*c3*b;
pvalb3=1-probchi(waldb3,1);
waldb4=(c4*b)`*ginv(c4*vdesb*c4`)*c4*b;
pvalb4=1-probchi(waldb4,1);

* BINOMIAL GWLS;

* Binomial GWLS estimation;
B_BIN=ginv(x`*ginv(h*vbin*h)*x)*x`*ginv(h*vbin*h)*logitp; *calculation of the Regression coefficients;
vB_BIN=ginv(x`*ginv(h*vbin*h)*x);*SRS covariance matrix for the Regression coefficients;
vbv2=vecdiag(vB_BIN);*variances of the Regression coefficients;
SE_B_BIN=sqrt(vbv2);*and their corresponding standard errors;
PRED_P_BIN=exp(x*B_BIN)/(1+exp(x*B_BIN)); *calculation of fitted proportions;

* Deff of Beta coefficients;
DEFF_B=vbv/vbv2;


* PRINT;
/*The following lines are for controlling the output*/
Model_term={"Intercept","Sex","Age","Phys"};
Domain={1,2,3,4,5,6,7,8};
Sex={M,M,M,M,F,F,F,F};
Age={"-44","-44","45-","45-","-44","-44","45-","45-"};
Phys={0,1,0,1,0,1,0,1};
print 	"A) DESIGN-BASED ANALYSIS",,	"Proportion of persons in the upper Psychic strain group and their standard errors with design effect estimates" ,, 
				Domain Sex Age Phys p[format=8.3] SE_P[format=8.4] deff[format=8.2] n[format=8.0] ,,
				
				"Estimates of model coefficients, design effects and standard errors, and t-test results under DES option" ,,
				Model_term b[format=8.4] DEFF_B[format=8.4] SE_B[format=8.4] t[format=8.2] PVAL_T[format=8.4]
				or[format=8.2] lcli[format=8.2] ucli[format=8.2] ,,

				"Wald test statistics and test results for overall model and model terms under DES option" ,,
				wald[format=8.2] df pvalwald[format=8.4],, 
				waldover[format=8.2] dfo pvaldo[format=8.4],,

				waldb[format=8.2] pvalb[format=8.4] 
				waldb1[format=8.2] pvalb1[format=8.4]
				waldB_BIN[format=8.2] pvalB_BIN[format=8.4]
				waldb3[format=8.2] pvalb3[format=8.4]
				waldb4[format=8.2] pvalb4[format=8.4],,

				"Observed (P) and fitted (PRED_P) Psych proportions with their standard errors (SE_P and SE_PRED_P), raw residuals (RES_P) and its standard error (SE_RES_P) and standardized residuals (STRES_P) for the main effects ANOVA model under DES option" ,,
				Domain p[format=8.3] SE_P[format=8.4] PRED_P[format=8.3] SE_PRED_P[format=8.4] 
				RES_P[format=8.4] SE_RES_P[format=8.4] STRES_P[format=8.3],, 
				/

      	"B) BINOMIAL ANALYSIS",,	"Observed and fitted Psych proportions and estimates of model coefficients with their standard errors under BIN option"
				Domain p[format=8.3] n[format=8.0] SE_Bin[format=8.4] PRED_P_BIN[format=8.3],, 

				Model_term B_BIN[format=8.4] SE_B_BIN[format=8.4],,

; 

quit;
run;

%mend;

*EXAMPLE CALL;

%gwls(xb);
