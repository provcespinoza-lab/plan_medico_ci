/*
  TABLA_22
*/

-- CREACIÓN DE LA TABLA
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_22` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

-- INSERCIÓN DE DATOS
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_22` (Codigo, Descripcion) VALUES
(0, '[0] Organo No Par'),
(1, '[1] Derecha'),
(2, '[2] Izquierda'),
(3, '[3] Bilateral'),
(4, '[4] Par Desconocido'),
(9, '[9] Desconocido');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_22` ORDER BY 1 ASC