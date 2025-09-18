DECLARE sql STRING;
DECLARE columnas STRING;

-- 1. Generar la lista de columnas dinámicas
SET columnas = (
  SELECT STRING_AGG(
    FORMAT("""
    MAX(CASE WHEN f.CAMPO_PK = %d THEN f.VALOR_CAMPO END) AS `%s`""",
    f.CAMPO_PK,
    --IFNULL(e.CAMPO_FINAL, CONCAT('CAMPO_', CAST(f.CAMPO_PK AS STRING)))
    CASE when f.CAMPO_PK = e.CAMPO_PK THEN e.CAMPO_FINAL ELSE CONCAT('CAMPO_', CAST(f.CAMPO_PK AS STRING)) END
  ), ',\n')
  FROM (
    SELECT DISTINCT CAMPO_PK FROM `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_FORMULARIOS_RNC-V1`
    WHERE FORMULARIO_PK = 978 AND EPIS_PK = 24368018
  ) f
  LEFT JOIN `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_MAESTRO_ETIQUETAS` e
  ON f.CAMPO_PK = e.CAMPO_PK
);

-- 2. Generar el query final
SET sql = FORMAT("""
SELECT
  f.EXP_FORM_PK,
  f.CODIGO_CLIENTE,
  f.EPIS_PK,
  f.FORMULARIO_PK,
  f.TIPO_EPISODIO_PK,
%s
FROM `ci-analytics-dev.ci_rretuerto_bqd_business_dev.TB_FORMULARIOS_RNC-V1` f
WHERE f.FORMULARIO_PK = 978 AND f.EPIS_PK = 24368018
GROUP BY
  f.EXP_FORM_PK,
  f.CODIGO_CLIENTE,
  f.EPIS_PK,
  f.FORMULARIO_PK,
  f.TIPO_EPISODIO_PK
""", columnas);

-- 3. Ejecutar dinámicamente
EXECUTE IMMEDIATE sql;
