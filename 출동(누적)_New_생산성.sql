SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

SET ARITHABORT OFF 
SET ARITHIGNORE OFF
SET ANSI_WARNINGS OFF 
SET DATEFIRST 1                 -- 주차 시작일 변경(1:월, 2:화.........7:일)

DECLARE @S_DATE NVARCHAR(10) 
DECLARE @E_DATE NVARCHAR(10) 

SET @S_DATE='2023-11-01'
SET @E_DATE='2023-11-15'


SELECT YY,MM  -- ,DD
       ,그룹명,담당명,부서명,사번,USER_ID_NM
    --  ,주중구분
			,SUM(개통건) 주간개통
			,SUM(장애건) 주간장애
			,SUM(출동건) 주간출동

			,SUM(야간개통건) 야간개통
			,SUM(야간장애건) 야간장애			
			,SUM(야간출동건) 야간출동

			,COUNT(DISTINCT YYMMDD) 근무일수
			,SUM(근무자) 근무자
					   			 
FROM (

SELECT	YYMMDD,YY							-- 실적연도
			,MM					  	    -- 실적월
			,DD							-- 실적일
			,wk
	--		,VOCDAYADD
	--        ,CASE	WHEN 주중구분 = '주중'      THEN '평일'
	--				WHEN 주중구분 = '토요일'    THEN '주말'
	--				WHEN 주중구분 = '일요일'    THEN '주말'
	--				ELSE '평일' END 주중구분
	--		,주중구분
	--		,주야간구분
	--		,NUM
			,그룹명,담당명,부서명
		--	,BB.HNS_YN					-- 작업자 실제 소속 HnS소속여부
			,BB.CTZ_SER_NUM
		--	,BB.LOGIN_ID			-- 작업자ID
			,USER_ID_NM					-- 작업자ID명
		--	,CASE WHEN BB.WRK_CO_ID_SUM = AA.WRK_CO_ID_SUM	 THEN '자체처리'
		--			ELSE '지원처리' END 자체처리여부
		    ,현장여부
			,직무명
			,사번

,SUM(CASE WHEN GBN = '개통' AND 주야간구분 = '주간' THEN 출동건 ELSE 0 END) 개통건	
,SUM(CASE WHEN GBN = '장애' AND 주야간구분 = '주간' THEN 출동건 ELSE 0 END) 장애건		
,SUM(CASE WHEN GBN = '개통' AND 주야간구분 = '주간' THEN 출동건 ELSE 0 END) 
                     + SUM(CASE WHEN GBN = '장애' AND 주야간구분 = '주간' THEN 출동건 ELSE 0 END)  출동건	

,SUM(CASE WHEN GBN = '개통' AND 주야간구분 = '야간' THEN 출동건 ELSE 0 END) 야간개통건	
,SUM(CASE WHEN GBN = '장애' AND 주야간구분 = '야간' THEN 출동건 ELSE 0 END) 야간장애건				
,SUM(CASE WHEN GBN = '개통' AND 주야간구분 = '야간' THEN 출동건 ELSE 0 END)  
                     + SUM(CASE WHEN GBN = '장애' AND 주야간구분 = '야간' THEN 출동건 ELSE 0 END)  야간출동건	

,COUNT(DISTINCT YYMMDD) 근무일수
,COUNT(DISTINCT BB.CTZ_SER_NUM) 근무자


FROM
(
		SELECT	'개통'GBN,YYMMDD,YY,MM,DD,wk
					,NWHQ,TEAM
					,OPER_CO_ID,OPER_CO_NM
					,WRK_CO_ID_SUM,MG_CO_NM_SUM
					,TYPE
					,RTRIM(LST_OPERTR_ID)LST_OPERTR_ID
					,HnS여부
					,VOCDAYADD,주중구분,주야간구분,NUM
				
		,COUNT(DISTINCT LST_OPERTR_ID) AS 작업자수
		,COUNT(DISTINCT B.YYMMDD ) AS 근무일수
		,COUNT(*) AS 출동건

		FROM
		(
		SELECT YYMMDD,YY,MM,DD,wk,TYPE,NWHQ,TEAM,OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD,OPER_ORD_ST_CD
		         ,VOCDAYADD
		         ,CASE	WHEN VOCDAYADD = '공휴일' THEN '일요일'
						WHEN VOCDAYADD = '일요일' THEN '일요일'						
						WHEN VOCDAYADD = '토요일' THEN '토요일'
						WHEN VOCDAYADD = '월요일' AND YYMMDD = '2020-08-17' THEN '일요일'
						ELSE '주중' END 주중구분
				,CASE WHEN ( DATEPART(HH,최초완료시간) IN (18,19,20,21,22,23)) THEN '야간' ELSE '주간' END 주야간구분				
				,HnS여부
				,NUM
					
				,COUNT(*) AS 고객수
				
					FROM 
					( 
					SELECT	CAST(STAT_DT AS DATE)YYMMDD,DATEPART(YY,STAT_DT)YY,DATEPART(MM,STAT_DT)MM,DATEPART(DD,STAT_DT)DD,DATEPART(wk,STAT_DT)wk
							,TYPE,NWHQ,TEAM,A.OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD
							,OPER_ORD_ST_CD,MIN(SVSET_FNSH_NOTI_DTM) AS 최초완료시간
							,HNS_YN HnS여부,VOCDAYADD,NUM
		
					
					,COUNT(*) AS TOTAL		
					
					
					from Issue_SB_DBM A 
							INNER JOIN ( SELECT SVC_CHG_CD, SVC_CHG_RSN_CD, GUBUN, ISNEW, INCLUDE FROM CHGCode 
										WHERE ISNEW = 'Y' AND INCLUDE = 'Y' ) B
							ON A.SVC_CHG_CD = B.SVC_CHG_CD AND A.SVC_CHG_RSN_CD = B.SVC_CHG_RSN_CD
							
							INNER JOIN ( SELECT DISTINCT MSVC_ORG_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,ISUNION,TYPE,HNS_YN FROM Teammapping_new_MAP ) C		-- 관리유통망 기준 JOIN
							ON A.MSVCORG_ID = C.MSVC_ORG_ID							
				
							INNER JOIN VOCWeekDay U
							ON CAST(A.STAT_DT AS DATE) = U.YYMMDD
						
					WHERE STAT_DT >= @S_DATE AND STAT_DT < @E_DATE
							AND GUBUN IN ('신규','변경')
							--AND A.SVC_CHG_CD <> 'C8'
							AND (BIZ_CL_CD IN('10','50','40') OR BIZ_DTL_CL_CD IN ('21','22','61','62'))
							AND SUBSTRING(UNIT_OPER_CD, 4,1) <> 3
							AND LST_OPERTR_ID IS NOT NULL
						--	AND TYPE IN ('Home센터','Home클리닉','지원팀')
						--	AND MASS_CO_CL_CD = '1' 
							AND FEE_PROD_ID NOT IN  ('NI00000556','NT00000189','NP00000948','NP00000949')		--	인천아시안게임 임시상품 제외조건				
							AND SIMPL_ADDR_CHG_YN = 'N'    -- 단순주소변경
							

					GROUP BY CAST(STAT_DT AS DATE),DATEPART(YY,STAT_DT),DATEPART(MM,STAT_DT),DATEPART(DD,STAT_DT),DATEPART(wk,STAT_DT)
							,TYPE,NWHQ,TEAM,A.OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD
							,OPER_ORD_ST_CD
							,HNS_YN,VOCDAYADD,NUM
							
						,CASE	WHEN VOCDAYADD = '공휴일' THEN '일요일'
						WHEN VOCDAYADD = '일요일' THEN '일요일'						
						WHEN VOCDAYADD = '토요일' THEN '토요일'
						WHEN VOCDAYADD = '월요일' AND YYMMDD = '2020-08-17' THEN '일요일'
						ELSE '주중' END 
				
					) A
					
					
		GROUP BY YYMMDD,YY,MM,DD,wk,TYPE,NWHQ,TEAM,OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD,OPER_ORD_ST_CD
		,VOCDAYADD
			,CASE	WHEN VOCDAYADD = '공휴일' THEN '일요일'
						WHEN VOCDAYADD = '일요일' THEN '일요일'						
						WHEN VOCDAYADD = '토요일' THEN '토요일'
						WHEN VOCDAYADD = '월요일' AND YYMMDD = '2020-08-17' THEN '일요일'
						ELSE '주중' END 

				,CASE WHEN ( DATEPART(HH,최초완료시간) IN (18,19,20,21,22,23)) THEN '야간' ELSE '주간' END
				,HnS여부
				,NUM

		) B



		GROUP BY YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(LST_OPERTR_ID)
				,HnS여부
				,VOCDAYADD,주중구분,주야간구분
				,NUM



UNION ALL

--------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 여기서부터 장애 실적 */


SELECT '장애'GBN,YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(CHKR_LOGIN_ID)LST_OPERTR_ID
				,HnS여부
				,VOCDAYADD,주중구분,주야간구분,NUM
						
		,COUNT(DISTINCT CHKR_LOGIN_ID) AS 작업자수
		,COUNT(DISTINCT YYMMDD ) AS 근무일수
		,COUNT(DISTINCT DABL_RCV_NUM) AS 출동건




		FROM 
		(
		SELECT	DISTINCT CAST(A.OPER_FNSH_DTM AS DATE)YYMMDD,DATEPART(YY,A.OPER_FNSH_DTM)YY,DATEPART(MM,A.OPER_FNSH_DTM)MM,DATEPART(DD,A.OPER_FNSH_DTM)DD,DATEPART(wk,OPER_FNSH_DTM)wk
				,CASE WHEN (VOCDAY = '일요일')	THEN VOCDAY
					  ELSE [WEEKDAY] END AS VOCDAY
				,NWHQ,B.TEAM
				,A.OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,ISUNION
				,TYPE
				,A.CHKR_LOGIN_ID,A.DABL_RCV_NUM				
				,HNS_YN HnS여부
				,VOCDAYADD,NUM
				,CASE	WHEN VOCDAYADD = '공휴일' THEN '일요일'
						WHEN VOCDAYADD = '일요일' THEN '일요일'						
						WHEN VOCDAYADD = '토요일' THEN '토요일'
						WHEN VOCDAYADD = '월요일' AND YYMMDD = '2020-08-17' THEN '일요일'
						ELSE '주중' END 주중구분
				,CASE WHEN ( DATEPART(HH,OPER_FNSH_DTM) IN (18,19,20,21,22,23)) THEN '야간' ELSE '주간' END 주야간구분
				
				FROM DayCalllistDone_DBM A 
					INNER JOIN ( SELECT DISTINCT MSVC_ORG_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,ISUNION,TYPE,HNS_YN FROM Teammapping_new_MAP ) B
					ON A.MSVCORG_ID = B.MSVC_ORG_ID
					
					INNER JOIN VOCWeekDay U
					ON CAST(A.OPER_FNSH_DTM AS DATE) = U.YYMMDD
					
					INNER JOIN ( SELECT DABL_RCV_NUM,CHKR_LOGIN_ID,MIN(SVC_MGMT_NUM)SVC_MGMT_NUM  FROM DayCalllistDone_DBM 
									WHERE OPER_FNSH_DTM >= @S_DATE and OPER_FNSH_DTM < @E_DATE 
									GROUP BY DABL_RCV_NUM,CHKR_LOGIN_ID ) E
					ON A.DABL_RCV_NUM = E.DABL_RCV_NUM AND A.CHKR_LOGIN_ID = E.CHKR_LOGIN_ID AND A.SVC_MGMT_NUM = E.SVC_MGMT_NUM
				
				WHERE   A.OPER_FNSH_DTM >= @S_DATE and A.OPER_FNSH_DTM < @E_DATE
							AND DABL_OP_ST_CD = '30' AND OPER_DRDOC_OP_ST_CD = '21' and INR_OUT_CL_CD = 'O'			--- 장애복구완료 / 완료_지시서처리 / 외부완료 
							AND DABL_SRC_TYP_CD_NM IS NOT NULL														--- 장애원인유형코드명 빈값은 제외
							AND MAIN_CNSL_CD_NM  in ('인터넷품질','유선전화품질','TV품질','기술문의_인터넷','기술문의_전화','기술문의_TV','해지관련_유선','해지문의','인증팀수관')  --해약전점검요청 및 품질불만_점검요청 추가반영함
							AND NOT (DABL_SRC_TYP_CD_NM  LIKE '%CS%' OR DABL_SRC_TYP_CD_NM  LIKE '%기타%' OR DABL_SRC_TYP_CD_NM = '30일 이상 처리지연에 따른 자동완료')						
						--	AND TYPE IN ('Home센터','Home클리닉','지원팀')
							AND DABL_RCV_TYP_CD IN ('0','1','2','3')--'2','3')
						
							
		) A
		
		GROUP BY YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(CHKR_LOGIN_ID)
				,HnS여부
				,VOCDAYADD
				,주중구분,주야간구분
				,NUM
		
			
			) AA

