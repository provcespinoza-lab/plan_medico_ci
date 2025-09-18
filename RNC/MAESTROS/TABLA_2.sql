/*
  TABLA_2
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_2` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_2` (Codigo, Descripcion)
VALUES
  (1, 'DNI'),
  (2, 'Carnet de Extranjeria'),
  (3, 'Pasaporte'),
  (4, 'Partida de Nacimiento');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_2` ORDER BY 1 ASC