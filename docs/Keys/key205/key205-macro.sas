**Reference example 6.2: MODEL-ASSISTED ESTIMATION FOR DomainS WITH DIFFERENT SAMPLE SIZES;

**The Horvitz-Thompson (HT) estimator and the generalized regression (Greg) estimator of a Domain 
total are compared by examining the standard error and coefficient of Variation estimates. ;

libname [your libname] "location of your Saem data";
*Example: libname a "u:\VLISS\datat\";

data Sae;
set [your libname].Saem;
*Example: set a.saem;
run;

* Macro parameters:
	n 		= sample size
	seed 	= seed for the random number generator
	first 	= group 1 size
	second 	= group 2 size;

%MACRO MAC(n,seed,first,second);

********************
* Sample selection
********************
;
proc surveyselect data=Sae out=Samplex method=srs n=&n stats seed=&seed;
title1 "Model-Assisted Estimation for Domains";
title2 "Selecting a SRSWOR sample (n=&n)";
run;

data Samplex;
set Samplex;
Filter=1;
w=.;
run;

data Saem;
set a.Saem;
Filter=.;
w=.;
pi=.;
run;

data Saem;
merge Saem Samplex;
by id;
if Filter=1 then w=1/(&n/7841);
Chrons=Chron;
if Filter=. then Chrons=.;
run;

**************
* Computation
**************
;

* Population totals;
proc summary data=Saem;
Var Chron;
class Domain;
output out=c1(drop=_type_ rename=(_freq_=Pop_n)) sum=t;
run;

*****************
*(1) HT estimator
*****************
;

proc summary data=Saem;
where Filter=1;
Var Chrons;
class Domain;
weight w;
output out=s11(drop=_type_ rename=(_freq_=n)) sum=t_HT;
run;

*********************
* y_Sum y_Css x_css 
*********************;
proc summary data=Saem;                                                                                                                 
where Filter=1;                                                                                                                         
Var Chrons Age;                                                                                                                         
class Domain;                                                                                                                               
output out=s12(drop=_type_ _freq_) sum(Chrons)=y_Sum css(Chrons)=y_Css css(Age)=z_Css;                                                  
run;                                                                                                                                    
         

***********************************
* hts (Estimate for the Population)
***********************************;
data hts(drop=Domain rename=(t_HT=t_HTs));                                                                                                  
set s11(keep=t_HT Domain);                                                                                                                  
where Domain=.;                                                                                                                             
run;                                
 
*******************************************************
* Correlation of Variables Chrons and Age in the sample
*******************************************************;                                                                                                                                                                                                                                                               
proc corr data=Saem cov noprint outp=s14;                                                                                               
where Filter=1;                                                                                                                         
Var Chrons Age;                                                                                                                         
run;       
 
data s14(keep=yz_Cov);                                                                                                                  
set s14;                                                                                                                                
rename                                                                                                                                  
Age=yz_Cov                                                                                                                              
;                                                                                                                                       
where _type_="COV" and _name_="chrons";  
run;

******************************************
* Calculation of Variances to every Domain
******************************************;
data s1c1;                                                                                                                              
merge c1 s11 s12;                                                                                                                       
by Domain;                                                                                                                                  
y_Var=y_Css/(n-1);                                                                                                                      
z_Var=z_Css/(n-1);                                                                                                                      
run;                                                                                                                                    
     
***********************************
* Variance of whole Population only
***********************************;
data s13(rename=(y_Var=y2_Var z_Var=z2_Var));                                                                                           
set s1c1(keep=Domain y_Var z_Var);                                                                                                          
where Domain=.;                                                                                                                             
run;  

*****************************
*(2) Greg estimators
*****************************
;

proc summary data=Saem;
Var Age;
class Domain;
output out=Agep(keep=Domain Agep) sum=Agep;

data Agep2(keep=Agep2);                                                                                                                 
set Agep;                                                                                                                               
where Domain=.;                                                                                                                             
rename Agep=Agep2;                                                                                                                      
run;                                                                                                                                    


proc summary data=Saem;                                                                                                                 
where Filter=1;                                                                                                                         
Var Age;                                                                                                                                
weight w;                                                                                                                               
class Domain;                                                                                                                               
output out=Ages(keep=Domain t_Age) sum=t_Age;                                                                                               


data Ages2(keep=Ages2 z_Mean z2_Mean);                                                                                                  
set Ages;                                                                                                                               
where Domain=.;                                                                                                                             
z_Mean=t_Age/7841;                                                                                                                      
z2_Mean=t_Age/&n;                                                                                                                       
rename t_Age=Ages2;                                                                                                                     
run; 

****************************
* Calculation of ratio r=y/z
****************************; 
data r(keep=r t_HTs);
merge hts Ages2;
r=t_HTs/Ages2;
run;

******* Linear Syn estimator ************;                                                                                              
                                                                                                                                        
** Area-level auxiliary data;                                                                                                           
                                                                                                                                                                                                                                                                  