LEFT OUTER JOIN ( SELECT DISTINCT NWHQ,TEAM,A.OPER_CO_ID AS WRK_CO_ID_SUM,OPER_CO_ID_NM AS MG_CO_NM_SUM,A.LOGIN_ID,USER_ID_NM,HNS_YN,CTZ_SER_NUM  FROM TB_DBM_BPRM_PTN_USER_CP A 

                 INNER JOIN ( SELECT DISTINCT OPER_CO_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,ISUNION,TYPE,HNS_YN FROM Teammapping_new_MAP ) B
                            ON A.OPER_CO_ID= B.OPER_CO_ID
					 
                              ) BB
							
ON AA.LST_OPERTR_ID = BB.LOGIN_ID

LEFT OUTER JOIN ( SELECT DISTINCT STAT_DT,그룹명,담당명,부서명,CTZ_SER_NUM,현장여부,직무명,사번  FROM HNS_CTZ_SER_NUM_MAP_NEW a
                        WHERE  A.STAT_DT  = '2023-10-01'        	---- 전월 인사정보 맵핑(연도 변경시 수정필요)
						) CC
			 			        --   ON BB.CTZ_SER_NUM = CC.CTZ_SER_NUM AND YY = DATEPART(YY,CC.STAT_DT) AND MM = DATEPART(MM,CC.STAT_DT)
								  ON BB.CTZ_SER_NUM = CC.CTZ_SER_NUM   
								   
