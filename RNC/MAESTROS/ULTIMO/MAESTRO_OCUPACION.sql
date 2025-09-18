{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red24\green25\blue27;\red255\green255\blue255;}
{\*\expandedcolortbl;;\cssrgb\c12549\c12941\c14118;\cssrgb\c100000\c100000\c100000;}
\paperw11900\paperh16840\margl1440\margr1440\vieww33100\viewh17340\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 CREATE OR REPLACE TABLE  `
\f1 \cf2 \cb3 \expnd0\expndtw0\kerning0
ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.
\f0 \cf0 \cb1 \kerning1\expnd0\expndtw0 MAESTRO_OCUPACION` (\
  CODIGO_OCUPACION_XHIS              INT64,\
  DESCRIPCION_OCUPACION_XHIS    STRING,\
  CODIGO_OCUPACION_RNC               INT64,\
  DESCRIPCION_OCUPACION_RNC    STRING\
);\
\
\
INSERT INTO `
\f1 \cf2 \cb3 \expnd0\expndtw0\kerning0
ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.
\f0 \cf0 \cb1 \kerning1\expnd0\expndtw0 MAESTRO_OCUPACION` \
  (CODIGO_OCUPACION_XHIS, DESCRIPCION_OCUPACION_XHIS, CODIGO_OCUPACION_RNC, DESCRIPCION_OCUPACION_RNC)\
VALUES\
  (1,'ABOGADOS',313,'Abogado')\
,(2,'ACTORES',112,'Actor,artista,afines')\
,(3,'ACTUARIOS',998,'Otras')\
,(4,'ADMINISTRADORES',998,'Otras')\
,(5,'AGRIMENSORES',317,'Top\'f3grafo')\
,(6,'ANAL.SISTEMAS',307,'Ingeniero')\
,(7,'ARQUITECTOS',312,'Arquitecto')\
,(8,'ART PLASTICOS',149,'Artesano')\
,(9,'ASTRONOMOS',998,'Otras')\
,(10,'AT. DPTO DE PERSONAL',998,'Otras')\
,(11,'BIBLIOTECARIOS',998,'Otras')\
,(12,'BIOLOGOS',200,'Bi\'f3logo(a)')\
,(13,'BIOQUIMICOS',998,'Otras')\
,(14,'CALIGRAFOS',998,'Otras')\
,(15,'CARTOGRAFOS',998,'Otras')\
,(16,'COMP.CIENTIFIC.',998,'Otras')\
,(17,'CONTADORES PUBL',315,'Contador')\
,(18,'DESP.DE ADUANAS',998,'Otras')\
,(19,'DIPLOMATICOS',998,'Otras')\
,(20,'DOCTOR',300,'M\'e9dico')\
,(21,'DOCTORA',300,'M\'e9dico')\
,(22,'ECONOMISTAS',322,'Economista')\
,(23,'ENFERMEROS',201,'Enfermero(a)')\
,(24,'ENOLOGOS',998,'Otras')\
,(25,'ESCRIBANOS PUBL',998,'Otras')\
,(26,'ESTADISTICOS',998,'Otras')\
,(27,'FARMACEUTICOS',319,'Quimico-farmac\'e9utico')\
,(28,'FILOSOF-HISTOR.',998,'Otras')\
,(29,'FISICOS',998,'Otras')\
,(30,'FONOAUDIOLOGOS',998,'Otras')\
,(31,'GEOGRAF-OCEANOG',998,'Otras')\
,(32,'GEOLOGOS',998,'Otras')\
,(33,'GUARDAPARQUES',150,'Guardi\'e1n')\
,(34,'ING.AGRONOMOS',310,'Ingeniero agr\'f3nomo')\
,(35,'ING.CIVILES',308,'Ingeniero civil')\
,(36,'ING.ELECTRICIST',307,'Ingeniero')\
,(37,'ING.ELECTROMEC.',307,'Ingeniero')\
,(38,'ING.ELECTRONIC.',307,'Ingeniero')\
,(39,'ING.EN SISTEMAS',307,'Ingeniero')\
,(40,'ING.INDUSTRIAL',311,'Ingeniero industrial')\
,(41,'ING.MECANICOS',998,'Otras')\
,(42,'ING.NUCLEARES',307,'Ingeniero')\
,(43,'ING.QUIMICOS',307,'Ingeniero')\
,(44,'ING.TELECOM',307,'Ingeniero')\
,(45,'LOCUTORES',998,'Otras')\
,(46,'MARINOS MERCANTES',106,'Marino')\
,(47,'MARTILLEROS',998,'Otras')\
,(48,'MATEMATICOS',998,'Otras')\
,(49,'MEDICOS',300,'M\'e9dico')\
,(50,'METEREOLOGOS',998,'Otras')\
,(51,'MILITARES',107,'Militar')\
,(52,'MUSICOS',998,'Otras')\
,(53,'NOTARIOS',316,'Notario')\
,(54,'ODONTOLOGOS',306,'Odont\'f3logo')\
,(55,'PERIODISTAS',206,'Periodista')\
,(56,'PILOTOS',998,'Otras')\
,(57,'PROCURADORES',998,'Otras')\
,(58,'PROFESORES',100,'Profesor')\
,(59,'PSICOLOGOS',314,'Psic\'f3logo(a)')\
,(60,'PSICOPEDAGOGOS',998,'Otras')\
,(61,'PUBLICISTAS',119,'Publicista')\
,(62,'QUIMICOS',998,'Otras')\
,(63,'RADIOLOGOS',998,'Otras')\
,(64,'RELAC.PUBLICAS',998,'Otras')\
,(65,'SIN PROFESION',998,'Otras')\
,(66,'SOCIOLOGOS',998,'Otras')\
,(67,'TEOLOGOS',998,'Otras')\
,(68,'URBANISTAS',998,'Otras')\
,(69,'VETERINARIOS',305,'M\'e9dico veterinario')\
,(9999,'Sin Datos',998,'Otras');\
}