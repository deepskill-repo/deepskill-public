SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

SET ARITHABORT OFF 
SET ARITHIGNORE OFF
SET ANSI_WARNINGS OFF 
SET DATEFIRST 1                 -- ���� ������ ����(1:��, 2:ȭ.........7:��)

DECLARE @S_DATE NVARCHAR(10) 
DECLARE @E_DATE NVARCHAR(10) 

SET @S_DATE='2023-11-01'
SET @E_DATE='2023-11-15'


SELECT YY,MM  -- ,DD
       ,�׷��,����,�μ���,���,USER_ID_NM
    --  ,���߱���
			,SUM(�����) �ְ�����
			,SUM(��ְ�) �ְ����
			,SUM(�⵿��) �ְ��⵿

			,SUM(�߰������) �߰�����
			,SUM(�߰���ְ�) �߰����			
			,SUM(�߰��⵿��) �߰��⵿

			,COUNT(DISTINCT YYMMDD) �ٹ��ϼ�
			,SUM(�ٹ���) �ٹ���
					   			 
FROM (

SELECT	YYMMDD,YY							-- ��������
			,MM					  	    -- ������
			,DD							-- ������
			,wk
	--		,VOCDAYADD
	--        ,CASE	WHEN ���߱��� = '����'      THEN '����'
	--				WHEN ���߱��� = '�����'    THEN '�ָ�'
	--				WHEN ���߱��� = '�Ͽ���'    THEN '�ָ�'
	--				ELSE '����' END ���߱���
	--		,���߱���
	--		,�־߰�����
	--		,NUM
			,�׷��,����,�μ���
		--	,BB.HNS_YN					-- �۾��� ���� �Ҽ� HnS�Ҽӿ���
			,BB.CTZ_SER_NUM
		--	,BB.LOGIN_ID			-- �۾���ID
			,USER_ID_NM					-- �۾���ID��
		--	,CASE WHEN BB.WRK_CO_ID_SUM = AA.WRK_CO_ID_SUM	 THEN '��üó��'
		--			ELSE '����ó��' END ��üó������
		    ,���忩��
			,������
			,���

,SUM(CASE WHEN GBN = '����' AND �־߰����� = '�ְ�' THEN �⵿�� ELSE 0 END) �����	
,SUM(CASE WHEN GBN = '���' AND �־߰����� = '�ְ�' THEN �⵿�� ELSE 0 END) ��ְ�		
,SUM(CASE WHEN GBN = '����' AND �־߰����� = '�ְ�' THEN �⵿�� ELSE 0 END) 
                     + SUM(CASE WHEN GBN = '���' AND �־߰����� = '�ְ�' THEN �⵿�� ELSE 0 END)  �⵿��	

,SUM(CASE WHEN GBN = '����' AND �־߰����� = '�߰�' THEN �⵿�� ELSE 0 END) �߰������	
,SUM(CASE WHEN GBN = '���' AND �־߰����� = '�߰�' THEN �⵿�� ELSE 0 END) �߰���ְ�				
,SUM(CASE WHEN GBN = '����' AND �־߰����� = '�߰�' THEN �⵿�� ELSE 0 END)  
                     + SUM(CASE WHEN GBN = '���' AND �־߰����� = '�߰�' THEN �⵿�� ELSE 0 END)  �߰��⵿��	

,COUNT(DISTINCT YYMMDD) �ٹ��ϼ�
,COUNT(DISTINCT BB.CTZ_SER_NUM) �ٹ���


FROM
(
		SELECT	'����'GBN,YYMMDD,YY,MM,DD,wk
					,NWHQ,TEAM
					,OPER_CO_ID,OPER_CO_NM
					,WRK_CO_ID_SUM,MG_CO_NM_SUM
					,TYPE
					,RTRIM(LST_OPERTR_ID)LST_OPERTR_ID
					,HnS����
					,VOCDAYADD,���߱���,�־߰�����,NUM
				
		,COUNT(DISTINCT LST_OPERTR_ID) AS �۾��ڼ�
		,COUNT(DISTINCT B.YYMMDD ) AS �ٹ��ϼ�
		,COUNT(*) AS �⵿��

		FROM
		(
		SELECT YYMMDD,YY,MM,DD,wk,TYPE,NWHQ,TEAM,OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD,OPER_ORD_ST_CD
		         ,VOCDAYADD
		         ,CASE	WHEN VOCDAYADD = '������' THEN '�Ͽ���'
						WHEN VOCDAYADD = '�Ͽ���' THEN '�Ͽ���'						
						WHEN VOCDAYADD = '�����' THEN '�����'
						WHEN VOCDAYADD = '������' AND YYMMDD = '2020-08-17' THEN '�Ͽ���'
						ELSE '����' END ���߱���
				,CASE WHEN ( DATEPART(HH,���ʿϷ�ð�) IN (18,19,20,21,22,23)) THEN '�߰�' ELSE '�ְ�' END �־߰�����				
				,HnS����
				,NUM
					
				,COUNT(*) AS ����
				
					FROM 
					( 
					SELECT	CAST(STAT_DT AS DATE)YYMMDD,DATEPART(YY,STAT_DT)YY,DATEPART(MM,STAT_DT)MM,DATEPART(DD,STAT_DT)DD,DATEPART(wk,STAT_DT)wk
							,TYPE,NWHQ,TEAM,A.OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD
							,OPER_ORD_ST_CD,MIN(SVSET_FNSH_NOTI_DTM) AS ���ʿϷ�ð�
							,HNS_YN HnS����,VOCDAYADD,NUM
		
					
					,COUNT(*) AS TOTAL		
					
					
					from Issue_SB_DBM A 
							INNER JOIN ( SELECT SVC_CHG_CD, SVC_CHG_RSN_CD, GUBUN, ISNEW, INCLUDE FROM CHGCode 
										WHERE ISNEW = 'Y' AND INCLUDE = 'Y' ) B
							ON A.SVC_CHG_CD = B.SVC_CHG_CD AND A.SVC_CHG_RSN_CD = B.SVC_CHG_RSN_CD
							
							INNER JOIN ( SELECT DISTINCT MSVC_ORG_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,ISUNION,TYPE,HNS_YN FROM Teammapping_new_MAP ) C		-- ��������� ���� JOIN
							ON A.MSVCORG_ID = C.MSVC_ORG_ID							
				
							INNER JOIN VOCWeekDay U
							ON CAST(A.STAT_DT AS DATE) = U.YYMMDD
						
					WHERE STAT_DT >= @S_DATE AND STAT_DT < @E_DATE
							AND GUBUN IN ('�ű�','����')
							--AND A.SVC_CHG_CD <> 'C8'
							AND (BIZ_CL_CD IN('10','50','40') OR BIZ_DTL_CL_CD IN ('21','22','61','62'))
							AND SUBSTRING(UNIT_OPER_CD, 4,1) <> 3
							AND LST_OPERTR_ID IS NOT NULL
						--	AND TYPE IN ('Home����','HomeŬ����','������')
						--	AND MASS_CO_CL_CD = '1' 
							AND FEE_PROD_ID NOT IN  ('NI00000556','NT00000189','NP00000948','NP00000949')		--	��õ�ƽþȰ��� �ӽû�ǰ ��������				
							AND SIMPL_ADDR_CHG_YN = 'N'    -- �ܼ��ּҺ���
							

					GROUP BY CAST(STAT_DT AS DATE),DATEPART(YY,STAT_DT),DATEPART(MM,STAT_DT),DATEPART(DD,STAT_DT),DATEPART(wk,STAT_DT)
							,TYPE,NWHQ,TEAM,A.OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD
							,OPER_ORD_ST_CD
							,HNS_YN,VOCDAYADD,NUM
							
						,CASE	WHEN VOCDAYADD = '������' THEN '�Ͽ���'
						WHEN VOCDAYADD = '�Ͽ���' THEN '�Ͽ���'						
						WHEN VOCDAYADD = '�����' THEN '�����'
						WHEN VOCDAYADD = '������' AND YYMMDD = '2020-08-17' THEN '�Ͽ���'
						ELSE '����' END 
				
					) A
					
					
		GROUP BY YYMMDD,YY,MM,DD,wk,TYPE,NWHQ,TEAM,OPER_CO_ID,OPER_CO_NM,WRK_CO_ID_SUM,MG_CO_NM_SUM,LST_OPERTR_ID,CUST_NUM,BLD_CD,OPER_ORD_ST_CD
		,VOCDAYADD
			,CASE	WHEN VOCDAYADD = '������' THEN '�Ͽ���'
						WHEN VOCDAYADD = '�Ͽ���' THEN '�Ͽ���'						
						WHEN VOCDAYADD = '�����' THEN '�����'
						WHEN VOCDAYADD = '������' AND YYMMDD = '2020-08-17' THEN '�Ͽ���'
						ELSE '����' END 

				,CASE WHEN ( DATEPART(HH,���ʿϷ�ð�) IN (18,19,20,21,22,23)) THEN '�߰�' ELSE '�ְ�' END
				,HnS����
				,NUM

		) B



		GROUP BY YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(LST_OPERTR_ID)
				,HnS����
				,VOCDAYADD,���߱���,�־߰�����
				,NUM



UNION ALL

--------------------------------------------------------------------------------------------------------------------------------------------------------------
/* ���⼭���� ��� ���� */


SELECT '���'GBN,YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(CHKR_LOGIN_ID)LST_OPERTR_ID
				,HnS����
				,VOCDAYADD,���߱���,�־߰�����,NUM
						
		,COUNT(DISTINCT CHKR_LOGIN_ID) AS �۾��ڼ�
		,COUNT(DISTINCT YYMMDD ) AS �ٹ��ϼ�
		,COUNT(DISTINCT DABL_RCV_NUM) AS �⵿��




		FROM 
		(
		SELECT	DISTINCT CAST(A.OPER_FNSH_DTM AS DATE)YYMMDD,DATEPART(YY,A.OPER_FNSH_DTM)YY,DATEPART(MM,A.OPER_FNSH_DTM)MM,DATEPART(DD,A.OPER_FNSH_DTM)DD,DATEPART(wk,OPER_FNSH_DTM)wk
				,CASE WHEN (VOCDAY = '�Ͽ���')	THEN VOCDAY
					  ELSE [WEEKDAY] END AS VOCDAY
				,NWHQ,B.TEAM
				,A.OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,ISUNION
				,TYPE
				,A.CHKR_LOGIN_ID,A.DABL_RCV_NUM				
				,HNS_YN HnS����
				,VOCDAYADD,NUM
				,CASE	WHEN VOCDAYADD = '������' THEN '�Ͽ���'
						WHEN VOCDAYADD = '�Ͽ���' THEN '�Ͽ���'						
						WHEN VOCDAYADD = '�����' THEN '�����'
						WHEN VOCDAYADD = '������' AND YYMMDD = '2020-08-17' THEN '�Ͽ���'
						ELSE '����' END ���߱���
				,CASE WHEN ( DATEPART(HH,OPER_FNSH_DTM) IN (18,19,20,21,22,23)) THEN '�߰�' ELSE '�ְ�' END �־߰�����
				
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
							AND DABL_OP_ST_CD = '30' AND OPER_DRDOC_OP_ST_CD = '21' and INR_OUT_CL_CD = 'O'			--- ��ֺ����Ϸ� / �Ϸ�_���ü�ó�� / �ܺοϷ� 
							AND DABL_SRC_TYP_CD_NM IS NOT NULL														--- ��ֿ��������ڵ�� ���� ����
							AND MAIN_CNSL_CD_NM  in ('���ͳ�ǰ��','������ȭǰ��','TVǰ��','�������_���ͳ�','�������_��ȭ','�������_TV','��������_����','��������','����������')  --�ؾ������˿�û �� ǰ���Ҹ�_���˿�û �߰��ݿ���
							AND NOT (DABL_SRC_TYP_CD_NM  LIKE '%CS%' OR DABL_SRC_TYP_CD_NM  LIKE '%��Ÿ%' OR DABL_SRC_TYP_CD_NM = '30�� �̻� ó�������� ���� �ڵ��Ϸ�')						
						--	AND TYPE IN ('Home����','HomeŬ����','������')
							AND DABL_RCV_TYP_CD IN ('0','1','2','3')--'2','3')
						
							
		) A
		
		GROUP BY YYMMDD,YY,MM,DD,wk
				
				,NWHQ,TEAM
				,OPER_CO_ID,OPER_CO_ID_NM
				,WRK_CO_ID_SUM,MG_CO_NM_SUM
				,TYPE
				,RTRIM(CHKR_LOGIN_ID)
				,HnS����
				,VOCDAYADD
				,���߱���,�־߰�����
				,NUM
		
			
			) AA