data Syn;                                                                                                                               
merge s1c1 Agep Ages;                                                                                                                   
by Domain;                                                                                                                                  
run;                                                                                                                                    
data Syn;                                                                                                                               
if _n_=1 then set r;                                                                                                                    
if _n_=1 then set Agep2;                                                                                                                
if _n_=1 then set Ages2;                                                                                                                
if _n_=1 then set s13;                                                                                                                  
if _n_=1 then set s14;                                                                                                                  
set Syn;                                                                                                                                
run;                                                                                                                                    
               

******* Linear Greg estimator ************;

** Unit-level auxiliary data;
data Saem;
if _n_=1 then set r;
set Saem;
if Filter=1 then do; 
	yhat=r*Age;
	ehat=Chrons-yhat;
	end;
run;

proc summary data=Saem;
title3 "Greg estimator";
where Filter=1;
Var ehat;
class Domain;
output out=s2(drop=_type_ _freq_) sum(ehat)=t_e css(ehat)=e_Css;
run;


data s22;
set s2;
where Domain=.;
rename e_Css=e_Css2;
run;

data s2;
if _n_=1 then set s22;
set s2;
run;


data All;
merge Syn s2;
by Domain;
w  = 7841/&n;
pd = n/&n;
qd = 1-pd;

y_CV       = sqrt(y_Var)/(t_HT/Pop_n); 
if y_CV=. then y_CV=0;
t_HT_Var   = 7841**2*(1-&n/7841)*(1/&n)*pd*y_Var*(1+qd/y_CV**2);  **Formula (6.22);
t_HT_se    = sqrt(t_HT_Var);
t_HT_CV    = 100*t_HT_se/t_HT;

t_Greg     = Agep*r+w*t_e;			

e_Var      = e_Css/(n-1);
e_CV       = sqrt(e_Var)/(t_e/Pop_n);

t_Greg_Var = 7841**2*(1-&n/7841)*(1/&n)*pd*e_Var*(1+qd/e_CV**2);  **Formula (6.22);
t_Greg_se  = sqrt(t_Greg_Var);
t_Greg_CV  = 100*t_Greg_se/t_Greg;


if n le &first then size=1;
else if n gt &first and n le &second then size=2;
else if n gt &second then size=3;
if Domain=. then size=4;
run;

*************************
***** Final results *****
*************************;
proc sort data=All out=Final;
by n;
run;

proc format;
value sizef
1="-" &first
2=&first " -" &second
3=&second " -"
4="Total"
;
run;

proc print data=Final noobs;
title2 "HT estimates and their Variance, s.e. and C.V";
title3 " ";
title4 "t_HT = HT estimate of Chron in each Domain";
title5 " ";
title6 "t_HT_Var   = 7841**2*(1-&n/7841)*(1/&n)*pd*y_Var*(1+qd/y_CV**2)";
title7 " "; 
title8 "t_HT_CV    = 100*t_HT_se/t_HT";

by size;
Var Domain n Pop_n t 
		t_HT t_HT_Var t_HT_se t_HT_CV;
format _numeric_ 5.0 
		t_HT 6.1
		t_HT_se t_HT_Var 6.2
		t_HT_CV 6.1
		size sizef.;  
run;


proc print data=Final noobs;
title2 "Greg estimates and their Variance, s.e. and C.V";
title3 "";
title4 "t_Greg     = Agep*r+w*t_e";
title5 "e_Var      = e_Css/(n-1)";
title6 "e_CV       = sqrt(e_Var)/(t_e/Pop_n)";
title7 " ";
title8 "t_Greg_Var = 7841**2*(1-&n/7841)*(1/&n)*pd*e_Var*(1+qd/e_CV**2)";
title9 " ";
title10 "t_Greg_CV  = 100*t_Greg_se/t_Greg";

by size;
Var Domain n t_Greg t_Greg_Var t_Greg_se t_Greg_CV e_Var e_CV;
format _numeric_ 5.0 
		t_Greg e_Var e_CV 6.1
		t_Greg_se t_Greg_Var 6.2
		t_Greg_CV 6.1
		size sizef.;
run;

proc print data=Final;
title4 " ";
by size;
Var Domain pd qd y_Var y_CV Agep r t_e e_Css;
format _numeric_ 5.0 
		pd qd r 6.5
		y_Var y_CV 6.3
		t_e 7.4
		Agep 6.0 
		e_Css 7.3
		size sizef.;
run;

******************;

proc format;
value sizef
.="All"
1="-" &first
2=&first " -" &second
3=&second " -"
;
run;

proc summary data=Final;
where Domain ne .;
Var n Pop_n t 
		t_HT t_Greg 
		t_HT_CV t_Greg_CV
		;
class size;
output out=sum1(drop=_type_) Mean= ;
run;


proc print data=sum1 noobs;
title2 "Means of C.V in groups";
Var size n t_HT_CV t_Greg_CV 
		 ;
format _numeric_ 6.0 
		t_HT_CV t_Greg_CV 6.2 	
		size sizef.;
run;

%MEND;

**recommendations: (500,seed,10,20), (1500,seed,30,60), (3000,seed,70,120);

%MAC(500,999194819,10,20);

%MAC(1500,999194819,30,60);

%MAC(3000,999194819,70,120);
