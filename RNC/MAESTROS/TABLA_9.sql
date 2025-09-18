/*
  TABLA_9
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_9` (
  Codigo STRING,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_9` (Codigo, Descripcion)
VALUES
  ('T0', 'T0'),
  ('T1', 'T1'),
  ('T2', 'T2'),
  ('T3', 'T3'),
  ('T4', 'T4');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_9` ORDER BY 1 ASC