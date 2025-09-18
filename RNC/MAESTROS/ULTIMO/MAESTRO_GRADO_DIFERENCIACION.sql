CREATE OR REPLACE TABLE `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_GRADO_DIFERENCIACION` (
  GRADO_DIFERIENCIACION_GCP         STRING,
  CODIGO_GRADO_DIFERIENCIACION_GCP  STRING,
  GRADO_DIFERENCIACION_RNC  STRING
);

INSERT INTO `ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.MAESTRO_GRADO_DIFERENCIACION`
  (GRADO_DIFERIENCIACION_GCP, CODIGO_GRADO_DIFERIENCIACION_GCP, GRADO_DIFERENCIACION_RNC)
VALUES
('Bien Diferenciado', '1', 'Bien Diferenciado'),
('Moderadamente Diferenciado', '2', 'Moderadamente Diferenciado'),
('Pobremente Diferenciado', '3', 'Pobremente Diferenciado'),
('Indiferenciado, Anaplasico', '4', 'Indiferenciado'),
('No Determinado (Tipo de celulas no determinado)', '9', 'No Determinado'),
('Celulas T', 'Celulas T', 'Celulas T'),
('Celulas B, pre B, B precursoras', 'Celulas B', 'Celulas B'),
('Celulas nulas (No T-no B)', 'Celulas Nula', 'Celulas Nula'),
('Celulas NK (Natural Killer)', null, null)