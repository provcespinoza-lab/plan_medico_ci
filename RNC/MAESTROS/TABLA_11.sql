/*
  TABLA_11
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_11` (
  Codigo STRING,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_11` (Codigo, Descripcion)
VALUES
  ('M0', 'M0'),
  ('M1', 'M1');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_11` ORDER BY 1 ASC