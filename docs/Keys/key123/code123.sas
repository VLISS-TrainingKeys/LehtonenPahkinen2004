**Reference example 4.3: Multiple Imputation;

**Multiple Imputation for province'91 data set using the previously chosen Sample
where are two nonResponse cases (Kuhmoinen and Toivakka). First, five complete data sets
are done and their corResponding Means and standard Errors are calculated. Then multiple Imputation
Variance is calculated from two components: Var_Sam (Sample Variance) and Var_Imp (Imputation Variance);

**To get a better picture of multiple Imputation use the interactive sections macro. Make your own
Samples and compare the Results;

data Province91;
input STR CLU ID LABEL $ 10-22 UE91 HOU85;
datalines;
1  1   1  Jyväskylä    4123 26881
1  2   2  Jämsä        	666  4663
1  2   3  Jämsänkoski  	528  3019
1  2   4  Keuruu       	760  4896
1  3   5  Saarijärvi   	721  3730
1  5   6  Suolahti     	457  2389
1  3   7  Äänekoski    	767  4264
2  5   8  Hankasalmi   	391  2179
2  6   9  Joutsa       	194  1823
2  7  10  Jyväskmlk    	1623 9230
2  4  11  KaNnonkoski  	153   726
2  4  12  Karstula     	341  1868
2  8  13  KiNnula      	129   675
2  8  14  Kivijärvi    	128   634
2  3  15  Konginkangas 	142   556
2  5  16  KoNnevesi    	201  1215
2  1  17  Korpilahti   	239  1793
2  2  18  Kuhmoinen    	187  1463
2  4  19  Kyyjärvi     	94    672
2  5  20  Laukaa       	874  4952
2  6  21  Leivonmäki   	61    545
2  6  22  Luhanka      	54    435
2  7  23  Multia       	119   925
2  1  24  Muurame      	296  1853
2  7  25  Petäjävesi   	262  1352
2  8  26  Pihtipudas   	331  1946
2  4  27  Pylkönmäki   	98    473
2  3  28  Sumiainen    	79    485
2  1  29  Säynätsalo   	166  1226
2  6  30  Toivakka     	127   834
2  7  31  Uurainen     	219   932
2  8  32  Viitasaari   	568  3119

;
run;
data Province91;
set Province91;
Res_Pop=1;
if id=18 or id=9 or id=22 or id=21 or id=30 then Res_Pop=2;
run;

proc print data=Province91;
title1 "Handling NonSampling Errors";
title2 "Frame Population Province'91 data set";
Var Id Label UE91 HOU85 Res_Pop;
sum UE91 HOU85;
run;

data Sample;
set Province91;
SamplingWeight=4;
RHG=Str;
UEHelp=UE91;
if Res_Pop=2 then UE91=.;
if id=18 or id=30 or id=26 or id=31 or id=15 or id=1 or id=4 or id=5 then output Sample;
run;
data Sample;
set Sample;
Mean_Imp=UE91;
Nearest_n=UE91;
Ratio=UE91;
run;

proc sort data=Sample;
by descending Res_Pop ;
run;
proc print data=Sample;
title2 "Selected Sample data set";
Var Id Label UE91 HOU85;
sum HOU85;
run;

* Mean Imputation values;
proc summary data=Sample;
where Res_Pop ne 2;
Var UE91;
output out=Mean_Imp (drop= _type_) Mean=Mean_i ;
run;

data Sample;
if _n_=1 then set Mean_Imp;
set Sample;
if Mean_Imp=. then Mean_Imp=Mean_i;
run;

* Ratio Imputation;

data Res;
set Sample;
where UE91 ne .;
run;
proc summary data = Res;
Var UE91 HOU85;
output out=Res_Mean (drop= _type_) Mean=;
run; 
data Res_Ratio;
set Res_Mean;
r=UE91/HOU85;
run;
data Sample;
if _n_=1 then set Res_Ratio (keep=r);
set Sample;
if UE91=. then Ratio=r*HOU85;
run;

* Nearest neighbour;

data Sample;
set Sample;
apu=.;
run;

proc iml;
edit Sample Var{Id UE91 HOU85 apu Res_Pop};
read all into Sample;

do i=1 to nrow(Sample);
if Sample[i,4] = . then do; 
	apu=Sample[i,3];
	dist=0;
	index=0;
	do j=1 to nrow(Sample);
		if( (Sample[j,2]^=.) & (abs(apu-Sample[j,3]) < dist | dist=0) & (i ^= j)  ) then do; 
			dist=abs(apu-Sample[j,3]); 
			index=j; 
			end;		
	end;
	find next where(apu={.}) into d;
	apu=Sample[index,2];
	replace;
end;	
end;
run;
quit;

data Sample;
set Sample;
if Nearest_n=. then Nearest_n=apu;
run;

proc print data=Sample;
title2 "The single Imputed values (Mean Imputation, Nearest neighbour and Ratio Imputation)";
Var Id Label UE91 HOU85 Mean_Imp Nearest_n Ratio UEHelp;
run;

