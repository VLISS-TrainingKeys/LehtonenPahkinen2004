**Reference example 3.1 from Lehtonen & Pahkinen (2004);
**Calculation of the parameter DEFF for stratified simple random sampling (STRSRS)
  with proportional allocation on the Province'91 population.;

data Province91;
input Id Municipality $ 10-22 UE91 URB85;
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
output out=a(keep=SST N_tot popmean) css=SST n=N_tot mean=popmean;
run;

* Division of the population into two subpopulations by variable URB85: 
  URB85=1 for towns and URB85=0 for rural municipalities;
data strata1 strata2;
set Province91;
if URB85=1 then output strata1;
if URB85=0 then output strata2;
run;

proc summary data=strata1;
var UE91;
output out=var1 n=n1 var=var1 css=css1 mean=mean1;
run;
proc summary data=strata2;
var UE91;
output out=var2 n=n2 var=var2 css=css2 mean=mean2;
run;

data intra(keep=SSW);
merge var1 var2;
SSW=css1+css2;
run;


data totalvar(keep=SSW SST N_tot SSB MST MSB MSW DEFF);
merge intra a;
SSB=SST-SSW;
* Mean squared errors (MSE);
MST=SST/(N_tot-1);
MSW=SSW/(N_tot-2); 
MSB=SSB/(2-1);
DEFF=MSW/MST;
run;

proc print data=totalvar noobs;
title2 "Population ANOVA Table";
var SSB SSW SST MSB MSW MST;
run;

proc print data=totalvar;
title2 'DEFF=MSW/MST';
var DEFF;
run;
