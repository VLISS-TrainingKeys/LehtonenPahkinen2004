**Reference example 2.4 from Lehtonen & Pahkinen (2004);
**Calculation of intra-class correlation under systematic sampling where the total
  of UE91 is to be estimated. We use Province'91 data set as the frame population;


data Province91;
input Id Municipality $ 4-17 UE91;
datalines;
1  Jyväskylä     4123
2  Jämsä          666
3  Jämsänkoski    528
4  Keuruu         760
5  Saarijärvi     721
6  Suolahti       457
7  Äänekoski      767
8  Hankasalmi     391
9  Joutsa         194
10  Jyväskmlk    1623
11  Kannonkoski   153
12  Karstula      341
13  Kinnula       129
14  Kivijärvi     128
15  Konginkangas  142
16  Konnevesi     201
17  Korpilahti    239
18  Kuhmoinen     187
19  Kyyjärvi       94
20  Laukaa        874
21  Leivonmäki     61
22  Luhanka        54
23  Multia        119
24  Muurame       296
25  Petäjävesi    262
26  Pihtipudas    331
27  Pylkönmäki     98
28  Sumiainen      79
29  Säynätsalo    166
30  Toivakka      127
31  Uurainen      219
32  Viitasaari    568
;
run;


* Systematic sample (see Table 2.5);
* Frame Population data set Province'91;

title 'EXAMPLE 2.4 Intra-class correlation in the Province91 population';
 
data sample1 sample2 sample3 sample4;
set Province91;
if id=1 or id=5 or id=9 or id=13 or id=17 or id=21 or id=25 or id=29 then output sample1;
if id=2 or id=6 or id=10 or id=14 or id=18 or id=22 or id=26 or id=30 then output sample2;
if id=3 or id=7 or id=11 or id=15 or id=19 or id=23 or id=27 or id=31 then output sample3;
if id=4 or id=8 or id=12 or id=16 or id=20 or id=24 or id=28 or id=32 then output sample4;
run;

%macro print(o);
proc print data=sample&o;
title2 "Sample&o from population Province91";
run;
%mend;
%print(1);
%print(2);
%print(3);
%print(4);

*Total sum of squares;
proc summary data=Province91;
var UE91;
output out=a(keep=SST N_tot) css=SST n=N_tot;
run;

*Between sum of squares;
%macro var(o);
proc summary data=sample&o;
var UE91;
output out=b&o css=cssw;
run;
%mend;
%var(1);
%var(2);
%var(3);
%var(4);

data b(keep=cssw);
set b1 b2 b3 b4;
run;

proc summary data=b;
var cssw;
output out=intra(keep=SSW) sum=SSW;
run;

proc summary data=sample1;
var UE91;
output out=c(keep=n_sample) n=n_sample;
run;

* Population ANOVA table;
data totalvar(keep=SST SSB SSW MST MSB MSW N_tot n_sample q);
merge intra a c;
q=N_tot/n_sample;
* Sum of squares;
SSB=SST-SSW;
* Mean squared errors (MSE);
MST=SST/(N_tot-1);
MSB=SSB/(q-1);
MSW=SSW/(N_tot-q);
run;

* Intra-class correlation coefficient rho_int and DEFF;
data totalvar;
set totalvar;
rho_int=1-n_sample/(n_sample-1)*SSW/SST;
DEFF=1+(n_sample-1)*rho_int;
run;

proc print data=totalvar noobs;
title2 "Population ANOVA Table";
var SSB SSW SST MSB MSW MST;
run;

proc print data=totalvar noobs;
title2 "Intra-class Correlation Coefficient and DEFF";
var rho_int DEFF;
run;
