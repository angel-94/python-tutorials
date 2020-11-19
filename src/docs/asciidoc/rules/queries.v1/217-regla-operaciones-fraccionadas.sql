-- 217 OPERACIONES FRACCIONADAS
-- detectar operaciones que intentan evadir la regla relaevante aplicando
-- El parámetro para discriminar las operaciones que no se evaluarán [Traspaso Final y Fonde]
-- Este parámetro se agrega en la subquery de la suma y en el query principal
-- Comparación del numero de operaciones del dia analizado vs el promedio de operaciones apattir e la fecha de inicio de cierre hasta el final
-- de la fecha de operacion analizada
-- Numero de operaciones que revasen las operaciones permitidas en un mes



SELECT OPE.OPERCNTRID
     , OPE.MONTOUSD
     , OPE.NUMPOLIZACNTR
     , OPE.TIPODOCUMENTOID
     , OPE.TIPOOPERACIONID
     , OPE.INSTRMONETARIOID
     , OPE.MONEDAID
     , OPE.CONTRATANTEID
     , OPE.AGENTEID
     , OPE.EMPLEADOID
     , OPE.SUCURSALID
     , OPE.PRODUCTOID
     , OPE.FECHAOPERACIONCNTR
     , OPE.LINEANEGOCIOID
     , OPE.MONTOMNCNTR
     , OPE.MONTOCNTR
     , OPE.MONTO_EFECTIVO -- Considera esta columna que está en pesos pero aquí se hace la conversión a usd
     , OPE.CONTRATANTERFC
     , OPE.CODOPER
FROM (SELECT OPER.OPERCNTRID
           , OPER.CONTRATANTECD
           , OPER.NUMPOLIZACNTR
           , OPER.TIPODOCUMENTOID
           , OPER.TIPOOPERACIONID
           , OPER.INSTRMONETARIOID
           , OPER.MONEDAID
           , OPER.CONTRATANTEID
           , OPER.AGENTEID
           , OPER.EMPLEADOID
           , OPER.SUCURSALID
           , OPER.PRODUCTOID
           , OPER.FECHAOPERACIONCNTR
           , OPER.LINEANEGOCIOID
           , OPER.MONTOMNCNTR
           , OPER.MONTOCNTR
           , OPER.MONTO_EFECTIVO -- CONSIDERA ESTA COLUMNA QUE ESTÁ EN PESOS PERO AQUÍ SE HACE LA CONVERSIÓN A USD
           , CNTE.CONTRATANTERFC
           , OPER.CODOPER
-- 						  ,(SELECT  SUM(ISNULL((HOPER.MONTOMNCNTR),0)/TIPO.TIPO_CAMBIO) AS  MONTO -- SE CONVIERTEN LOS PESOS A USD
           -- Toma la fecha fin de cierre y un mes hacia atras ejemplo 30 de mayo = 30 de junio
           , (SELECT SUM(ISNULL((HOPER.MONTOUSD), 0)) AS MONTO -- SE CONVIERTEN LOS PESOS A USD
              FROM SOFOM.MTS_HOPERACIONESCNTR HOPER,
                   SOFOM.MTS_CRN_CIERRE NCIER
-- 						              SOFOM.MTS_HTIPOS_CAMBIO     TIPO
              WHERE NCIER.CIERREID = CIERRE.CIERREID
                AND HOPER.FECHAOPERACIONCNTR <= NCIER.FECHA_FIN_CIERRE
--                 AND HOPER.FECHAOPERACIONCNTR >= DATEADD(MONTH, -1, NCIER.FECHA_FIN_CIERRE) -- A UN MES CALENDARIO
                AND HOPER.FECHAOPERACIONCNTR >= DATEADD(day, -?, NCIER.FECHA_FIN_CIERRE) -- A UN MES CALENDARIO
                AND RIGHT('00' + HOPER.INSTRMONETARIOID, 2) = RIGHT('00' + OPER.INSTRMONETARIOID, 2)
-- 								  AND TIPO.MONEDAID                         =   'USD'
-- 								  AND TIPO.FECHA = (SELECT   MAX (FECHA)
-- 														   FROM   SOFOM.MTS_HTIPOS_CAMBIO
-- 														   WHERE   FECHA    <=  NCIER.FECHA_FIN_CIERRE
-- 														   AND   MONEDAID   =   'USD')
                AND RIGHT('00' + HOPER.TIPOOPERACIONID, 2) = RIGHT('00' + OPER.TIPOOPERACIONID, 2)
                AND HOPER.CONTRATANTEID = OPER.CONTRATANTEID
           -- and discrimiarn fondeo y traspaso final
              GROUP BY HOPER.CONTRATANTEID) MONTOUSD
      FROM SOFOM.MTS_HOPERACIONESCNTR OPER,
           SOFOM.MTS_DCONTRATANTE CNTE,
           SOFOM.MTS_CRN_CIERRE CIERRE
      WHERE OPER.CONTRATANTEID = CNTE.CONTRATANTEID
        AND CIERRE.CIERREID = ?                                                  -- PARAMETRO CIERRE
        AND OPER.FECHAOPERACIONCNTR <= CIERRE.FECHA_FIN_CIERRE
        --
        AND OPER.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, CIERRE.FECHA_FIN_CIERRE) -- 30 ES POR PARAMETRO
--                     AND RIGHT('00'+ OPER.INSTRMONETARIOID,2)          	        =   '01' -- PARAMETRO INSTRUMENTO MONETARIO EFECTIVO
        AND RIGHT('00' + OPER.INSTRMONETARIOID, 2) IN (?)                        -- PARAMETRO INSTRUMENTO MONETARIO EFECTIVO
        AND RIGHT('00' + OPER.TIPOOPERACIONID, 2) IN (?
--                         SELECT  RIGHT('00'+ TIPOOPERACIONID, 2)
--                                                      FROM  SOFOM.MTS_DTIPO_OPERACIONES
--                                                     WHERE  APORTACION = 'S'
          )
     ) OPE
WHERE OPE.MONTOUSD > ? -- PARAMETRO MONTO 7500 USD
-- and discrimiarn fondeo y traspaso final
--                    AND    EXISTS (  SELECT NULL
--                                        FROM   SOFOM.MTS_EXT_PRODUCTOS_CIERRE PROD
--                                        WHERE  PROD.ID_PROCESO   = ?
--                                        AND    PROD.PRODUCTID    = OPE.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = OPE.CODOPER
                   AND REGLANEGOCIOID = ?)
ORDER BY OPE.CONTRATANTEID, OPE.FECHAOPERACIONCNTR, OPE.OPERCNTRID







