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

-- Análiza las operaciones de un día anterior,

declare @NUM_DIAS_ANALISIS INT
set @NUM_DIAS_ANALISIS = 100

-- Este parámetro usar como lista IN (01, 02)
declare @TIPO_OPERACION VARCHAR
set @TIPO_OPERACION = '''01'',''02'''
select @NUM_DIAS_ANALISIS;

declare @ID_CIERRE VARCHAR
SET @ID_CIERRE = '20200627002'

declare @NUM_TRANSACCIONES_PERMITIDAS INT
SET @NUM_TRANSACCIONES_PERMITIDAS = 500

declare @REGLA_ID INT
SET @REGLA_ID = 201

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
         -- Suma del numero de registros
--          , (SELECT sum(REGISTROS)
         -- Realiando el ajuste de la Ana agregamos la división para
         -- Clientes cuyo número de operaciones del día a analizar rebasa el promedio de operaciones de los últimos 3 días naturales
         , (SELECT sum(REGISTROS)
                       / @NUM_DIAS_ANALISIS --
            FROM ( --  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                     SELECT CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
                            COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                     FROM SOFOM.MTS_HOPERACIONESCNTR OPE
                          -- Oper2 trae información de la operación analizada
                          -- Ope información contra los registros a analizar
                     WHERE OPE.FECHAOPERACIONCNTR < OPER2.FECHAOPERACIONCNTR
                       AND OPE.FECHAOPERACIONCNTR >=
                           DATEADD(DAY, -@NUM_DIAS_ANALISIS, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
                       AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
--                        AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                    -- Se agrega tipo de operación de entrada
--                        AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                    -- Se agrega tipo de operación de entrada
                       AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                     Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112)) Rgs) CONTPROM
         -- Cuneta el número de registros sumados
         , (SELECT COUNT(1)
            FROM SOFOM.MTS_HOPERACIONESCNTR OPE
            WHERE OPE.FECHAOPERACIONCNTR = OPER2.FECHAOPERACIONCNTR            --Se Cambian las fechas por fecha de ejecución
              AND month(OPE.FECHAOPERACIONCNTR) >= month(CIE.FECHA_FIN_CIERRE) -- Cambian las fechas por inicio de mes
--               AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                     -- Se agrega tipo de operación de entrada
              AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
              AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID)                        NUMTRANS
    FROM SOFOM.MTS_HOPERACIONESCNTR OPER2,
         SOFOM.MTS_CRN_CIERRE CIE
    WHERE CIE.CIERREID = @ID_CIERRE -- Parametro Cierre
      AND (OPER2.CVE_ESTATUS = 'S' OR OPER2.CVE_ESTATUS IS NULL)
--       AND OPER2.TIPOOPERACIONID in (@TIPO_OPERACION) -- Se agrega tipo de operación de entrada
      AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_FIN_CIERRE
      AND OPER2.FECHAOPERACIONCNTR >= CIE.FECHA_INI_CIERRE) Oper
   , SOFOM.MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND Oper.CONTPROM IS NOT NULL
  AND Oper.NUMTRANS >= Oper.CONTPROM
  AND Oper.NUMTRANS >= @NUM_TRANSACCIONES_PERMITIDAS -- Parametro Numero de Transacciones
--   AND EXISTS(SELECT NULL
--              FROM SOFOM.MTS_EXT_PRODUCTOS_CIERRE
--              WHERE Id_Proceso = ?--Parametro Id_Proceso
--                AND Productid = Oper.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = @REGLA_ID)   -- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID;


--
-- select *
-- from SOFOM.MTS_HRN_PARAMETROS
-- where REGLANEGOCIOID = 201;
SELECT Oper.OPERCNTRID
     , PROMEDIO_OPERACIONES
--      , NUMTRANS
     , NUM_OPERACIONES_DIAS
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
         , (SELECT COUNT(CODOPER) NUM_OPERACIONES
            FROM SOFOM.MTS_HOPERACIONESCNTR OPE
            WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
                BETWEEN '2020-06-24' AND '2020-06-26'
              and OPE.CONTRATANTEID = 344) NUM_OPERACIONES_DIAS
         -- Suma del numero de registros
