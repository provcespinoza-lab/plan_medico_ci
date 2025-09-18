DECLARE INI DATE DEFAULT '2020-01-01';
DECLARE FIN DATE DEFAULT '2025-04-01';

DECLARE p_start DATE DEFAULT INI ;  -- REPROCESO
DECLARE p_end   DATE DEFAULT FIN ;  -- REPROCESO

--DECLARE p_start DATE DEFAULT DATE_SUB(INI, INTERVAL 2 MONTH);    -- MES -2
--DECLARE p_end   DATE DEFAULT DATE_SUB(FIN, INTERVAL 2 MONTH);    -- MES -2


-- INICIO FOR
FOR mm IN (
  SELECT
    m                                  AS fecha_ini,
    DATE_ADD(m, INTERVAL 1 MONTH)      AS fecha_fin
  FROM UNNEST(GENERATE_DATE_ARRAY(
         DATE_TRUNC(p_start, MONTH),
         DATE_TRUNC(p_end,   MONTH),INTERVAL 1 MONTH)) AS m ) DO


-- COMIENZO DE LOGICA
CREATE OR REPLACE  TABLE `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.RNC_ENTREGABLE_3_TEMP` AS 
WITH
DIAGNOSTICO AS ( SELECT a.DIAGNOSTICO_PK
                       ,a.CODIGO_CLIENTE
                       ,a.FECHA_APERTURA AS fecha_incidencia
                       ,a.HORA_APERTURA
                       ,a.DESCRIPCION AS DX_CLINICO
                       ,CASE WHEN a.DESCRIPCION = b.ONCOLOGIA_MAMA THEN 'SI' ELSE 'NO' END AS DX_ONCO_MAMA
                       ,a.FECHA_REGISTRO
                       ,a.HORA_REGISTRO
                       ,a.FECHA_CIERRE
                       ,b.ICD_COD
                       ,b.LOCALIZACION_ANATOMICA
                FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_DIAGNOSTICO_acc` a
                INNER JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_CIE10_DIAGNOSTICOS` b ON a.ICD_PK = b.ICD_PK AND TRIM(b.aplica) = 'S'
                INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_DIAGNOSTICO_MADUREZ_acc` d ON a.MADUREZ_PK = d.MADUREZ_PK  AND a.MADUREZ_PK = 2
                WHERE FORMAT_DATE('%Y%m', a.FECHA_APERTURA) BETWEEN FORMAT_DATE('%Y%m', mm.fecha_ini )  AND FORMAT_DATE('%Y%m', mm.fecha_ini )  
                QUALIFY ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.FECHA_APERTURA ASC) = 1 ),

ENCUENTRO AS ( SELECT a.DIAGNOSTICO_PK
                     ,a.ENCUENTRO_PK
                     ,b.EPIS_PK
                     ,b.ENCUENTRO_TIPO_PK
                     ,d.DESCRIPCION AS TIPO_ENCUENTRO
                     -- Servicio ingreso
                     ,CASE WHEN ce.TIPO_EPISODIO_PK = 1 THEN U.CODIGO_SERVICIO
                           WHEN ce.TIPO_EPISODIO_PK = 3 THEN I.CODIGO_SERVICIO
                           WHEN ce.TIPO_EPISODIO_PK = 2 THEN C.CODIGO_SERVICIO1
                        ELSE B.SERVICIO_RESPONSABLE END AS COD_SERVICIO_ING
                     -- Servicio atención
                    ,CASE WHEN ce.TIPO_EPISODIO_PK = 1 THEN U.CODIGO_SERVICIO4
                          WHEN ce.TIPO_EPISODIO_PK = 3 THEN I.CODIGO_SERVICIO4
                          WHEN ce.TIPO_EPISODIO_PK = 2 THEN C.CODIGO_SERVICIO1
                        ELSE B.SERVICIO_RESPONSABLE END AS COD_SERVICIO_ATE
                     ,COALESCE(c.COD_PAGADOR_PK, i.COD_PAGADOR_PK, u.COD_PAGADOR_PK ) AS COD_PAGADOR_PK
                     ,COALESCE(MOTIVO_URG_LIBRE , CEX_ICD_DESCR, DIAGNO1_ING) TIPO_ENCUENTRO_DES
               FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_BE_ENC_DIAG_acc` a
               INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_BE_ENCUENTRO_acc` b  ON a.ENCUENTRO_PK = b.ENCUENTRO_PK
               INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_EPISODIOS_acc` ce  ON b.EPIS_PK = ce.EPIS_PK
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_BE_ENCUENTRO_TIPO_acc` d ON b.ENCUENTRO_TIPO_PK = d.ENCUENTRO_TIPO_PK
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CEX_acc` C ON ce.REFERENCIA_ID = C.CEX_PK AND ce.TIPO_EPISODIO_PK = 2                -- CEX
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_INGRESOS_acc` I  ON ce.REFERENCIA_ID = I.COD_INGRESO_PK AND ce.TIPO_EPISODIO_PK = 3  -- HOSPITAL
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_URGENCIAS_acc` U ON ce.REFERENCIA_ID = U.ID_URGENCIA_PK AND ce.TIPO_EPISODIO_PK = 1  -- URGENCIAS
               WHERE FORMAT_DATE('%Y%m', b.FECHA_APERTURA) BETWEEN FORMAT_DATE('%Y%m', mm.fecha_ini )  AND FORMAT_DATE('%Y%m', mm.fecha_ini )  
               QUALIFY ROW_NUMBER() OVER (PARTITION BY a.DIAGNOSTICO_PK ORDER BY b.FECHA_APERTURA ASC) = 1
               ORDER BY 1,2  ),

