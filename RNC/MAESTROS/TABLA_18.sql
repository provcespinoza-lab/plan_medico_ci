/*
  TABLA_18
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_18` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_18` (Codigo, Descripcion)
VALUES
  (1, '[1] Medicina'),
  (2, '[2] Cirugía'),
  (3, '[3] Ginecología'),
  (4, '[4] Pediatría'),
  (5, '[5] Emergencia'),
  (6, '[6] Oncología'),
  (7, '[7] Cirugía Pediátrica'),
  (8, '[8] Otros'),
  (9, '[9] No especificado'),
  (10, '[10] Dermatología');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_18` ORDER BY 1 ASC