LEFT OUTER JOIN ( SELECT DISTINCT NWHQ,TEAM,A.OPER_CO_ID AS WRK_CO_ID_SUM,OPER_CO_ID_NM AS MG_CO_NM_SUM,A.LOGIN_ID,USER_ID_NM,HNS_YN,CTZ_SER_NUM  FROM TB_DBM_BPRM_PTN_USER_CP A 

                 INNER JOIN ( SELECT DISTINCT OPER_CO_ID,WRK_CO_ID_SUM,MG_CO_NM_SUM,NWHQ,TEAM,ISUNION,TYPE,HNS_YN FROM Teammapping_new_MAP ) B
                            ON A.OPER_CO_ID= B.OPER_CO_ID
					 
                              ) BB
							
ON AA.LST_OPERTR_ID = BB.LOGIN_ID

LEFT OUTER JOIN ( SELECT DISTINCT STAT_DT,�׷��,����,�μ���,CTZ_SER_NUM,���忩��,������,���  FROM HNS_CTZ_SER_NUM_MAP_NEW a
                        WHERE  A.STAT_DT  = '2023-10-01'        	---- ���� �λ����� ����(���� ����� �����ʿ�)
						) CC
			 			        --   ON BB.CTZ_SER_NUM = CC.CTZ_SER_NUM AND YY = DATEPART(YY,CC.STAT_DT) AND MM = DATEPART(MM,CC.STAT_DT)
								  ON BB.CTZ_SER_NUM = CC.CTZ_SER_NUM   
								   
