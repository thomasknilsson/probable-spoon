* Encoding: UTF-8.



* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Sex COUNT()[name="COUNT"] Survived MISSING=LISTWISE
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.

* Chart Builder.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Sex=col(source(s), name("Sex"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Sex"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Sex by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Sex*COUNT), color.interior(Survived),
    shape.interior(shape.square))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived),
    shape.interior(shape.square))
END GPL.

DATASET ACTIVATE DataSet1.
RECODE Pclass (1=1) (ELSE=0) INTO Class_1.
EXECUTE.

RECODE Pclass (2=1) (ELSE=0) INTO Class_2.
EXECUTE.

CORRELATIONS
  /VARIABLES=Age Female Has_Sibling_Spouse two_parentsorchild has_cabin Class_1 Class_2
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Female Class_1 Class_2 Age Has_Sibling_Spouse two_parentsorchild 
  /PRINT=CORR CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Female Class_1 Class_2 Age Has_Sibling_Spouse 
    two_parentsorchild
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.
