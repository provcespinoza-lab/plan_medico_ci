DECLARE sql STRING;
DECLARE columnas STRING;

CREATE OR REPLACE TEMP TABLE tmp_formularios AS (
WITH RECURSIVE 
cons_recursivo_form AS ( SELECT FORMULARIO_PK
                               ,REF_FORM_PADRE
                               ,FORMULARIO_PK AS ROOT_FORMULARIO_PK
                              FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_FORMULARIO_acc`
                              WHERE FORMULARIO_PK IN ( 557 ) -- REFERENCIA_PACIENTE
                         UNION ALL
                         SELECT f.FORMULARIO_PK
                               ,f.REF_FORM_PADRE
                               ,r.ROOT_FORMULARIO_PK
                         FROM `ci-datalake-prod.ci_dtlk_bqd_access_prod.xhis6_HCE_FORMULARIO_acc` f
                         JOIN cons_recursivo_form r ON f.REF_FORM_PADRE = r.FORMULARIO_PK )

SELECT DISTINCT FORMULARIO_PK FROM cons_recursivo_form
);


SET columnas = (
  SELECT STRING_AGG(
    FORMAT( """MAX(CASE WHEN f.CAMPO_PK = %d THEN f.VALOR_CAMPO END) AS `%s`"""
           ,f.CAMPO_PK
           ,CASE WHEN f.CAMPO_PK = e.CAMPO_PK THEN e.CAMPO_FINAL ELSE CONCAT('CAMPO_', CAST(f.CAMPO_PK AS STRING)) END ), ',\n')
  FROM ( SELECT DISTINCT CAMPO_PK 
         FROM `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_FORMULARIOS_RNC-V1`
         WHERE FORMULARIO_PK IN ( SELECT FORMULARIO_PK FROM tmp_formularios  )   ) f
  LEFT JOIN `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_MAESTRO_ETIQUETAS` e ON f.CAMPO_PK = e.CAMPO_PK
);


-- 2. Generar el query final
SET sql = FORMAT("""
SELECT
  f.exp_form_pk,
  f.codigo_cliente,
  f.epis_pk,
  f.formulario_pk,
  f.tipo_episodio_pk,
  f.fecha_registro_form,
%s
FROM `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_FORMULARIOS_RNC-V1` f
WHERE f.FORMULARIO_PK IN ( SELECT FORMULARIO_PK FROM tmp_formularios  ) 
GROUP BY
  f.exp_form_pk,
  f.codigo_cliente,
  f.epis_pk,
  f.formulario_pk,
  f.tipo_episodio_pk,
  f.fecha_registro_form
""", columnas);

-- 3. Ejecutar dinámicamente
EXECUTE IMMEDIATE FORMAT(""" CREATE OR REPLACE TABLE `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.FORM_REFERENCIA_PACIENTE` AS %s """, sql);
