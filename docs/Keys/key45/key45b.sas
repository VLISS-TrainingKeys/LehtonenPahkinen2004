**Calculation of intra-class correlation under systematic sampling where the total
  of UE91 is to be estimated. We use Province'91 data set as the frame population;
**In this exercise we examine the effect of varying sorting orders;

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


* Macroparameters: population and variable;
%Macro sorted(population,var);


* Population in random order;
data Population;
set &population;
* Note: Pick a personal seed number;
Random=ranuni(654326597);
run;

proc sort data=Population;
by &var;
run;

data Population;
set Population;
i+1;
run;

proc print data=Population;
title2 "Population sorted by variable &var";
run;

* Generating the four systematic samples from the population;
data sample1 sample2 sample3 sample4;
set Population;
if i=1 or i=5 or i=9 or i=13 or i=17 or i=21 or i=25 or i=29 then output sample1;
if i=2 or i=6 or i=10 or i=14 or i=18 or i=22 or i=26 or i=30 then output sample2;
if i=3 or i=7 or i=11 or i=15 or i=19 or i=23 or i=27 or i=31 then output sample3;
if i=4 or i=8 or i=12 or i=16 or i=20 or i=24 or i=28 or i=32 then output sample4;
run;

%macro print(o);
proc print data=sample&o;
title2 "Sample&o from population &population";
run;
%mend;
%print(1);
%print(2);
%print(3);
%print(4);


* Total sum of squares;
proc summary data=Population;
var UE91;
output out=a(keep=SST N_tot) css=SST n=N_tot;
run;

* Between sum of squares;
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

proc summary data=sample1;
var UE91;
output out=c(keep=n_sample) n=n_sample;
run;

proc summary data=b;
var cssw;
output out=intra(keep=SSW) sum=SSW;
run;

data totalvar(keep=SSB SST SSW n_sample N_tot rho_int DEFF q);
merge intra a c;
* Intra-class correlation coefficient rho_int and DEFF;
rho_int=1-n_sample/(n_sample-1)*SSW/SST;
DEFF=1+(n_sample-1)*rho_int;
q=N_tot/n_sample;
SSB=SST-SSW;
run;

proc print data=totalvar noobs;
title2 "Intra-class Correlation Coefficient and DEFF from the population";
var rho_int DEFF;
run;

%mend;

* Macrocalls;
* Population sorted by UE91;
%sorted(Province91,UE91);

* Population sorted by Municipality;
%sorted(Province91,Municipality);

* Population in random order;
%sorted(Province91,Random);

* Population sorted by Urbanicity (original data, see Part A);
%sorted(Province91,Id);
