CREATE OR REPLACE TABLE `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_FORMULARIOS_RNC-V1` AS 
WITH RECURSIVE 
cons_recursivo_form AS ( SELECT FORMULARIO_PK
                               ,REF_FORM_PADRE
                               ,FORMULARIO_PK AS ROOT_FORMULARIO_PK
                              FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_FORMULARIO_acc`
                              WHERE FORMULARIO_PK IN ( 524  -- FICHA_EVALUACION_GINECOLOGICA
                                                      ,979  -- ADMINISTRACION_QUIMIOTERAPIA_ENFERMERIA
                                                      ,883  -- EPICRISIS_INFORME_ALTA
                                                      ,978  -- HISTORIA_CLINICA_ONCOLOGICA
                                                      ,1552 -- REPORTE_OPERATORIO
                                                      ,557  -- REFERENCIA_PACIENTE
                                                     )
                         UNION ALL
                         SELECT f.FORMULARIO_PK
                               ,f.REF_FORM_PADRE
                               ,r.ROOT_FORMULARIO_PK
                         FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_FORMULARIO_acc` f
                         JOIN cons_recursivo_form r ON f.REF_FORM_PADRE = r.FORMULARIO_PK ),

campos_form AS ( SELECT FORMULARIO_PK, CAMPO_PK
                 FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_CAMPOS_FORM_acc` 
                 WHERE FORMULARIO_PK IN ( SELECT FORMULARIO_PK FROM cons_recursivo_form  ) 
                 ORDER BY 1,2
               ),

cons_valores_form_unificados AS ( SELECT CAMPO_PK         --STRING
                                        ,CAMPOS_FORM_PK
                                        ,VAL_EXP_STR_PK AS VAL_EXP_PK 
                                        ,EXP_FORM_PK
                                        ,VALOR_CAMPO
                                  FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_VAL_EXP_STR_acc`
                                  WHERE CAMPO_PK IN ( SELECT DISTINCT CAMPO_PK FROM campos_form )
                                UNION ALL
                                  SELECT CAMPO_PK          --BLOB
                                        ,CAMPOS_FORM_PK
                                        ,VAL_EXP_BLOD_PK AS VAL_EXP_PK 
                                        ,EXP_FORM_PK
                                        ,VALOR_CAMPO
                                  FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_VAL_EXP_BLOD_acc`
                                  WHERE CAMPO_PK IN ( SELECT DISTINCT CAMPO_PK FROM campos_form )
                                UNION ALL
                                  SELECT CAMPO_PK         -- NUM
                                        ,CAMPOS_FORM_PK
                                        ,VAL_EXP_NUM_PK AS VAL_EXP_PK 
                                        ,EXP_FORM_PK
                                        ,CAST(VALOR_CAMPO AS STRING) AS VALOR_CAMPO
                                  FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_VAL_EXP_NUM_acc`
                                  WHERE CAMPO_PK IN ( SELECT DISTINCT CAMPO_PK FROM campos_form )
                                UNION ALL
                                  SELECT CAMPO_PK        -- DATE
                                        ,CAMPOS_FORM_PK
                                        ,VAL_EXP_DATE_PK AS VAL_EXP_PK 
                                        ,EXP_FORM_PK
                                        ,FORMAT_DATE('%d/%m/%Y', VALOR_CAMPO) AS VALOR_CAMPO
                                  FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_VAL_EXP_DATE_acc`
                                  WHERE CAMPO_PK IN ( SELECT DISTINCT CAMPO_PK FROM campos_form )
                                UNION ALL
                                  SELECT CAMPO_PK      -- TIME
                                        ,CAMPOS_FORM_PK
                                        ,VAL_EXP_TIME_PK AS VAL_EXP_PK 
                                        ,EXP_FORM_PK
                                        ,FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP(VALOR_CAMPO)) AS VALOR_CAMPO
                                  FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_VAL_EXP_TIME_acc`
                                  WHERE CAMPO_PK IN ( SELECT DISTINCT CAMPO_PK FROM campos_form ) ),
 

forms_base AS ( SELECT HEF.EXP_FORM_PK
                      ,HEF.FORMULARIO_PK
                      ,HEF.EPIS_PK
                      ,HEF.CODIGO_CLIENTE
                      ,HEF.ERRONEO_SN
                      ,HRF.TIPO_OPER_PK
                      ,HRF.FECHA_REG
                      ,HRF.HORA_REG
                      ,TIMESTAMP(DATETIME(DATE(HRF.FECHA_REG), TIME(HRF.HORA_REG))) AS FORM_REG_FH
                FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_EXP_FORM_acc` HEF
                JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_REGISTRO_FORM_acc` HRF
                ON HRF.EXP_FORM_PK = HEF.EXP_FORM_PK
                WHERE HEF.ERRONEO_SN = 0 -- SOLO NO ANULADOS
                AND HRF.TIPO_OPER_PK IN (10, 30, 24) -- CIERRE DEL FORMULARIO, CIERRE AUTOMATICO, CIERRE POR TEMPORIZADOR
                AND HEF.FORMULARIO_PK IN ( SELECT FORMULARIO_PK FROM cons_recursivo_form )
                ),

