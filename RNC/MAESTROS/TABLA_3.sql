/*
  TABLA_3
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_3` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_3` (Codigo, Descripcion)
VALUES
  (1, 'Masculino'),
  (2, 'Femenino');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_3` ORDER BY 1 ASC