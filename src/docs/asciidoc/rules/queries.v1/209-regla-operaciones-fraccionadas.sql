-- ORIGINAL
SELECT Ope.OPERCNTRID
     , Ope.NUMPOLIZACNTR
     , Ope.TIPODOCUMENTOID
     , Ope.TIPOOPERACIONID
     , Ope.INSTRMONETARIOID
     , Ope.MONEDAID
     , Ope.CONTRATANTEID
     , Ope.AGENTEID
     , Ope.EMPLEADOID
     , Ope.SUCURSALID
     , Ope.PRODUCTOID
     , Ope.FECHAOPERACIONCNTR
     , Ope.LINEANEGOCIOID
     , Ope.MONTOMNCNTR
     , Ope.MONTOCNTR
     , Ope.MONTO_EFECTIVO
     , Ope.CONTRATANTERFC
     , Ope.CODOPER
FROM (SELECT Oper.OPERCNTRID
           , Oper.NUMPOLIZACNTR
           , Oper.TIPODOCUMENTOID
           , Oper.TIPOOPERACIONID
           , Oper.INSTRMONETARIOID
           , Oper.MONEDAID
           , Oper.CONTRATANTEID
           , Oper.AGENTEID
           , Oper.EMPLEADOID
           , Oper.SUCURSALID
           , Oper.PRODUCTOID
           , Oper.FECHAOPERACIONCNTR
           , Oper.LINEANEGOCIOID
           , Oper.MONTOMNCNTR
           , Oper.MONTOCNTR
           , Oper.MONTO_EFECTIVO
           , Cnte.CONTRATANTERFC
           , Oper.CODOPER
           , (SELECT SUM(ISNULL((Hoper.MONTOMNCNTR), 0) / Tipo.TIPO_CAMBIO) as MONTO
              FROM [SOFOM].MTS_HOPERACIONESCNTR Hoper,
                   [SOFOM].MTS_CRN_CIERRE NCier,
                   [SOFOM].MTS_HTIPOS_CAMBIO Tipo
              WHERE NCier.CIERREID = Cierre.CIERREID
                AND Hoper.FECHAOPERACIONCNTR <= Oper.FECHAOPERACIONCNTR
                AND Hoper.FECHAOPERACIONCNTR >= DATEADD(MONTH, -1, NCier.FECHA_FIN_CIERRE)
                AND Hoper.INSTRMONETARIOID = Oper.INSTRMONETARIOID
                AND Tipo.MONEDAID = 'USD'
                AND Tipo.FECHA = (SELECT MAX(FECHA)
                                  FROM [SOFOM].MTS_HTIPOS_CAMBIO
                                  WHERE FECHA <= NCier.FECHA_FIN_CIERRE
                                    AND MONEDAID = 'USD')
                AND Hoper.TIPOOPERACIONID = Oper.TIPOOPERACIONID
                AND (Hoper.MONTOMNCNTR / Htipo.TIPO_CAMBIO) between (select VALOR
                                                                     from [SOFOM].MTS_HRN_PARAMETROS
                                                                     where REGLANEGOCIOID = 209
                                                                       and PARAMETROID = 5)
                  and (select VALOR
                       from [SOFOM].MTS_HRN_PARAMETROS
                       where REGLANEGOCIOID = 209
                         and PARAMETROID = 6)
                AND Hoper.CONTRATANTEID = Oper.CONTRATANTEID
              GROUP BY Hoper.CONTRATANTEID) MONTO
      FROM [SOFOM].MTS_HOPERACIONESCNTR Oper,
           [SOFOM].MTS_DCONTRATANTE Cnte,
           [SOFOM].MTS_CRN_CIERRE Cierre,
           [SOFOM].MTS_HTIPOS_CAMBIO Htipo
      WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
        AND Cierre.CIERREID = ?
        AND Oper.FECHAOPERACIONCNTR <= Cierre.FECHA_FIN_CIERRE
        AND Oper.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, Cierre.FECHA_FIN_CIERRE)
        AND right('00' + Oper.INSTRMONETARIOID, 2) = '01'
        AND Htipo.MONEDAID = 'USD'
        AND Htipo.FECHA = (SELECT MAX(FECHA)
                           FROM [SOFOM].MTS_HTIPOS_CAMBIO
                           WHERE FECHA <= Cierre.FECHA_FIN_CIERRE
                             AND MONEDAID = 'USD')
        AND (Oper.MONTOMNCNTR / Htipo.TIPO_CAMBIO) between (select VALOR
                                                            from [SOFOM].MTS_HRN_PARAMETROS
                                                            where REGLANEGOCIOID = 209
                                                              and PARAMETROID = 5)
          and (select VALOR
               from [SOFOM].MTS_HRN_PARAMETROS
               where REGLANEGOCIOID = 209
                 and PARAMETROID = 6)
        AND Oper.TIPOOPERACIONID IN (SELECT TipoOperacionId
                                     FROM [SOFOM].MTS_DTIPO_OPERACIONES
                                     WHERE APORTACION = 'S')
     ) Ope
