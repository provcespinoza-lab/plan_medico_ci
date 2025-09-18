/*
  TABLA_14
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_14` (
  Codigo INT64,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_14` (Codigo, Descripcion)
VALUES
  (1, '[1] Cancer'),
  (2, '[2] Otra Enfermedad'),
  (3, '[3] Infecciosa'),
  (4, '[4] Accidente'),
  (5, '[5] Desconocida');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_14` ORDER BY 1 ASC