forms_ordenados_registro AS ( SELECT *
                                    ,ROW_NUMBER() OVER (PARTITION BY EXP_FORM_PK ORDER BY FORM_REG_FH DESC) AS rn
                              FROM forms_base ),
 
forms_recientes AS ( SELECT * FROM forms_ordenados_registro
                     WHERE rn = 1 ),

--- NUEVO BLOQUE EL FORMULARIO MAS RECIENTE 

cons_forms_epis AS ( SELECT HEF.EXP_FORM_PK
                           ,CRF.ROOT_FORMULARIO_PK
                           ,HEF.CODIGO_CLIENTE
                           ,HEF.EPIS_PK
                           ,HEF.FORMULARIO_PK
                           ,F.DESCRIPCION AS FORMULARIO_DESC
                           ,EP.TIPO_EPISODIO_PK
                           ,HC.CAMPO_PK
                           ,VU.CAMPOS_FORM_PK
                           ,HC.ETIQUETA AS CAMPO_DESC
                           ,VU.VALOR_CAMPO
                           ,VU.VAL_EXP_PK
                           ,DATE(HRF.FECHA_REG) AS FECHA_REGISTRO_FORM
                           ,EXTRACT(YEAR FROM HRF.FECHA_REG) AS FORM_REG_Y
                           ,EXTRACT(MONTH FROM HRF.FECHA_REG) AS FORM_REG_M
                           ,TIMESTAMP(DATETIME(DATE(HRF.FECHA_REG), TIME(HRF.HORA_REG))) AS FORM_REG_FH
                           ,CASE WHEN VU.VALOR_CAMPO IS NULL THEN "Nulo" ELSE "Con valor" END AS CAT_CAMPO
                           ,CASE WHEN CRF.ROOT_FORMULARIO_PK IN (SELECT  FORMULARIO_PK FROM cons_recursivo_form ) AND HC.CAMPO_PK IN (( SELECT DISTINCT CAMPO_PK FROM campos_form ) ) THEN 1 ELSE 0 END AS FLAG_CAMPO_VALIDO
                      FROM forms_recientes HEF
                      JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_FORMULARIO_acc` F ON F.FORMULARIO_PK = HEF.FORMULARIO_PK
                      JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_EPISODIOS_acc` EP ON EP.EPIS_PK = HEF.EPIS_PK
                      JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_REGISTRO_FORM_acc` HRF ON HRF.EXP_FORM_PK = HEF.EXP_FORM_PK
                      JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_CAMPOS_FORM_acc` HCF ON HEF.FORMULARIO_PK = HCF.FORMULARIO_PK
                      JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_CAMPOS_acc` HC ON HC.CAMPO_PK = HCF.CAMPO_PK
                      LEFT JOIN cons_recursivo_form CRF ON CRF.FORMULARIO_PK = HCF.FORMULARIO_PK
                      LEFT JOIN cons_valores_form_unificados VU
                        ON VU.CAMPO_PK = HC.CAMPO_PK
                        AND VU.CAMPOS_FORM_PK = HCF.CAMPOS_FORM_PK
                        AND VU.EXP_FORM_PK = HEF.EXP_FORM_PK
                      WHERE HCF.FORMULARIO_PK IN (SELECT  FORMULARIO_PK FROM cons_recursivo_form)
                      AND HEF.ERRONEO_SN != 1
                      AND HRF.TIPO_OPER_PK IN (10,30,24)
                      ORDER BY HC.CAMPO_PK  )
                      
SELECT EXP_FORM_PK
      ,ROOT_FORMULARIO_PK
      ,CODIGO_CLIENTE
      ,EPIS_PK
      ,FORMULARIO_PK
      ,FORMULARIO_DESC
      ,TIPO_EPISODIO_PK
      ,CAMPO_PK
      ,CAMPO_DESC
      ,CAMPOS_FORM_PK
      --CONCATENACION DE VALORES DEBIDO A CAMPOS CON MULTIPLES VALORES ASOCIADOS A UN CAMPO_PK
      ,STRING_AGG(VALOR_CAMPO, ', ' ORDER BY VAL_EXP_PK ASC) AS VALOR_CAMPO
      ,FECHA_REGISTRO_FORM
      ,FORM_REG_Y
      ,FORM_REG_M
      ,FORM_REG_FH
      ,CAT_CAMPO
FROM cons_forms_epis
WHERE FLAG_CAMPO_VALIDO = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10, 12,13,14,15,16
