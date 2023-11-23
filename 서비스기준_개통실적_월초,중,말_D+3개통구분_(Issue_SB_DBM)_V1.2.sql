
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

SET ARITHABORT OFF 
SET ARITHIGNORE OFF
SET ANSI_WARNINGS OFF 
 
declare @strS nvarchar(10) 
declare @strE nvarchar(10) 
  
set @strS='2017-11-21' -- �Ϸ��뺸�Ͻ���
set @strE='2017-11-30'-- �Ϸ��뺸�ϳ�


SELECT	DATEPART(YY,STAT_DT)YY
			,DATEPART(MM,STAT_DT)MM
			--,DATEPART(DD,STAT_DT)DD
			--,VOCDAYADD
			,GUBUN
			,CASE	WHEN  GUBUN = '�ű�'	THEN '�ű�'  
					WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '����_��ġ��Һ���'
					WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '����_���񽺺���'
					WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '����_�ΰ������߰�'
					WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '����_��Ÿ'
					ELSE NULL END ���Ա���_����
			,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '���ͳ�'  
					WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
					WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '��ȭ'
					ELSE NULL END ���񽺱���
			,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10��'  
					WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20��'
					WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~����'
					ELSE NULL END �����뱸������
			
			,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3���̳�'  
					ELSE NULL END ��û����뱸��


			/*		
			,CASE 
					WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH�ܵ�'	-- FTTH�ܵ� ����
					WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC����
					WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
							AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
							OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '��������'	-- ��������(APT����)		
					WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '��ȭ'		-- ��ȭ
										
					WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
					ELSE NULL END ������������
			*/
					
			--,A.SVC_CHG_CD,SVC_CHG_NM
			,D.TYPE				�������������
			,C.TYPE				�����ü����																						
			,D.NWHQ				����
			,D.TEAM				ǰ���ַ����																	-- ��������,��
			,D.MSVC_ORG_ID_SUM	���������ID
			,D.MG_CO_NM_SUM		�����������																	-- ���������ID,��																						
			,C.WRK_CO_ID_SUM	���������۾���üID
			,C.MG_CO_NM_SUM		���������۾���ü��																	-- �����۾���ü����
			,RTRIM(E.BIZ_CL_CD)BIZ_CL_CD,RTRIM(E.BIZ_CL_CD_NM)BIZ_CL_CD_NM										-- �������
			--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- �������ڵ�,��
			--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- �����������ڵ�,��
				
			
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
					AND GUBUN = '�ű�'
					--AND A.SVC_CHG_CD IN ('A1','H1','C8')
					AND E.BIZ_CL_CD IN('10','50')--,'40') OR E.BIZ_DTL_CL_CD IN ('21','22','61','62'))
					AND BIZ_OBJ_YN = 'Y'
					AND S_MART_OBJ_YN = 'Y'
					AND MASS_CO_CL_CD = '1'
				    AND SUBSTRING(UNIT_OPER_CD, 4,1) <> 3		-- �����۾��ڵ� 4��°�ڸ��� 3�ΰ��� ������, �׿ܰ��� �����
					AND FEE_PROD_ID NOT IN  ('NI00000556','NT00000189','NP00000948','NP00000949')		--	��õ�ƽþȰ��� �ӽû�ǰ ��������
					AND A.SVC_TECH_MTHD_CD NOT IN ('B0069','B0070','B0075','P0004','P0018','P0006','T0003','T0006','T0010','T0014','T0017')					
					AND C.TYPE IN ('Home����','������','HomeŬ����')--,'SO/RO')
					AND SIMPL_ADDR_CHG_YN = 'N'							-- �������� �ܼ��ּҺ������ ���� ����
										


