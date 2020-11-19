-- Variables utilizadas en la regla
DECLARE @INI_FEC_CIERRE AS VARCHAR = '012019';
DECLARE @FIN_FEC_CIERRE AS VARCHAR = '072020';
DECLARE @CVE_ROL AS VARCHAR = 'CV';

SELECT PERFIL.CONTRATANTEID                                AS CONTRATANTEID,
       '1'                                                 AS SUCURSALID,
       '03'                                                AS INSTRMONETARIOID,
       'MXN'                                               AS MONEDAID,
       NULL                                                AS AGENTEID,
       '9'                                                 AS TIPOOPERACIONID,
       NULL                                                AS NUMPOLIZACNTR,
       GETDATE()                                           AS FECHAOPERACIONCNTR,
       NULL                                                AS OPERCNTRID,
       NULL                                                AS TIPODOCUMENTOID,
       NULL                                                AS EMPLEADOID,
       NULL                                                AS LINEANEGOCIOID,
       NULL                                                AS MONTOMNCNTR,
       NULL                                                AS MONTOCNTR,
       NULL                                                AS MONTO_EFECTIVO,
       KPER.RFC                                            AS CONTRATANTERFC,
       NULL                                                AS CODOPER,
       1                                                   AS MESINI,
       2020                                                AS ANIOINI,
       6                                                   AS MESFIN,
       2020                                                AS ANIOFIN,
       GETDATE()                                              FECHAOPERACIONCNTR,
       '1'                                                    PRODUCTOID,
       KPER.ID_CONTRATO,
       KPER.CVE_ROL,
       KPER.NOMBRES,
       KPER.APELLIDO_PATERNO,
       KPER.APELLIDO_MATERNO,
       KPER.DS_RAZON_SOCIAL,
       KPER.CVE_TIPO_FISICA_MORAL,
       KPER.CVE_NIVEL_RIESGO,
       KPER.RFC,
       KPER.CURP,
       KPER.ID_KYC,
        -- PERFIL DECLARADO
       SUM(CAST(IMP_MONTO_ESTIMADO_TRX_DEPOSITO AS FLOAT)) AS MONTO_DEPOSITO_DECLARADO,
       SUM(CAST(NO_OPERACIONES_DEPOSITO AS INT))           AS NO_DEPOSITOS_DECLARADO,
       SUM(CAST(IMP_MONTO_ESTIMADO_TRX_RETIRO AS FLOAT))   AS MONTO_DISPOSICIONES_DECLARADO,
       SUM(CAST(NO_OPERACIONES_RETIRO AS INT))             AS NO_DISPOSICIONES_DECLARADO,
        -- PERFIL OPERADO
       AVG(ACT_IMP_MONTO_TOT_DEPOSITOS)                    AS MONTO_DEPOSITOS_AVG,
       AVG(ACT_NO_TOT_DEPOSITOS)                           AS TOT_DEPOSITOS_AVG,
       AVG(ACT_IMP_MONTO_TOT_RETIROS)                      AS MONTO_DISPOSICIONES_AVG,
       AVG(ACT_NO_TOT_RETIROS)                             AS TOT_DISPOSICIONES_AVG
FROM SOFOM.MTS_VL_KYC_ANALISIS_PERFIL PERFIL,
     SOFOM.MTS_VL_KYC_PERSONAS KPER
WHERE KPER.ID_CONTRATO = PERFIL.CONTRATANTECD
  AND KPER.CVE_ROL in (@CVE_ROL)
  -- RIGHT Extrae los últimos 2 carácteres del campo MONTH
  AND CAST((CAST(PERFIL.YEAR AS VARCHAR) + RIGHT(REPLICATE('0', 2) + CAST(PERFIL.MONTH AS VARCHAR), 2)) AS INTEGER)
    BETWEEN @INI_FEC_CIERRE AND @FIN_FEC_CIERRE
  AND PERFIL.CONTRATANTECD = KPER.ID_CONTRATO
GROUP BY KPER.ID_CONTRATO,
         KPER.CVE_ROL,
         KPER.NOMBRES,
         KPER.APELLIDO_PATERNO,
         KPER.APELLIDO_MATERNO,
         KPER.DS_RAZON_SOCIAL,
         KPER.CVE_TIPO_FISICA_MORAL,
         KPER.CVE_NIVEL_RIESGO,
         KPER.RFC,
         KPER.CURP,
         KPER.ID_KYC,
         PERFIL.CONTRATANTEID;