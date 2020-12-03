SET SQLBLANKLINES on ;

ALTER SESSION ENABLE PARALLEL DML;

EXEC HCA_SNDBX.PR_TRUNCATE_TAB('EXE_KPI_ER_OFFICEVISITS') ;
   
INSERT /*+ APPEND PARALLEL (4) */
INTO HCA_SNDBX.EXE_KPI_ER_OFFICEVISITS (
	"ER_CPT_LEVEL" ,
	"CLM_LINE_LOB_CD" ,
	"CLM_PROD_BSNS_CAT_CD" , 
	"DRVD_CO_NM",
	"DRVD_LOB_CAT",
	"YR_MNTH_KEY",
	"YR_MNTH_DT" ,
    	"CLM_LINE_PROC_CD",
	"CAT_FLAG" , 
	"CLAIM_COUNT" ,
	"DRVD_TOTAL_PAID_AMT",
  "ER_OFFICE_FLAG" 

)
    WITH DYNAMIC_DATE AS (
            SELECT
                MAX(YR_MNTH_KEY) - 20200 AS MIN_DATE
            FROM
                DM_FNC.PRFTBLTY_FACT
        )
      
    SELECT  /*+ PARALLEL (4) */
            ER.ER_CPT_LEVEL
            , ER.CLM_LINE_LOB_CD
            , ER.CLM_PROD_BSNS_CAT_CD
            , LB.LOB_NM AS DRVD_CO_NM
            , CASE
                WHEN ER.CLM_PROD_BSNS_CAT_CD = 'COMM'
                     AND ER.CLM_LINE_LOB_CD IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN ER.CLM_PROD_BSNS_CAT_CD = 'MA' THEN
                    'MEDICARE'
                WHEN ER.CLM_LINE_LOB_CD = '5000'       THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END AS DRVD_LOB_CAT
            ,TO_NUMBER(TO_CHAR(TO_DATE(TRUNC(ER.ADMIT_DATE, 'MONTH'), 'DD-MON-YY'), 'YYYYMMDD'), '99999999') AS YR_MNTH_KEY
            , TRUNC(ER.ADMIT_DATE, 'MONTH') AS YR_MNTH_DT
            ,NULL AS CLM_LINE_PROC_CD
            , ER.CAT_FLAG
            , COUNT(DISTINCT(ER.EVENT_ID)) AS CLAIM_COUNT
          --  , COUNT(DISTINCT(ER.CLM_MEM_V3_KEY)) AS MEMBER_COUNT
            , (SUM(ER.FAC_PAID) + SUM(ER.PRO_PAID) )AS DRVD_TOTAL_PAID_AMT
            ,'ER_VISITS' AS   ER_OFFICE_FLAG
        FROM
            schema.ER_FAC_SUMM   ER
          , DYNAMIC_DATE      DD
            , schema.LOB                LB
        WHERE
            TO_NUMBER(TO_CHAR(TO_DATE(TRUNC(ER.ADMIT_DATE, 'MONTH'), 'DD-MON-YY'), 'YYYYMMDD'), '99999999') >= DD.MIN_DATE
            AND ER.CLM_LINE_LOB_CD = LB.LOB_CD
            AND LB.DW_CUR_IND = 'Y'
            AND ER.CLM_LINE_LOB_CD IN (
                '1000'
                , '4000'
                , '5000'
            )
        GROUP BY
           ER.ER_CPT_LEVEL
            , ER.CLM_LINE_LOB_CD
            , ER.CLM_PROD_BSNS_CAT_CD
            , LB.LOB_NM 
            , CASE
                WHEN ER.CLM_PROD_BSNS_CAT_CD = 'COMM'
                     AND ER.CLM_LINE_LOB_CD IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN ER.CLM_PROD_BSNS_CAT_CD = 'MA' THEN
                    'MEDICARE'
                WHEN ER.CLM_LINE_LOB_CD = '5000'       THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END
            , TO_NUMBER(TO_CHAR(TO_DATE(TRUNC(ER.ADMIT_DATE, 'MONTH'), 'DD-MON-YY'), 'YYYYMMDD'), '99999999')
            , TRUNC(ER.ADMIT_DATE, 'MONTH') 
            ,NULL
            ,ER.CAT_FLAG
            , 'ER_VISITS'
            
 
