-- Que el monto sea mayor a 500 y menor a 7500
-- Estos datos son efectivos
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
     , Oper.MONTOMNCNTR -- Este es el monto a considerar expresado en USD
     , Oper.MONTOCNTR
     , Oper.MONTO_EFECTIVO
     , Cnte.CONTRATANTERFC
     , Oper.CODOPER
FROM [SOFOM].MTS_HOPERACIONESCNTR Oper,
     [SOFOM].MTS_DCONTRATANTE Cnte,
     [SOFOM].MTS_CRN_CIERRE Cier
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  -- AND Cnte.TIPOPERSONAFISCALID    =  1 --Tipo de Persona Física
  AND Cier.CIERREID = ?                             -- Parametro Cierre     
  AND Oper.FECHAOPERACIONCNTR <= Cier.FECHA_FIN_CIERRE
  AND Oper.FECHAOPERACIONCNTR >= Cier.FECHA_INI_CIERRE
  AND right('00' + Oper.INSTRMONETARIOID, 2) = '01' -- Parametro Instrumento Monetario  Efectivo
  AND right('00' + Oper.TIPOOPERACIONID, 2) IN (SELECT right('00' + TIPOOPERACIONID, 2)
                                                FROM [SOFOM].MTS_DTIPO_OPERACIONES
                                                WHERE APORTACION = 'S')
  AND Oper.MONEDAID = ?                             --  Moneda Pesos
  AND Oper.MONTOCNTR > ?                            -- Parametro Monto Persona Física
  -- Cambiarlo a parametro enviado desde Java
  AND Oper.MONTOCNTR < (select VALOR
                        from [SOFOM].MTS_HRN_PARAMETROS
                        where REGLANEGOCIOID = 208
                          and PARAMETROID = 3)      -- Parametro Monto de Regla relevante
  AND (Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
  AND EXISTS(SELECT NULL
             FROM [SOFOM].MTS_EXT_PRODUCTOS_CIERRE
             WHERE Id_Proceso = ? --Parámetro Proceso
               AND Productid = Oper.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM [SOFOM].MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = ?)          --Parámetro Regla               
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID





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
     , Oper.MONTOMNCNTR -- Este es el monto a considerar expresado en USD
     , Oper.MONTOCNTR
     , Oper.MONTO_EFECTIVO
     , Oper.MONTOUSD
     , Cnte.CONTRATANTERFC
     , Oper.CODOPER
FROM [SOFOM].MTS_HOPERACIONESCNTR Oper,
     [SOFOM].MTS_DCONTRATANTE Cnte,
     [SOFOM].MTS_CRN_CIERRE Cier
WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
  -- AND Cnte.TIPOPERSONAFISCALID    =  1 --Tipo de Persona Física
  AND Cier.CIERREID = ?                             -- Parametro Cierre
  AND Oper.FECHAOPERACIONCNTR <= Cier.FECHA_FIN_CIERRE
  AND Oper.FECHAOPERACIONCNTR >= Cier.FECHA_INI_CIERRE
  AND right('00' + Oper.INSTRMONETARIOID, 2) = '01' -- Parametro Instrumento Monetario  Efectivo
  AND right('00' + Oper.TIPOOPERACIONID, 2) IN (SELECT right('00' + TIPOOPERACIONID, 2)
                                                FROM [SOFOM].MTS_DTIPO_OPERACIONES
                                                WHERE APORTACION = 'S')
  AND Oper.MONEDAID = ?                             --  Moneda Pesos
  AND Oper.MONTOCNTR > ?                            -- Parametro Monto Persona Física
  AND Oper.MONTOCNTR < (select VALOR
                        from [SOFOM].MTS_HRN_PARAMETROS
                        where REGLANEGOCIOID = 208
                          and PARAMETROID = 3)      -- Parametro Monto de Regla relevante
  AND (Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
  AND EXISTS(SELECT NULL
             FROM [SOFOM].MTS_EXT_PRODUCTOS_CIERRE
             WHERE Id_Proceso = ? --Parámetro Proceso
               AND Productid = Oper.PRODUCTOID)
  AND NOT EXISTS(SELECT NULL
                 FROM [SOFOM].MTS_HRN_CASOS_REGLAS
                 WHERE CODOPER = Oper.CODOPER
                   AND REGLANEGOCIOID = ?)          --Parámetro Regla
Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID


SELECT right('00' + TIPOOPERACIONID, 2), APORTACION, DS_TIPO_OPERACION
FROM [SOFOM].MTS_DTIPO_OPERACIONES;
WHERE APORTACION = 'S';

-- Tenemos buscar el catálogo de oficial de tipo de operaciones
-- Esto para generar de manera correcta los reportes
SELECT right('00' + TIPOOPERACIONID, 2), APORTACION, DS_TIPO_OPERACION
FROM [TD].MTS_DTIPO_OPERACIONES;
WHERE APORTACION = 'S';
