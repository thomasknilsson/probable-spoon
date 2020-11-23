* Encoding: UTF-8.
*Sex dummy coded 1 male 0 female

DATASET ACTIVATE DataSet1.
RECODE sex ('male'=1) ('female'=0) INTO sex_male.
EXECUTE.

*Correlations day1-4

CORRELATIONS
  /VARIABLES=pain1 pain2 pain3 pain4
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*Random Intercept model

MIXED pain_rating WITH sex_male age STAI_trait pain_cat cortisol_serum mindfulness time
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=sex_male age STAI_trait pain_cat cortisol_serum mindfulness time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.

*Random slope model

MIXED pain_rating WITH sex_male age STAI_trait pain_cat cortisol_serum mindfulness time
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=sex_male age STAI_trait pain_cat cortisol_serum mindfulness time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

*Time centered

DATASET ACTIVATE DataSet2.
COMPUTE centered_time=time - 2.5.
EXECUTE.

*Time centered squared

DATASET ACTIVATE DataSet2.
COMPUTE centered_time_squared=centered_time * centered_time.
EXECUTE.


*Random intercept model with time cnetered and squared

MIXED pain_rating WITH sex_male age STAI_trait pain_cat cortisol_serum mindfulness centered_time 
    centered_time_sq
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=sex_male age STAI_trait pain_cat cortisol_serum mindfulness centered_time centered_time_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.

*Random slope model with time centered and squared

MIXED pain_rating WITH sex_male age STAI_trait pain_cat cortisol_serum mindfulness centered_time 
    centered_time_sq
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=sex_male age STAI_trait pain_cat cortisol_serum mindfulness centered_time centered_time_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT centered_time centered_time_sq | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(Paint_rating)[name="MEAN_Paint_rating"] 
    data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: MEAN_Paint_rating=col(source(s), name("MEAN_Paint_rating"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("Mean Paint_rating"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of Paint_rating by time by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time*MEAN_Paint_rating), color.interior(data_type), missing.wings())
END GPL.


DATASET ACTIVATE DataSet1.
COMPUTE Resid_sq=RESID_slope_timesq * RESID_slope_timesq.
EXECUTE.

SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT resid_sq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.
