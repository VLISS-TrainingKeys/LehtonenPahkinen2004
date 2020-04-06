* TRAINING KEY 298: Alternative multivariate analyses for the OHC Survey design;

* INSTRUCTIONS:

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
;

libname [your libname] "path to Ohc data in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example:  set a.ohc;
run;


proc summary data=Ohc nway;
class stratum cluster;
output out=a (keep=stratum cluster);
run;

data a;
set a;
subject + 1;
run;

data Ohc;
merge a Ohc;
by stratum cluster;
run;

*A) ACCOUNTING FOR CLUSTERING EFFECTS FOR A CONTINOUS STUDY VARIABLE;

***************************************************************
SUDAAN PROCEDURE REGRESS
***************************************************************
Inferential approach: Design-based

Accounting for stratification and clustering:
            NEST statement,
            Option DESIGN=WR.

Model formulation and estimation method: 
            Fixed-effects model, 
            Estimation: QML (Quasi maximum likelihood), 
            Exchangeable correlation structure (option R=EXCH), 
            Robust SE (standard error) method, 
            Linearization method in SE estimation.

CODE for the analysis of the model 
PSYCH = Intercept + AGE + SEX + CHRON:
;
proc regress data=Ohc design=wr r=exchangeable;
nest stratum cluster;
weight _one_;
model psych=age sex chron;
print /style=nchs;
run;

***************************************************************
SAS PROCEDURE SURVEYREG
***************************************************************
Inferential approach: Design-based

Accounting for stratification and clustering:
            STRATA statement,
            CLUSTER statement.

Model formulation and estimation method: 
            Fixed-effects model, 
            Estimation: Taylor expansion method. 

CODE for the analysis of the model 
PSYCH = Intercept + AGE + SEX + CHRON:
;

proc surveyreg data=Ohc;
cluster Cluster;
strata Stratum;
model psych=Sex Age Chron / solution;
run;


***************************************************************
SAS PROCEDURE MIXED
***************************************************************
Inferential approach: Model-based

Accounting for clustering:
            REPEATED and RANDOM statements (SUBJECT=CLUSTER),

Model formulation and estimation method: 
            Mixed model (variance components model, TYPE=VC), 
            Estimation: REML (Restricted maximum likelihood),       
            Robust SE (standard error) method (option EMPIRICAL).

CODE for the analysis of the model 
PSYCH = Intercept + AGE + SEX + CHRON:
;
proc mixed data=Ohc empirical method=reml;
class subject;
model psych=age sex chron/solution;
repeated / subject=subject type=vc;
run;


***************************************************************
SAS PROCEDURE GENMOD
***************************************************************
Inferential approach: Model-based

Accounting for clustering:
            REPEATED statement (SUBJECT=SUBJECT),

Model formulation and estimation method: 
            Fixed-effects model, 
            Estimation: GEE (Generalized estimation equations), 
            Exchangeable correlation structure,
            Robust SE (standard error) method

CODE for the analysis of the model 
PSYCH = Intercept + AGE + SEX + CHRON:
;
proc genmod data=Ohc;
class subject;
model psych=age sex chron /dist=normal link=identity;
repeated subject=subject / type=exch;
run;


***************************************************************
SAS PROCEDURE REG
***************************************************************
Inferential approach: Model-based

Accounting for clustering: None.

Model formulation and estimation method: 
            Fixed-effect model, 
            Estimation: ML (Maximum likelihood), 
            Model-based SE (standard error) method.

CODE for the analysis of the model 
PSYCH = Intercept + AGE + SEX + CHRON:
;
proc reg data=Ohc;
model psych=age sex chron;
run;

