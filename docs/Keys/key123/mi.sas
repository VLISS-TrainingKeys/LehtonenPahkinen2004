****************************
 Multiple Imputation macro
****************************;

**Multiple Imputation macro to make your own Samples and multiple Imputation configurations.
In the second survey select point you must change the number of nonResponse cases From the Sample
selected in the first Sample selection procedure. And just below this is an note to change also
the number of columns that are changed (number of nonResponse cases);

data Province91;
input STR CLU Id Label $ 10-22 UE91 HOU85;
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

%macro MI(data,n,seed,rep,Var);

data Province91;
set Province91;
Res_Pop=1;
if Id=18 or Id=9 or Id=22 or Id=21 or Id=30 then Res_Pop=2;
run;


proc surveyselect data=&data out=Sample n=&n method=SRS seed=&seed;
title1 "Multiple Imputation";
title2 "Selecting an SRSWOR Sample";
run;

proc Summary data=Sample;
Var UE91;
class Res_Pop;
output out=n Sum=;
run;

proc iml;
use n Var{_FrEQ_};
read All into help;
Pop_n=32;
n=help[1,1];
n_r=help[2,1];
non_r=n-n_r;
create Nn Var{Pop_n n n_r non_r};
append;
close Nn;
run;
quit;

data Sample;
set Sample;
Fr=&Var;
if Res_Pop=2 then &Var=.;
array mi(&rep) mi1-mi&rep;
do i=1 to &rep;
    mi(i)=&Var;
	end;
run;

proc sort data=Sample;
by UE91;
run;

*NOTE: Here you have to chance. In n you must change the number of missing items;
proc surveyselect data=Sample out=Repl n=2 method=SRS rep=&rep seed=&seed;
title2 "Selecting an SRSWOR Sample (Imputations)";
where UE91 ne .;
run;

data Repl;
set Repl(keep=Replicate UE91);
rename UE91=UE91mi;
run;

proc transpose data=Repl
     out=Repl;
     Var UE91mi;
     by Replicate;
run;
*NOTE: In col2 you must change the number of missing items col*;
proc transpose data=Repl(keep=col1-col2)
     out=Repl(rename=(col1-col&rep=mi1-mi&rep));
run;

data Sample;
merge Sample Repl;
run;

proc Summary data=Sample ;
Var mi1-mi&rep Fr;
output out=Sample_mi Mean=mmi1-mmi&rep Std=Std1-Std&rep Mean(Fr)=Fr_m Std(Fr)=Fr_Std;
run;

proc transpose data=Sample_mi(keep=mmi1-mmi&rep)
	out=Apu2(rename=col1=mi); 
	Var mmi1-mmi&rep;
run;
proc transpose data=Sample_mi(keep=Std1-Std&rep)
	out=Apu3(rename=col1=Std); 
	Var Std1-Std&rep;
run;


data Apu4;
if _n_=1 then set Nn;
merge Apu2 Apu3; 
Estimate=mi*Pop_n/&rep;
Var_Sam=1/&rep*(1-n/Pop_n)*Pop_n**2*Std**2/n;
run;

proc Summary data=Apu4;
Var Estimate Var_Sam;
output out=Sum (rename= (Estimate=Est Var_Sam=Var_Sam2))Sum=;
run;

data Sum2;
set Apu4;
if _n_=1 then set Sum;
if _n_=1 then set Nn;
Apu=(mi*Pop_n-Est)**2/(&rep-1);
run;
proc Summary data=Sum2;
Var Apu;
output out=Sum3 Sum=;
run;

data All2;
merge Sum Sum3;

Var_Imp=(1+1/&rep)*(Apu);
Std_Imp=sqrt(Var_Imp);

Std_Sam=sqrt(Var_Sam2);

Var_Tot=Var_Sam2+Var_Imp;
Std_Tot=sqrt(Var_Tot);
run;

proc print data=Sample;
title2 "Multiple Imputed values";
Var Id Label UE91 mi1-mi&rep;
run;

proc print data=Sample_mi;
title2 "CorResponding Means";
Var mmi1-mmi&rep;
run;
proc print data=Sample_mi;
title2 "CorResponding standard errors";
Var Std1-Std&rep;
run;

data Fr;
if _n_=1 then set Nn;
set Sample_mi(keep=Fr_m Fr_Std);
Std_Tot=sqrt(Pop_n**2*(1-&n/Pop_n)*(1/&n)*Fr_Std**2);
Std_Sam=Std_Tot;
Std_Imp=0;
Estimate=Fr_m*Pop_n;
run;

data All;
set  All2(rename=Est=Estimate)  Fr;
run;

proc print data=All;
title2 "Total Estimates and their corResponding standard error components";
Var Estimate Std_Tot Std_Sam Std_Imp; 
run;

%mend;

%MI(Province91,8,987654321,5,UE91);