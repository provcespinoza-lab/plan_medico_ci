{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red24\green25\blue27;\red255\green255\blue255;\red0\green0\blue0;
}
{\*\expandedcolortbl;;\cssrgb\c12549\c12941\c14118;\cssrgb\c100000\c100000\c100000;\cssrgb\c0\c0\c0;
}
\paperw11900\paperh16840\margl1440\margr1440\vieww33100\viewh17340\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 CREATE OR REPLACE TABLE `
\f1 \cf2 \cb3 \expnd0\expndtw0\kerning0
ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.
\f0 \cf0 \cb1 \kerning1\expnd0\expndtw0 MAESTRO_TIPO_DOCUMENTO` (\
  CODIGO_DOCUMENTO_XHIST               INT64,\
  DESCRIPCION_DOCUMENTO_XHIST    STRING,\
  CODIGO_DOCUMENTO_RNC                 STRING,\
  DESCRIPCION_DOCUMENTO_RNC       STRING\
);\
\
\
INSERT INTO `
\f1 \cf2 \cb3 \expnd0\expndtw0\kerning0
ci-datalake-dev.ci_dtlk_bqd_staging_dev_RNC.
\f0 \cf0 \cb1 \kerning1\expnd0\expndtw0 MAESTRO_TIPO_DOCUMENTO`  \
(CODIGO_DOCUMENTO_XHIST, DESCRIPCION_DOCUMENTO_XHIST, CODIGO_DOCUMENTO_RNC, DESCRIPCION_DOCUMENTO_RNC)\
VALUES\
  (1,'D.N.I.','1','DNI')\
, (2,'PASAPORTE','3','PASAPORTE')\
, (3,'CARNET EXTRANJERIA','2','CARNET DE EXTRANJERIA')\
, (4,'CARNET IDENTIDAD',NULL,NULL)\
, (5,'LIBRETA ELECTORAL',NULL,NULL)\
, (6,'NO ESPECIFICA',NULL,NULL)\
, (7,'LICENCIA DE CONDUCIR',NULL,NULL);\
}