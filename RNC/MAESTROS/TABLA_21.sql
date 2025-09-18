/*
  TABLA_21
*/

-- CREACIÓN DE LA TABLA
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_21` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

-- INSERCIÓN DE DATOS
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_21` (Codigo, Descripcion) VALUES
(1, '[1] Bien Diferenciado'),
(2, '[2] Moderadamente Diferenciado'),
(3, '[3] Pobremente Diferenciado'),
(4, '[4] Indiferenciado'),
(5, '[9] No Determinado'),
(6, 'Celulas T'),
(7, 'Celulas B'),
(8, 'Celulas Nula');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_21` ORDER BY 1 ASC