/*
  TABLA_13
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_13` (
  Codigo INT64,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_13` (Codigo, Descripcion)
VALUES
  (1, '[1] VCE - Visto con Enfermedad'),
  (2, '[2] VSE - Visto sin Enfermedad'),
  (3, '[3] M - Muerto'),
  (4, '[4] PVCE - Perdido de Vista con Enfermedad'),
  (5, '[5] PVSE - Perdido de Vista sin Enfermedad');


SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_13` ORDER BY 1 ASC
