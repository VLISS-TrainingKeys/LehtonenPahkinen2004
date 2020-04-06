* TRAINING KEY 298: Alternative multivariate analyses for the OHC Survey design;

* INSTRUCTIONS:

1) FILL in the LIBNAME Statement and first DATA STEP to gain access to OHC data.
2) Submit LIBNAME and DATA statements. Check Log window. Everything went fine? 
;
libname [your libname] "path to Ohc data in your computer";
*Example: libname a "u:\VLISS\datat\";

data Ohc;
set [your libname].Ohc;
*Example: set a.ohc;
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



*B) ACCOUNTING FOR CLUSTERING EFFECTS FOR A BINARY STUDY VARIABLE; 


***************************************************************
SUDAAN PROCEDURE RLOGIST
***************************************************************
Inferential approach: Design-based

Accounting for stratification and clustering
            NEST statement,
            Option DESIGN=WR.

Model formulation and estimation method: 
            Fixed-effects model, 
            Estimation: QML (Quasi maximum likelihood), 
            Exchangeable correlation structure (option R=EXCH), 
            Robust SE (standard error) method, 
            Linearization method in SE estimation.

CODE for the analysis of the model 
PSYCH2 = Intercept + AGE + SEX + CHRON:
;
proc rlogist data=Ohc design=wr deft1 r=exchangeable;
nest stratum cluster;
weight _one_;
model psych2=age sex chron;
setenv decwidth=4;
print /style=nchs;
run;

***************************************************************
GLIMMIX-MACRO
***************************************************************
Inferential approach: Model-based

Accounting for clustering:
            REPEATED and RANDOM statements (SUBJECT=CLUSTER),

Model formulation and estimation method: 
            Mixed model (variance components model, TYPE=VC), 
            Estimation: REML (restricted maximum likelihood) producing REML 
                        variance component estimates. REML estimates produce
                        REPL (restricted pseudo  likelihood) estimation of the generalized linear mixed model, 
            Robust SE method (EMPIRICAL option in PROC statement) .

CODE for the analysis of the model 
PSYCH2 = Intercept + AGE + SEX + CHRON:
;

%include 'path to SAS macro GLIMMIX in your computer';
%glimmix(data=Ohc, 
procopt=empirical method=reml,
stmts=%str(
class subject;
model psych2=age sex chron /solution;
repeated / subject=subject type=vc;),
link=logit);
quit;


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

CODE for the analysis of the model PSYCH = Intercept + AGE + SEX + CHRON:
;
proc genmod data=Ohc descending;
class subject;
model psych2=age sex chron /dist=bin link=logit;
repeated subject=subject / type=exch;
run;


***************************************************************
SAS PROCEDURE GENMOD under the reference option
***************************************************************
Inferential approach: Model-based

Accounting for clustering: None

Model formulation and estimation method: 
            Fixed-effects model, 
            Estimation: ML (Maximum likelihood), 
            Model-based SE method

CODE for the analysis of the model PSYCH = Intercept + AGE + SEX + CHRON:
;
proc genmod data=Ohc descending;
model psych2=age sex chron /dist=bin link=logit;
run;