PACIENTE AS ( SELECT a.CODIGO_CLIENTE
                    ,IFNULL(b.DESCRIPCION_DOCUMENTO_RNC ,'Sin Dato') AS TIPODOC
                    ,a.CODIGO1   AS NUMDOC
                    ,a.APELLIDO1 AS APEPAT
                    ,a.APELLIDO2 AS APEMAT
                    ,a.NOMBRE    AS NOMBRES
                    ,CASE WHEN c.CODIGO_SEXO = 2 THEN 'MASCULINO'
                        WHEN c.CODIGO_SEXO = 3 THEN 'FEMENINO'
                        ELSE 'Sin Dato' END SEXO
                    ,DATE(a.NAC_FECHA) AS FECHA_NAC
                    ,IFNULL(d.DESCRIPCION_INSTRUCCION_RNC,'Sin Dato') AS INSTRUCCION
                    ,IFNULL(e.DESCRIPCION_OCUPACION_RNC,'Sin Dato') AS OCUPACION
                    ,a.DOM_DIRECCION AS DIRECCION_RES
                    ,a.TELEFONO1 AS TELEFONO_RES
                    ,a.TELEFONO2 AS CELULAR_RES
                    ,f.NHC AS HISTCLI
                    ,CASE WHEN a.nac_ld1 = 1 THEN 'PERUANO'
                          WHEN a.nac_ld1 <> 1 THEN 'EXTRANJERO'
                          ELSE 'Sin Dato' END PAIS_NAC
                    ,IFNULL(g.NOMBRE_UBIGEO_RNC, 'RN') AS ubigeo_nac
                    ,A.nac_ld5
                    ,IFNULL(CAST(h.NOMBRE_UBIGEO_RNC AS STRING), 'RN') AS ubigeo_res
                    ,a.dom_ld5
              FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CLIENTES_acc` a
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_TIPO_DOCUMENTO` b ON a.TIPO_DNI_PK = b.CODIGO_DOCUMENTO_XHIST
              LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SEXO_acc` c ON a.CODIGO_SEXO = c.CODIGO_SEXO
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_GRADO_INSTRUCCION` d ON a.CODIGO_ESTUDIOS = d.CODIGO_INSTRUCCION_XHIS
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_OCUPACION` e ON a.CODIGO_PROFESION = e.CODIGO_OCUPACION_XHIS
              LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HC_acc` f ON a.CODIGO_CLIENTE = f.CODIGO_CLIENTE  AND f.ACTIVA_SN = 1
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_UBIGEO` g ON a.nac_ld5 = CAST(g.CODIGO_UBIGEO_XHIS AS INT64)
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_UBIGEO` h ON a.dom_ld5 = CAST(h.CODIGO_UBIGEO_XHIS AS INT64) ),

SERV_INGRESO_ORDENADO AS ( SELECT a.CODIGO_CLIENTE
                                 ,a.CEX_FECHA_CITA       AS FECHA_EVENTO
                                 ,A.CEX_PK
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.CEX_FECHA_CITA ASC, a.CEX_PK ASC ) AS rn_asc
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.CEX_FECHA_CITA DESC, a.CEX_PK DESC ) AS rn_desc
                           FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CEX_acc` a
                           INNER JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_CIE10_DIAGNOSTICOS` b  ON a.ICD_COD = b.ICD_COD  AND TRIM(b.aplica) = 'S' 
                           WHERE  a.CODIGO_SERVICIO1 IN ( SELECT CODIGO_SERVICIO FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_SERVICIOS_RNC`)
                           UNION ALL
                           SELECT a.CODIGO_CLIENTE
                                 ,a.FECHA_INGRESO        AS FECHA_EVENTO
                                 ,a.COD_INGRESO_PK
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.FECHA_INGRESO ASC, a.COD_INGRESO_PK ASC ) AS rn_asc
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.FECHA_INGRESO DESC, a.COD_INGRESO_PK DESC ) AS rn_desc
                           FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_INGRESOS_acc` a
                           INNER JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_CIE10_DIAGNOSTICOS` b  ON a.ICD_COD = b.ICD_COD  AND TRIM(b.aplica) = 'S' 
                           WHERE  a.CODIGO_SERVICIO IN ( SELECT CODIGO_SERVICIO FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_SERVICIOS_RNC`) 
                           UNION ALL
                           SELECT a.CODIGO_CLIENTE
                                 ,a.ENTRADA_FECHA        AS FECHA_EVENTO
                                 ,a.ID_URGENCIA_PK
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.ENTRADA_FECHA ASC, a.ID_URGENCIA_PK ASC ) AS rn_asc
                                 ,ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.ENTRADA_FECHA DESC, a.ID_URGENCIA_PK DESC ) AS rn_desc
                           FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_URGENCIAS_acc` a
                           INNER JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_CIE10_DIAGNOSTICOS` b  ON a.ICD_COD = b.ICD_COD  AND TRIM(b.aplica) = 'S' 
                           WHERE  a.CODIGO_SERVICIO IN ( SELECT CODIGO_SERVICIO FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_SERVICIOS_RNC`) ),

DATA_SERV_INGRESO AS (  SELECT  CODIGO_CLIENTE
                              ,MIN(FECHA_EVENTO) AS FECHA_PRI_EVALUACION
                              ,MAX(FECHA_EVENTO) AS FECHA_ULT_CONTROL    
                        FROM SERV_INGRESO_ORDENADO
                        GROUP BY 1 ),

DATA_CEX2 AS ( SELECT CEX.CODIGO_CLIENTE AS CODIGO_CLIENTE 
                     ,epi.epis_pk        AS ENCUENTRO 
                     ,CL.CODIGO1         AS DNI 
                     ,ghist.ghi_fecha    AS fecha_ult_mamo 
               FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CEX_acc`  CEX
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CLIENTES_acc`  CL ON CL.CODIGO_CLIENTE = CEX.CODIGO_CLIENTE
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIOS_acc`  S ON S.CODIGO_SERVICIO = CEX.CODIGO_SERVICIO1 
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIOS_acc`  S4 ON S4.CODIGO_SERVICIO = CEX.CODIGO_SERVICIO1 
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CENTROS_acc`  C4 ON C4.COD_CENTRO = S4.COD_CENTRO 
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_TPO_DNI_acc`  tpodni on CL.TIPO_DNI_PK = tpodni.TIPO_DNI_PK
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_EPISODIOS_acc`  epi on CEX.CEX_PK = epi.referencia_id
               --- NUEVO AÑADIDO APOYO AL DX 
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PEDIDO_acc`  gped on epi.epis_pk = gped.epis_pk  and epi.codigo_cliente = gped.codigo_cliente
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PETICION_acc`  gpeti on gped.pedido_pk = gpeti.pedido_pk
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_FAMILIA_acc`  gfamilia on gpeti.familia_pk = gfamilia.familia_pk AND (gfamilia.familia_pk in (2))
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PRUEBA_acc`  gprueba on gpeti.peticion_pk = gprueba.peticion_pk
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_CATALOGO_acc`  gcat on gprueba.catalogo_pk = gcat.catalogo_pk
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIO_BASICO_acc`  servbas on servbas.serv_bas_pk = gpeti.serv_bas_pk
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_ESTADO_acc`  gest on gpeti.estado_pk =  gest.estado_pk
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` fper2 ON gpeti.CODIGO_PERSONAL_DEST= fper2.codigo_personal 
               LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` fper3 ON fper3.codigo_personal = CEX.codigo_personal 
               -------------------------------------------------------------
               inner join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_HIST_ESTADO_acc` ghist on  ghist.peticion_pk = gpeti.peticion_pk
               inner join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_ESTADO_acc` gest2 on ghist.estado_pk =  gest2.estado_pk AND  ghist.ESTADO_PK = gest2.estado_pk AND gest2.estado_pk in (7)
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` persona_destino ON gpeti.CODIGO_PERSONAL_DEST = persona_destino.CODIGO_PERSONAL
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` persona_solicitante ON gped.codigo_personal_sol = persona_solicitante.CODIGO_PERSONAL
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` persona_responsable ON gpeti.CODIGO_PERSONAL_ASIG = persona_responsable.CODIGO_PERSONAL
               left join `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` persona_finaliza ON gpeti.CODIGO_PERSONAL_FIN = persona_finaliza.CODIGO_PERSONAL
               left JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_CAT_NIVEL_2_acc`  gcatn2 ON gcatn2.CAT_NIVEL_2_PK = gcat.CAT_NIVEL_2_PK
               left JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_CAT_NIVEL_1_acc`  gcatn1 ON gcatn1.CAT_NIVEL_1_PK = gcatn2.CAT_NIVEL_1_PK
               WHERE CEX.CEX_FECHA_OUT IS NOT NULL --NO DEBE CONTAR CON FECHA DE ALTA ADMINISTRATIVA
               AND epi.tipo_episodio_pk = 2 --EMERGENCIA
               AND gcat.GCA_NOMBRE LIKE '%AMOGRAFI%'
               QUALIFY ROW_NUMBER() OVER (PARTITION BY CEX.CODIGO_CLIENTE ORDER BY ghist.ghi_fecha DESC) = 1
               ORDER BY CEX_FECHA_CITA ),

