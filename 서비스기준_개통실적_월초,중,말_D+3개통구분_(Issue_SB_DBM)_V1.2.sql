
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

SET ARITHABORT OFF 
SET ARITHIGNORE OFF
SET ANSI_WARNINGS OFF 
 
declare @strS nvarchar(10) 
declare @strE nvarchar(10) 
  
set @strS='2017-11-21' -- 완료통보일시작
set @strE='2017-11-30'-- 완료통보일끝


SELECT	DATEPART(YY,STAT_DT)YY
			,DATEPART(MM,STAT_DT)MM
			--,DATEPART(DD,STAT_DT)DD
			--,VOCDAYADD
			,GUBUN
			,CASE	WHEN  GUBUN = '신규'	THEN '신규'  
					WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '변경_설치장소변경'
					WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '변경_서비스변경'
					WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '변경_부가서비스추가'
					WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '변경_기타'
					ELSE NULL END 가입구분_세부
			,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '인터넷'  
					WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
					WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '전화'
					ELSE NULL END 서비스구분
			,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10일'  
					WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20일'
					WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~월말'
					ELSE NULL END 월개통구간구분
			
			,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3일이내'  
					ELSE NULL END 요청대비개통구간


			/*		
			,CASE 
					WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH단독'	-- FTTH단독 지역
					WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC지역
					WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
							AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
							OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '공동주택'	-- 공동주택(APT유형)		
					WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '전화'		-- 전화
										
					WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
					ELSE NULL END 개통유형구분
			*/
					
			--,A.SVC_CHG_CD,SVC_CHG_NM
			,D.TYPE				관리유통망유형
			,C.TYPE				개통업체유형																						
			,D.NWHQ				본부
			,D.TEAM				품질솔루션팀																	-- 상위본부,팀
			,D.MSVC_ORG_ID_SUM	관리유통망ID
			,D.MG_CO_NM_SUM		관리유통망명																	-- 관리유통망ID,명																						
			,C.WRK_CO_ID_SUM	최종개통작업업체ID
			,C.MG_CO_NM_SUM		최종개통작업업체명																	-- 최종작업업체기준
			,RTRIM(E.BIZ_CL_CD)BIZ_CL_CD,RTRIM(E.BIZ_CL_CD_NM)BIZ_CL_CD_NM										-- 사업구분
			--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- 기술방식코드,명
			--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- 이전기술방식코드,명
				
			
			,SUM(CAST(SVC_CNT AS INT)) AS TOTAL	
			
			
			FROM Issue_SB_DBM A 
					LEFT OUTER JOIN ( SELECT SVC_CHG_CD, SVC_CHG_RSN_CD, GUBUN, ISNEW, INCLUDE FROM CHGCode 
								WHERE ISNEW = 'Y' AND INCLUDE = 'Y' ) B
					ON A.SVC_CHG_CD = B.SVC_CHG_CD AND A.SVC_CHG_RSN_CD = B.SVC_CHG_RSN_CD
					
					LEFT OUTER JOIN ( SELECT DISTINCT OPER_CO_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,TYPE FROM Teammapping_new_MAP WHERE ISNEW = 'Y') C
					ON A.OPER_CO_ID = C.OPER_CO_ID
					
					LEFT OUTER JOIN ( SELECT DISTINCT MSVC_ORG_ID,MSVC_ORG_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,TYPE FROM Teammapping_new_MAP WHERE ISNEW = 'Y') D
					ON A.MSVCORG_ID = D.MSVC_ORG_ID
					
					LEFT OUTER JOIN PRODDTLNMCode E
					ON A.SVC_TECH_MTHD_CD = E.SVC_TECH_MTHD_CD AND A.FEE_PROD_ID = E.PROD_ID
					
					INNER JOIN VOCWeekDay U
					ON CAST(A.STAT_DT AS DATE) = U.YYMMDD	
					
				
			WHERE STAT_DT >= @strS AND STAT_DT < @strE
					AND GUBUN = '신규'
					--AND A.SVC_CHG_CD IN ('A1','H1','C8')
					AND E.BIZ_CL_CD IN('10','50')--,'40') OR E.BIZ_DTL_CL_CD IN ('21','22','61','62'))
					AND BIZ_OBJ_YN = 'Y'
					AND S_MART_OBJ_YN = 'Y'
					AND MASS_CO_CL_CD = '1'
				    AND SUBSTRING(UNIT_OPER_CD, 4,1) <> 3		-- 단위작업코드 4번째자리가 3인경우는 해지건, 그외건이 개통건
					AND FEE_PROD_ID NOT IN  ('NI00000556','NT00000189','NP00000948','NP00000949')		--	인천아시안게임 임시상품 제외조건
					AND A.SVC_TECH_MTHD_CD NOT IN ('B0069','B0070','B0075','P0004','P0018','P0006','T0003','T0006','T0010','T0014','T0017')					
					AND C.TYPE IN ('Home센터','지원팀','Home클리닉')--,'SO/RO')
					AND SIMPL_ADDR_CHG_YN = 'N'							-- 설변건중 단순주소변경건은 제외 조건
										