--          , (SELECT sum(REGISTROS)
         -- Realiando el ajuste de la Ana agregamos la división para
         -- Clientes cuyo número de operaciones del día a analizar rebasa el promedio de operaciones de los últimos 3 días naturales
         , (SELECT sum(REGISTROS) / 3 --Obtenemos el promedio de operaciones en el promedio de tiempo
            FROM (
                     --  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
--                 ..............................
--                  Obtenemos el conteo de las operaciones realizadas en un periodo de tiempo
                     SELECT CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23) AS FECHA,
                            COUNT(1)
--                             OPE.FECHAOPERACIONCNTR
                                                                            Registros
--                             OPE.* -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                     FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
                          SOFOM.MTS_CRN_CIERRE CIE
                          -- Oper2 trae información de la operación analizada
                          -- Ope información contra los registros a analizar
                     WHERE CIE.CIERREID = 20200627002
--                            OPE.FECHAOPERACIONCNTR < OPER2.FECHAOPERACIONCNTR
                       AND
--                        OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, CIE.FECHA_FIN_CIERRE) -- 30 es por parametro
--                        OPE.FECHAOPERACIONCNTR = '2020-03-18 00:00:00' -- 30 es por parametro
                         convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) between '2020-06-24' AND '2020-06-26'
--                        AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
                       AND OPE.CONTRATANTEID = 344
--                        AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                    -- Se agrega tipo de operación de entrada
--                        AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                    -- Se agrega tipo de operación de entrada
--                        AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                     Group by CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23)
--                 ORDER BY OPE.FECHAOPERACIONCNTR
                     --                      )
                 ) Rgs)                    PROMEDIO_OPERACIONES -- 5567 /3 = 1855
         -- Cuneta el número de registros sumados
--          , (SELECT COUNT(1)
--             FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
--                  SOFOM.MTS_CRN_CIERRE CIE
--             WHERE CIE.CIERREID = 20200627002
-- --                   OPE.FECHAOPERACIONCNTR = OPER2.FECHAOPERACIONCNTR            --Se Cambian las fechas por fecha de ejecución
-- --               AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, CIE.FECHA_FIN_CIERRE) -- 30 es por parametro
--               AND convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) between '2020-06-24' AND '2020-06-26'
-- --               AND month(OPE.FECHAOPERACIONCNTR) >= month(CIE.FECHA_FIN_CIERRE) -- Cambian las fechas por inicio de mes
-- --               AND OPE.TIPOOPERACIONID in (@TIPO_OPERACION)                     -- Se agrega tipo de operación de entrada
-- --               AND OPE.CVE_ESTATUS = 'S'
-- --               AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
--               AND OPE.CONTRATANTEID = 344
--     )                                      NUMTRANS             -- 5567
    FROM SOFOM.MTS_HOPERACIONESCNTR OPER2,
         SOFOM.MTS_CRN_CIERRE CIE
    WHERE CIE.CIERREID = 20200627002 -- Parametro Cierre
--       AND (OPER2.CVE_ESTATUS = 'S' OR OPER2.CVE_ESTATUS IS NULL)
--       AND OPER2.TIPOOPERACIONID in (@TIPO_OPERACION) -- Se agrega tipo de operación de entrada
--       AND OPER2.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, CIE.FECHA_INI_CIERRE)
--       AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_INI_CIERRE) Oper
--       AND OPER2.FECHAOPERACIONCNTR = CIE.FECHA_INI_CIERRE) Oper
      and OPER2.CONTRATANTEID = 344
      AND convert(VARCHAR, OPER2.FECHAOPERACIONCNTR, 23) BETWEEN '2020-06-24' AND '2020-06-26') Oper
   , SOFOM.MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND Oper.PROMEDIO_OPERACIONES IS NOT NULL
  -- Comparar con el número de transacciones del día de cierre.
