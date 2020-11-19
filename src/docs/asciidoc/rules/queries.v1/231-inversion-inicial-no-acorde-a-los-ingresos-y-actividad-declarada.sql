	-- RN32 INVERSIÓN INICIAL NO ACORDÉ A LOS INGRESOS Y ACTIVIDAD

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
				            ,Oper.MONTOMNCNTR -- Este es el monto a considerar espresado en USD
				            ,Oper.MONTOCNTR
				            ,Oper.MONTO_EFECTIVO
				            ,Cnte.CONTRATANTERFC
				            ,Oper.CODOPER
				         FROM
				           [schema].MTS_HOPERACIONESCNTR  Oper,
				            [schema].MTS_DCONTRATANTE    Cnte,
				               [schema].MTS_CRN_CIERRE        Cier
				       WHERE  Oper.CONTRATANTEID                   =   Cnte.CONTRATANTEID
				          AND Cier.CIERREID                        =   ?     -- Parametro Cierre
				          AND Oper.FECHAOPERACIONCNTR              <=  Cier.FECHA_FIN_CIERRE
				          AND Oper.FECHAOPERACIONCNTR              >=  Cier.FECHA_INI_CIERRE
				          AND right('00'+ Oper.TIPOOPERACIONID, 2) IN (  SELECT  right('00'+ TIPOOPERACIONID, 2)
				                 FROM   [schema].MTS_DTIPO_OPERACIONES
				                WHERE  APORTACION = 'S')
				          AND Oper.MONTOMNCNTR                       >   Cnte.CONTRATANTEINGRESOS
				          AND ( Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
				         AND    EXISTS (  SELECT NULL
				                          FROM    [schema].MTS_EXT_PRODUCTOS_CIERRE
				                          WHERE  Id_Proceso   = ?  --Parámetro
				                          AND    Productid    = Oper.PRODUCTOID)
				        AND NOT EXISTS (SELECT NULL
				                      FROM [schema].MTS_HRN_CASOS
				                      WHERE CODOPER = Oper.CODOPER
				                      AND REGLANEGOCIOID = ? ) --Parámetro
				      Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID