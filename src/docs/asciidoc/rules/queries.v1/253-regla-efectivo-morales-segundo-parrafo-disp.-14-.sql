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
				      ,Oper.MONTOMNCNTR -- Este es el monto a considerar expresado en PESOS
				      ,Oper.MONTOCNTR
				      ,Oper.MONTO_EFECTIVO
				      ,Cnte.CONTRATANTERFC
				      ,Oper.CODOPER
				  FROM  SOFOM.MTS_HOPERACIONESCNTR  Oper,
				        SOFOM.MTS_DCONTRATANTE      Cnte,
				        SOFOM.MTS_CRN_CIERRE        Cier
				 WHERE  Oper.CONTRATANTEID                   =   Cnte.CONTRATANTEID
					AND Cnte.TIPOPERSONAFISCALID			 in (2)	 --Tipo de Persona Moral
				    AND Cier.CIERREID                        =   ?     -- Parametro Cierre
				    AND Oper.FECHAOPERACIONCNTR              <=  Cier.FECHA_FIN_CIERRE
				    AND Oper.FECHAOPERACIONCNTR              >=  Cier.FECHA_INI_CIERRE
				    AND right('00'+Oper.INSTRMONETARIOID,2)  =   ?         -- Parámetro Instrumento Monetario  Efectivo
				    AND Oper.TIPOOPERACIONID IN (  SELECT  TipoOperacionId
				                                     FROM  SOFOM.MTS_DTIPO_OPERACIONES
				                                    WHERE  APORTACION = 'S')
				    AND Oper.MONEDAID                        =  ? --  Moneda Pesos
				    AND Oper.MONTOMNCNTR                     >  ? -- Parámetro Monto Persona Física
				    AND ( Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
				   AND    EXISTS (  SELECT NULL
				                    FROM   SOFOM.MTS_EXT_PRODUCTOS_CIERRE
				                    WHERE  Id_Proceso   = ? --Parámetro Proceso
				                    AND    Productid    = Oper.PRODUCTOID)
				  AND NOT EXISTS (SELECT NULL
				                FROM SOFOM.MTS_HRN_CASOS_REGLAS
				                WHERE CODOPER = Oper.CODOPER
				                AND REGLANEGOCIOID = ?)     --Parámetro Regla
				Order By Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.OPERCNTRID