WHERE BB.LOGIN_ID IS NOT NULL
      AND HNS_YN = 'Y'
	  AND ���忩�� = 'SM'

GROUP BY	YYMMDD,YY							-- ��������
				,MM					  	    -- ������
				,DD							-- ������
				,wk
		--		,VOCDAYADD
		         ,CASE	WHEN ���߱��� = '����'      THEN '����'
					WHEN ���߱��� = '�����'    THEN '�ָ�'
					WHEN ���߱��� = '�Ͽ���'    THEN '�ָ�'
					ELSE '����' END 
		--		,���߱���
		--		,�־߰�����
		--		,NUM
				,�׷��,����,�μ���	
			--	,BB.HNS_YN					-- �۾��� ���� �Ҽ� HnS�Ҽӿ���
		
		--		,AA.NWHQ					-- ����DB ������� ���� �������������
		--		,AA.TEAM					-- ����DB ������� ��� �������������
			--	,AA.OPER_CO_ID				-- ����DB ������� ����ID �۾���ü����
			--	,AA.OPER_CO_NM				-- ����DB ������� ����ID�� �۾���ü����
		--		,AA.WRK_CO_ID_SUM			-- ����DB ������� ��������ID �������������
		--		,AA.MG_CO_NM_SUM			-- ����DB ������� ��������ID�� �������������
		--		,AA.TYPE					-- ����DB ������� �������� �������������
				,BB.CTZ_SER_NUM
			--	,BB.LOGIN_ID			-- �۾���ID
				,USER_ID_NM					-- �۾���ID��
			--	,AA.HnS����					-- ����DB ����(AA.OPER_CO_ID)�� Ȩ�ؼ��� ����
		--		,CASE WHEN BB.WRK_CO_ID_SUM = AA.WRK_CO_ID_SUM	 THEN '��üó��'
		--				ELSE '����ó��' END
				 ,���忩��	
				 ,������	
				 ,���
						)DD

						
GROUP BY YY,MM--,  DD
           ,�׷��,����,�μ���,���,USER_ID_NM
		  -- ,���߱���

ORDER BY YY,MM--,  DD
           ,�׷��,����,�μ���,���,USER_ID_NM
		  -- ,���߱���
