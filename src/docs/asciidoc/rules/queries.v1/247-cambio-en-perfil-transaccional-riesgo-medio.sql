/**************************************************************************
REGLA 247
Alerta de Inusualidad - Cambio en el Perfil Transaccional Medio
***************************************************************************/
         SELECT
			       ? ANIO,
               ? MES,
        Kper.CONTRATANTECD,
        Kper.CVE_ROL,
        Kper.NOMBRES,
        Kper.APELLIDO_PATERNO,
        Kper.APELLIDO_MATERNO,
        Kper.DS_RAZON_SOCIAL,
        Kper.CURP,
        Kper.RFC CONTRATANTERFC,
        Kper.CVE_TIPO_FISICA_MORAL,
        Kper.CVE_NIVEL_RIESGO,
        pERFIL.*
FROM   [schema].MTS_VL_KYC_ANALISIS_PERFIL Perfil,
       [schema].MTS_VL_KYC_PERSONAS  Kper
WHERE YEAR =  ? /* Se obtiene a partir de la fecha fin de cierre */
AND   MONTH =  ? /*  Se obtiene a partir de la fecha fin de cierre */
AND 	Kper.ID_CONTRATO = Perfil.CONTRATANTECD
AND   Kper.CVE_ROL  = 'CL'
AND   Kper.CVE_TIPO_FISICA_MORAL IN (?)    -- -- PARAMETRO DE TIPO DE PERSONAS
AND	 CHARINDEX(Kper.CVE_NIVEL_RIESGO,  ? ) > 0  -- Parameto NIVEL DE RIESGO
AND (
        (((cast(NO_OPERACIONES_DEPOSITO AS DECIMAL) * 1.#percent) - ACT_NO_TOT_DEPOSITOS) < 0 AND NO_OPERACIONES_DEPOSITO > 0) OR
        (((cast(IMP_MONTO_ESTIMADO_TRX_DEPOSITO AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_DEPOSITOS) < 0 AND IMP_MONTO_ESTIMADO_TRX_DEPOSITO > 0) OR
        (((cast(NO_OPERACIONES_RETIRO AS DECIMAL) * 1.#percent) - ACT_NO_TOT_RETIROS) < 0 AND NO_OPERACIONES_RETIRO > 0) OR
        (((cast(IMP_MONTO_ESTIMADO_TRX_RETIRO AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_RETIROS) < 0 AND IMP_MONTO_ESTIMADO_TRX_RETIRO > 0) OR
        (((CAST(NO_PAGOS_CREDITO_MENSUAL AS DECIMAL) * 1.#percent) - ACT_NO_TOT_APORTACIONES) < 0 AND NO_PAGOS_CREDITO_MENSUAL > 0) OR
        (((cast(IMP_MONTO_PAGOS_CREDITO_MENSUAL AS DECIMAL) * 1.#percent) - ACT_IMP_MONTO_TOT_APORTACIONES) < 0 AND IMP_MONTO_PAGOS_CREDITO_MENSUAL > 0))					            
	
