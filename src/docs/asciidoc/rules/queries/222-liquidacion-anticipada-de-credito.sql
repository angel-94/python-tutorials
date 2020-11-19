-- RN23 LIQUIDACIÓN ANTICIPADA DE CRÉDITO
						-- Parametro: Porcentaje del periodo de cancelacion: 30
						SELECT Oper.OPERCNTRID
				            ,Oper.NUMPOLIZACNTR
				            ,Oper.TIPODOCUMENTOID
				            ,Oper.TIPOOPERACIONID
				            ,Oper.INSTRMONETARIOID
				            ,Oper.MONEDAID
				            ,Oper.CONTRATANTEID
				            ,Oper.AGENTEID
				            ,Oper.EMPLEADOID
				            ,Oper.SUCURSALID
				            ,Oper.PRODUCTOID
				            ,Oper.FECHAOPERACIONCNTR
				            ,Oper.LINEANEGOCIOID
				            ,Oper.MONTOMNCNTR
				            ,Oper.MONTOCNTR
				            ,Oper.MONTO_EFECTIVO
				            ,Cnte.CONTRATANTERFC
				            ,Oper.CODOPER
				       FROM
				        [schema].MTS_HOPERACIONESCNTR Oper,
				        [schema].MTS_DCONTRATANTE     Cnte,
				        [schema].MTS_CRN_CIERRE       Cierre
				      WHERE Oper.CONTRATANTEID = Cnte.CONTRATANTEID
				      AND Cierre.CIERREID                         =   ?  -- Parametro Cierre
				      AND Oper.FECHAOPERACIONCNTR                 <=  Cierre.FECHA_FIN_CIERRE
				      AND Oper.FECHAOPERACIONCNTR                 >=  Cierre.FECHA_INI_CIERRE
				      AND Oper.PRODUCTOID IN (
				            SELECT PRODUCTOID
				            FROM [schema].MTS_DPRODUCTO
				            WHERE UPPER(NOMBREPRODUCTO) LIKE '%CREDITO%')
				      --AND PLAZO_CREDITO_MESES > 0
				      AND OPER.FEC_CANCELACION_CREDITO IS NOT NULL
				      AND (((DATEDIFF(month,FEC_APERTURA_CUENTA,FEC_CANCELACION_CREDITO))*100.00)/
				          CAST(PLAZO_CREDITO_MESES AS FLOAT)) < ?  -- Parametro Porcentaje
				      AND ( Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
				      AND    EXISTS (  SELECT NULL
				                         FROM   [schema].MTS_EXT_PRODUCTOS_CIERRE Prod
				                         WHERE  Prod.Id_Proceso   = ? -- Parametro id proceso
				                         AND    Prod.Productid    = Oper.PRODUCTOID)
				      AND NOT EXISTS (SELECT NULL
				                  FROM [schema].MTS_HRN_CASOS_REGLAS
				                  WHERE CODOPER = Oper.CODOPER
				                  AND REGLANEGOCIOID = ?) -- Parametro Regla de Negocio
				      Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID
