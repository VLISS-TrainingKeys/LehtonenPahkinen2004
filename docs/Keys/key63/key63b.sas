**Stratified SRSWOR with different allocation schemes;
**Reference example 3.2 from Lehtonen & Pahkinen (2004);


data Province91;
input Id Municipality $ 4-17 UE91 URB85;
datalines;
 1  Jyväskylä    4123 1
 2  Jämsä         666 1
 3  Jämsänkoski   528 1
 4  Keuruu        760 1
 5  Saarijärvi    721 1
 6  Suolahti      457 1
 7  Äänekoski     767 1
 8  Hankasalmi    391 0
 9  Joutsa        194 0
10  Jyväskmlk    1623 0
11  Kannonkoski   153 0
12  Karstula      341 0
13  Kinnula       129 0
14  Kivijärvi     128 0
15  Konginkangas  142 0
16  Konnevesi     201 0
17  Korpilahti    239 0
18  Kuhmoinen     187 0
19  Kyyjärvi       94 0
20  Laukaa        874 0
21  Leivonmäki     61 0
22  Luhanka        54 0
23  Multia        119 0
24  Muurame       296 0
25  Petäjävesi    262 0
26  Pihtipudas    331 0
27  Pylkönmäki     98 0
28  Sumiainen      79 0
29  Säynätsalo    166 0
30  Toivakka      127 0
31  Uurainen      219 0
32  Viitasaari    568 0
;
run;


proc summary data=Province91;
var UE91;
output out=a css=SST n=N_tot mean=popmean var=var std=std cv=cv sum=tot;
run;

* Division of the population into two subpopulations by variable URB85: 
  URB85=1 for towns and URB85=0 for rural municipalities;
data strata1 strata2;
set Province91;
if URB85=1 then output strata1;
if URB85=0 then output strata2;
run;

proc print data=strata1;
title2 "Stratum 1";
run;
proc print data=strata2;
title2 "Stratum 2";
run;

proc summary data=strata1;
var UE91;
output out=var1 n=n1 var=var1 css=css1 mean=mean1 cv=cv1 std=std1 sum=tot1;
run;
proc summary data=strata2;
var UE91;
output out=var2 n=n2 var=var2 css=css2 mean=mean2 cv=cv2 std=std2 sum=tot2;
run;


data stra1;
set var1;
rename n1=StratumSize;
rename cv1=Cv;
rename std1=Std;
rename tot1=Total;
rename mean1=Mean;
name="Stratum 1";
run;

data stra2;
set var2;
rename n2=StratumSize;
rename cv2=Cv;
rename std2=Std;
rename tot2=Total;
rename mean2=Mean;
name="Stratum 2";
run;

data pop;
set a;
rename N_tot=StratumSize;
rename cv=Cv;
rename std=Std;
rename tot=Total;
rename popmean=Mean;
name="All         ";
run;


data info(keep=name Mean Total Std Cv StratumSize);
set pop stra1 stra2;
run;

proc print data=info;
var  name Mean Total Std Cv StratumSize;
title2 "Stratum-level parameters for the variable UE91";
run;


* The total number of units to be sampled is eight (n=8);
data alloc(keep=var var1 var2 tot1 tot2 tot n1 n2 N_tot std1 std2 cv1 cv2 n11_pro n22_pro n11_opt n22_opt 
  n11_pow1 n22_pow1 n11_pow2 n22_pow2 CV1_pro CV2_pro CV1_opt CV2_opt CV1_pow1 CV2_pow1 CV1_pow2 CV2_pow2 
  CV_pro CV_opt CV_pow1 CV_pow2 DEFF_pro DEFF_opt DEFF_pow1 DEFF_pow2);