--   and convert(VARCHAR, Oper.FECHAOPERACIONCNTR, 23)
--            BETWEEN '2020-06-25' AND '2020-06-25'
  AND (SELECT COUNT(CODOPER) NUM_OPERACIONES
       FROM SOFOM.MTS_HOPERACIONESCNTR OPE
       WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
           BETWEEN '2020-06-25' AND '2020-06-25'
         and OPE.CONTRATANTEID = 344)
    >= Oper.PROMEDIO_OPERACIONES
--   AND Oper.NUMTRANS >= 5                     -- Parametro Numero de Transacciones
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = 201) -- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID;


-- Llenar el cabecero con valores nulos
-- Después se ejecuta otra query para ejecutar el detalle de los casos
select *
from SOFOM.MTS_HOPERACIONESCNTR;


SELECT CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23) AS FECHA,
       COUNT(1)                                        Registros
FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
     SOFOM.MTS_CRN_CIERRE CIE
WHERE CIE.CIERREID = 20200627002
  AND convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) between '2020-06-26' AND '2020-06-26'
  AND OPE.CONTRATANTEID = 344
Group by CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23)


-- Obtenemos el num de operaciones realizadas en un periodo de tiempo
-- Agrupado por la fecha de operación
SELECT
--        CNT.CONTRATANTECD,
COUNT(CODOPER)                   NUM_OPERACIONES,
OPE.CONTRATANTECD,
cast(FECHAOPERACIONCNTR as date) FEC_OPERACION
FROM SOFOM.MTS_HOPERACIONESCNTR OPE
--      SOFOM.MTS_DCONTRATANTE CNT
WHERE 1 = 1
  AND convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
    BETWEEN '2020-06-24' AND '2020-06-26'
  and OPE.CONTRATANTEID = 344
--   and CNT.CONTRATANTEID = OPE.CONTRATANTEID
group by OPE.CONTRATANTECD, cast(FECHAOPERACIONCNTR as date)
ORDER BY cast(FECHAOPERACIONCNTR as date) DESC;


--

-- select *
-- from SOFOM.MTS_HRN_PARAMETROS
-- where REGLANEGOCIOID = 201;
SELECT Oper.OPERCNTRID
     , CONTPROM
     , NUMTRANS
     , NUM_OPERACIONES_DIAS
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
         , (SELECT COUNT(CODOPER) NUM_OPERACIONES
            FROM SOFOM.MTS_HOPERACIONESCNTR OPE
            WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
                BETWEEN '2020-06-25' AND '2020-06-25'
              and OPE.CONTRATANTEID = 344) NUM_OPERACIONES_DIAS
         -- Suma del numero de registros
