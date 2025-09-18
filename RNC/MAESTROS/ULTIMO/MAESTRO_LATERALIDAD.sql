CREATE OR REPLACE TABLE `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_LATERALIDAD` (
  CODIGO_LATERALIDAD_GCP INT64,
  LATERALIDAD_GCP STRING,
  CODIGO_LATERALIDAD_RNC INT64,
  LATERALIDAD_RNC STRING
);

INSERT INTO `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_LATERALIDAD`
  (CODIGO_LATERALIDAD_GCP, LATERALIDAD_GCP, CODIGO_LATERALIDAD_RNC, LATERALIDAD_RNC)
VALUES
(0, 'Organo No Par', 0, 'Organo No Par'),
(1, 'Derecha', 1, 'Derecha'),
(2, ' Izquierda', 2, ' Izquierda'),
(3, 'Bilateral', 3, 'Bilateral'),
(4, 'Par Desconocido', 4, 'Par Desconocido'),
(9, 'Desconocido', 9, 'Desconocido')