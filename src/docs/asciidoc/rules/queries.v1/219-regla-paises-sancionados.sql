SELECT Oper.OPERCNTRID,
            Oper.NUMPOLIZACNTR,
            Oper.TIPODOCUMENTOID,
            Oper.TIPOOPERACIONID,
            Oper.INSTRMONETARIOID,
            Oper.MONEDAID,
            Oper.CONTRATANTEID,
            Oper.AGENTEID,
            Oper.EMPLEADOID,
            Oper.SUCURSALID,
            Oper.PRODUCTOID,
            Oper.FECHAOPERACIONCNTR,
            Oper.LINEANEGOCIOID,
            Oper.MONTOMNCNTR,
            Oper.MONTOCNTR,
            Oper.MONTO_EFECTIVO,
            Cnte.CONTRATANTERFC,
            Oper.CODOPER
            ,Cnte.PAISID
            ,Cnte.PAIS_NACIMIENTO
       FROM [schema].MTS_HOPERACIONESCNTR Oper,
            [schema].MTS_DCONTRATANTE     Cnte,
            [schema].MTS_CRN_CIERRE       Cierre
      WHERE     Oper.CONTRATANTEID             =   Cnte.CONTRATANTEID
            AND Cierre.CIERREID                =   ?                 -- Parametro Cierre
            AND Oper.FECHAOPERACIONCNTR        <=  Cierre.FECHA_FIN_CIERRE
            AND Oper.FECHAOPERACIONCNTR        >=  Cierre.FECHA_INI_CIERRE
            AND (/*(Cnte.PAISID IN (SELECT PAIS.PAISID
                               FROM [schema].MTS_DPAIS PAIS
                               WHERE PAIS.SW_ALTO_RIESGO = 'S'))
            OR */(Oper.PAISID_BANCO_DESTINO IN (SELECT PAIS.PAISID
                               FROM [schema].MTS_DPAIS PAIS
                               WHERE PAIS.SW_ALTO_RIESGO = 'S'))
            OR (Oper.PAISID_BANCO_ORIGEN IN (SELECT PAIS.PAISID
                               FROM [schema].MTS_DPAIS PAIS
                               WHERE PAIS.SW_ALTO_RIESGO = 'S'))
                )
            AND ( Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
            AND EXISTS
                   (SELECT NULL
                      FROM [schema].MTS_EXT_PRODUCTOS_CIERRE
                     WHERE ID_PROCESO = ?                --PARAMETRO ID_PROCESO
                       AND PRODUCTID = OPER.PRODUCTOID)
            AND NOT EXISTS
                   (SELECT NULL
                      FROM [schema].MTS_HRN_CASOS_REGLAS
                     WHERE CODOPER = OPER.CODOPER
                      AND REGLANEGOCIOID = ?) -- NUMERO DE REGLA