merge a var1 var2;
* Proportional allocation;
n1_pro=8*n1/N_tot;
n11_pro=round(n1_pro,1);
n2_pro=8*n2/N_tot;
n22_pro=round(n2_pro,1);
* Optimal allocation;
n1_opt=8*(n1*std1)/(n1*std1+n2*std2);
n11_opt=round(n1_opt,1);
n2_opt=8*(n2*std2)/(n1*std1+n2*std2);
n22_opt=round(n2_opt,1);
* Power allocation (approximate) with a=0;
n1_pow1=8*cv1/(cv1+cv2);
n11_pow1=round(n1_pow1,1);
n2_pow1=8*cv2/(cv1+cv2);
n22_pow1=round(n2_pow1,1);
* Power allocation (exact) with a=0 and a stratum-specific coefficient c_h;
n1_pow2=n1_pow1*0.81;
n11_pow2=round(n1_pow2);
n2_pow2=8*cv2/(cv1+cv2)*1.19;
n22_pow2=round(n2_pow2);
* Stratum specific coefficient of variation for different allocation schemes;
CV1_pro=sqrt(n1**2*(1-n11_pro/n1)*(1/n11_pro)*var1)/tot1;
CV2_pro=sqrt(n2**2*(1-n22_pro/n2)*(1/n22_pro)*var2)/tot2;
CV1_opt=sqrt(n1**2*(1-n11_opt/n1)*(1/n11_opt)*var1)/tot1;
CV2_opt=sqrt(n2**2*(1-n22_opt/n2)*(1/n22_opt)*var2)/tot2;
CV1_pow1=sqrt(n1**2*(1-n11_pow1/n1)*(1/n11_pow1)*var1)/tot1;
CV2_pow1=sqrt(n2**2*(1-n22_pow1/n2)*(1/n22_pow1)*var2)/tot2;
CV1_pow2=sqrt(n1**2*(1-n11_pow2/n1)*(1/n11_pow2)*var1)/tot1;
CV2_pow2=sqrt(n2**2*(1-n22_pow2/n2)*(1/n22_pow2)*var2)/tot2;
* Coefficient of variation for different allocation schemes;
CV_pro=sqrt(n1**2*(1-n11_pro/n1)*(1/n11_pro)*var1+n2**2*(1-n22_pro/n2)*(1/n22_pro)*var2)/tot;
CV_opt=sqrt(n1**2*(1-n11_opt/n1)*(1/n11_opt)*var1+n2**2*(1-n22_opt/n2)*(1/n22_opt)*var2)/tot;
CV_pow1=sqrt(n1**2*(1-n11_pow1/n1)*(1/n11_pow1)*var1+n2**2*(1-n22_pow1/n2)*(1/n22_pow1)*var2)/tot;
CV_pow2=sqrt(n1**2*(1-n11_pow2/n1)*(1/n11_pow2)*var1+n2**2*(1-n22_pow2/n2)*(1/n22_pow2)*var2)/tot;
* Design effects;
DEFF_pro=(n1**2*(1-n11_pro/n1)*(1/n11_pro)*var1+n2**2*(1-n22_pro/n2)*(1/n22_pro)*var2)/(N_tot**2*(1-(n11_pro+n22_pro)/N_tot)*(1/(n11_pro+n22_pro))*var);
DEFF_opt=(n1**2*(1-n11_opt/n1)*(1/n11_opt)*var1+n2**2*(1-n22_opt/n2)*(1/n22_opt)*var2)/(N_tot**2*(1-(n11_opt+n22_opt)/N_tot)*(1/(n11_opt+n22_opt))*var);
DEFF_pow1=(n1**2*(1-n11_pow1/n1)*(1/n11_pow1)*var1+n2**2*(1-n22_pow1/n2)*(1/n22_pow1)*var2)/(N_tot**2*(1-(n11_pow1+n22_pow1)/N_tot)*(1/(n11_pow1+n22_pow1))*var);
DEFF_pow2=(n1**2*(1-n11_pow2/n1)*(1/n11_pow2)*var1+n2**2*(1-n22_pow2/n2)*(1/n22_pow2)*var2)/(N_tot**2*(1-(n11_pow2+n22_pow2)/N_tot)*(1/(n11_pow2+n22_pow2))*var);
run;

data d(keep=n11_pro n22_pro CV1_pro CV2_pro CV_pro DEFF_pro) e(keep=n11_opt n22_opt CV1_opt CV2_opt CV_opt DEFF_opt) 
     f(keep=n11_pow1 n22_pow1 CV1_pow1 CV2_pow1 CV_pow1 DEFF_pow1) g(keep=n11_pow2 n22_pow2 CV1_pow2 CV2_pow2 CV_pow2 DEFF_pow2);
set alloc;
run;

data d;
set d;
Alloc="Proport";
rename n11_pro=n1;
rename n22_pro=n2; 
rename CV1_pro=CV1;
rename CV2_pro=CV2;
rename Cv_pro=CV;
rename DEFF_pro=DEFF;
run;

data e;
set e;
Alloc="Optimal";
rename n11_opt=n1;
rename n22_opt=n2;
rename CV1_opt=CV1;
rename CV2_opt=CV2;
rename CV_opt=CV;
rename DEFF_opt=DEFF;
run;

data f;
set f;
Alloc="Power1 ";
rename n11_pow1=n1;
rename n22_pow1=n2;
rename CV1_pow1=CV1;
rename CV2_pow1=CV2;
rename CV_pow1=CV;
rename DEFF_pow1=DEFF;
run;

data g;
set g;
Alloc="Power2 ";
rename n11_pow2=n1;
rename n22_pow2=n2;
rename CV1_pow2=CV1;
rename CV2_pow2=CV2;
rename CV_pow2=CV; 
rename DEFF_pow2=DEFF;
run;


data defg;
set d e f g;
run;

proc print data=defg split='*' noobs round;
var Alloc n1 n2 CV1 CV2 CV DEFF;
label Alloc='Allocation';
title2 "Stratum sample sizes and coefficients of variation";
run;

