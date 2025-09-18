/*
  TABLA_12
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_12` (
  Codigo STRING,
  Descripcion STRING
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_12` (Codigo, Descripcion)
VALUES
  ('0', '0'),
  ('I', 'I'),
  ('IA', 'IA'),
  ('IB', 'IB'),
  ('IC', 'IC'),
  ('II', 'II'),
  ('IIA', 'IIA'),
  ('IIB', 'IIB'),
  ('IIC', 'IIC'),
  ('III', 'III'),
  ('IIIA', 'IIIA'),
  ('IIIB', 'IIIB'),
  ('IIIC', 'IIIC'),
  ('IV', 'IV');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_12` ORDER BY 1 ASC