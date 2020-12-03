SET SQLBLANKLINES on ;

ALTER SESSION ENABLE PARALLEL DML;

EXEC HCA_SNDBX.PR_TRUNCATE_TAB('EXE_KPI_TELEHLTHVIS') ;
   
INSERT /*+ APPEND PARALLEL (4) */
INTO HCA_SNDBX.EXE_KPI_TELEHLTHVIS(
"CLM_LINE_LOB_CD" , 
	"CLM_PROD_BSNS_CAT_CD" , 
	"DRVD_CO_NM" , 
	"DRVD_LOB_CAT", 
	"YR_MNTH_KEY" , 
	"YR_MNTH_DT" , 
    	"CLM_SRVC_FROM_DT",
	"CLAIMS_COUNT" , 
	"CLM_LINE_PAID_AMT" , 
	"DRVD_TOTAL_PAID_AMT" 
)

      WITH DYNAMIC_DATE AS (
            SELECT
                MAX(YR_MNTH_KEY) - 20200 AS MIN_DATE
            FROM
                DM_FNC.PRFTBLTY_FACT
        )
        SELECT  /*+ PARALLEL (4) */
            CLM.CLM_LINE_LOB_CD
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
                WHEN CLM.CLM_LINE_LOB_CD = '5000'    THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END AS DRVD_LOB_CAT
            , TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999') AS YR_MNTH_KEY
            , TO_DATE(TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                                || '01', '99999999'), 'YYYYMMDD') AS YR_MNTH_DT
            , TO_DATE(CLM.CLM_SRVC_FROM_DT, 'YYYYMMDD') AS CLM_SRVC_FROM_DT
            , COUNT(DISTINCT CLM.CLM_SRC_ID) AS CLAIMS_COUNT
            , SUM(CLL.CLM_LINE_PAID_AMT) AS CLM_LINE_PAID_AMT
            ,SUM(CLM.DRVD_TOT_CLM_PAID_AMT) AS DRVD_TOTAL_PAID_AMT
        FROM
              SCHEMA.MED_CLM        CLM
            , SCHEMA.MED_CLM_LINE   CLL
            , SCHEMA.PROV           PROV
            , SCHEMA.LOB            LB
            ,DYNAMIC_DATE DD
        WHERE
            CLM.MED_CLM_KEY = CLL.MED_CLM_KEY
            AND CLM.CLM_SRVCNG_PROV_ID = PROV.PROV_ID
                        AND  CLM.CLM_LINE_LOB_CD = LB.LOB_CD
            AND LB.DW_CUR_IND = 'Y'
          AND CLL.CLM_SUB_TYPE_CD = 'M'
            AND ( CLL.DRVD_CLM_LINE_POS_CD = '02'
                  OR PROV.PROV_NM = 'ONLINE CARE NETWORK II PC'
                  OR CLL.CLM_LINE_PROC_MDFR1_CD IN (
                '95'
                , 'G0'
                , 'GQ'
                , 'GT'
            )
                  OR CLL.CLM_LINE_PROC_MDFR2_CD IN (
                '95'
                , 'G0'
                , 'GQ'
                , 'GT'
            )
                  OR CLL.CLM_LINE_PROC_MDFR3_CD IN (
                '95'
                , 'G0'
                , 'GQ'
                , 'GT'
            )
                  OR CLL.CLM_LINE_PROC_CD IN (
                '98966'
                , '98967'
                , '98968'
                , '99421'
                , '98970'
                , '98971'
                , '98972'
                , '99422'
                , '99423'
                , '99441'
                , '99442'
                , '99443'
                , '99444'
                , '99446'
                , '99447'
                , '99448'
                , '99449'
                , '99451'
                , '99452'
                , 'G0071'
                , 'G0406'
                , 'G0407'
                , 'G0408'
                , 'G0425'
                , 'G0426'
                , 'G0427'
                , 'G0459'
                , 'G0508'
                , 'G0509'
                , 'G2010'
                , 'G2012'
                , 'G2061'
                , 'G2062'
                , 'G2063'
                , 'G2086'
                , 'G2087'
                , 'G2088'
            ) )
            AND PROV.DW_CUR_IND = 'Y'
            AND CLM.DRVD_CLM_DENY_IND = 'N'
            AND CLM.DRVD_CLM_FNL_VIEW_IND = 'Y'
            AND CLM.CLM_STS_CD IN (
                '02'
                , '14'
            )
              AND CLM.CLM_LINE_LOB_CD IN (
                  '1000'
                , '4000'
                , '5000'
            )
           AND CLM.CLM_SRVC_FROM_DT >= DD.MIN_DATE
            AND CLM.DRVD_CLM_PAID_PERD_DT > 20180100
        GROUP BY
         CLM.CLM_LINE_LOB_CD
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
                WHEN CLM.CLM_LINE_LOB_CD = '5000'    THEN
                    'MEDICAID'
                ELSE
                    'OTHERS'
            END
            , TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                        || '01', '99999999') 
            , TO_DATE(TO_NUMBER(SUBSTR(CLM.CLM_SRVC_FROM_DT, 1, 6)
                                || '01', '99999999'), 'YYYYMMDD') 
            ,TO_DATE(CLM.CLM_SRVC_FROM_DT, 'YYYYMMDD') 

;

--EXEC DBMS_STATS.GATHER_TABLE_STATS('APATEL3', 'EXE_KPI_TELEHLTHVIS');

COMMIT ; 
