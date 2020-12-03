
CREATE TABLE EXE_KPI_TELEHLTHVIS
   (	"CLM_LINE_LOB_CD" VARCHAR2(30 BYTE), 
	"CLM_PROD_BSNS_CAT_CD" VARCHAR2(30 BYTE), 
	"DRVD_CO_NM" VARCHAR2(100 BYTE), 
	"DRVD_LOB_CAT" VARCHAR2(10 BYTE), 
	"YR_MNTH_KEY" NUMBER, 
	"YR_MNTH_DT" DATE, 
    "CLM_SRVC_FROM_DT" DATE,
	"CLAIMS_COUNT" NUMBER, 
	"CLM_LINE_PAID_AMT" NUMBER, 
	"DRVD_TOTAL_PAID_AMT" NUMBER
   ) ;