WHERE BB.LOGIN_ID IS NOT NULL
      AND HNS_YN = 'Y'
	  AND 현장여부 = 'SM'

GROUP BY	YYMMDD,YY							-- 실적연도
				,MM					  	    -- 실적월
				,DD							-- 실적일
				,wk
		--		,VOCDAYADD
		         ,CASE	WHEN 주중구분 = '주중'      THEN '평일'
					WHEN 주중구분 = '토요일'    THEN '주말'
					WHEN 주중구분 = '일요일'    THEN '주말'
					ELSE '평일' END 
		--		,주중구분
		--		,주야간구분
		--		,NUM
				,그룹명,담당명,부서명	
			--	,BB.HNS_YN					-- 작업자 실제 소속 HnS소속여부
		
		--		,AA.NWHQ					-- 원본DB 실적대상 본부 관리유통망기준
		--		,AA.TEAM					-- 원본DB 실적대상 담당 관리유통망기준
			--	,AA.OPER_CO_ID				-- 원본DB 실적대상 센터ID 작업업체기준
			--	,AA.OPER_CO_NM				-- 원본DB 실적대상 센터ID명 작업업체기준
		--		,AA.WRK_CO_ID_SUM			-- 원본DB 실적대상 최종센터ID 관리유통망기준
		--		,AA.MG_CO_NM_SUM			-- 원본DB 실적대상 최종센터ID명 관리유통망기준
		--		,AA.TYPE					-- 원본DB 실적대상 센터유형 관리유통망기준
				,BB.CTZ_SER_NUM
			--	,BB.LOGIN_ID			-- 작업자ID
				,USER_ID_NM					-- 작업자ID명
			--	,AA.HnS여부					-- 원본DB 센터(AA.OPER_CO_ID)의 홈앤서비스 여부
		--		,CASE WHEN BB.WRK_CO_ID_SUM = AA.WRK_CO_ID_SUM	 THEN '자체처리'
		--				ELSE '지원처리' END
				 ,현장여부	
				 ,직무명	
				 ,사번
						)DD

						
GROUP BY YY,MM--,  DD
           ,그룹명,담당명,부서명,사번,USER_ID_NM
		  -- ,주중구분

ORDER BY YY,MM--,  DD
           ,그룹명,담당명,부서명,사번,USER_ID_NM
		  -- ,주중구분
