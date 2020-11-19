-- Listas negras


# PERSONAS FISICAS STP
				SELECT NOMBRES,ISNULL(APELLIDO_PATERNO,'') APELLIDO_PATERNO,ISNULL(APELLIDO_MATERNO,'') APELLIDO_MATERNO,ID_DECLARATIVA_PEP, ID_KYC from [schema].MTS_VL_KYC_PERSONAS  KPER where CVE_TIPO_FISICA_MORAL = 1

-- PERSONAS FISIOCAS FINACEN

SELECT NOMBRES,
						   ISNULL(APELLIDO_PATERNO, '') APELLIDO_PATERNO,
						   ISNULL(APELLIDO_MATERNO, '') APELLIDO_MATERNO,
						   ID_DECLARATIVA_PEP,
						   ID_KYC
					FROM [schema].MTS_VL_KYC_PERSONAS KPER
					WHERE CVE_TIPO_FISICA_MORAL = 1
					AND ID_PROCESO = %s


-- Personas morales

SELECT KP.DS_RAZON_SOCIAL,ISNULL(KP.RFC,'') RFC,ISNULL(KP.ID_DECLARATIVA_PEP,'') ID_DECLARATIVA_PEP, KP.ID_KYC
					FROM [schema].MTS_KYC_PERSONAS KP, [schema].MTS_KYC_CONTRATO_PERSONAS CP WHERE KP.CVE_TIPO_PERSONA = 2
					AND CP.SW_ESTATUS = 'A'
  					AND KP.ID_KYC = CP.ID_KYC
  					AND KP.SW_LISTAS_NEGRAS != 'P' AND KP.SW_LISTAS_NEGRAS != 'S'