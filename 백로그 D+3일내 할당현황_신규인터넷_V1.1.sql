
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SET ARITHABORT OFF 
SET ARITHIGNORE OFF
SET ANSI_WARNINGS OFF 

DECLARE @S_DATE NVARCHAR(10)    
DECLARE @E_DATE NVARCHAR(10) 
declare @T_DATE nvarchar(10)    

SET @S_DATE = '2023-09-01' 
SET @E_DATE = '2023-09-20' 
--SET @T_DATE= RIGHT(@E_DATE,2)



		SELECT	'��α״���Ҵ���Ȳ'GBN
					,DATEPART(YY,STAT_DT)				YY
					,DATEPART(MM,STAT_DT)			MM
					,DATEPART(DD,STAT_DT)				DD
			--		,VOCDAYADD							���߱���
					,F.NWHQ									����
					,F.TEAM									���
			--		,F.HNS_YN								HNS����
			--		,F.TYPE									��������
			--		,F.MSVC_ORG_ID_SUM				����ID
			--		,F.MG_CO_NM_SUM					����ID��


				
		
		,COUNT(*)	TOT
		
		,COUNT(CASE WHEN OPER_PROC_DTL_ST IN ('3','6') AND DATEDIFF(DAY,STAT_DT,ADJ_PREFR_SVSET_DTM) > 0 AND
										DATEDIFF(DAY,STAT_DT,ADJ_PREFR_SVSET_DTM) < 5  THEN SVC_MGMT_NUM ELSE NULL END)	[TOT_ALC_D+3]
		
		FROM IssueDelay_Ukey A
			
				INNER JOIN ( SELECT SVC_CHG_CD, SVC_CHG_RSN_CD, GUBUN, ISNEW, INCLUDE FROM CHGCode ) C
				ON A.SVC_CHG_CD = C.SVC_CHG_CD AND A.SVC_CHG_RSN_CD = C.SVC_CHG_RSN_CD
							
				LEFT OUTER JOIN PRODDTLNMCode E
				ON A.SVC_TECH_MTHD_CD = E.SVC_TECH_MTHD_CD AND A.FEE_PROD_ID = E.PROD_ID

				LEFT OUTER JOIN ( SELECT DISTINCT WRK_CO_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,TYPE,HNS_YN FROM Teammapping_new_MAP ) D 
				ON A.OPER_CO_ID = D.WRK_CO_ID

				LEFT OUTER JOIN ( SELECT DISTINCT MSVC_ORG_ID,MSVC_ORG_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,TYPE,HNS_YN FROM Teammapping_new_MAP ) F
				ON A.MSVCORG_ID = F.MSVC_ORG_ID

				INNER JOIN VOCWeekDay U
				ON CAST(A.STAT_DT AS DATE) = U.YYMMDD
			
									
		WHERE	STAT_DT >= @S_DATE AND STAT_DT < @E_DATE
				--	AND GUBUN = '�ű�'
					AND E.BIZ_CL_CD IN ('10','50')--,'40') OR E.BIZ_DTL_CL_CD IN ('21','22','61','62'))
				--	AND MASS_CO_CL_CD = '1'																										--  ����������� MASS���񽺸� ���
					AND FEE_PROD_ID NOT IN  ('NI00000556','NT00000189','NP00000948','NP00000949')												--	��õ�ƽþȰ��� �ӽû�ǰ ��������
					AND A.SVC_TECH_MTHD_CD NOT IN ('B0069','B0070','B0075','P0004','P0018','P0006','T0003','T0006','T0010','T0014','T0017','T0019')		-- ������������
					AND SUBSTRING(UNIT_OPER_CD, 4,1) <> 3								-- �̰� ������� ��� ���������� �Բ� ������ ���ܽ��Ѿ� �� ����		
				    AND F.TYPE IN ('Home����','������','HomeŬ����')
					--AND DATEPART(DD,STAT_DT) < @T_DATE				-- ������ ��¥ ���Ⱓ ����
					AND BIZ_OBJ_YN = 'Y'
					AND A.FEE_PROD_ID NOT IN ('NJ00000235','NJ00000236','NJ00000250','NJ00000248','NJ00000283','NJ00000285','NI00000056')
					AND S_MART_OBJ_YN = 'Y'
					AND OPER_PROC_DTL_ST IN ('3','6')				-- �Ҵ�Ǹ� ������� ����

GROUP BY		DATEPART(YY,STAT_DT)				--YY
					,DATEPART(MM,STAT_DT)			--MM
					,DATEPART(DD,STAT_DT)				--DD
					
					,F.NWHQ									--����
					,F.TEAM									--���
					
ORDER BY		DATEPART(YY,STAT_DT)				--YY
					,DATEPART(MM,STAT_DT)			--MM
					,DATEPART(DD,STAT_DT)				--DD
					
					,F.NWHQ									--����
					,F.TEAM									--���
				