where 1 = 1
  AND Ope.MONTO > ?
  AND EXISTS(SELECT NULL
             FROM [SOFOM].MTS_EXT_PRODUCTOS_CIERRE Prod
             WHERE Prod.Id_Proceso = ?
               AND Prod.Productid = Ope.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM [SOFOM].MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Ope.CODOPER
                   AND REGLANEGOCIOID = ?)
Order By Ope.CONTRATANTEID, Ope.FECHAOPERACIONCNTR, Ope.OPERCNTRID




-- MODIFICADA
/**
  *
  *
  */
SELECT OPE.OPERCNTRID,
       OPE.NUMPOLIZACNTR,
       OPE.TIPODOCUMENTOID,
       OPE.TIPOOPERACIONID,
       OPE.INSTRMONETARIOID,
       OPE.MONEDAID,
       OPE.CONTRATANTEID,
       OPE.AGENTEID,
       OPE.EMPLEADOID,
       OPE.SUCURSALID,
       OPE.PRODUCTOID,
       OPE.FECHAOPERACIONCNTR,
       OPE.LINEANEGOCIOID,
       OPE.MONTOMNCNTR,
       OPE.MONTOCNTR,
       OPE.MONTOUSD,
       OPE.MONTO_EFECTIVO,
       OPE.CONTRATANTERFC,
       OPE.CODOPER
FROM (SELECT OPER.OPERCNTRID,
             OPER.NUMPOLIZACNTR,
             OPER.TIPODOCUMENTOID,
             OPER.TIPOOPERACIONID,
             OPER.INSTRMONETARIOID,
             OPER.MONEDAID,
             OPER.CONTRATANTEID,
             OPER.AGENTEID,
             OPER.EMPLEADOID,
             OPER.SUCURSALID,
             OPER.PRODUCTOID,
             OPER.FECHAOPERACIONCNTR,
             OPER.LINEANEGOCIOID,
             OPER.MONTOMNCNTR,
             OPER.MONTOCNTR,
             OPER.MONTOUSD,
             OPER.MONTO_EFECTIVO,
             CNTE.CONTRATANTERFC,
             OPER.CODOPER,
             (SELECT SUM(ISNULL(MONTOUSD, 0)) AS MONTO
              FROM SOFOM.MTS_HOPERACIONESCNTR HOPER,
                   SOFOM.MTS_CRN_CIERRE NCIER,
                   SOFOM.MTS_HTIPOS_CAMBIO TIPO
              WHERE NCIER.CIERREID = CIERRE.CIERREID
                AND HOPER.FECHAOPERACIONCNTR <= OPER.FECHAOPERACIONCNTR
                AND HOPER.FECHAOPERACIONCNTR >= DATEADD(MONTH, -1, NCIER.FECHA_FIN_CIERRE)
                AND HOPER.INSTRMONETARIOID = OPER.INSTRMONETARIOID
                AND HOPER.TIPOOPERACIONID = OPER.TIPOOPERACIONID
                AND (OPER.MONTOUSD) BETWEEN (?) AND (?)
                AND HOPER.CONTRATANTEID = OPER.CONTRATANTEID
              GROUP BY HOPER.CONTRATANTEID) MONTO
      FROM SOFOM.MTS_HOPERACIONESCNTR OPER,
           SOFOM.MTS_DCONTRATANTE CNTE,
           SOFOM.MTS_CRN_CIERRE CIERRE,
           SOFOM.MTS_HTIPOS_CAMBIO HTIPO
      WHERE OPER.CONTRATANTEID = CNTE.CONTRATANTEID
        AND CIERRE.CIERREID = ?
        AND OPER.FECHAOPERACIONCNTR <= CIERRE.FECHA_FIN_CIERRE
        AND OPER.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, CIERRE.FECHA_FIN_CIERRE)
        AND RIGHT('00' + OPER.INSTRMONETARIOID, 2) IN (?)
        AND (OPER.MONTOUSD) BETWEEN (?) AND (?)
        AND OPER.TIPOOPERACIONID IN (?)
     ) OPE
WHERE 1 = 1
  AND OPE.MONTO > ?
  AND EXISTS(SELECT NULL
             FROM SOFOM.MTS_EXT_PRODUCTOS_CIERRE PROD
             WHERE PROD.ID_PROCESO = ?
               AND PROD.PRODUCTID = OPE.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = OPE.CODOPER
                   AND REGLANEGOCIOID = ?)
ORDER BY OPE.CONTRATANTEID, OPE.FECHAOPERACIONCNTR, OPE.OPERCNTRID;


select *
from TD.MTS_CRN_CIERRE;;