--          , (SELECT sum(REGISTROS)
         -- Realiando el ajuste de la Ana agregamos la división para
         -- Clientes cuyo número de operaciones del día a analizar rebasa el promedio de operaciones de los últimos 3 días naturales
         , (SELECT sum(REGISTROS) / 1--
            FROM ( --  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                     SELECT CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23) AS FECHA,
                            COUNT(1)
                                                                            Registros
                     FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
                          SOFOM.MTS_CRN_CIERRE CIE
                     WHERE CIE.CIERREID = 20200627002
                       AND convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) = '2020-06-24' -- AND '2020-06-27'
--                        AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
                       AND OPE.CONTRATANTEID = 344
                     Group by CONVERT(varchar, OPE.FECHAOPERACIONCNTR, 23)
--                 ORDER BY OPE.FECHAOPERACIONCNTR
                     --                      )
                 ) Rgs)                    CONTPROM -- 5567 /3 = 1855
         -- Cuneta el número de registros sumados
         , (SELECT COUNT(1)
            FROM SOFOM.MTS_HOPERACIONESCNTR OPE,
                 SOFOM.MTS_CRN_CIERRE CIE
            WHERE CIE.CIERREID = 20200627002
              AND convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) = '2020-06-24' -- AND '2020-06-27'
              AND OPE.CONTRATANTEID = 344
    )                                      NUMTRANS -- 5567
    FROM SOFOM.MTS_HOPERACIONESCNTR OPER2,
         SOFOM.MTS_CRN_CIERRE CIE
    WHERE CIE.CIERREID = 20200627002 -- Parametro Cierre
      AND convert(VARCHAR, OPER2.FECHAOPERACIONCNTR, 23) = '2020-06-25') Oper
   , SOFOM.MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND Oper.CONTPROM IS NOT NULL
  -- Comparar con el número de transacciones del día de cierre.
  AND (SELECT COUNT(CODOPER) NUM_OPERACIONES
       FROM SOFOM.MTS_HOPERACIONESCNTR OPE
       WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
           BETWEEN '2020-06-25' AND '2020-06-25'
         and OPE.CONTRATANTEID = 344)
    >= Oper.CONTPROM
  AND Oper.NUMTRANS >= 5                     -- Parametro Numero de Transacciones
  AND NOT EXISTS(SELECT NULL
                 FROM SOFOM.MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = 201) -- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID;


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
         , (SELECT sum(REGISTROS) / 3
            FROM (--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                     SELECT top 3 CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
                                  COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                     FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
--                      WHERE OPE.FECHAOPERACIONCNTR < OPER2.FECHAOPERACIONCNTR
                     WHERE OPE.FECHAOPERACIONCNTR < '2020-07-03 00:00:00'
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
                       AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, '2020-07-03 00:00:00') -- 30 es por parametro
                       AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
--                        AND OPE.CONTRATANTEID = 344
                       -- En STP se manejan las operaciones 1, 2 Retiro y Deposito
                       -- AND OPE.TIPOOPERACIONID = 40                                              -- Se agrega tipo de operación de entrada
                       -- Se elimina, cuando la operación caen en esta tabla su estatus por default es S
                       -- AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                     Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112)
                     order by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) desc
                 ) Rgs)                    CONTPROM
         , (SELECT COUNT(1)
            FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
            WHERE
--                   OPE.FECHAOPERACIONCNTR = OPER2.FECHAOPERACIONCNTR   --Se Cambian las fechas por fecha de ejecución
--               AND month(OPE.FECHAOPERACIONCNTR) >= month(CIE.FECHA_FIN_CIERRE) -- Cambian las fechas por inicio de mes
                cast(OPE.FECHAOPERACIONCNTR as date) = '2020-07-03' -- Cambian las fechas por inicio de mes
--               AND OPE.TIPOOPERACIONID = 40                                     -- Se agrega tipo de operación de entrada
--               AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
--               AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID)                        NUMTRANS
              AND OPE.CONTRATANTEID = 344) NUMTRANS
    FROM [SOFOM].MTS_HOPERACIONESCNTR OPER2,
         [SOFOM].MTS_CRN_CIERRE CIE
    WHERE CIE.CIERREID = 20200701002 -- Parametro Cierre
--       AND (OPER2.CVE_ESTATUS = 'S' OR OPER2.CVE_ESTATUS IS NULL)
--       AND OPER2.TIPOOPERACIONID = 40 -- Se agrega tipo de operación de entrada
--       AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_FIN_CIERRE
      AND cast(OPER2.FECHAOPERACIONCNTR as date) = '2020-07-03') Oper
--       AND OPER2.FECHAOPERACIONCNTR >= CIE.FECHA_INI_CIERRE) Oper
   , [SOFOM].MTS_DCONTRATANTE Cnte
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  AND Oper.CONTPROM IS NOT NULL
  AND Oper.NUMTRANS >= Oper.CONTPROM
  AND cast(Oper.FECHAOPERACIONCNTR as date) = '2020-07-03'
  AND Oper.NUMTRANS >= Oper.CONTPROM
  AND (SELECT COUNT(CODOPER) NUM_OPERACIONES
       FROM SOFOM.MTS_HOPERACIONESCNTR OPE
       WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
           BETWEEN '2020-06-25' AND '2020-06-25'
         and OPE.CONTRATANTEID = 344) >= Oper.CONTPROM
  AND Oper.NUMTRANS >= 8; -- Parametro Numero de Transacciones


AND NOT EXISTS(SELECT NULL
                 FROM [SOFOM].MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = 201) -- Numero de Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID;