GROUP BY	DATEPART(YY,STAT_DT)
				,DATEPART(MM,STAT_DT)
				--,DATEPART(DD,STAT_DT)
				--,VOCDAYADD
				,GUBUN
				,CASE	WHEN  GUBUN = '신규'	THEN '신규'  
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '변경_설치장소변경'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '변경_서비스변경'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '변경_부가서비스추가'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '변경_기타'
						ELSE NULL END 
				,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '인터넷'  
						WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
						WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '전화'
						ELSE NULL END
				,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10일'  
						WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20일'
						WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~월말'
						ELSE NULL END 
			
				,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3일이내'  
						ELSE NULL END
				/*
				,CASE 
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH단독'	-- FTTH단독 지역
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC지역
						WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
								AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
								OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '공동주택'	-- 공동주택(APT유형)		
						WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '전화'		-- 전화
											
						WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
						ELSE NULL END
				*/
				
				--,A.SVC_CHG_CD,SVC_CHG_NM
				,D.TYPE 
				,C.TYPE																							
				,D.NWHQ 
				,D.TEAM																								-- 상위본부,팀
				,D.MSVC_ORG_ID_SUM,D.MG_CO_NM_SUM																	-- 관리유통망ID,명																						
				,C.WRK_CO_ID_SUM,C.MG_CO_NM_SUM																		-- 최종작업업체기준
				,RTRIM(E.BIZ_CL_CD),RTRIM(E.BIZ_CL_CD_NM)															-- 사업구분
				--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- 기술방식코드,명
				--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- 이전기술방식코드,명
				
			
ORDER BY	DATEPART(YY,STAT_DT)
				,DATEPART(MM,STAT_DT)
				--,DATEPART(DD,STAT_DT)
				--,VOCDAYADD
				,GUBUN
				,CASE	WHEN  GUBUN = '신규'	THEN '신규'  
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '변경_설치장소변경'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '변경_서비스변경'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '변경_부가서비스추가'
						WHEN  GUBUN = '변경' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '변경_기타'
						ELSE NULL END 
				,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '인터넷'  
						WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
						WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '전화'
						ELSE NULL END
				,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10일'  
						WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20일'
						WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~월말'
						ELSE NULL END 
			
				,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3일이내'  
						ELSE NULL END
				/*
				,CASE 
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH단독'	-- FTTH단독 지역
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC지역
						WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
								AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
								OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '공동주택'	-- 공동주택(APT유형)		
						WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '전화'		-- 전화
											
						WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
						ELSE NULL END
				*/
				
				--,A.SVC_CHG_CD,SVC_CHG_NM
				,D.TYPE 
				,C.TYPE																							
				,D.NWHQ 
				,D.TEAM																								-- 상위본부,팀
				,D.MSVC_ORG_ID_SUM,D.MG_CO_NM_SUM																	-- 관리유통망ID,명																						
				,C.WRK_CO_ID_SUM,C.MG_CO_NM_SUM																		-- 최종작업업체기준
				,RTRIM(E.BIZ_CL_CD),RTRIM(E.BIZ_CL_CD_NM)															-- 사업구분
				--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- 기술방식코드,명
				--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- 이전기술방식코드,명
				
			