ULTIMA_MAMOGRAFIA AS ( SELECT a.CODIGO_CLIENTE AS CODIGO_CLIENTE
                             ,b.CODIGO1        AS DNI                                                         
                             ,d.EPIS_PK        AS ENCUENTRO
                             ,j.GHI_FECHA      AS fecha_ult_mamo
                        FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CEX_acc` a
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CLIENTES_acc` b ON b.CODIGO_CLIENTE = a.CODIGO_CLIENTE
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIOS_acc` c ON c.CODIGO_SERVICIO = a.CODIGO_SERVICIO1
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_EPISODIOS_acc` d ON a.CEX_PK = d.referencia_id
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PEDIDO_acc` e ON d.epis_pk = e.epis_pk AND d.codigo_cliente = e.codigo_cliente
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PETICION_acc` f ON e.pedido_pk = f.pedido_pk
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_FAMILIA_acc` g ON f.familia_pk = g.familia_pk AND g.familia_pk IN (2)
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_PRUEBA_acc` h ON f.peticion_pk = h.peticion_pk
                        LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_CATALOGO_acc` i ON h.catalogo_pk = i.catalogo_pk
                        INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_HIST_ESTADO_acc` j ON j.peticion_pk = f.peticion_pk
                        INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GPC_ESTADO_acc` k ON j.estado_pk = k.estado_pk AND k.estado_pk IN (7)
                        WHERE a.CEX_FECHA_OUT IS NOT NULL
                        AND d.tipo_episodio_pk = 2
                        AND i.GCA_NOMBRE LIKE '%AMOGRAFI%'
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY j.ghi_fecha DESC) = 1 ),

/*
  SEGUNDO ENTRETABLE - 25 CAMPOS
*/

FORM_FICHA_EVAL_GINECOLOGICA AS ( SELECT  a.codigo_cliente
                                         ,a.fecha_registro_form
                                         ,a.ULT_PAP
                                         ,FORMAT_DATE('%Y-%m-%d',
                                          CASE WHEN ULT_PAP IS NULL OR TRIM(CAST(ULT_PAP AS STRING)) IN ('', '0') THEN NULL
                                               WHEN REGEXP_CONTAINS(TRIM(CAST(ULT_PAP AS STRING)), r'^\d{4}$') THEN DATE(CAST(ULT_PAP AS INT64), 6, 15)  -- solo año -> 15/06/<año>
                                               ELSE COALESCE(
                                               SAFE.PARSE_DATE('%Y-%m-%d', TRIM(CAST(ULT_PAP AS STRING))),
                                               SAFE.PARSE_DATE('%d/%m/%Y', TRIM(CAST(ULT_PAP AS STRING))),
                                               SAFE.PARSE_DATE('%Y%m%d',   TRIM(CAST(ULT_PAP AS STRING)))
                                              ) END ) AS fecha_ult_papanico  -- SEGUNDO ENTREGABLE
                                  FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_FICHA_EVALUACION_GINECOLOGICA` a
                                  WHERE a.SEXO = 'Femenino' AND a.ULT_PAP IS NOT NULL
                                  QUALIFY ROW_NUMBER() OVER (PARTITION BY a.codigo_cliente ORDER BY a.fecha_registro_form DESC) = 1 ),

VACUNA_PAPILOMA AS ( SELECT a.CODIGO_CLIENTE
                           ,a.COD_VACUNA
                           ,b.NOM_VACUNA
                           ,c.FECHA2
                           ,c.FECHA1
                           ,COALESCE(c.FECHA2, c.FECHA1) AS FECHA_VACUNA_PAPILOMA
                           ,CASE WHEN COALESCE(c.FECHA2, c.FECHA1) IS NOT NULL THEN 'SI' ELSE 'NO' END  AS rec_vac_papiloma  -- SEGUNDO ENTREGABLE
                      FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_VACC_VACUNAS_PAC_acc` a
                      LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_VACC_VACUNAS_acc`  b ON a.COD_VACUNA      = b.COD_VACUNA
                      LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_VACC_DOSIS_PAC_acc` c ON a.VACUNAS_PAC_PK = c.COD_VACUNA_PAC
                      LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_VACC_ESTADOS_DOSIS_acc` d ON c.ESTADO = d.ESTADO_DOSIS_PK
                      LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CLIENTES_acc` e ON a.CODIGO_CLIENTE = e.CODIGO_CLIENTE
                      WHERE a.ACTIVO_SN = 1 AND c.ESTADO = 1 AND a.COD_VACUNA IN (13,33)
                      QUALIFY ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY FECHA_VACUNA_PAPILOMA DESC) = 1 ),

FORM_HIST_CLINICA_ONCOLOGICA AS ( SELECT a.codigo_cliente
                                        ,a.fecha_registro_form
                                        ,CASE WHEN a.TIEMPO_ENFERMEDAD IS NOT NULL AND a.TIEMPO_ENFERMEDAD_1 IS NOT NULL THEN CONCAT(CAST(a.TIEMPO_ENFERMEDAD AS STRING), ' ', TRIM(CAST(a.TIEMPO_ENFERMEDAD_1 AS STRING)) ) ELSE NULL END AS temf_dias_hco
                                        ,CONCAT('T', CAST(a.T AS STRING)) AS t  -- SEGUNDO ENTREGABLE
                                        ,CONCAT('N', CAST(a.N AS STRING)) AS n  -- SEGUNDO ENTREGABLE
                                        ,CONCAT('M', CAST(a.M AS STRING)) AS m  -- SEGUNDO ENTREGABLE
                                        ,a.ESTADIO AS estadio_cli  -- SEGUNDO ENTREGABLE
                                  FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_HISTORIA_CLINICA_ONCOLOGICA` a
                                  QUALIFY ROW_NUMBER() OVER (PARTITION BY a.codigo_cliente ORDER BY a.fecha_registro_form DESC) = 1 ),

