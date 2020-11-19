/************************************************************************** 
							 REGLA 245
							 Alerta de Inusualidad - Cambio en el Perfil Transaccional PEP
						***************************************************************************/
						SELECT
						? ANIO,
						? MES,
						KPER.CONTRATANTECD,
						KPER.CVE_ROL,
						KPER.NOMBRES,
						KPER.APELLIDO_PATERNO,
						KPER.APELLIDO_MATERNO,
						KPER.DS_RAZON_SOCIAL,
						KPER.CURP,
						KPER.RFC CONTRATANTERFC,
						KPER.CVE_TIPO_FISICA_MORAL,
						KPER.CVE_NIVEL_RIESGO,
						PERFIL.*
						FROM SOFOM.MTS_VL_KYC_ANALISIS_PERFIL PERFIL,
						SOFOM.MTS_VL_KYC_PERSONAS KPER
						WHERE YEAR = ? 
						AND MONTH = ? 
						AND KPER.ID_CONTRATO = PERFIL.CONTRATANTECD
						AND KPER.CVE_ROL = 'CL'
						AND KPER.CVE_TIPO_FISICA_MORAL IN (?)
--             			AND (KPER.ID_DECLARATIVA_PEP = 1 OR KPER.SW_LISTAS_NEGRAS in ('P','S'))
            			AND (KPER.ID_DECLARATIVA_PEP = 1 OR KPER.SW_LISTAS_NEGRAS in (?)) -- Siempre y cuando sea cliente
						AND (
					        (((cast(NO_OPERACIONES_DEPOSITO AS DECIMAL) * 1.#percent) - ACT_NO_TOT_DEPOSITOS) < 0 AND NO_OPERACIONES_DEPOSITO > 0) OR
					        (((cast(IMP_MONTO_ESTIMADO_TRX_DEPOSITO AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_DEPOSITOS) < 0 AND IMP_MONTO_ESTIMADO_TRX_DEPOSITO > 0) OR
					        (((cast(NO_OPERACIONES_RETIRO AS DECIMAL) * 1.#percent) - ACT_NO_TOT_RETIROS) < 0 AND NO_OPERACIONES_RETIRO > 0) OR
					        (((cast(IMP_MONTO_ESTIMADO_TRX_RETIRO AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_RETIROS) < 0 AND IMP_MONTO_ESTIMADO_TRX_RETIRO > 0) OR
					        (((CAST(NO_PAGOS_CREDITO_MENSUAL AS DECIMAL) * 1.#percent) - ACT_NO_TOT_APORTACIONES) < 0 AND NO_PAGOS_CREDITO_MENSUAL > 0) OR
					        (((cast(IMP_MONTO_PAGOS_CREDITO_MENSUAL AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_APORTACIONES) < 0 AND IMP_MONTO_PAGOS_CREDITO_MENSUAL > 0))

	     	