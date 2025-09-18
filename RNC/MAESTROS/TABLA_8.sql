/*
  TABLA_8
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_8` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_8` (Codigo, Descripcion)
VALUES
  (1, 'POR INICIATIVA PROPIA'),
  (2, 'MEDICO PARTICULAR'),
  (3, 'POR REFERENCIA');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_8` ORDER BY 1 ASC
