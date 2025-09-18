/*
  TABLA_1
*/

-- Crear la tabla (estructura)
CREATE OR REPLACE TABLE `ci-datalake-dev.test_dataset.TABLA_1` (
  Codigo INT64,
  Descripcion STRING
);

-- Insertar los valores
INSERT INTO `ci-datalake-dev.test_dataset.TABLA_1` (Codigo, Descripcion)
VALUES 
  (0, '[0] Diagnosticado en el Hospital desde la fecha de inicio de Registro, recibiendo tratamiento inicial en otra institución'),
  (1, '[1] Diagnosticado y tratado inicialmente (total o parcial) en el Hospital reportante'),
  (2, '[2] Diagnosticado en otra institución y recibiendo todo o parte del tratamiento inicial en el hospital reportante'),
  (3, '[3] Diagnosticado y recibiendo todo el tratamiento inicial en otra institución'),
  (4, '[4] Diagnosticado y tratado en el hospital reportante anteriormente a la fecha de inicio de registro'),
  (5, '[5] Diagnosticado al momento de la autopsia'),
  (7, '[8] Diagnosticado solo por Certificado de Defunción'),
  (9, '[9] Desconocido');

SELECT * FROM `ci-datalake-dev.test_dataset.TABLA_1` ORDER BY 1 ASC