FORM_REPORTE_OPERATORIO AS ( SELECT  a.codigo_cliente
                                    ,a.fecha_registro_form  AS fecha_tra_cir  -- SEGUNDO ENTREGABLE
                                    ,CASE WHEN a.fecha_registro_form IS NOT NULL THEN 'SI' ELSE 'NO' END AS tra_cir  -- SEGUNDO ENTREGABLE
                             FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_REPORTE_OPERATORIO` a
                             QUALIFY ROW_NUMBER() OVER (PARTITION BY a.CODIGO_CLIENTE ORDER BY a.fecha_registro_form ASC) = 1 ),

TRATAMIENTO_TERAPIA_BIOLOGICA AS ( SELECT HP.CODIGO_CLIENTE
                                         ,HP.EPIS_PK
                                         ,HP.PROT_MEDICO_PK AS CODIGO_PROTOCOLO
                                         ,PM.NOMBRE AS PROTOCOLO
                                         ,PRO.TIPO --Tipo de Tratamiento
                                         ,DATE(HP.FECHA_REG) AS fecha_tra_ter_bio  -- TERCER ENTREGABLE (AMARILLO)
                                         ,CASE HP.ESTADO
                                            WHEN 1 THEN 'Provisional'
                                            WHEN 2 THEN 'Planificado'
                                            WHEN 3 THEN 'En curso'
                                            WHEN 4 THEN 'Finalizado'
                                            WHEN 5 THEN 'Interrumpido'
                                            WHEN 6 THEN 'Anulado'
                                          END AS ESTADO
                                         ,DATE(HP.FECHA_PREV_INICIO) AS FECHA_INICIO
                                         ,DATE(HP.FECHA_FIN)         AS FECHA_FIN
                                         ,FORMAT_TIMESTAMP('%d/%m/%Y %H:%M:%S', TIMESTAMP(HP.FECHA_ULT_MODIF)) AS FECHA_MODIF
                                         ,HP.ICD_PK AS CODIGO_DIAGNOSTICO
                                         ,DIAG.ICD_COD as CIE10_DIAGNOSTICO
                                         ,CONCAT(DIAG.ICD_COD, ' - ', DIAG.ICD_NOM) AS DIAGNOSTICO
                                         ,CASE WHEN PM.NOMBRE IS NOT NULL THEN 'SI' ELSE 'NO' END AS tra_ter_bio  -- SEGUNDO ENTREGABLE
                                    FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HOJA_PROT_acc` HP
                                    INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_PROT_MEDICO_acc` PM ON PM.PROT_MEDICO_PK = HP.PROT_MEDICO_PK
                                    LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` FP ON FP.codigo_personal = HP.PRESCRIPTOR
                                    LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc` FP2 ON FP2.codigo_personal = HP.PROF_ULT_MODIF
                                    INNER JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_ICD_acc` DIAG ON DIAG.ICD_PK = HP.ICD_PK
                                    INNER JOIN `ci-analytics-dev.ci_iagreda_bqd_business_dev.protocolo_tipo_tratamiento_rnc` PRO ON TRIM(PM.NOMBRE) = TRIM(PRO.PROTOCOLO)
                                    WHERE PRO.TIPO = 'Terapia Biológica'
                                    QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(HP.CODIGO_CLIENTE AS INT64) ORDER BY fecha_tra_ter_bio DESC) = 1 ),

FORM_QUIMIO_ENFERMERIA AS ( SELECT a.codigo_cliente
                                  ,a.fecha_registro_form AS fecha_tra_qui  -- SEGUNDO ENTREGABLE
                                  ,CASE WHEN MAX(a.fecha_registro_form) IS NOT NULL THEN 'SI' ELSE 'NO' END AS tra_qui  -- SEGUNDO ENTREGABLE
                            FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_ADMINISTRACION_QUIMIOTERAPIA_ENFERMERIA` a
                            WHERE a.AMBITO IN ('Ambulatorio', 'Hospitalario')
                            GROUP BY 1,2
                            QUALIFY ROW_NUMBER() OVER (PARTITION BY a.codigo_cliente ORDER BY fecha_tra_qui ASC) = 1 ),

TRATAMIENTO_CUIDADOS AS ( SELECT CEX.CODIGO_CLIENTE
                                ,CEX.CEX_FECHA_IN
                                ,CEX.CODIGO_SERVICIO1
                                ,S.SERVICIO
                                ,CASE WHEN CEX.CEX_FECHA_IN IS NOT NULL AND S.CODIGO_SERVICIO IN (1278, 946, 947, 1622, 1623, 1624, 885, 886) THEN DATE(CEX.CEX_FECHA_IN) ELSE NULL END AS fecha_tra_cui  -- SEGUNDO ENTREGABLE
                                ,CASE WHEN CEX.CEX_FECHA_IN IS NOT NULL AND S.CODIGO_SERVICIO IN (1278, 946, 947, 1622, 1623, 1624, 885, 886) THEN 'SI' ELSE 'NO' END AS tra_cui  -- SEGUNDO ENTREGABLE
                          FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_CEX_acc` CEX
                          LEFT JOIN  `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIOS_acc` S ON S.CODIGO_SERVICIO = CEX.CODIGO_SERVICIO1
                          QUALIFY ROW_NUMBER() OVER (PARTITION BY CEX.CODIGO_CLIENTE ORDER BY CEX.CEX_FECHA_IN ASC) = 1 ),