GROUP BY	DATEPART(YY,STAT_DT)
				,DATEPART(MM,STAT_DT)
				--,DATEPART(DD,STAT_DT)
				--,VOCDAYADD
				,GUBUN
				,CASE	WHEN  GUBUN = '�ű�'	THEN '�ű�'  
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '����_��ġ��Һ���'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '����_���񽺺���'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '����_�ΰ������߰�'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '����_��Ÿ'
						ELSE NULL END 
				,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '���ͳ�'  
						WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
						WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '��ȭ'
						ELSE NULL END
				,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10��'  
						WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20��'
						WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~����'
						ELSE NULL END 
			
				,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3���̳�'  
						ELSE NULL END
				/*
				,CASE 
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH�ܵ�'	-- FTTH�ܵ� ����
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC����
						WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
								AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
								OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '��������'	-- ��������(APT����)		
						WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '��ȭ'		-- ��ȭ
											
						WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
						ELSE NULL END
				*/
				
				--,A.SVC_CHG_CD,SVC_CHG_NM
				,D.TYPE 
				,C.TYPE																							
				,D.NWHQ 
				,D.TEAM																								-- ��������,��
				,D.MSVC_ORG_ID_SUM,D.MG_CO_NM_SUM																	-- ���������ID,��																						
				,C.WRK_CO_ID_SUM,C.MG_CO_NM_SUM																		-- �����۾���ü����
				,RTRIM(E.BIZ_CL_CD),RTRIM(E.BIZ_CL_CD_NM)															-- �������
				--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- �������ڵ�,��
				--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- �����������ڵ�,��
				
			
ORDER BY	DATEPART(YY,STAT_DT)
				,DATEPART(MM,STAT_DT)
				--,DATEPART(DD,STAT_DT)
				--,VOCDAYADD
				,GUBUN
				,CASE	WHEN  GUBUN = '�ű�'	THEN '�ű�'  
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'H'	THEN '����_��ġ��Һ���'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'C'	THEN '����_���񽺺���'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) = 'I'	THEN '����_�ΰ������߰�'
						WHEN  GUBUN = '����' AND LEFT(A.SVC_CHG_CD,1) NOT IN ('H','C','I')	THEN '����_��Ÿ'
						ELSE NULL END 
				,CASE	WHEN  E.BIZ_CL_CD IN('10','50')	THEN '���ͳ�'  
						WHEN  E.BIZ_CL_CD  = '40'	THEN 'TV'
						WHEN  E.BIZ_DTL_CL_CD IN ('21','22','61','62')	THEN '��ȭ'
						ELSE NULL END
				,CASE	WHEN DATEPART(DD,STAT_DT) < 11	THEN '1~10��'  
						WHEN DATEPART(DD,STAT_DT) >= 11 AND DATEPART(DD,STAT_DT) < 21	THEN '11~20��'
						WHEN DATEPART(DD,STAT_DT) >= 21	THEN '21~����'
						ELSE NULL END 
			
				,CASE	WHEN DATEDIFF(DD,REQ_RCV_DTM,SVSET_FNSH_NOTI_DTM) < 4	THEN 'D+3���̳�'  
						ELSE NULL END
				/*
				,CASE 
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'Y'	THEN 'FTTH�ܵ�'	-- FTTH�ܵ� ����
						WHEN E.BIZ_DTL_CL_CD IN ('11','12','51') AND A.SVC_TECH_MTHD_CD IN ('B0004','B0017','B0019','B0020','B0036','B0045')	THEN 'HFC'		-- HFC����
						WHEN ( E.BIZ_DTL_CL_CD IN ('11','12','51') 
								AND ( A.SVC_TECH_MTHD_CD NOT IN ('B0004','B0017','B0019','B0020','B0036','B0045','B0030','B0032','B0039')
								OR (A.SVC_TECH_MTHD_CD IN ('B0030','B0032','B0039') AND FTTH_INDPND_YN = 'N')))									THEN '��������'	-- ��������(APT����)		
						WHEN ( E.BIZ_DTL_CL_CD IN ('21','22','61','62'))																		THEN '��ȭ'		-- ��ȭ
											
						WHEN ( E.BIZ_DTL_CL_CD IN ('41','42','43'))																				THEN 'TV'		-- TV
						ELSE NULL END
				*/
				
				--,A.SVC_CHG_CD,SVC_CHG_NM
				,D.TYPE 
				,C.TYPE																							
				,D.NWHQ 
				,D.TEAM																								-- ��������,��
				,D.MSVC_ORG_ID_SUM,D.MG_CO_NM_SUM																	-- ���������ID,��																						
				,C.WRK_CO_ID_SUM,C.MG_CO_NM_SUM																		-- �����۾���ü����
				,RTRIM(E.BIZ_CL_CD),RTRIM(E.BIZ_CL_CD_NM)															-- �������
				--,RTRIM(SVC_TECH_MTHD_CD)SVC_TECH_MTHD_CD,RTRIM(SVC_TECH_MTHD_NM)SVC_TECH_MTHD_NM					-- �������ڵ�,��
				--,RTRIM(CHG_TERM_SVC_TECH_MTHD_CD)CHG_TERM_SVC_TECH_MTHD_CD										-- �����������ڵ�,��
				
			
