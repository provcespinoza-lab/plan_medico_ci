/*
  TABLA_10
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_10` (
  Codigo STRING,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_10` (Codigo, Descripcion)
VALUES
  ('N0', 'N0'),
  ('N1', 'N1'),
  ('N2', 'N2'),
  ('N3', 'N3');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_10` ORDER BY 1 ASC