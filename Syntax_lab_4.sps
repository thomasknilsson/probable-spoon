* Encoding: UTF-8.
*Sex_dummy Male 1 female 0

RECODE sex ('male'=1) ('female'=0) (MISSING=SYSMIS) INTO sex_dummy.
EXECUTE.

*Intercept model

DATASET ACTIVATE DataSet1.
MIXED pain WITH sex_dummy age STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=sex_dummy age STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=CPS CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

*null model

MIXED pain WITH sex_dummy age STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0,
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=PRED RESID.

*variance fixedpredictors

DESCRIPTIVES VARIABLES=FXPRED_int
  /STATISTICS=MEAN SUM STDDEV VARIANCE MIN MAX.

*Dataset B

DATASET ACTIVATE DataSet1.
RECODE sex ('male'=1) ('female'=0) (MISSING=SYSMIS) INTO sex_dummy_male.
EXECUTE.

*pain prediction from equation

COMPUTE pain_prediction=3.502 + sex_dummy_male * 0.298 + age *  - 0.054 + STAI_trait * 0.001 + 
    pain_cat * 0.037 + cortisol_serum * 0.610 + mindfulness *  - 0.262.
EXECUTE.

*Residual Error

COMPUTE Resid_err=pain - pain_prediction.
EXECUTE.

*RSS

COMPUTE RSS=Resid_err * Resid_err.
EXECUTE.

*null model with residuals

MIXED pain WITH sex_dummy_male age STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=RESID.

*RSS null model

COMPUTE RSS_null_TSS=RESID_null * RESID_null.
EXECUTE.

*RSS and TSS

DESCRIPTIVES VARIABLES=RSS_pred_pain RSS_null
  /STATISTICS=MEAN SUM STDDEV MIN MAX.

