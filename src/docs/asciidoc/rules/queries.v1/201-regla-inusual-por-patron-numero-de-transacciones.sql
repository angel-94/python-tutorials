-- Comparación del numero de operaciones del dia analizado vs el promedio de operaciones apattir e la fecha de inicio de cierre hasta el final
-- de la fecha de operacion analizada

-- Numero de operaciones que revasen las operaciones permitidas en un mes
-- PARAMETROS REGLA  v1.1
-- Porcentaje desviacion
-- Numero de Dias:30
-- Cierre
-- Numero de Transacciones:60
-- Id proceso
-- Numero de regla

SELECT Oper.OPERCNTRID
     , CONTPROM
     , NUMTRANS
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
FROM (
    SELECT Oper2.OPERCNTRID
         , Oper2.NUMPOLIZACNTR
         , Oper2.TIPODOCUMENTOID
         , Oper2.TIPOOPERACIONID
         , Oper2.INSTRMONETARIOID
         , Oper2.MONEDAID
         , Oper2.CONTRATANTEID
         , Oper2.AGENTEID
         , Oper2.EMPLEADOID
         , Oper2.SUCURSALID
         , Oper2.PRODUCTOID
         , Oper2.FECHAOPERACIONCNTR
         , Oper2.LINEANEGOCIOID
         , Oper2.MONTOMNCNTR
         , Oper2.MONTOCNTR
         , Oper2.MONTO_EFECTIVO
         , Oper2.CODOPER
         -- Suma las operaciones de los últimos 90 días
         , (SELECT sum(REGISTROS)
            FROM (--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                     SELECT CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
                            COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                     FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                     WHERE OPE.FECHAOPERACIONCNTR < OPER2.FECHAOPERACIONCNTR
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
                       AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -90, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
                       AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
                       AND OPE.TIPOOPERACIONID = 40                                             -- Se agrega tipo de operación de entrada
                       AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                     Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112)) Rgs) CONTPROM
         , (SELECT COUNT(1)
            FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
            WHERE OPE.FECHAOPERACIONCNTR = OPER2.FECHAOPERACIONCNTR            --Se Cambian las fechas por fecha de ejecución
              AND month(OPE.FECHAOPERACIONCNTR) >= month(CIE.FECHA_FIN_CIERRE) -- Cambian las fechas por inicio de mes
              AND OPE.TIPOOPERACIONID = 40                                     -- Se agrega tipo de operación de entrada
              AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
              AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID)                        NUMTRANS
    FROM [SOFOM].MTS_HOPERACIONESCNTR OPER2,
         [SOFOM].MTS_CRN_CIERRE CIE
    WHERE CIE.CIERREID = ?           -- Parametro Cierre
      AND (OPER2.CVE_ESTATUS = 'S' OR OPER2.CVE_ESTATUS IS NULL)
      AND OPER2.TIPOOPERACIONID = 40 -- Se agrega tipo de operación de entrada
      AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_FIN_CIERRE
      AND OPER2.FECHAOPERACIONCNTR >= CIE.FECHA_INI_CIERRE) Oper
   , [SOFOM].MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND Oper.CONTPROM IS NOT NULL
  AND Oper.NUMTRANS >= Oper.CONTPROM
  AND Oper.NUMTRANS >= ?                   -- Parametro Numero de Transacciones
  AND EXISTS(SELECT NULL
             FROM [SOFOM].MTS_EXT_PRODUCTOS_CIERRE
             WHERE Id_Proceso = ?--Parametro Id_Proceso
               AND Productid = Oper.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM [SOFOM].MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = ?) -- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID
