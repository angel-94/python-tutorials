	/***********************************************************************
				REGLA 229 DOMICILIOS IGUALES
				Alerta de Inusualidad - DOMICILIOS IGUALES
				-- Parametros:
				-- Número de veces domicilio cliente: 3
				-- Este parámetro s repite 3 veces, para domicilio, Celular y teléfono Fijo
				************************************************************************/
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
					,Kper.RFC CONTRATANTERFC
					,Oper.CODOPER
				  ,Kper.ID_KYC
					FROM [schema].MTS_HOPERACIONESCNTR Oper,
						 [schema].MTS_VL_KYC_PERSONAS Kper,
						 [schema].MTS_CRN_CIERRE Cier
					WHERE Oper.CONTRATANTECD = Kper.CONTRATANTECD
					AND Cier.CIERREID = ? -- Parametro Cierre
					AND Oper.FECHAOPERACIONCNTR <= Cier.FECHA_FIN_CIERRE
					AND Oper.FECHAOPERACIONCNTR >= Cier.FECHA_INI_CIERRE
					AND ( Oper.CVE_ESTATUS = 'S' OR Oper.CVE_ESTATUS IS NULL)
					AND (Kper.ID_KYC IN (
						SELECT DISTINCT kdir.id_kyc
						FROM [schema].MTS_KYC_DIRECCIONES Kdir
						WHERE Kdir.id_kyc IN (SELECT id_kyc
													FROM [schema].MTS_VL_KYC_PERSONAS Kpe
													WHERE cve_rol = 'CL')
									AND CVE_ESTADO + ' ' + CVE_MUNICIPIO + ' ' + CVE_COLONIA + ' ' + CODIGO_POSTAL + ' ' + DS_CALLE  + ' ' + NO_EXTERIOR IN
											(SELECT domicilio
											 		FROM (SELECT
															 CVE_ESTADO + ' ' + CVE_MUNICIPIO + ' ' + CVE_COLONIA + ' ' + CODIGO_POSTAL + ' ' + DS_CALLE  + ' ' + NO_EXTERIOR AS domicilio,
															 count(ID_KYC)                                                              AS cuenta
														 FROM [schema].MTS_KYC_DIRECCIONES
														 WHERE CVE_ESTADO IS NOT NULL
															AND id_kyc IN (SELECT id_kyc
																			 FROM [schema].MTS_VL_KYC_PERSONAS Kpe
																			 WHERE cve_rol = 'CL')
															GROUP BY CVE_ESTADO, CVE_MUNICIPIO, CVE_COLONIA, CODIGO_POSTAL, DS_CALLE, NO_EXTERIOR ) a
											 WHERE a.cuenta >= ? )) --Parámetro número de veces que se repite el domicilio
					OR Kper.ID_KYC IN (
						SELECT DISTINCT Kpe.id_kyc
						FROM [schema].MTS_KYC_PERSONAS Kpe
							WHERE Kpe.id_kyc IN (SELECT id_kyc
												 FROM [schema].MTS_VL_KYC_PERSONAS Kpe
												 WHERE cve_rol = 'CL')
									AND Kpe.NUM_TEL_CASA IN
											(SELECT NUM_TEL_CASA
											 	FROM (SELECT
															 NUM_TEL_CASA AS NUM_TEL_CASA,
															 count(*)     AS Cuenta_tel
														 FROM [schema].MTS_KYC_PERSONAS Kpe
														 WHERE NUM_TEL_CASA IS NOT NULL
															AND Kpe.ID_KYC IN (SELECT Kpe.id_kyc
																				FROM [schema].MTS_VL_KYC_PERSONAS Kpe
																				WHERE Kpe.cve_rol = 'CL')
														 GROUP BY NUM_TEL_CASA) b
						WHERE b.Cuenta_tel >= ? )) -- Parámetro número de veces que se repite el domicilio (Teléfono Fijo)
					OR Kper.ID_KYC IN (
						SELECT DISTINCT Kpe.id_kyc
						FROM [schema].MTS_KYC_PERSONAS Kpe
						WHERE Kpe.id_kyc IN (SELECT id_kyc
																 FROM [schema].MTS_VL_KYC_PERSONAS Kpe
																 WHERE cve_rol = 'CL')
									AND Kpe.NUM_TEL_CELULAR IN
											(SELECT NUM_TEL_CELULAR
											 FROM (SELECT
															 NUM_TEL_CELULAR AS NUM_TEL_CELULAR,
															 count(*)        AS Cuenta_cel
														 FROM [schema].MTS_KYC_PERSONAS Kpe
														 WHERE NUM_TEL_CASA IS NOT NULL
																	 AND Kpe.ID_KYC IN (SELECT Kpe.id_kyc
																											FROM [schema].MTS_VL_KYC_PERSONAS Kpe
																											WHERE Kpe.cve_rol = 'CL')
														 GROUP BY NUM_TEL_CELULAR) c
											 WHERE c.Cuenta_cel >= ?)) --Parámetro número de veces que se repite el domicilio (Celular)
					)
					AND EXISTS (SELECT NULL
								FROM [schema].MTS_EXT_PRODUCTOS_CIERRE
								WHERE ID_PROCESO = ? --PARAMETRO ID_PROCESO
								AND PRODUCTID = OPER.PRODUCTOID)
					AND NOT EXISTS (SELECT NULL
								FROM [schema].MTS_HRN_CASOS_REGLAS
								-- WHERE OPERCNTRID = OPER.OPERCNTRID
								WHERE CONTRATANTEID = OPER.CONTRATANTEID
								AND REGLANEGOCIOID = ?) -- NUMERO DE REGLA
					ORDER BY Oper.CONTRATANTEID, Oper.FECHAOPERACIONCNTR, Oper.Opercntrid
