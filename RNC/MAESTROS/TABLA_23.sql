/*
  TABLA_23
*/

-- CREACIÓN DE LA TABLA
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_23` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

-- INSERCIÓN DE DATOS
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_23` (Codigo, Descripcion) VALUES
(0, '[0] Sólo por Certificado de Defunción'),
(1, '[1] Solamente Clínico'),
(2, '[2] Por Imágenes'),
(3, '[3] Por Endoscopía, Colonoscopía, IVVA, etc'),
(4, '[4] Cirugía Exploradora'),
(5, '[5] Exámenes Bioquímicos y/o inmunológicos'),
(6, '[6] Citología o Hematología Lámina'),
(7, '[7] Histología de Metástasis'),
(8, '[8] Histología de tumor primario'),
(9, 'Desconocido');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_23` ORDER BY 1 ASC