select count(1)
from SOFOM.MTS_HOPERACIONESCNTR
where cast(FECHAOPERACIONCNTR as date) = '2020-07-03'
  and CONTRATANTEID = 2896426;


select top 10 cast(FECHAOPERACIONCNTR as date) date
from SOFOM.MTS_HOPERACIONESCNTR;

select *
from [SOFOM].MTS_CRN_CIERRE CIE
-- where CIERREID = 20200627002
order by FECHA_INI_CIERRE desc;


-- 20200627002
select count(1)
from SOFOM.MTS_HOPERACIONESCNTR OPE
where CONTRATANTECD = 'SBR130327HU9'
  and FECHAOPERACIONCNTR > '2020-06-30 00:00:00';


--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
SELECT top 3 CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
             COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
WHERE OPE.FECHAOPERACIONCNTR < '2020-07-03 00:00:00'
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
  AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -90, '2020-07-03 00:00:00') -- 30 es por parametro
  AND OPE.CONTRATANTEID = 344
--                        AND OPE.TIPOOPERACIONID = 40                                              -- Se agrega tipo de operación de entrada
  AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112);


SELECT COUNT(1)
FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
WHERE cast(OPE.FECHAOPERACIONCNTR as date) = '2020-07-03' -- Cambian las fechas por inicio de mes
  AND OPE.CONTRATANTEID = 344


select *
from [SOFOM].MTS_HOPERACIONESCNTR OPE;


select OPER3333.OPERCNTRID
     , OPER3333.NUMPOLIZACNTR
     , OPER3333.TIPODOCUMENTOID
     , OPER3333.TIPOOPERACIONID
     , OPER3333.INSTRMONETARIOID
     , OPER3333.MONEDAID
     , OPER3333.CONTRATANTEID
     , OPER3333.AGENTEID
     , OPER3333.EMPLEADOID
     , OPER3333.SUCURSALID
     , OPER3333.PRODUCTOID
     , OPER3333.FECHAOPERACIONCNTR
     , OPER3333.LINEANEGOCIOID
     , OPER3333.MONTOMNCNTR
     , OPER3333.MONTOCNTR
     , OPER3333.MONTO_EFECTIVO
     , OPER3333.CODOPER
--      ,CONTPROM
from (
         SELECT Oper.CONTRATANTEID
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
                       , (SELECT sum(REGISTROS) / 3
                          FROM (--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                                   SELECT top 3 CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
                                                COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                                   FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
--                      WHERE OPE.FECHAOPERACIONCNTR < OPER2.FECHAOPERACIONCNTR
                                   WHERE OPE.FECHAOPERACIONCNTR < '2020-07-03 00:00:00'
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -?, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
--                        AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -3, OPER2.FECHAOPERACIONCNTR) -- 30 es por parametro
                                     AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -10, '2020-07-03 00:00:00') -- 30 es por parametro
                                     AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
--                        AND OPE.CONTRATANTEID = 344
                                     -- En STP se manejan las operaciones 1, 2 Retiro y Deposito
                                     -- AND OPE.TIPOOPERACIONID = 40                                              -- Se agrega tipo de operación de entrada
                                     -- Se elimina, cuando la operación caen en esta tabla su estatus por default es S
                                     -- AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                                   Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112)
                                   order by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) desc
                               ) Rgs)                                    CONTPROM
                       , (SELECT COUNT(1)
                          FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                          WHERE
--                   OPE.FECHAOPERACIONCNTR = OPER2.FECHAOPERACIONCNTR   --Se Cambian las fechas por fecha de ejecución
--               AND month(OPE.FECHAOPERACIONCNTR) >= month(CIE.FECHA_FIN_CIERRE) -- Cambian las fechas por inicio de mes
                              cast(OPE.FECHAOPERACIONCNTR as date) = '2020-07-03' -- Cambian las fechas por inicio de mes
--               AND OPE.TIPOOPERACIONID = 40                                     -- Se agrega tipo de operación de entrada
--               AND (OPE.CVE_ESTATUS = 'S' OR OPE.CVE_ESTATUS IS NULL)
                            AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID) NUMTRANS
