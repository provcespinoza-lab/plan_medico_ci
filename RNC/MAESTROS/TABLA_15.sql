/*
  TABLA_15
*/

--DROP TABLE `ci-datalake-dev.test_dataset.TABLA_15`

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_15` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_15` (Codigo, Descripcion)
VALUES
  (1, '[1] INEN'),
  (2, '[2] Hospital / Clinica'),
  (3, '[3] Domicilio'),
  (4, '[4] Otros'),
  (5, '[5] Ignorado');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_15` ORDER BY 1 ASC