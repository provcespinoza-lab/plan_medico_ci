/*
  TABLA_6
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_6` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_6` (Codigo, Descripcion)
VALUES
  (0, 'No Asegurado'),
  (1, 'SIS'),
  (2, 'EsSalud – Regular – Titular'),
  (3, 'EsSalud – Regular – Familiar'),
  (4, 'EsSalud – Facultativo'),
  (5, 'EsSalud – Regímenes Especiales'),
  (6, 'FFAA/PNP'),
  (7, 'Privado Nacional – Pre-Pagas'),
  (8, 'Privado Nacional – Auto-Seguro'),
  (9, 'Privado Nacional – Seguro de Asistencia Médica'),
  (10, 'Privado Extranjero'),
  (99, 'No Especificado');

 SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_6` ORDER BY 1 ASC