--               AND OPE.CONTRATANTEID = 344) NUMTRANS
                  FROM [SOFOM].MTS_HOPERACIONESCNTR OPER2
--                   [SOFOM].MTS_CRN_CIERRE CIE
--     WHERE CIE.CIERREID = 20200701002 -- Parametro Cierre
--       AND (OPER2.CVE_ESTATUS = 'S' OR OPER2.CVE_ESTATUS IS NULL)
--       AND OPER2.TIPOOPERACIONID = 40 -- Se agrega tipo de operación de entrada
--       AND OPER2.FECHAOPERACIONCNTR <= CIE.FECHA_FIN_CIERRE
                  WHERE cast(OPER2.FECHAOPERACIONCNTR as date) = '2020-07-03'
              ) Oper
--       AND OPER2.FECHAOPERACIONCNTR >= CIE.FECHA_INI_CIERRE) Oper
--             , [SOFOM].MTS_DCONTRATANTE Cnte
         WHERE
--                Oper.CONTRATANTEID = Cnte.CONTRATANTEID
--            AND
             Oper.CONTPROM IS NOT NULL
           AND Oper.NUMTRANS >= Oper.CONTPROM
           AND cast(Oper.FECHAOPERACIONCNTR as date) = '2020-07-03'
--   AND Oper.NUMTRANS >= Oper.CONTPROM
           AND (SELECT COUNT(CODOPER) NUM_OPERACIONES
                FROM SOFOM.MTS_HOPERACIONESCNTR OPE
                WHERE convert(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
                    BETWEEN '2020-06-25' AND '2020-06-25'
                  and OPE.CONTRATANTEID = 344) >= Oper.CONTPROM
           AND Oper.NUMTRANS >= 8 -- Parametro Numero de Transacciones
         group by Oper.CONTRATANTEID) op_tmp,
     SOFOM.MTS_HOPERACIONESCNTR OPER3333
where OPER3333.CONTRATANTEID = op_tmp.CONTRATANTEID
  AND cast(OPER3333.FECHAOPERACIONCNTR as date) = '2020-07-03';


SELECT COUNT(1) as total, CONTRATANTECD
FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
WHERE cast(OPE.FECHAOPERACIONCNTR as date) = '2020-07-03' -- Cambian las fechas por inicio de mes
group by CONTRATANTECD
order by total desc;


select OPER3333.OPERCNTRID
     , OPER3333.NUMPOLIZACNTR
     , OPER3333.TIPODOCUMENTOID
     , OPER3333.TIPOOPERACIONID
     , OPER3333.INSTRMONETARIOID
     , OPER3333.MONEDAID
     , OPER3333.CONTRATANTEID
     , OPER3333.AGENTEID
     , OPER3333.EMPLEADOID
     , OPER3333.SUCURSALID
     , OPER3333.PRODUCTOID
     , OPER3333.FECHAOPERACIONCNTR
     , OPER3333.LINEANEGOCIOID
     , OPER3333.MONTOMNCNTR
     , OPER3333.MONTOCNTR
     , OPER3333.MONTO_EFECTIVO
     , OPER3333.CODOPER
from (
         SELECT Oper.CONTRATANTEID
         FROM (
                  SELECT Oper2.CONTRATANTEID
                       , Oper2.FECHAOPERACIONCNTR
                       -- Suma las operaciones de los últimos 90 días
                       , (SELECT sum(REGISTROS) / 3
                          FROM (--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                                   SELECT top 3 CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) AS FECHA,
                                                COUNT(1)                                         Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                                   FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                                   WHERE OPE.FECHAOPERACIONCNTR < '2020-07-03 00:00:00'
                                     AND OPE.FECHAOPERACIONCNTR >= DATEADD(DAY, -10, '2020-07-03 00:00:00') -- 30 es por parametro
                                     AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
                                   Group by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112)
                                   order by CONVERT(Char(8), OPE.FECHAOPERACIONCNTR, 112) desc
                               ) Rgs)                                    CONTPROM
                       , (SELECT COUNT(1)
                          FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                          WHERE cast(OPE.FECHAOPERACIONCNTR as date) = '2020-07-03' -- Cambian las fechas por inicio de mes
                            AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID) NUMTRANS
                  FROM [SOFOM].MTS_HOPERACIONESCNTR OPER2
                  WHERE cast(OPER2.FECHAOPERACIONCNTR as date) = '2020-07-03') Oper
         WHERE Oper.CONTPROM IS NOT NULL
           AND Oper.NUMTRANS >= Oper.CONTPROM
           AND cast(Oper.FECHAOPERACIONCNTR as date) = '2020-07-03'
           AND Oper.NUMTRANS >= 8 -- Parametro Numero de Transacciones
         group by Oper.CONTRATANTEID) op_tmp,
     SOFOM.MTS_HOPERACIONESCNTR OPER3333
