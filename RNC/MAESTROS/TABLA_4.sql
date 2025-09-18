/*
  TABLA_4
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_4` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_4` (Codigo, Descripcion)
VALUES
  (1, 'Sin instrucción'),
  (2, 'Primario'),
  (3, 'Secundario'),
  (4, 'Superior Técnica'),
  (5, 'Superior Universitario'),
  (9, 'Sin dato');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_4` ORDER BY 1 ASC