/************************************************************************** 
         			REGLA 250 REGLA INUSUAL POR PATRÓN MONTO  -  DISPOSICIONES     
					***************************************************************************/
SELECT Oper.OPERCNTRID
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
     , Oper.MONTOMNCNTR -- Este es el monto a considerar espresado en USD
     , Oper.MONTOCNTR
     , Oper.MONTOUSD
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
              , Oper2.MONTOMNCNTR                      -- Este es el monto a considerar espresado en USD
              , Oper2.MONTOCNTR
              , Oper2.MONTOUSD
              , Oper2.MONTO_EFECTIVO
              , Oper2.CODOPER
              , (SELECT (SUM(DOLARES) / COUNT(1)) -- Parametro de porcentaje desviacion 1.5% --Se quita el % de Desviación
                 FROM (SELECT ROW_NUMBER() OVER (ORDER BY OPE.FECHAOPERACIONCNTR, OPE.OPERCNTRID DESC) NUM,
--                               OPE.MONTOMNCNTR                                                          DOLARES
                              OPE.MONTOUSD                                                          DOLARES
                       FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
                            SOFOM.MTS_CRN_CIERRE CIE1
                       WHERE OPE.FECHAOPERACIONCNTR <= OPER2.FECHAOPERACIONCNTR
                         AND OPE.FECHAOPERACIONCNTR >= (CIE1.FECHA_INI_CIERRE - ?) -- (Validar) Parámetro desde pantalla, número de días
                         AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
--                          AND OPE.TIPOOPERACIONID = 40
                         AND OPE.TIPOOPERACIONID = ?
                         AND CONTRATANTEID = (SELECT DISTINCT CONTRATANTEID
                                              FROM SOFOM.MTS_HOPERACIONESCNTR HOPE
                                              WHERE HOPE.OPERCNTRID = OPER2.OPERCNTRID)
                         AND OPE.OPERCNTRID <> OPER2.OPERCNTRID) ANALISIS
                 WHERE ANALISIS.NUM <= ?) PROMEDIOOPER -- Parametro Numero de Operaciones
         FROM SOFOM.MTS_HOPERACIONESCNTR OPER2,
              SOFOM.MTS_CRN_CIERRE CIE
         WHERE CIE.CIERREID = ? -- Parametro Cierre
           AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_FIN_CIERRE
           AND OPER2.FECHAOPERACIONCNTR >= CIE.FECHA_INI_CIERRE
--            AND OPER2.TIPOOPERACIONID = 40
           AND OPER2.TIPOOPERACIONID = ?
--            AND OPER2.MONTOMNCNTR > ?) Oper, -- Parametro Monto USD
           AND OPER2.MONTOUSD > ?) Oper, -- Parametro Monto USD
     SOFOM.MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND PROMEDIOOPER IS NOT NULL
--   AND Oper.MONTOMNCNTR >= PROMEDIOOPER
  AND Oper.MONTOUSD >= (PROMEDIOOPER * PARMAETRO_PANTALLA) -- % De desviación
  AND OPER.TIPOOPERACIONID = ?
--   AND EXISTS(SELECT NULL
--              FROM SOFOM.MTS_EXT_PRODUCTOS_CIERRE
--              WHERE Id_Proceso = ? --Parametro Id_Proceso
--                AND Productid = Oper.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = ?)-- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID
                    