where OPER3333.CONTRATANTEID = op_tmp.CONTRATANTEID
  AND cast(OPER3333.FECHAOPERACIONCNTR as date) = '2020-07-03';


select OPER3333.OPERCNTRID
     , OPER3333.NUMPOLIZACNTR
     , OPER3333.TIPODOCUMENTOID
     , OPER3333.TIPOOPERACIONID
     , OPER3333.INSTRMONETARIOID
     , OPER3333.MONEDAID
     , OPER3333.CONTRATANTEID
     , OPER3333.AGENTEID
     , OPER3333.EMPLEADOID
     , OPER3333.SUCURSALID
     , OPER3333.PRODUCTOID
     , OPER3333.FECHAOPERACIONCNTR
     , OPER3333.LINEANEGOCIOID
     , OPER3333.MONTOMNCNTR
     , OPER3333.MONTOCNTR
     , OPER3333.MONTO_EFECTIVO
     , OPER3333.CODOPER
from (
         SELECT
--        COUNT(1)
Oper.CONTRATANTEID
         FROM (
                  SELECT Oper2.CONTRATANTEID
                       , CONVERT(VARCHAR, FECHAOPERACIONCNTR, 23) as     fecha
                       -- Suma las operaciones de los últimos 90 días
                       , (SELECT sum(REGISTROS) / 3
                          FROM (--  Parametro de porcentaje en este caso 1.5% -- Se elimina el parametro
                                   SELECT CONVERT(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) AS FECHA,
                                          COUNT(1)                                        Registros -- Cuenta los registros de los últimos 30 dias a partir de la fecha de operación anlizada
                                   FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                                   WHERE OPE.FECHAOPERACIONCNTR < '2020-07-03 00:00:00'
                                     AND OPE.FECHAOPERACIONCNTR > DATEADD(DAY, -10, '2020-07-03 00:00:00') -- 30 es por parametro
                                     AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID
--                               Group by cast(OPE.FECHAOPERACIONCNTR as date )
                                   Group by CONVERT(VARCHAR, OPE.FECHAOPERACIONCNTR, 23)
--                               order by cast(OPE.FECHAOPERACIONCNTR as date) desc
                               ) Rgs)                                    CONTPROM
                       , (SELECT COUNT(1)
                          FROM [SOFOM].MTS_HOPERACIONESCNTR OPE
                          WHERE CONVERT(VARCHAR, OPE.FECHAOPERACIONCNTR, 23) = '2020-07-03' -- Cambian las fechas por inicio de mes
                            AND OPE.CONTRATANTEID = Oper2.CONTRATANTEID) NUMTRANS
                  FROM [SOFOM].MTS_HOPERACIONESCNTR OPER2
--                 , [SOFOM].MTS_DCONTRATANTE Cnte
                  WHERE cast(OPER2.FECHAOPERACIONCNTR as date) = '2020-07-03'
                  group by CONTRATANTEID, CONVERT(VARCHAR, FECHAOPERACIONCNTR, 23)
--                and OPER2.CONTRATANTEID = Cnte.CONTRATANTEID
--              and Cnte.TIPOPERSONAFISCALID = 2
              ) Oper
         WHERE Oper.CONTPROM IS NOT NULL
           AND Oper.NUMTRANS >= Oper.CONTPROM
           AND cast(Oper.fecha as date) = '2020-07-03'
           AND Oper.NUMTRANS >= 8 -- Parametro Numero de Transacciones
         group by Oper.CONTRATANTEID -- , CONTPROM
     ) op_tmp,
     SOFOM.MTS_HOPERACIONESCNTR OPER3333