TRATAMIENTO_HORMONOTERAPIA AS ( SELECT SAFE_CAST(a.COD_PACIENTE AS INT64)
                                    ,a.NUM_ENCUENTRO
                                    ,a.COD_PRESTACION
                                    ,a.DES_PRESTACION
                                    ,'Hormonoterapia' AS TIPO_TRATAMIENTO
                                    ,a.COD_PACIENTE
                                    ,CASE WHEN a.FEH_PRESTACION_SERVICIO IS NULL THEN 'NO' ELSE 'SI' END AS tra_horm  -- SEGUNDO ENTREGABLE
                                    ,FORMAT_DATE('%Y-%m-%d', DATE(a.FEH_PRESTACION_SERVICIO)) AS fecha_horm  -- TERCER ENTREGABLE (AMARILLO)
                                    ,a.FEH_PRESTACION_SERVICIO
                                    ,a.FEH_INGRESO,FEH_SALIDA
                                    ,a.FEH_ATENCION
                                FROM `ci-datalake-prod.ci_dtlk_bqd_staging_prod.OD_PREF_DETALLE_SERVICIO` a
                                --WHERE TIMESTAMP_TRUNC(_PARTITIONTIME, DAY) = CURRENT_DATE()  -- FECHA ACTUAL
                                WHERE DATE(_PARTITIONTIME) = CURRENT_DATE()
                                AND FEH_INGRESO >= "2024-01-01" -- 2 ANIOS ATRAS
                                AND COD_PRESTACION IN
                                ('2000098689', '2000095351', '2000087789', '2000098411', '2000096205', '2000083133', '2000061991', '2000087108', 
                                '2000088513', '2000095282', '2000011756', '2000094683', '2000088138', '2000048918', '2000040581', '2000048208', 
                                '2000099339', '2000088118', '2000062107', '2000049745', '2000098083', '2000040476', '2000054271', '2000013501', 
                                '2000054118', '2000043326', '2000050253', '2000054241', '2000096802', '2000096176', '2000052790', '2000094081', 
                                '2000059071', '2000054108', '2000054139', '2000050168', '2000052233', '2000051277', '2000047731', '2000047295', 
                                '2000043434', '2000062269', '2000063309', '20000631')
                                AND COD_APLICATIVO IN ('XHIS6','XHIS5')
                                QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(a.COD_PACIENTE AS INT64) ORDER BY a.FEH_PRESTACION_SERVICIO ASC) = 1 ),

FORM_EPICRISIS AS ( SELECT a.codigo_cliente
                          ,a.fecha_registro_form
                          ,CASE WHEN a.TIEMPO_ENFERMEDAD IS NOT NULL AND a.TIEMPO_ENFERMEDAD_1 IS NOT NULL THEN CONCAT(CAST(a.TIEMPO_ENFERMEDAD AS STRING), ' ', TRIM(CAST(a.TIEMPO_ENFERMEDAD_1 AS STRING)) ) ELSE NULL END AS temf_dias_epi
                          ,a.CONDICION_ALTA
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN 3 ELSE 1 END AS status  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.CAUSA_MORTALIDAD ELSE NULL END AS causa_muerte  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.CENTRO ELSE NULL END AS lug_deceso  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.fecha_registro_form ELSE NULL END AS fecha_defun  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.CAUSA_MORTALIDAD ELSE NULL END AS causa_final  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.CAUSA_MORTALIDAD ELSE NULL END AS causa_intermedia  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN a.CAUSA_MORTALIDAD ELSE NULL END AS causa_basica  -- SEGUNDO ENTREGABLE
                          ,CASE WHEN TRIM(a.CONDICION_ALTA) = 'Fallecido' THEN REGEXP_EXTRACT(IFNULL(FIRMA_MEDICO,''), r'(\d{4,7})') ELSE NULL END AS cmp  -- SEGUNDO ENTREGABLE
                    FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_EPICRISIS_INFORME_ALTA` a
                    WHERE a.tipo_episodio_pk = 3 -- HOSPITALARIO
                    QUALIFY ROW_NUMBER() OVER (PARTITION BY a.codigo_cliente ORDER BY a.fecha_registro_form DESC) = 1 ),  --> Agrego el campo fecha_registro_form para validar el ultino registro


--TERCER ENTREGABLE - 15 CAMPOS PARA ESTE JUEVES 04/09/2025

ALERTAS_PATOLOGICAS AS ( SELECT DISTINCT CODIGO_CASO                           --Nro. anatomía patológica
                               ,LPAD(CAST(DNI AS STRING), 8, '0') as DNI_PCTE  -- Código clase caso
                               ,CASE WHEN FECHA_DIAGNOSTICO IS NULL OR FECHA_DIAGNOSTICO = 'nan' THEN NULL ELSE CAST(LEFT(TRIM(FECHA_DIAGNOSTICO),10) AS DATE) END as FCH_DX
                               ,CASE WHEN FECHA_COMUNICACION_ALERTA IS NULL OR FECHA_COMUNICACION_ALERTA = 'nan' THEN NULL ELSE CAST(LEFT(TRIM(FECHA_COMUNICACION_ALERTA),10) AS DATE) END AS fecha_exam_pato  --Fecha exámen patológico
                               ,TIPO_MUESTRA_PRUEBA
                               ,CASE WHEN SEDE_CLIENTE = 'SAN BORJA' THEN '00009682' ELSE NULL END AS eess  -- VALIDADO 17/09/2025  -- SEGUNDO ENTREGABLE
                         FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.aext_RESULTADO_PATOLOGIA_acc`
                         QUALIFY ROW_NUMBER() OVER (PARTITION BY DNI_PCTE ORDER BY fecha_exam_pato ASC) = 1 ),

TRATAMIENTO_INMUNOTERAPIA AS (  SELECT HP.CODIGO_CLIENTE
                                        ,HP.EPIS_PK
                                        ,HP.PROT_MEDICO_PK AS CODIGO_PROTOCOLO
                                        ,PM.NOMBRE AS PROTOCOLO
                                        ,PRO.TIPO --Tipo de Tratamiento
                                        ,DATE(HP.FECHA_REG) AS fecha_tra_inmu  -- TERCER ENTREGABLE (AMARILLO)
                                        ,CASE WHEN HP.FECHA_REG IS NOT NULL THEN 'SI' ELSE 'NO' END AS tra_inmu  -- TERCER ENTREGABLE (AMARILLO)
                                        ,CASE HP.ESTADO
                                            WHEN 1 THEN 'Provisional'
                                            WHEN 2 THEN 'Planificado'
                                            WHEN 3 THEN 'En curso'
                                            WHEN 4 THEN 'Finalizado'
                                            WHEN 5 THEN 'Interrumpido'
                                            WHEN 6 THEN 'Anulado'
                                        END AS ESTADO
                                        ,DATE(HP.FECHA_PREV_INICIO) AS FECHA_INICIO
                                        ,DATE(HP.FECHA_FIN) AS FECHA_FIN
                                        ,FORMAT_TIMESTAMP('%d/%m/%Y %H:%M:%S', TIMESTAMP(HP.FECHA_ULT_MODIF)) AS FECHA_MODIF
                                        ,HP.ICD_PK AS CODIGO_DIAGNOSTICO
                                        ,DIAG.ICD_COD as CIE10_DIAGNOSTICO
                                        ,CONCAT(DIAG.ICD_COD, ' - ', DIAG.ICD_NOM) AS DIAGNOSTICO
                                FROM ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HOJA_PROT_acc  HP
                                INNER JOIN ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_PROT_MEDICO_acc  PM ON PM.PROT_MEDICO_PK = HP.PROT_MEDICO_PK
                                LEFT JOIN ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc  FP ON FP.codigo_personal = HP.PRESCRIPTOR
                                LEFT JOIN ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_FPERSONA_acc  FP2 ON FP2.codigo_personal = HP.PROF_ULT_MODIF
                                INNER JOIN ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_ICD_acc  DIAG ON DIAG.ICD_PK = HP.ICD_PK
                                INNER JOIN `ci-analytics-dev.ci_iagreda_bqd_business_dev.protocolo_tipo_tratamiento_rnc` PRO ON TRIM(PM.NOMBRE) = TRIM(PRO.PROTOCOLO)
                                WHERE PRO.TIPO = 'Inmunoterapia'
                                QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(HP.CODIGO_CLIENTE AS INT64) ORDER BY fecha_tra_inmu ASC) = 1 ),

PACIENTES_NUEVOS_RNC AS  ( SELECT DISTINCT TRIM(NUMERO_DOCUMENTO) AS NUMERO_DOCUMENTO
                                 ,EXTRACT(DATE FROM SAFE_CAST(NULLIF(FECHA_REGISTRO, 'nan') AS DATETIME)) AS FECHA_REGISTRO
                                 ,TRIM(ORGANO_DIAGNOSTICO)           AS LOCALIZACION_ANATOMICA
                                 ,TRIM(CODIGO_MORFOLOGIA)            AS CODIGO_MORFOLOGIA            --cod_morfo
                                 ,TRIM(CODIGO_GRADO_DIFERIENCIACION) AS CODIGO_GRADO_DIFERIENCIACION --grado_dif 
                                 ,TRIM(CODIGO_LATERALIDAD)           AS CODIGO_LATERALIDAD           --lateralidad 
                                 ,TRIM(PROCEDENCIA_PACIENTE)         AS PROCEDENCIA_PACIENTE         --tra_eess_ref
                           FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.aext_PACIENTES_NUEVOS_acc` 
                           QUALIFY ROW_NUMBER() OVER (PARTITION BY NUMERO_DOCUMENTO ORDER BY FECHA_REGISTRO ASC) = 1 ),

SEGUIMIENTO_ONCOLOGICO AS ( SELECT DISTINCT LPAD(REPLACE(TRIM(DNI),"",TRIM(DNI)),8,"0") AS DNI
                                  ,EXTRACT(DATE FROM SAFE_CAST(NULLIF(FECHA_RECEPCION_ORDEN, 'nan') AS DATETIME)) AS FECHA_REGISTRO --Fecha debe ser igual|posterior a la consulta
                                  ,TRIM(ORGANO_DIAGNOSTICO) AS ORGANO_DIAGNOSTICO
                                  ,TRIM(SERVICIO) AS SERVICIO
                                  ,TRIM(GARANTE) AS GARANTE
                                  ,TRIM(ESTADO_CARTA_GARANTIA) AS ESTADO_CARTA_GARANTIA
                                  ,UPPER(TRIM(CODIGO_METODO_PRIMER_DIAGNOSTICO)) AS CODIGO_METODO_PRIMER_DIAGNOSTICO ---metodo_pri_diag / Método Primer Diagnostico
                                  ,UPPER(TRIM(DIAGNOSTICO)) AS DIAGNOSTICO                                           --cod_topo / Código Topografía
                                  ,UPPER(TRIM(CODIGO_BASE_DIAGNOSTICO)) AS CODIGO_BASE_DIAGNOSTICO                   --- base_diag / Código Base Diagnóstico
                            FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.aext_SEGUIMIENTO_ONCOLOGICO_acc` 
                            QUALIFY ROW_NUMBER() OVER (PARTITION BY DNI ORDER BY FECHA_REGISTRO ASC) = 1  ),