UNION ALL

        SELECT  /*+ PARALLEL (4) */      
            NULL AS ER_CPT_LEVEL
             ,CLM.CLM_LINE_LOB_CD
            , CLM.CLM_PROD_BSNS_CAT_CD
            , LB.LOB_NM AS DRVD_CO_NM
            , CASE
                WHEN CLM.CLM_PROD_BSNS_CAT_CD = 'COMM'
                     AND CLM.CLM_LINE_LOB_CD IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN CLM.CLM_PROD_BSNS_CAT_CD = 'MA' THEN
                    'MEDICARE'
                WHEN CLM.CLM_LINE_LOB_CD = '5000'  THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END AS DRVD_LOB_CAT
            , TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999') AS YR_MNTH_KEY
            ,TO_DATE(TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999') ,'YYYYMMDD')AS YR_MNTH_DT
            , CLL.CLM_LINE_PROC_CD
            ,NULL AS   CAT_FLAG
            , COUNT(DISTINCT CLM.CLM_SRC_ID) AS CLAIM_COUNT
            , SUM(CLM.DRVD_TOT_CLM_PAID_AMT) AS DRVD_TOTAL_PAID_AMT
            , 'OFFICE_VISITS' AS  ER_OFFICE_FLAG
        FROM
            SCHEMA.MED_CLM               CLM
            , SCHEMA.MED_CLM_LINE          CLL
            , DYNAMIC_DATE              DD
            , SCHEMA.LOB                LB
        WHERE
            CLM.MED_CLM_KEY = CLL.MED_CLM_KEY
            AND CLL.CLM_SUB_TYPE_CD = 'M'
            AND CLL.CLM_LINE_PROC_CD IN (
                  '99201'
                , '99202'
                , '99203'
                , '99204'
                , '99205'
                , '99211'
                , '99212'
                , '99213'
                , '99214'
                , '99215'
            )
            AND CLM.DRVD_CLM_DENY_IND = 'N'
            AND CLM.DRVD_CLM_FNL_VIEW_IND = 'Y'
            AND CLM.CLM_STS_CD IN (
                '02'
                , '14'
            )
            AND CLM.CLM_SRVC_FROM_DT >= DD.MIN_DATE
            AND CLM.DRVD_CLM_PAID_PERD_DT >= 20180100
            AND  CLM.CLM_LINE_LOB_CD = LB.LOB_CD
            AND LB.DW_CUR_IND = 'Y'
            AND CLM.CLM_LINE_LOB_CD IN (
                  '1000'
                , '4000'
                , '5000'
            )
        GROUP BY
        NULL
             ,CLM.CLM_LINE_LOB_CD
            , CLM.CLM_PROD_BSNS_CAT_CD
            , LB.LOB_NM
            , CASE
                WHEN CLM.CLM_PROD_BSNS_CAT_CD = 'COMM'
                     AND CLM.CLM_LINE_LOB_CD IN (
                    '1000'
                    , '4000'
                ) THEN
                    'COMMERCIAL'
                WHEN CLM.CLM_PROD_BSNS_CAT_CD = 'MA' THEN
                    'MEDICARE'
                WHEN CLM.CLM_LINE_LOB_CD = '5000'       THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END 
            , TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999')
            ,TO_DATE(TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999') ,'YYYYMMDD')
            , CLL.CLM_LINE_PROC_CD
            ,'OFFICE_VISITS'  
            ;

--EXEC DBMS_STATS.GATHER_TABLE_STATS('APATEL3', 'EXE_KPI_ER_OFFICEVISITS');

COMMIT ; 

