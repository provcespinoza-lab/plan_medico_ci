/*
  TABLA_17
*/

CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_17` (
  Codigo INT64 NOT NULL,
  Descripcion STRING NOT NULL
);

INSERT INTO `ci-datalake-dev.test_dataset.TABLA_17` (Codigo, Descripcion)
VALUES
  (1, '[1] Programa de Detección / Tamizaje'),
  (2, '[2] Hallazgo incidental por exploración clínica'),
  (3, '[3] Hallazgo incidental por exploración endoscópica'),
  (4, '[4] Hallazgo incidental por imágenes'),
  (5, '[5] Hallazgo incidental por exploración quirúrgica'),
  (6, '[6] Presentación Clinica (con Síntoma)'),
  (7, '[7] Hallazgo incidental en la autopsia'),
  (8, '[8] Otros'),
  (9, '[9] Desconocido');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_17` ORDER BY 1 ASC