data_final AS ( SELECT --CAST(FORMAT_DATE('%Y%m', INI) AS INT64)             AS PERIODO_EJECUCION              -- MES -2
                      CAST(FORMAT_DATE('%Y%m', fecha_incidencia) AS INT64)       AS PERIODO_EJECUCION     -- REPROCESO
                       --,CAST(FORMAT_DATE('%Y%m', fecha_incidencia) AS INT64) AS PERIODO_REPORTE                -- MES -2
                      ,CAST(FORMAT_DATE('%Y%m', fecha_incidencia) AS INT64)       AS PERIODO_REPORTE       -- REPROCESO
                      ,a.CODIGO_CLIENTE
                      ,b.ENCUENTRO_PK
                      ,b.EPIS_PK
                      ,a.LOCALIZACION_ANATOMICA
                      ,DATE(fecha_pri_evaluacion)   AS fecha_pri_evaluacion
                      ,DATE(fecha_ult_control)      AS fecha_ult_control
                      ,c.histcli
                      ,c.tipodoc
                      ,c.numdoc
                      ,c.apepat
                      ,c.apemat
                      ,c.nombres
                      ,c.sexo
                      ,DATE(c.fecha_nac)            AS fecha_nac
                      ,c.instruccion
                      ,c.ocupacion 
                      ,f.DESCRIPCION_GARANTE_RNC    AS condaseg
                      ,c.pais_nac 
                      ,c.ubigeo_nac
                      ,c.ubigeo_res
                      ,c.direccion_res
                      ,c.telefono_res
                      ,c.celular_res
                      ,DATE(i.fecha_ult_mamo)       AS fecha_ult_mamo
                      ,dx_clinico
                      ,DX_ONCO_MAMA
                      ,DATE(a.fecha_incidencia)     AS fecha_incidencia
                      ,g.SERVICIO                   AS dept_servicio
                      ,CASE WHEN g.CODIGO_SERVICIO IN (1398, 1399, 1400, 154, 119, 234, 1091, 1092, 1093, 913) THEN 'SI' ELSE 'NO' END AS SERVICIO_ONCO
                      ,eess
                      ,k.rec_vac_papiloma
                      ,IFNULL(l.status, 1)          AS status
                      ,l.causa_muerte
                      ,l.lug_deceso
                      ,DATE(l.fecha_defun)                AS fecha_defun      -- validar
                      ,l.causa_final
                      ,l.causa_intermedia
                      ,l.causa_basica
                      ,l.cmp
                      ,DATE(m.fecha_ult_papanico)   AS fecha_ult_papanico
                      ,n.t
                      ,n.n
                      ,n.m
                      ,n.estadio_cli
                      ,CASE WHEN UPPER(TRIM(l.CONDICION_ALTA)) = 'FALLECIDO' THEN COALESCE(l.temf_dias_epi, n.temf_dias_hco) ELSE COALESCE(n.temf_dias_hco, l.temf_dias_epi) END AS temf_dias
                      ,o.tra_cir
                      ,o.fecha_tra_cir 
                      ,p.tra_qui
                      ,p.fecha_tra_qui
                      ,q.tra_cui
                      --,DATE(CEX.CEX_FECHA_IN) AS fecha_tra_cui
                      ,DATE(q.fecha_tra_cui) AS fecha_tra_cui
                      ,r.tra_horm
                      ,DATE(r.fecha_horm) AS fecha_horm
                      --,DATE(a.FEH_PRESTACION_SERVICIO) AS fecha_horm
                      ,t.tra_ter_bio
                      ,DATE(t.fecha_tra_ter_bio) AS fecha_tra_ter_bio
                      --,DATE(HP.FECHA_REG) AS fecha_tra_ter_bio
                      ,u.tra_inmu
                      ,u.fecha_tra_inmu
                      ,s.fecha_exam_pato
                      ,s.CODIGO_CASO AS nro_anatomia_pato 
                      ,s.DNI_PCTE
                      ,v.CODIGO_MORFOLOGIA                AS cod_morfo
                      ,v.CODIGO_GRADO_DIFERIENCIACION     AS grado_dif
                      ,v.CODIGO_LATERALIDAD               AS lateralidad
                      ,v.PROCEDENCIA_PACIENTE             AS tra_eess_ref
                      ,w.CODIGO_METODO_PRIMER_DIAGNOSTICO AS metodo_pri_diag
                      ,w.DIAGNOSTICO                      AS cod_topo
                      ,w.CODIGO_BASE_DIAGNOSTICO          AS base_diag 
              FROM DIAGNOSTICO a
              INNER JOIN ENCUENTRO b ON a.DIAGNOSTICO_PK = b.DIAGNOSTICO_PK
              INNER JOIN PACIENTE c ON a.CODIGO_CLIENTE = c.CODIGO_CLIENTE
              LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_PAGADORES_acc` d ON b.COD_PAGADOR_PK = d.COD_PAGADOR_PK
              LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_GARANTES_acc` e ON d.CODIGO_GARANTE_PK = e.CODIGO_GARANTE_PK
              LEFT JOIN `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_GARANTE` f ON e.CODIGO_GARANTE_PK = f.CODIGO_GARANTE_XHIS
              LEFT JOIN `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_SERVICIOS_acc` g ON b.COD_SERVICIO_ING = g.CODIGO_SERVICIO
              LEFT JOIN data_serv_ingreso h ON a.CODIGO_CLIENTE = h.CODIGO_CLIENTE
              LEFT JOIN data_cex2 i ON a.CODIGO_CLIENTE = i.CODIGO_CLIENTE
              LEFT JOIN ULTIMA_MAMOGRAFIA j ON a.CODIGO_CLIENTE = j.CODIGO_CLIENTE
              LEFT JOIN VACUNA_PAPILOMA k ON a.CODIGO_CLIENTE = k.CODIGO_CLIENTE
              LEFT JOIN FORM_EPICRISIS l ON a.CODIGO_CLIENTE = l.CODIGO_CLIENTE
              LEFT JOIN FORM_FICHA_EVAL_GINECOLOGICA m ON a.CODIGO_CLIENTE = m.CODIGO_CLIENTE
              LEFT JOIN FORM_HIST_CLINICA_ONCOLOGICA n ON a.CODIGO_CLIENTE = n.CODIGO_CLIENTE
              LEFT JOIN FORM_REPORTE_OPERATORIO o ON a.CODIGO_CLIENTE = o.CODIGO_CLIENTE
              LEFT JOIN FORM_QUIMIO_ENFERMERIA p ON a.CODIGO_CLIENTE = p.CODIGO_CLIENTE
              LEFT JOIN TRATAMIENTO_CUIDADOS q ON a.CODIGO_CLIENTE = q.CODIGO_CLIENTE
              LEFT JOIN TRATAMIENTO_HORMONOTERAPIA r ON a.CODIGO_CLIENTE = SAFE_CAST(r.COD_PACIENTE AS INT64 ) 
              LEFT JOIN TRATAMIENTO_TERAPIA_BIOLOGICA t ON a.CODIGO_CLIENTE = t.CODIGO_CLIENTE
              LEFT JOIN TRATAMIENTO_INMUNOTERAPIA u ON a.CODIGO_CLIENTE = u.CODIGO_CLIENTE
              LEFT JOIN ALERTAS_PATOLOGICAS s ON c.NUMDOC = s.DNI_PCTE 
              LEFT JOIN PACIENTES_NUEVOS_RNC v ON c.NUMDOC = v.NUMERO_DOCUMENTO 
              LEFT JOIN SEGUIMIENTO_ONCOLOGICO w ON c.NUMDOC = w.DNI  )