where OPER3333.CONTRATANTEID = op_tmp.CONTRATANTEID
  AND cast(OPER3333.FECHAOPERACIONCNTR as date) = '2020-07-03';

-- 2, 103, 104
select top 3 *
from SOFOM.MTS_HOPERACIONESCNTR;


-- 2 1:18 seg 5,775
-- 103 50 seg 8393
-- 104 2 seg 125
SELECT B.OPERCNTRID
     , C.NUMPOLIZACNTR
     , C.TIPODOCUMENTOID
     , C.TIPOOPERACIONID
     , C.INSTRMONETARIOID
     , C.MONEDAID
     , B.CONTRATANTEID
     , C.AGENTEID
     , C.EMPLEADOID
     , C.SUCURSALID
     , C.PRODUCTOID
     , C.FECHAOPERACIONCNTR
     , C.LINEANEGOCIOID
     , C.MONTOMNCNTR
     , C.MONTOCNTR
     , C.MONTO_EFECTIVO
     , C.CODOPER
FROM (
         SELECT A.CONTRATANTEID, A.OPERCNTRID, A.OPER_DIA, SUM(A.OPERACIONES) / 3 PROMEDIO
         FROM (
                  SELECT ROW_NUMBER()
                                 OVER (PARTITION BY CNTE.CONTRATANTEID ORDER BY CNTE.CONTRATANTEID,CAST(OPE.FECHAOPERACIONCNTR AS DATE) DESC) ORDEN,
                         CNTE.CONTRATANTEID,
                         CAST(OPE.FECHAOPERACIONCNTR AS DATE)                    AS                                                           FECHA,
                         (SELECT MAX(OPERCNTRID)
                          FROM SOFOM.MTS_HOPERACIONESCNTR
                          WHERE CONTRATANTEID = CNTE.CONTRATANTEID
                            AND CAST(FECHAOPERACIONCNTR AS DATE) = '2020-07-03') AS                                                           OPERCNTRID,
                         (SELECT COUNT(1)
                          FROM SOFOM.MTS_HOPERACIONESCNTR
                          WHERE CONTRATANTEID = CNTE.CONTRATANTEID
                            AND CAST(FECHAOPERACIONCNTR AS DATE) = '2020-07-03') AS                                                           OPER_DIA,
                         COUNT(CAST(OPE.FECHAOPERACIONCNTR AS DATE))             AS                                                           OPERACIONES
                  FROM [SOFOM].MTS_HOPERACIONESCNTR OPE,
                       [SOFOM].MTS_DCONTRATANTE CNTE
                  WHERE CAST(OPE.FECHAOPERACIONCNTR AS DATE) < '2020-07-03'                     -- Fecha de fin de cierre
                    AND CAST(OPE.FECHAOPERACIONCNTR AS DATE) >= DATEADD(DAY, -90, '2020-07-03') -- Fecha fin de cierre
                    AND OPE.CONTRATANTEID = CNTE.CONTRATANTEID
                    AND CNTE.TIPOPERSONAFISCALID = 2
                  GROUP BY CNTE.CONTRATANTEID, CAST(OPE.FECHAOPERACIONCNTR AS DATE)
              ) A
         WHERE A.OPER_DIA >= 1 -- OPERACIONES MINIMA POR DIA ANALISIS
           AND A.ORDEN <= 3    -- PROMEDIO DE 3 DIAS ULTIMOS DIAS
         GROUP BY A.CONTRATANTEID, A.OPERCNTRID, A.OPER_DIA
     ) B,
     [SOFOM].MTS_HOPERACIONESCNTR C
WHERE B.OPERCNTRID = C.OPERCNTRID
  AND B.OPER_DIA > B.PROMEDIO
ORDER BY B.CONTRATANTEID;

