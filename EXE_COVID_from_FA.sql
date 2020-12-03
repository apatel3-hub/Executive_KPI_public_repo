SET SQLBLANKLINES on ;

ALTER SESSION ENABLE PARALLEL DML;

EXEC HCA_SNDBX.PR_TRUNCATE_TAB('EXE_KPI_COVID_19') ;

INSERT /*+ APPEND PARALLEL (4) */
INTO HCA_SNDBX.EXE_KPI_COVID_19 
   (	"CLAIM_ID", 
	"CLCL_CL_SUB_TYPE" , 
	"PLAN_CD", 
	"MEME_RECORD_NO", 
	"YR_DATE_KEY" , 
	"YR_DATE_DT", 
	"CLAIM_COUNT", 
	"LOBD_ID" , 
	"RUN_DATE" , 
	"Final_Test_Rslt" , 
	"DRVD_CO_NM", 
	"DRVD_LOB_CAT", 
	"Business_Cat_Desc"
   )

SELECT
      CLCL_ID AS CLAIM_ID
     ,CLCL_CL_SUB_TYPE
    , PLAN_CD
    , MEME_RECORD_NO
    ,TO_NUMBER( TO_CHAR(HDR_LOW_SVC_DT, 'YYYYMMDD'), '99999999') AS YR_DATE_KEY
    ,HDR_LOW_SVC_DT AS YR_DATE_DT
    , SUM(CLM_LINE_NO) AS CLAIM_COUNT
    , LOBD_ID
    , RUN_DATE
    , "Final_Test_Rslt"
    , "LOB_Name" AS DRVD_CO_NM
    ,CASE
                WHEN "Business_Cat_Desc" = 'COMMERCIAL'
                     AND LOBD_ID IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN "Business_Cat_Desc" = 'MEDICARE ADVANTAGE' THEN
                    'MEDICARE'
                WHEN LOBD_ID = '5000'    THEN
                    'MEDICAID'
                 WHEN    SUBSTR(LOBD_ID,1,1) = '6' THEN 'ASO'
                ELSE
                    "Business_Cat_Desc"
            END AS DRVD_LOB_CAT
            ,"Business_Cat_Desc"
FROM
    "APATEL3"."Covid_19_raw_df"
GROUP BY    
      CLCL_ID
     ,CLCL_CL_SUB_TYPE
    , PLAN_CD
    , MEME_RECORD_NO
    , TO_NUMBER( TO_CHAR(HDR_LOW_SVC_DT, 'YYYYMMDD'), '99999999') 
    ,HDR_LOW_SVC_DT
    , LOBD_ID
    , RUN_DATE
    , "Final_Test_Rslt"
    , "LOB_Name" 
    ,CASE
                WHEN "Business_Cat_Desc" = 'COMMERCIAL'
                     AND LOBD_ID IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN "Business_Cat_Desc" = 'MEDICARE ADVANTAGE' THEN
                    'MEDICARE'
                WHEN LOBD_ID = '5000'    THEN
                    'MEDICAID'
                 WHEN    SUBSTR(LOBD_ID,1,1) = '6' THEN 'ASO'
                ELSE
                    "Business_Cat_Desc"
            END 
            ,"Business_Cat_Desc" ;
            
COMMIT ; 