*************************************
 Variance Estimation
*************************************;
proc summary data=Sample; 
where UE91 ne .;
Var UE91 HOU85;
output out=Sample_m (drop= _type_) Mean(UE91)=UE91_m Mean(HOU85)=HOU85_m;
run;

proc summary data=Sample; 
Var Mean_Imp Nearest_n;
output out=Mean_1 (drop= _type_) Mean(Nearest_n)=Nn_m Mean(Mean_Imp)=Rm_m;
run;

data Error;
if _n_=1 then set Sample_m(keep=UE91_m HOU85_m);
set Sample;
where UE91 ne .;
e_hat1=UE91-UE91_m;
e_hat2=UE91-apu;
e_hat3=UE91-(UE91_m/HOU85_m)*HOU85;
run;
proc summary data=Error ; 
Var  e_hat1 e_hat2 e_hat3;
output out=Sample_Error (drop= _type_) Std(e_hat1)=Std_e1 Std(e_hat2)=Std_e2 Std(e_hat3)=Std_e3;
run;

data Var;
merge Sample_Error Mean_1(keep=Nn_m Rm_m);
Pop_N=32;
n_r=6;
n=8;

Var_Sam=Pop_N**2*(1-n/Pop_N)*Std_e1**2/n;
Std_Sam=sqrt(Var_Sam);
run;

data Rm;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e1**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=Rm_m*Pop_N;

run;

data Nn;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e2**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=Nn_m*Pop_N;
run;
data Ra;
set Var;
Var_Imp=Pop_N**2*(1-n_r/n)*Std_e3**2/n_r;
Std_Imp=sqrt(Var_Imp);
Std_Tot=sqrt(Var_Imp+Var_Sam);
Estimate=26669;
run;

data Rd;
set Var;
Estimate=Rm_m*Pop_N;
Std_Imp=0;
Var_Sam=Pop_N**2*(1-n_r/Pop_N)*Std_e1**2/n_r;
Std_Sam=sqrt(Var_Sam);
Std_Tot=Std_Sam;
run;

****************************
 Multiple Imputation
****************************;
data Sample;
set Sample;
mi1=UE91;
mi2=UE91;
mi3=UE91;
mi4=UE91;
mi5=UE91;
if id=18 then mi1=760;
if id=30 then mi1=142;

if id=18 then mi2=760;
if id=30 then mi2=721;

if id=18 then mi3=721;
if id=30 then mi3=219;

if id=18 then mi4=4123;
if id=30 then mi4=760;

if id=18 then mi5=760;
if id=30 then mi5=219;
run;

proc summary data=Sample ;
Var mi1 mi2 mi3 mi4 mi5 Nearest_n;
output out=Sample_mi Mean(mi1)=mi1_m Mean(mi2)=mi2_m Mean(mi3)=mi3_m Mean(mi4)=mi4_m Mean(mi5)=mi5_m Std(mi1)=mi1_Std Std(mi2)=mi2_Std Std(mi3)=mi3_Std Std(mi4)=mi4_Std Std(mi5)=mi5_Std;
run;

data Mi;
set Sample_mi;
Pop_N=32;
n=8;
n_r=6;
m=5;

Estimate=(1/m)*(mi1_m*Pop_N+mi2_m*Pop_N+mi3_m*Pop_N+mi4_m*Pop_N+mi5_m*Pop_N);


Var_Sam=1/m*(1-n/Pop_N)*Pop_N**2*(mi1_Std**2+mi2_Std**2+mi3_Std**2+mi4_Std**2+mi5_Std**2)/n;
Std_Sam=sqrt(Var_Sam);

apu=(mi1_m*Pop_N-Estimate)**2/(m-1)+ (mi2_m*Pop_N-Estimate)**2/(m-1) + (mi3_m*Pop_N-Estimate)**2/(m-1) + (mi4_m*Pop_N-Estimate)**2/(m-1) + (mi5_m*Pop_N-Estimate)**2/(m-1);
apu2=sqrt(apu);

Var_Imp=(1+1/m)*(apu);
Std_Imp=sqrt(Var_Imp);

Var_Tot=Var_Sam+Var_Imp;
Std_Tot=sqrt(Var_Tot);
run;

proc print data=Sample;
title2 "Multiple Imputed values";
Var id label UE91 mi1 mi2 mi3 mi4 mi5;
run;

proc print data=mi;
title2 "CorResponding Sample Means";
Var mi1_m mi2_m mi3_m mi4_m mi5_m;
run;
proc print data=mi;
title2 "CorResponding Sample standard Errors";
Var mi1_Std mi2_Std mi3_Std mi4_Std mi5_Std;
run;

data Fr;
Std_Tot=13282;
Std_Sam=13282;
Std_Imp=0;
Estimate=26440;
run;

data all;
set Rd Rm Mi Nn Ra Fr;
run;

proc print data=all;
title2 "Total Estimates and their corResponding standard Error components";
Var Estimate Std_Tot Std_Sam Std_Imp; 
run;