select PERIODO_EJECUCION
      ,PERIODO_REPORTE
      ,CODIGO_CLIENTE
      ,ENCUENTRO_PK
      ,EPIS_PK
      ,LOCALIZACION_ANATOMICA
      ,eess
      ,fecha_pri_evaluacion
      ,histcli
      ,fecha_ult_control
      ,CASE WHEN NUMDOC = DNI_PCTE AND ( tra_cir = 'SI' OR  tra_qui = 'SI' OR tra_cui = 'SI' OR tra_horm = 'SI' OR tra_ter_bio = 'SI' OR tra_inmu = 'SI' )  THEN '1' 
            WHEN NUMDOC <> DNI_PCTE AND ( tra_cir = 'SI' OR  tra_qui = 'SI' OR tra_cui = 'SI' OR tra_horm = 'SI' OR tra_ter_bio = 'SI' OR tra_inmu = 'SI' ) THEN '2' ELSE '9' END clase_caso
      ,tipodoc
      ,numdoc
      ,apepat
      ,apemat
      ,nombres
      ,sexo
      ,fecha_nac
      ,instruccion
      ,ocupacion
      ,condaseg
      ,pais_nac
      ,ubigeo_nac
      ,ubigeo_res
      ,direccion_res
      ,telefono_res
      ,celular_res
      ,'SD' AS celular_contacto 
      ,'1'  AS tipo_referencia
      ,'SD' AS eess_ref
      ,fecha_ult_papanico
      ,fecha_ult_mamo
      ,rec_vac_papiloma
      ,CAST(NULL AS DATE) AS fecha_ref
      ,temf_dias
      ,dx_clinico
      ,t
      ,n
      ,m
      ,estadio_cli
      ,fecha_incidencia
      ,metodo_pri_diag
      ,dept_servicio
      ,cod_topo
      ,cod_morfo
      ,grado_dif
      ,lateralidad
      ,base_diag
      ,'SD' AS diag_histologico
      ,nro_anatomia_pato
      ,fecha_exam_pato
      ,tra_cir
      ,fecha_tra_cir
      ,CAST(NULL AS STRING) AS tra_med_nuclear
      ,CAST(NULL AS DATE)   AS fecha_tra_med_nuclear
      ,tra_ter_bio
      ,fecha_tra_ter_bio
      ,CAST(NULL AS STRING) AS tra_rad
      ,CAST(NULL AS DATE)   AS fecha_tra_rad
      ,tra_qui
      ,fecha_tra_qui
      ,tra_cui
      ,fecha_tra_cui
      ,tra_inmu
      ,fecha_tra_inmu
      ,tra_horm
      ,fecha_horm
      ,CAST(NULL AS STRING) AS tra_ref
      ,tra_eess_ref
      ,CAST(NULL AS DATE) AS fecha_tra_eess_ref
      ,CASE WHEN tra_cir = 'NO' AND tra_qui = 'NO' AND tra_cui = 'NO' AND tra_horm = 'NO' AND tra_ter_bio = 'NO' AND tra_inmu = 'NO' THEN 'SI' ELSE 'NO' END AS tra_ninguno
      ,CAST((SELECT MIN(d) FROM UNNEST([CAST(fecha_tra_ter_bio AS DATE), CAST(fecha_tra_qui AS DATE), CAST(fecha_tra_inmu AS DATE), CAST(fecha_horm AS DATE)]) d) AS DATE) AS fecha_ini_tra
      ,CAST(NULL AS DATE) AS fecha_cul_tra
      ,CAST(status AS STRING) AS status
      ,causa_muerte
      ,lug_deceso
      ,fecha_defun
      ,causa_final
      ,causa_intermedia
      ,causa_basica
      ,cmp
from data_final;


MERGE `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.RNC_ENTREGABLE_3` a
USING (
SELECT * FROM `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.RNC_ENTREGABLE_3_TEMP`
) s 
ON a.CODIGO_CLIENTE = s.CODIGO_CLIENTE
AND a.LOCALIZACION_ANATOMICA = s.LOCALIZACION_ANATOMICA
WHEN NOT MATCHED THEN INSERT (
  PERIODO_EJECUCION, PERIODO_REPORTE, CODIGO_CLIENTE, ENCUENTRO_PK, EPIS_PK, LOCALIZACION_ANATOMICA, eess, fecha_pri_evaluacion, histcli, fecha_ult_control, clase_caso,
  tipodoc, numdoc, apepat, apemat, nombres, sexo, fecha_nac, instruccion, ocupacion, condaseg, pais_nac, ubigeo_nac, ubigeo_res, direccion_res,
  telefono_res, celular_res, celular_contacto, tipo_referencia, eess_ref, fecha_ult_papanico, fecha_ult_mamo, rec_vac_papiloma, fecha_ref, temf_dias,
  dx_clinico, t, n, m, estadio_cli, fecha_incidencia, metodo_pri_diag, dept_servicio, cod_topo, cod_morfo, grado_dif, lateralidad, base_diag, diag_histologico,
  nro_anatomia_pato, fecha_exam_pato, tra_cir, fecha_tra_cir, tra_med_nuclear, fecha_tra_med_nuclear, tra_ter_bio, fecha_tra_ter_bio, tra_rad, fecha_tra_rad, tra_qui,
  fecha_tra_qui, tra_cui, fecha_tra_cui, tra_inmu, fecha_tra_inmu, tra_horm, fecha_horm, tra_ref, tra_eess_ref, fecha_tra_eess_ref, tra_ninguno, fecha_ini_tra, fecha_cul_tra, 
  status, causa_muerte, lug_deceso, fecha_defun, causa_final, causa_intermedia, causa_basica, cmp
) VALUES (
  S.PERIODO_EJECUCION, S.PERIODO_REPORTE, S.CODIGO_CLIENTE, S.ENCUENTRO_PK, S.EPIS_PK, S.LOCALIZACION_ANATOMICA, S.eess, S.fecha_pri_evaluacion, S.histcli, S.fecha_ult_control, S.clase_caso, 
  S.tipodoc, S.numdoc, S.apepat, S.apemat, S.nombres, S.sexo, S.fecha_nac, S.instruccion, S.ocupacion, S.condaseg, S.pais_nac, S.ubigeo_nac, S.ubigeo_res, S.direccion_res, S.telefono_res,
  S.celular_res, S.celular_contacto, S.tipo_referencia, S.eess_ref, S.fecha_ult_papanico, S.fecha_ult_mamo, S.rec_vac_papiloma, S.fecha_ref, S.temf_dias, S.dx_clinico, S.t, S.n, S.m,
  S.estadio_cli, S.fecha_incidencia, S.metodo_pri_diag, S.dept_servicio, S.cod_topo, S.cod_morfo, S.grado_dif, S.lateralidad, S.base_diag, S.diag_histologico, S.nro_anatomia_pato,
  S.fecha_exam_pato, S.tra_cir, S.fecha_tra_cir, S.tra_med_nuclear, S.fecha_tra_med_nuclear, S.tra_ter_bio, S.fecha_tra_ter_bio, S.tra_rad, S.fecha_tra_rad, S.tra_qui, S.fecha_tra_qui,
  S.tra_cui, S.fecha_tra_cui, S.tra_inmu, S.fecha_tra_inmu, S.tra_horm, S.fecha_horm, S.tra_ref, S.tra_eess_ref, S.fecha_tra_eess_ref, S.tra_ninguno, S.fecha_ini_tra, S.fecha_cul_tra,
  S.status, S.causa_muerte, S.lug_deceso, S.fecha_defun, S.causa_final, S.causa_intermedia, S.causa_basica, S.cmp
);



-- TERMINO LOGICA
END FOR;
