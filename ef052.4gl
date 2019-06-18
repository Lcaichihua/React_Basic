#####################################################################################################################################################
# PROGRAMA: ef052.4gl
# VERSION : 1.0
# OBJETIVO: Consolidado de Atraso de Cobranza por Etapas
# FECHA   : 23/06/2005
# AUTOR   : HCC
# COMPILAR: ef052.4gl gb001.4gl
#----------------------------------------------------------------------------------------------------------------------------------------------------
# CODIGO   REQ   ANALISTA                       FECHA         	MOTIVO
# (@#)1-A  2725  Cesar E. Muguerza Ortiz	01/01/2011    	Incluir Procurador P3
# (@#)2-A  2994  EDGAR CAMPOS			26/01/2010    	Redondeo de porcentajes a 2 digitos
# (@#)3-A  3435  VAT-Verónica Alcalde T.	28/03/2011	CAMBIOS EN VISUALIZACIóE MONTOS Y OBJETIVOS DEL REP. ATRASO POR ETAPAS
# (@#)4-A  3271	 VAT-Verónica Alcalde T.	05/11/2010    	Cobranza Atrasada 3º Fase: Motos Efectiva
# (@#)5-A  3783	 VAT-Verónica Alcalde T.	19/05/2011  	Agregar quiebres de Tipos de Clientes Premium y Dia de Pago de Linea
# (@#)6-A  xxxx	 VAT-Verónica Alcalde T.	14/06/2011  	Modificar formato excel
# (@#)7-A  4211	 VAT-Verónica Alcalde T.	17/08/2011	Modificar Reporte de Atraso por Etapas - para mostrar "todas" las plazas.
# (@#)8-A  ----	 SS -Siempresoft		21/04/2012	Solicitud de modelo de cobranza (nuevo input) y validaciones para Modulo de cobranzas
# (@#)9-A  ----	 VAT-Verónica Alcalde T.	10/05/2012	Permitir imprimir Total Modelos de Cobranza
# (@#)10-A  ---- ACC-Ana Coronel.	09/08/2012	Corregir los espacios que se daban al generar el reporte en excel.
# (@#)11-A  3974 ACC-Ana Coronel.	25/08/2012	Agregar filtro por microzona.
# (@#)12-A  ---- JAZ	JULIANA ALVA		13/09/2012	LECTURA DE LIMITES DE PORCETAJES PARA CARTERA MOTOS.
# (@#)13-A  ---- SS Siempresoft	                01/10/2012      NO MOSTRAR PROCURACION 3 SEGUN PARAMETRIZACION FECHA DE CORTE
# (@#)14-A  ---- JCH-Jaime Chavarri	         18/07/2013     CAMBIAR FILTRO NIVEL DE GESTION X RANGO DE COBRADORES - PROCURACION 3
# (@#)15-A   ---- Diana Salazar - Siempresoft	11/07/2013      Adicionar los filtros Retail, Tipo Plaza, modificar los reportes
# (@#)16-A  7747 SS Angel Salazar		16/08/2013	AUTOMATIZACION Y ENVIO DE EMAIL CULMINANDO EL PROCESO
# (@#)17-A  ---- SS Diana Salazar		16/05/2014	CORRECCION DE REPORTE PARA RESETEAR VARIABLE DE AGENCIA.
# (@#)18-A 15637 JCH-Jaime Chavarri	        27/02/2014      Corregir el reportes por fusion de TSE
# (@#)19-A 15637 JCH-Jaime Chavarri	        25/07/2015      Separar el Tipo de Cartera.
# (@#)20-A 17335 JCH-Jaime Chavarri	        15/10/2015      Ajuste por Agencias TSE
# (@#)21-A HD 31281 Elias Flores	          14/12/2016      AYACUCHO - ZONAS INCONSISTENTES PARA FECHA 30/11/2015
# (@#)22-A 22267 LUIS MORI                  04/06/2018      PMSS - OPTMIZACIÓN DE PROCESO ef052
#####################################################################################################################################################

DATABASE tbsfi
	DEFINE	p1		RECORD
				  msis		CHAR(1),
				  # inicio (@#)15-A 
				  crtl		SMALLINT,
				  #fin (@#)15-A 
				  cmon		SMALLINT,
				  fech		DATE,
				  # inicio (@#)15-A 
				  ctpl		SMALLINT,
				  #fin (@#)15-A 
				  tcre		CHAR(1),
				  tcr1		SMALLINT,
				  tcre1		SMALLINT,
				  tcre2		SMALLINT,
				  tcuo		SMALLINT,
				  agen1		SMALLINT,
				  agen2		SMALLINT,
				  tdat		CHAR(1),
				  tcar		SMALLINT,
				  tcas		SMALLINT,
				  microz	CHAR(1), #(@#)11-A
				  ctap		CHAR(1),
				  itr7		CHAR(1),
				  tfilt         CHAR(1)
				  END RECORD,
		p2		ARRAY[7] OF RECORD
				  dcar		CHAR(30)
				END RECORD,
		p3		ARRAY[7] OF RECORD
				  dcar		CHAR(30)
				END RECORD,
		{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
		p4		RECORD
			#(@#)13-A Inicio
				  ocpu CHAR(20),
			#(@#)13-A Fin			
				  tges SMALLINT,	{VAT Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}
				  trep SMALLINT,	{VAT Filtro de Reporteo por Zona o Cobrador(ADC/PROCs) 02/09/2009}
				  mcip SMALLINT,
				# Inicio (@#)4-A
				  cart SMALLINT,	# Cartera de: 1: Electrodomesticos, 2: Motos, 0: Total
				  dcar CHAR(20),																																			# (@#)19-A
				  tefe SMALLINT,																																			# (@#)19-A
				  defe CHAR(20),																																			# (@#)19-A
				# Fin (@#)4-A
				  diap SMALLINT		# (@#)5-A	Dia de Pago del Prestamo
				END RECORD,
		{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}	
		t1		RECORD					
				  fech		DATE,
				  csuc		SMALLINT,
				  #(@#)15-A - Inicio
				  agep		INTEGER,
				  #(@#)15-A - Fin				  
				  agen		SMALLINT,
				  plzo		SMALLINT,
				  #(@#)15-A - Inicio
				  plza		SMALLINT,
				  #(@#)15-A - Fin
				  tpro		INTEGER,
				  gpro		INTEGER,
				  impt		DECIMAL(14,2),
				  numc		INTEGER
				END RECORD,
		t2		RECORD LIKE efrd1.*,								
		{VAT Ini 06/11/2009 Pasar Reportes a Excel}
		p5	RECORD
				tform	SMALLINT
			END RECORD,
		{VAT Fin 06/11/2009 Pasar Reportes a Excel}
		g_tcam		LIKE gbhtc.gbhtctcof,
		g_impt, g_impv	DECIMAL(14,2),
		g_numc, g_numv	INTEGER,
		g_subp,
		g_subt, g_tott	ARRAY[7] OF RECORD
				  impv		DECIMAL(14,2),
				  numc		INTEGER
				END RECORD,
		g_plim		ARRAY[7] OF DECIMAL(7,2),
		#################################
		# variables generales NO BORRAR #
		#################################
		t0      	RECORD LIKE gbpmt.*,
		m1     RECORD
			o1 	CHAR(1),
			d1 	CHAR(25),
			o2 	CHAR(1),
			d2 	CHAR(25),
			o3 	CHAR(1),
			d3 	CHAR(25),
			o4 	CHAR(1),
			d4 	CHAR(25)
		       END RECORD,
		i, j, k		SMALLINT,
		g_user          CHAR(3),
		g_string        CHAR(79),
		g_ancho         SMALLINT,
		g_opcion	SMALLINT,
		g_spool         CHAR(10),
		g_ctasp		INTEGER,
		g_ctass		INTEGER,
		g_ctast		INTEGER,
		g_ctasst	INTEGER,
		g_itr7		CHAR(1),	#S=Incuir tramo de 1 a 8 Dias
						#N=No incluir tramo de 1 a 8 dias 
		g_plaz          SMALLINT,
		{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}
		g_proc CHAR(8),
		g_tpmt CHAR(100),
		g_ntri INTEGER,
		{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion} 
		g_Html 		CHAR(10000),	{VAT 07/11/2009}
		# Inicio (@#)3-A
		g_miles	DECIMAL(7,2)
		# Fin (@#)3-A
		# Inicio (@#)8-A
		,
		g_mode SMALLINT,
		g_desc CHAR(200)
		# Fin (@#)8-A
		,g_flgp	SMALLINT #(@#)16-A
#(@#)22-A Inicio
		,g_efmzotipoN   CHAR(1)  -- TIPO DE MICROZONA 'N'
		,g_efmzotipoI   CHAR(1)  -- TIPO DE MICROZONA 'I'
    ,g_efparpfij150 SMALLINT -- PREFIJO 150
    ,g_efparstat1   SMALLINT -- ESTADO 1
    ,g_gbconpfij335 SMALLINT -- PREFIJO CONCEPTO 355
    ,g_gbconcorr0   SMALLINT -- CORRELATIVO CONCEPTO 0
    ,g_gbconpfij524 SMALLINT -- PREFIJO CONCEPTO 524
#(@#)22-A Fin
	
MAIN 
	IF NOT f0000_open_database_gb000() THEN EXIT PROGRAM END IF
	DEFER INTERRUPT
	OPTIONS PROMPT  LINE 23,
		ERROR   LINE 23
	SET LOCK MODE TO WAIT
	#WHENEVER ERROR CONTINUE
	LET g_user=ARG_VAL(1) 
	LET g_flgp = ARG_VAL(2) #(@#)16-A          
#(@#)22-A Inicio
	LET g_efmzotipoN = 'N'
	LET g_efmzotipoI = 'I'
	LET g_efparpfij150 = 150
  LET g_efparstat1 = 1
  LET g_gbconpfij335 = 355
  LET g_gbconpfij524 = 524
  LET g_gbconcorr0 = 0
#(@#)22-A Fin
	OPEN FORM ef052_01 FROM "ef052a"
	DISPLAY FORM ef052_01
	{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}        
	LET g_proc = 'ef052'
	CALL f8994_funcionalidad_set_explain_gb000(g_proc,g_user) #(@#)22-A
	{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion}
	IF NOT f6050_empresa_ef052() THEN
		ERROR "No existen parametros"
		EXIT PROGRAM
	END IF

	CALL f6100_cabecera_ef052()
	CALL f6200_carga_menu_ef052()
	##
	CALL f6300_carga_csuc_ef052()
#(@#)22-A Inicio
	CALL f7000_crear_temporal_ef052(1)
	CALL f7000_crear_temporal_ef052(2)
	CALL f7000_crear_temporal_ef052(3)
	CALL f7000_crear_temporal_ef052(4)
	##
	CALL prepara_querys()
	CALL f0300_proceso_ef052()
	SQL DROP TABLE IF EXISTS ef052 END SQL
	SQL DROP TABLE IF EXISTS ef052q END SQL
#(@#)22-A Fin
END MAIN

###########################
# DECLARACION DE PUNTEROS #
###########################

#(@#)22-A Inicio
FUNCTION prepara_querys()
# Descripcion: Prepara querys para ser usados durante el proceso
DEFINE l_text CHAR(1000)

  LET l_text = 'SELECT pctcrtcre FROM pctcr INTO TEMP tmp_pctcr1 WITH NO LOG;'
  PREPARE s_pctcr1 FROM l_text
  
  LET l_text = 'SELECT efmzocorr FROM tbsfi:efmzo WHERE efmzotipo = ? ',
               'INTO TEMP tmp_efmzo1 WITH NO LOG;'
  PREPARE s_efmzo1 FROM l_text
  
  LET l_text = 'SELECT efmzocorr FROM tbsfi:efmzo WHERE efmzotipo IN (?,?) ',
               'INTO TEMP tmp_efmzo2 WITH NO LOG;'
  PREPARE s_efmzo2 FROM l_text
  
  LET l_text = 'SELECT efparplaz FROM efpar WHERE efparpfij = ? AND efparstat = ? ',
               'AND efparfec1 <= ? INTO TEMP tmp_efpar1 WITH NO LOG;'
  PREPARE s_efpar1 FROM l_text
  
  LET l_text = 'SELECT gbofinofi FROM gbofi WHERE gboficemp = ? ',
               'INTO TEMP tmp_gbofi1 WITH NO LOG;'
  PREPARE s_gbofi1 FROM l_text
  
  LET l_text = 'SELECT gbconcorr FROM gbcon WHERE gbconpfij = ? AND gbconcorr <> ? ',
               'INTO TEMP tmp_gbcon1 WITH NO LOG;'
  PREPARE s_gbcon1 FROM l_text
  
  LET l_text = 'SELECT gboficemp FROM gbofi WHERE gbofinofi = ? ',
               'INTO TEMP tmp_gbofi2 WITH NO LOG;'
  PREPARE s_gbofi2 FROM l_text
END FUNCTION
#(@#)22-A Fin

FUNCTION f0200_declarar_efrd1_ef052()
	DEFINE	l_text	CHAR(1000), 
		l_text2 CHAR(1000),
		l_flag  SMALLINT,
		l_qry   CHAR(600),
		s1      CHAR(600),
		l_tges	SMALLINT, # (@#)14-A
		
		l_cobi  SMALLINT, # (@#)14-A
		l_cobf  SMALLINT, # (@#)14-A
	  l_tefe  SMALLINT	# (@#)19-A
	CALL f0251_in_usuario_agencia_gb000(g_user)
		RETURNING l_flag,l_qry

	#Inicio (@#)15-A   
	IF p1.ctpl = 1 THEN
		LET s1 = " AND efrd1age1 BETWEEN ",1, " AND ",999

		IF l_flag = 1 THEN
			LET s1 = s1 CLIPPED," AND efrd1age1 ",l_qry CLIPPED
		END IF 	
	ELSE 
	#Fin (@#)15-A    
		LET s1 = " AND efrd1agen BETWEEN ",1, " AND ",999

		IF l_flag = 1 THEN
			LET s1 = s1 CLIPPED," AND efrd1agen ",l_qry CLIPPED
		END IF 	## 
	#Inicio (@#)15-A   
	END IF
	#Fin (@#)15-A    
	
	LET l_text = "SELECT * FROM tbsfi:efrd1 WHERE  efrd1fech = '";
	IF p1.itr7 = "S" THEN
		LET l_text = l_text CLIPPED, p1.fech, "' AND efrd1plzo IN (0,1,2,3,4,5,7) "
	ELSE
		LET l_text = l_text CLIPPED, p1.fech, "' AND efrd1plzo IN (0,1,2,3,4,5) "
	END IF

	IF p1.msis <> "T" THEN
	    LET l_text = l_text CLIPPED, " AND efrd1msis = '",p1.msis,"'"
	END IF
	IF p1.cmon = 1 OR p1.cmon = 2 THEN
	    LET l_text = l_text CLIPPED, " AND efrd1cmon = ",p1.cmon USING "&"
	END IF
	IF p1.tcre <> "T" THEN
	    IF p1.tcr1 = 0 THEN
		LET l_text = l_text CLIPPED, " AND ( efrd1tcre BETWEEN ",
			     p1.tcre1 USING "<<<"," AND ",p1.tcre2 USING "<<<" 
		IF p1.tcre2 < 30 THEN
			LET l_text = l_text CLIPPED,
				     " OR efrd1tcre IN (995,996)) "
		ELSE
			LET l_text = l_text CLIPPED,")"
		END IF	
	    ELSE
		LET l_text = l_text CLIPPED, 
			     " AND efrd1tcr1 = ", p1.tcr1 USING "&"
	    END IF
	    IF p1.tcuo > 0 THEN
		LET l_text = l_text CLIPPED, " AND efrd1tcuo = ", p1.tcuo
	    END IF
	END IF
	
	{VAT Ini. Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}
	#Inicio (@#) 1-A
	IF p4.tges > 0 THEN
		CASE p4.tges
			WHEN 1		LET l_tges = 3	#ADCs
			WHEN 2		LET l_tges = 4	#P1
			WHEN 3		LET l_tges = 6	#P2
			WHEN 4		LET l_tges = 7	#P3	# CEMO (@#) 1-A
			WHEN 5		LET l_tges = 2	#Eco	(@#)8-A
		END CASE
	
		{ IF p4.tges = 1 THEN
			LET l_tges = 3		
		ELSE
			IF p4.tges = 2 THEN
				LET l_tges = 4			
			ELSE
				IF p4.tges = 3 THEN
					LET l_tges = 6				
				END IF
			END IF
		END IF }

		LET l_text = l_text CLIPPED, " AND efrd1tges = ", l_tges
# (@#)13-A Inicio	
	ELSE
		IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
			LET l_text = l_text CLIPPED, " AND efrd1tges <> 7 "  # (@#)14-A
				# Inicio (@#)14-A
				CALL f5010_obtener_rango_cobrador_ef451(7)
		     		RETURNING l_cobi,l_cobf
				LET l_text = l_text CLIPPED, " AND  efrd1cobr NOT BETWEEN ",l_cobi, " AND ",l_cobf
				# Fin (@#)14-A
		END IF
# (@#)13-A Fin		
	END IF	
	{VAT Fin Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}
	#Fin (@#) 1-A
	
	# INICIO (@#)15-A 
	IF p1.ctpl = 1 THEN
		LET l_text = l_text CLIPPED,
		     " AND efrd1age1 BETWEEN ", p1.agen1 USING "<<<",
		     " AND ", p1.agen2 USING "<<<",s1 CLIPPED
	ELSE 
	#Fin (@#)15-A   
		LET l_text = l_text CLIPPED,
		     " AND efrd1agen BETWEEN ", p1.agen1 USING "<<<",
		     " AND ", p1.agen2 USING "<<<",s1 CLIPPED
	#Inicio (@#)15-A  
	END IF
	#Fin (@#)15-A    
	
	CASE p1.tcar
	WHEN 1
	    LET l_text = l_text CLIPPED, " AND efrd1tcar <> 'A'"
	WHEN 2
	    LET l_text = l_text CLIPPED, " AND efrd1tcar = 'N'"
	WHEN 3
	    LET l_text = l_text CLIPPED, " AND efrd1tcar = 'A'"
	WHEN 4
	    LET l_text = l_text CLIPPED, " AND efrd1tcar = 'P'"
	WHEN 5
	    LET l_text = l_text CLIPPED, " AND efrd1tcar <> 'N'"
	END CASE

	CASE p1.tcas
	WHEN 1
	    LET l_text = l_text CLIPPED, " AND efrd1tcas <> 'K'"
	WHEN 2
	    LET l_text = l_text CLIPPED, " AND efrd1tcas = 'N'"
	WHEN 3
	    LET l_text = l_text CLIPPED, " AND efrd1tcas = 'K'"
	WHEN 4
	    LET l_text = l_text CLIPPED, " AND efrd1tcas = 'C'"
	WHEN 5
	    LET l_text = l_text CLIPPED, " AND efrd1tcas <> 'N'"
	END CASE
	{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
	IF p4.mcip <> 0 THEN
		IF p4.mcip = 1 THEN
			LET l_text = l_text CLIPPED, " AND efrd1mcip <> 2"
		ELSE
			LET l_text = l_text CLIPPED, " AND efrd1mcip = 2"
		END IF
	END IF
	{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}
	
	# Inicio (@#)4-A
	#IF p4.cart = 1 OR p4.cart = 2 THEN																																													# (@#)19-A
	IF p4.cart <> 0 THEN																																																				# (@#)19-A
		#LET l_text = l_text CLIPPED, " AND efrd1cred = ",p4.cart																																	# (@#)19-A
#(@#)22-A Inicio
		SQL DROP TABLE IF EXISTS tmp_pctcr1 END SQL
		EXECUTE s_pctcr1
#		LET l_text = l_text CLIPPED, " AND efrd1tcre IN(SELECT pctcrtcre FROM pctcr WHERE pctcrcred = ",p4.cart,")"								# (@#)19-A
    LET l_text = l_text CLIPPED, " AND efrd1tcre IN(SELECT pctcrtcre FROM tmp_pctcr1 WHERE pctcrcred = ",p4.cart,")"
#(@#)22-A Fin
		# (@#)14-A - Inicio
		IF p4.cart = 5 THEN 						
			IF p4.tefe <> 0 THEN
				  CASE p4.tefe
				  	WHEN 1
				  				LET l_tefe = 2
				  	WHEN 2
				  				LET l_tefe = 3
				  END CASE
					LET l_text = l_text CLIPPED, " AND efrd1tlin = ",l_tefe
			END IF
		END IF
		# (@#)14-A - Fin
	END IF
	
	# Fin (@#)4-A
	#inicio (@#)11-A
	IF p1.microz <> "D" THEN
		IF p1.microz <> "T" THEN
#(@#)22-A Inicio
		  SQL DROP TABLE IF EXISTS tmp_efmzo1 END SQL
		  EXECUTE s_efmzo1 USING p1.microz
#			LET l_text = l_text CLIPPED,"  and efrd1micr in (select efmzocorr from tbsfi:efmzo where efmzotipo = '",p1.microz CLIPPED,"') "
      LET l_text = l_text CLIPPED,"  and efrd1micr in (select efmzocorr from tmp_efmzo1) "
#(@#)22-A Fin
		END IF
	ELSE
#(@#)22-A Inicio
	  SQL DROP TABLE IF EXISTS tmp_efmzo2 END SQL
	  EXECUTE s_efmzo2 USING g_efmzotipoN,g_efmzotipoI
#		LET l_text = l_text CLIPPED," and efrd1micr not in (select efmzocorr from tbsfi:efmzo where efmzotipo in ('N','I'))"
		LET l_text = l_text CLIPPED," and efrd1micr not in (select efmzocorr from tmp_efmzo2))"
#(@#)22-A Fin
	END IF
	#fin (@#)11-A
	# Inicio (@#)5-A
	IF p4.diap > 0 THEN
		CASE p4.diap
			WHEN 1
				LET l_text = l_text CLIPPED, " AND efrd1diap BETWEEN 0 AND 4 "
			WHEN 5
				LET l_text = l_text CLIPPED, " AND efrd1diap BETWEEN ",p4.diap, "AND 9 "
			WHEN 10
				LET l_text = l_text CLIPPED, " AND efrd1diap BETWEEN ",p4.diap, "AND 14 "
			WHEN 15
				LET l_text = l_text CLIPPED, " AND efrd1diap BETWEEN ",p4.diap, "AND 19 "
			WHEN 20
				LET l_text = l_text CLIPPED, " AND efrd1diap BETWEEN ",p4.diap, "AND 24 "
			WHEN 25
				LET l_text = l_text CLIPPED, " AND efrd1diap >= ",p4.diap
		END CASE
	END IF
	# Fin (@#)5-A
	# Inicio (@#)8-A
	#Inicio (@#)15-A   
#(@#)22-A Inicio
  SQL DROP TABLE IF EXISTS tmp_efpar1 END SQL
  EXECUTE s_efpar1 USING g_efparpfij150,g_efparstat1,p1.fech
#(@#)22-A Fin
	IF p1.ctpl = 1 THEN
		IF g_mode <> 0 THEN
			IF g_mode = 1 THEN
#(@#)22-A Inicio
#  			   LET l_text = l_text CLIPPED, " AND efrd1agen NOT IN (SELECT efparplaz FROM efpar WHERE efparpfij = 150 AND efparstat = 1 AND efparfec1 <= '", p1.fech USING "dd/mm/yyyy", "') "				
  			   LET l_text = l_text CLIPPED, " AND efrd1agen NOT IN (SELECT efparplaz FROM tmp_efpar1) "
#(@#)22-A Fin
			END IF
			IF g_mode = 2 THEN
#(@#)22-A Inicio
#			   LET l_text = l_text CLIPPED, " AND efrd1agen IN (SELECT efparplaz FROM efpar WHERE efparpfij = 150 AND efparstat = 1 AND efparfec1 <= '", p1.fech USING "dd/mm/yyyy", "') "
         LET l_text = l_text CLIPPED, " AND efrd1agen IN (SELECT efparplaz FROM tmp_efpar1) "
#(@#)22-A Fin
			END IF
		END IF
	ELSE
	#Fin (@#)15-A    
		IF g_mode <> 0 THEN
			IF g_mode = 1 THEN
#(@#)22-A Inicio
#				LET l_text = l_text CLIPPED, " AND efrd1agen NOT IN (SELECT efparplaz FROM efpar WHERE efparpfij = 150 AND efparstat = 1 AND efparfec1 <= '", p1.fech USING "dd/mm/yyyy", "') "
				LET l_text = l_text CLIPPED, " AND efrd1agen NOT IN (SELECT efparplaz FROM tmp_efpar1) "
#(@#)22-A Fin
			END IF
			IF g_mode = 2 THEN
#(@#)22-A Inicio
#				LET l_text = l_text CLIPPED, " AND efrd1agen IN (SELECT efparplaz FROM efpar WHERE efparpfij = 150 AND efparstat = 1 AND efparfec1 <= '", p1.fech USING "dd/mm/yyyy", "') "
				LET l_text = l_text CLIPPED, " AND efrd1agen IN (SELECT efparplaz FROM tmp_efpar1) "
#(@#)22-A Fin
			END IF
		END IF
	#Inicio (@#)15-A   
	END IF
	#Fin (@#)15-A    
	# Fin (@#)8-A
	# INICIO (@#)15-A 
  IF(p1.crtl<>0)THEN
#(@#)22-A Inicio
    SQL DROP TABLE IF EXISTS tmp_gbofi1 END SQL
    EXECUTE s_gbofi1 USING p1.crtl
#(@#)22-A Fin
    IF p1.ctpl = 1 THEN  
      # (@#)20-A - Inicio
      IF p1.crtl = 2 OR p1.crtl = 8 THEN
#(@#)22-A Inicio
        SQL DROP TABLE IF EXISTS tmp_gbcon1 END SQL
        EXECUTE s_gbcon1 USING g_gbconpfij335,g_gbconcorr0
#(@#)22-A Fin
        IF p1.crtl = 2 THEN
#(@#)22-A Inicio
#        	LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from gbofi where gboficemp =",p1.crtl,")"
        	LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from tmp_gbofi)"
#        	LET l_text = l_text CLIPPED, " AND efrd1age1 NOT IN (select gbconcorr from gbcon where gbconpfij = 335 and gbconcorr <> 0)"
          LET l_text = l_text CLIPPED, " AND efrd1age1 NOT IN (select gbconcorr from tmp_gbcon)"
#(@#)22-A Fin
        ELSE
#(@#)22-A Inicio
#        	LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from gbofi where gboficemp =",p1.crtl," UNION select gbconcorr from gbcon where gbconpfij = 335 and gbconcorr <> 0)"
          LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from tmp_gbofi UNION select gbconcorr from tmp_gbcon)"
#(@#)22-A Fin
        END IF
      ELSE
      # (@#)20-A - Fin	
#(@#)22-A Inicio
#      	LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from gbofi where gboficemp =",p1.crtl,")"
      	LET l_text = l_text CLIPPED, " AND efrd1age1 IN (select gbofinofi from tmp_gbofi)"
#(@#)22-A Fin
      END IF	 # (@#)20-A 			   	
    ELSE
#(@#)22-A Inicio
#      LET l_text = l_text CLIPPED, " AND efrd1agen IN (select gbofinofi from gbofi where gboficemp =",p1.crtl,")"
      LET l_text = l_text CLIPPED, " AND efrd1agen IN (select gbofinofi from tmp_gbofi)"
#(@#)22-A Fin
    END IF
  END IF
	LET l_text2 = l_text CLIPPED, " ORDER BY efrd1agen,efrd1plzo,efrd1tpro,efrd1age1"
	#LET l_text2 = l_text CLIPPED, " ORDER BY efrd1agen,efrd1plzo,efrd1tpro"
	# FIN (@#)15-A 
	PREPARE l_curs22 FROM l_text2
	DECLARE q_cur222 CURSOR FOR l_curs22

	IF p1.itr7="S" THEN
	   LET l_text=l_text CLIPPED ," INTO TEMP ef052xq WITH NO LOG"
	   PREPARE q_falso FROM l_text
	   EXECUTE q_falso 
	   CALL MueveParaReporte2()
	   LET l_text=" select * from ef052xq "
	END IF

	LET l_text = l_text CLIPPED, 
		# inicio (@#)15-A  
		     #" ORDER BY efrd1agen,efrd1plzo,efrd1tpro"
		     " ORDER BY efrd1agen,efrd1plzo,efrd1tpro,efrd1age1"
		# fin (@#)15-A  

	PREPARE l_curs FROM l_text
	DECLARE q_cur1 CURSOR FOR l_curs
  
END FUNCTION

FUNCTION f0250_declarar_puntero_ef052()
	#INICIO (@#)15-A 
	DEFINE	r	RECORD
			  fech		DATE,
			  csuc		SMALLINT,
			  agen		SMALLINT,
			  plzo		SMALLINT,
			  plza		SMALLINT, 
			  tpro		INTEGER,
			  gpro		INTEGER,
			  impt		DECIMAL(14,2),
			  numc		INTEGER
			END RECORD,
		l_txt CHAR (500)
		
		#DECLARE q_curs CURSOR FOR
		#	#SELECT MAX(fech),csuc,agen,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc) 	# (@#)6-A
		#	#SELECT efzcbczon,MAX(fech),csuc,agen,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc) 	# (@#)6-A
		#	SELECT MAX(fech),csuc,agen,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc) 	# (@#)6-A		# (@#)7-A
		#	  #FROM ef052			# (@#)6-A
		#	  #FROM ef052,tmp_efzcb		# (@#)6-A			# (@#)7-A
		#	  FROM ef052		# (@#)6-A			# (@#)7-A
		#	 WHERE csuc <> 98
		#	 #  AND agen = efzcbplaz		# (@#)6-A	# (@#)7-A
		#	 #GROUP BY csuc, agen, plzo	# (@#)6-A
		#	 #ORDER BY csuc, agen, plzo	# (@#)6-A
		#	 #GROUP BY efzcbczon,csuc, agen, plzo	# (@#)6-A			# (@#)7-A
		#	 GROUP BY csuc, agen, plzo	# (@#)6-A							# (@#)7-A
		#	 #ORDER BY efzcbczon,csuc, agen, plzo	# (@#)6-A			# (@#)7-A
		#	 ORDER BY csuc, agen, plzo	# (@#)6-A								# (@#)7-A
		#	 #agregado por mi  
		
		IF p1.ctpl =1 THEN  
			LET l_txt = " SELECT MAX(fech),csuc,agen||plza,agen,plzo,plza,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc)", 
			    " FROM ef052",
			    " WHERE csuc <> 98", 
			    " GROUP BY csuc, agen, plzo,plza",
			    " ORDER BY csuc, 3,agen, plzo, plza"				                	    
		ELSE
			LET l_txt = " SELECT MAX(fech),csuc,0,agen,plzo,0,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc)", 
			    " FROM ef052",
			    " WHERE csuc <> 98", 										
			    " GROUP BY csuc, agen, plzo,4",                                                                     
			    " ORDER BY csuc, agen, plzo"					                                
		END IF                                                                                                          
			                                                                                                        
		PREPARE p_txt FROM l_txt                                                                                        
		DECLARE q_curs CURSOR FOR p_txt			                                                                
				                                                                                                
                                                                                                                                
	#FIN (@#)15-A                                                                                                          
	DECLARE q_curs2 CURSOR FOR                                                                                              
		#SELECT *				# (@#)6-A                                                               
		#SELECT efzcbczon,ef.*			# (@#)6-A			# (@#)7-A                               
		SELECT *			# (@#)6-A			# (@#)7-A
		  #FROM ef052b				# (@#)6-A
		  #FROM ef052b ef,tmp_efzcb		# (@#)6-A		# (@#)7-A
		  FROM ef052b		# (@#)6-A		# (@#)7-A
		 WHERE csuc <> 98
		   AND agen IN (60,61,66)
		   AND plzo NOT IN (6)	
		   #AND agen = efzcbplaz		# (@#)6-A			# (@#)7-A
		 #ORDER BY csuc, agen, gpro,tpro,plzo	# (@#)6-A
		 #ORDER BY efzcbczon,csuc, agen, gpro,tpro,plzo	# (@#)6-A		# (@#)7-A
		 ORDER BY csuc, agen, gpro,tpro,plzo	# (@#)6-A		# (@#)7-A
END FUNCTION

###################
# PROCESO CENTRAL #
###################

FUNCTION f0300_proceso_ef052()
	OPTIONS INPUT WRAP
	LET g_spool = "ef052.r"
	WHILE TRUE
		CALL f6000_limpiar_campos_ef052()
		INPUT BY NAME m1.* WITHOUT DEFAULTS
		        #(@#)16-A Inicio
			BEFORE INPUT
        			IF g_flgp = 1 THEN
        				CALL f0310_proceso_automatico_ef052()	
        			END IF
        		#(@#)16-A Fin	
			ON KEY (CONTROL-M)
				IF INFIELD(o1) THEN
				    IF f0400_pedir_datos_ef052() THEN
					CALL f7100_genera_archivo_ef052()
					{VAT Ini 06/11/2009 Pasar Reportes a Excel}
					MESSAGE "Generando Reporte... un momento por favor!!!"
					CALL f0420_pedir_formato_reporte_ef052()					
					IF p5.tform = 1 THEN 
					#INICIO (@#)15-A   	
						IF p1.ctpl =1 THEN
							CALL f1000_impreso_b_ef052()
						ELSE 
					#FIN (@#)15-A  
							CALL f1000_impreso_ef052()
					#INICIO (@#)15-A  
						END IF
					#FIN (@#)15-A  
					ELSE
					#INICIO (@#)15-A  
						IF p1.ctpl =1 THEN
#(@#)22-A Inicio
						  LET g_spool = "ef052.xls"
						  START REPORT imprime_rep_detallado TO g_spool 
							CALL f1100_proceso_impr_excel_b_ef052()
#(@#)22-A Fin
              FINISH REPORT imprime_rep_detallado #(@#)22-A
						ELSE 
					#FIN (@#)15-A  
#(@#)22-A Inicio
					    LET g_spool = "ef052.xls"
					    START REPORT imprime_rep_detallado TO g_spool 
#(@#)22-A Fin
							  CALL f1100_proceso_impr_excel_ef052()
							FINISH REPORT imprime_rep_detallado #(@#)22-A
					#INICIO (@#)15-A  	
						END IF
					#FIN (@#)15-A  
					END IF
					{VAT Fin 06/11/2009 Pasar Reportes a Excel}
					#CALL f1000_impreso_ef052()
					MESSAGE " "
					{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}
					CALL f9100_inserta_log_ini_fin_ef052('0701',t0.gbpmtplaz,p1.fech,'F','I')
					{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion}
					CALL f0100_imprimir_gb001(g_spool)
					CALL f1010_impreso_sismo_ef052()
					MESSAGE " "
					{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}
					CALL f9100_inserta_log_ini_fin_ef052('0702',t0.gbpmtplaz,p1.fech,'F','I')
					{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion}
					CALL f0100_imprimir_gb001(g_spool)
					{VAT Ini. 09/09/2009 - Se borra Temp ef052xq}
					IF p1.itr7="S" THEN
						DROP TABLE ef052xq	
					END IF
					{VAT Fin 09/09/2009 - Se borra Temp ef052xq}
				    END IF
				    NEXT FIELD o1   
				END IF
				IF INFIELD(o2) THEN
				    ERROR "Opcion NO Disponible"
				    NEXT FIELD o2   
				END IF
				IF INFIELD(o3) THEN
				    CALL f0100_imprimir_gb001(g_spool)
				    NEXT FIELD o3   
				END IF
				IF INFIELD(o4) THEN
				    EXIT WHILE
				END IF
			BEFORE FIELD o1
				DISPLAY m1.d1 TO d1 ATTRIBUTE(REVERSE)
				LET m1.o1 = "*"
			AFTER FIELD o1
				INITIALIZE m1.o1 TO NULL
				DISPLAY m1.d1 TO d1 ATTRIBUTE(NORMAL)
				DISPLAY m1.o1 TO o1
			BEFORE FIELD o2
				DISPLAY m1.d2 TO d2 ATTRIBUTE(REVERSE)
				LET m1.o2 ="*"
			AFTER FIELD o2
				INITIALIZE m1.o2 TO NULL
				DISPLAY m1.d2 TO d2 ATTRIBUTE(NORMAL)
				DISPLAY m1.o2 TO o2
			BEFORE FIELD o3
				DISPLAY m1.d3 TO d3 ATTRIBUTE(REVERSE)
				LET m1.o3 = "*"
				AFTER FIELD o3
				INITIALIZE m1.o3 TO NULL
				DISPLAY m1.d3 TO d3 ATTRIBUTE(NORMAL)
				DISPLAY m1.o3 TO o3
			BEFORE FIELD o4
				DISPLAY m1.d4 TO d4 ATTRIBUTE(REVERSE)
				LET m1.o4 = "*"
			AFTER FIELD o4
				INITIALIZE m1.o4 TO NULL
				DISPLAY m1.d4 TO d4 ATTRIBUTE(NORMAL)
				DISPLAY m1.o4 TO o4
		END INPUT
		IF int_flag THEN
			LET int_flag = FALSE
			CONTINUE WHILE
		END IF
	END WHILE
END FUNCTION

#(@#)16-A Inicio
FUNCTION f0310_proceso_automatico_ef052()
DEFINE  l_mes	CHAR(500),
	l_ntri	INTEGER
	
	LET p1.msis = "T"
	LET p1.tfilt = "P"
	LET p1.agen1 = 1
	LET p1.agen2 = 999
	LET p1.cmon = 3
	LET p1.fech = TODAY - 1
	LET p1.tcre = "P"
	LET p1.tcr1 = 0
	LET p1.tcre1 = 1
	LET p1.tcre2 = 29
	LET p1.tcuo = 0
	LET p4.tges = 0	
	LET p4.trep = 1
	LET p4.mcip = 0
	LET p4.cart = 0
	LET p4.diap = 0
	LET p1.tdat = "T"
	LET p1.tcar = 1
	LET p1.tcas = 1
	LET p1.microz = "T"
	LET p1.ctap = "N"
	LET p1.itr7 = "N"
	LET g_mode = 2
	LET g_desc = "MODELO COBRANZA 2012"
	LET p5.tform = 2
	
	DISPLAY BY NAME p1.msis
	DISPLAY BY NAME p1.agen1
	DISPLAY BY NAME p1.agen2
	DISPLAY BY NAME p1.cmon 
	DISPLAY BY NAME p1.fech 
	DISPLAY BY NAME p1.tcre 
	DISPLAY BY NAME p1.tcr1 
	DISPLAY BY NAME p1.tcre1
	DISPLAY BY NAME p1.tcre2
	DISPLAY BY NAME p1.tcuo 
	DISPLAY BY NAME p1.tdat
	DISPLAY BY NAME p1.tcar
	DISPLAY BY NAME p1.tcas
	DISPLAY BY NAME p1.microz
	DISPLAY BY NAME p1.ctap
	DISPLAY BY NAME p1.itr7
	
	SELECT gbhtctcof INTO g_tcam
		FROM gbhtc
	WHERE gbhtcfech = p1.fech
	IF status = NOTFOUND THEN 
	    LET g_tcam = t0.gbpmttcof 
	END IF
	
	IF NOT f6402_llenar_temp_efzcb_ef052() THEN
		ERROR "TEMPORALES NO CREADAS"
	END IF
	
	CALL f1100_insert_log_ini_fin_ef451(g_proc,'0400',0,p1.fech,'I','I','INICIO DE PROCESO',g_user,0)
		RETURNING l_ntri
		
	{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}        
	LET g_tpmt = p1.msis CLIPPED,"-",p1.cmon USING "&","-",p1.tcre CLIPPED,"-",
	p1.tcr1 USING "&&&","-",p1.tcre1 USING "&&&","-",p1.tcre2 USING "&&&","-",p1.tcuo USING "&","-",p1.tdat CLIPPED,"-",
	p1.tcar USING "&&&","-",p1.tcas USING "&","-",p1.ctap CLIPPED,"-",p1.itr7 CLIPPED,"-",
	p4.tges USING "&","-",p4.trep USING "&","-",p4.mcip USING "&"," - ",p4.cart USING "&"
	CALL f9100_inserta_log_ini_fin_ef052('0701',t0.gbpmtplaz,p1.fech,'I','I')
	CALL f9100_inserta_log_ini_fin_ef052('0702',t0.gbpmtplaz,p1.fech,'I','I')
	CALL f0250_declarar_puntero_ef052()
	MESSAGE "Procesando... un momento por favor!!!"
	CALL f6400_carga_limites_ef052()
	
	CALL f7100_genera_archivo_ef052()
	{VAT Ini 06/11/2009 Pasar Reportes a Excel}
	MESSAGE "Generando Reporte... un momento por favor!!!"
#(@#)22-A Inicio
	LET g_spool = "ef052.xls"
	START REPORT imprime_rep_detallado TO g_spool
#(@#)22-A Fin
	  CALL f1100_proceso_impr_excel_ef052()
	FINISH REPORT imprime_rep_detallado #(@#)22-A
	MESSAGE ""
	
	CALL f9100_inserta_log_ini_fin_ef052('0701',t0.gbpmtplaz,p1.fech,'F','I')
	CALL f9100_inserta_log_ini_fin_ef052('0702',t0.gbpmtplaz,p1.fech,'F','I')
	
	CALL f1100_insert_log_ini_fin_ef451(g_proc,'0400',0,p1.fech,'F','I','FIN DE PROCESO',g_user,l_ntri)
		RETURNING l_ntri
	CALL f1120_procesar_mensaje_ef052() RETURNING l_mes

	CALL f1314_enviar_correos_ef451(l_mes,g_spool,t0.gbpmtnemp,"modCobranza","Consolidado de Atraso de Cobranza por Etapas")
	EXIT PROGRAM
END FUNCTION
#(@#)16-A Fin

FUNCTION f0400_pedir_datos_ef052()
	# Inicio (@#)8-A
	#DEFINE l_flag SMALLINT        OPTIONS INPUT NO WRAP
	DEFINE l_flag SMALLINT,
		l_fec1 DATE,
		#inicio (@#)15-A 
		l_drtl  char(50),
		l_dtpl  char(50),
		l_fech	DATE	
		#fin (@#)15-A 
	OPTIONS INPUT NO WRAP
	# Fin (@#)8-A
	INPUT BY NAME p1.msis THROUGH p1.itr7 WITHOUT DEFAULTS
		ON KEY (INTERRUPT,CONTROL-C)
			LET int_flag = TRUE
			EXIT INPUT
		ON KEY (CONTROL-V)
			IF INFIELD (tcar) THEN
			    LET p1.tcar = f0450_selec_tcar_ef052()
			    DISPLAY BY NAME p1.tcar
			END IF
			#inicio (@#)15-A 
			IF INFIELD (crtl) THEN
			   CALL f0200_selec_cursor_gb900(124, 524) RETURNING p1.crtl,l_drtl
			   DISPLAY BY NAME p1.crtl
			END IF
			#fin (@#)15-A 
		{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
		ON KEY (CONTROL-O)
			IF p1.fech IS NULL THEN
				ERROR "Inf: Primero debe llenar este campo de fecha de Reporte"
				NEXT FIELD fech
			END IF
			IF NOT f0410_pedir_datos_aux_ef052() THEN
				NEXT FIELD fech
			END IF
		{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}
		BEFORE INPUT			
			MESSAGE "<CONTROL-O> Pedir Datos Auxiliares"
		AFTER FIELD msis
			IF p1.msis IS NULL THEN
			    NEXT FIELD msis
			END IF
			CALL f9000_pedir_filtro_plaz_gb000
				(p1.tfilt,p1.agen1,p1.agen2,1)
			    RETURNING l_flag,p1.tfilt,p1.agen1,p1.agen2
			IF NOT l_flag THEN
			    NEXT FIELD msis
			END IF
		# INICIO (@#)15-A 
		BEFORE FIELD crtl
        		MESSAGE " Seleccione Tipo de Retail ... (CONTROL-V) "
		AFTER FIELD crtl
			MESSAGE ""
			IF p1.crtl IS NULL THEN
			    NEXT FIELD crtl
			ELSE
			   IF (p1.crtl<>0)THEN
			      CALL f0412_obtener_descripcion_ef052(p1.crtl,524) 
			          RETURNING  l_drtl
			          
			      IF l_drtl IS NULL THEN
			         ERROR "NO EXISTE .. (CONTROL-V)"
			         LET p1.crtl=NULL
			         DISPLAY BY NAME p1.crtl
			         NEXT FIELD crtl
			      ELSE
			         DISPLAY BY NAME p1.crtl
			         LET l_drtl=NULL
			         NEXT FIELD cmon
			      END IF
			   END IF
			END IF
			
        	# FIN (@#)15-A 
		
		AFTER FIELD fech
			IF p1.fech IS NULL THEN
			    LET p1.fech = t0.gbpmtfdia - 1
			    DISPLAY BY NAME p1.fech
			END IF
			SELECT gbhtctcof INTO g_tcam
			    FROM gbhtc
			    WHERE gbhtcfech = p1.fech
			IF status = NOTFOUND THEN 
			    LET g_tcam = t0.gbpmttcof 
			END IF
			# Inicio (@#)5-A
			# Se comenta llamado a esta rutina porque se necesita el tipo de cuota
			{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
			{
				IF NOT f0410_pedir_datos_aux_ef052() THEN
					NEXT FIELD fech
				END IF
			}
			{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}
			# Fin (@#)5-A
			
			# Inicio (@#)8-A
			## Inicio (@#)6-A
			#DELETE FROM tmp_efzcb
			###
			#INSERT INTO tmp_efzcb
			#SELECT efzcbczon,efzcbdzon,efzcbcsuc,efzcbdsuc,efzcbplaz
			#  FROM tbsfi:efzcb
			# WHERE p1.fech BETWEEN efzcbfini AND efzcbffin
			###
			#IF NOT f5090_valida_efzcb_ef052(p1.fech) THEN
			#    LET int_flag = TRUE
			#    EXIT INPUT
			#END IF
			## Inicio (@#)7-A
			#INSERT INTO tmp_efzcb VALUES(0,0,0,0,50)
			#INSERT INTO tmp_efzcb VALUES(0,0,0,0,88)
			## Fin (@#)7-A			
			#
			## Fin (@#)6-A
			# Fin (@#)8-A
		# inicio (@#)15-A 
		BEFORE FIELD ctpl
		             IF p1.ctpl IS NULL THEN 
		                LET p1.ctpl = 2
		             END IF 
		AFTER FIELD ctpl
			IF p1.ctpl IS NULL THEN
			    NEXT FIELD ctpl
			ELSE			
			    IF p1.ctpl = 1 THEN
			         SELECT efparfec1   
				   INTO l_fech       
				   FROM efpar
				  WHERE efparpfij = 604
				    AND efparstat = 1
				     
			            IF STATUS = NOTFOUND THEN
			               LET l_fech = '01/08/2013'
			            END IF 
			           
			      	 IF(l_fech<=p1.fech) THEN
			      		DISPLAY BY NAME p1.ctpl
			         ELSE
			      		ERROR "**Fecha ingresada supera a fecha de corte (",l_fech,")"	
			      		NEXT FIELD ctpl			        	
			      	END IF	
			      	NEXT FIELD tcre
			   END IF
			END IF
		# fin (@#)15-A 
		AFTER FIELD tcre
			IF p1.tcre IS NULL THEN
			    NEXT FIELD tcre
			END IF
			IF p1.tcre = "T" THEN
			    LET p1.tcr1 = 0
			    LET p1.tcuo = 0
			    INITIALIZE p1.tcre1,p1.tcre2 TO NULL
			    DISPLAY BY NAME p1.tcr1,p1.tcuo
			    NEXT FIELD agen1
			END IF
		AFTER FIELD tcr1
			IF p1.tcr1 IS NULL THEN
			    NEXT FIELD tcr1
			END IF
			IF p1.tcr1 > 0 THEN
			    INITIALIZE p1.tcre1,p1.tcre2 TO NULL
			    DISPLAY BY NAME p1.tcre1,p1.tcre2
			    NEXT FIELD tcuo
			END IF
		AFTER FIELD tcre1
			IF p1.tcre1 IS NULL THEN
			    LET p1.tcre1 = 1
			    DISPLAY BY NAME p1.tcre1
			END IF
		AFTER FIELD tcre2
			IF p1.tcre2 IS NULL THEN
			    LET p1.tcre2 = 999
			    DISPLAY BY NAME p1.tcre2
			END IF
		AFTER FIELD agen1
			#(@#)15-A  - Inicio 
			#IF p1.agen1 IS NULL THEN
			IF p1.agen1 IS NULL OR p1.agen1 = 0 THEN
			#(@#)15-A  - Fin
			    LET p1.agen1 = 1
			    DISPLAY BY NAME p1.agen1
			END IF
		AFTER FIELD agen2
			IF p1.agen2 IS NULL THEN
			    LET p1.agen2 = 999
			    DISPLAY BY NAME p1.agen2
			END IF
			# Inicio (@#)5-A
				IF NOT f0410_pedir_datos_aux_ef052() THEN
					NEXT FIELD fech
				END IF
			# Fin (@#)5-A
		AFTER FIELD tdat
			IF p1.tdat IS NULL THEN
			    NEXT FIELD tdat
			END IF
		BEFORE FIELD tcar
			LET p1.tcar = f0450_selec_tcar_ef052()
		AFTER FIELD tcar
			IF p1.tcar IS NULL THEN
			    NEXT FIELD tcar
			END IF
			IF p1.tcar < 0 OR p1.tcar > 5 THEN
			    NEXT FIELD tcar
			END IF
		BEFORE FIELD tcas
			LET p1.tcas = f0450_selec_tcas_ef052()
		AFTER FIELD tcas
			IF p1.tcas IS NULL THEN
			    NEXT FIELD tcas
			END IF
			IF p1.tcas < 0 OR p1.tcas > 5 THEN
			    NEXT FIELD tcas
			END IF
		#inicio (@#)11-A
		AFTER FIELD microz
			IF p1.microz IS NULL THEN
				NEXT FIELD microz
			END IF	
		#fin (@#)11-A
		AFTER INPUT
			# Inicio (@#)8-A
			## DETERMINAR MODELO POR DEFECTO
			SELECT efparfec1
			  INTO l_fec1
			  FROM efpar
			 WHERE efparpfij = 177
			IF status = NOTFOUND THEN
				NEXT FIELD msis
			END IF
			IF p1.fech > l_fec1 THEN
				LET g_mode = 2
			ELSE
				LET g_mode = 1
			END IF
			IF g_mode IS NOT NULL THEN
				SELECT gbcondesc
				  INTO g_desc
				  FROM gbcon
				 #WHERE gbconpfij = 270		# (@#)9-A
				 WHERE gbconpfij = 278		# (@#)9-A
				   AND gbconcorr = g_mode
			END IF

			## SOLICITUD DE MODELO
			IF NOT f6401_solicitud_modelo_cobranza_ef052() THEN
				NEXT FIELD msis
			END IF
			
			## CREAR TABLA TEMPORALES
			IF NOT f6402_llenar_temp_efzcb_ef052() THEN
				NEXT FIELD msis
			END IF
			# Fin (@#)8-A
			IF p1.tcre1 > p1.tcre2 THEN
			    ERROR "Rango de Tipos de Credito Incorrecto"
			    NEXT FIELD tcre1
			END IF
			IF p1.agen1 > p1.agen2 THEN
			    ERROR "Rango de Agencias Incorrecto"
			    NEXT FIELD agen1
			END IF
		AFTER FIELD ctap
			IF p1.ctap IS NULL THEN
			    NEXT FIELD ctap
			END IF
	END INPUT
	OPTIONS INPUT WRAP
	IF int_flag THEN
		LET int_flag = FALSE
		RETURN FALSE
	END IF
	{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}        
	LET g_tpmt = p1.msis CLIPPED,"-",p1.cmon USING "&","-",p1.tcre CLIPPED,"-",
	p1.tcr1 USING "&&&","-",p1.tcre1 USING "&&&","-",p1.tcre2 USING "&&&","-",p1.tcuo USING "&","-",p1.tdat CLIPPED,"-",
	p1.tcar USING "&&&","-",p1.tcas USING "&","-",p1.ctap CLIPPED,"-",p1.itr7 CLIPPED,"-",
	# Inicio (@#)4-A
	#p4.tges USING "&","-",p4.trep USING "&","-",p4.mcip USING "&"
	p4.tges USING "&","-",p4.trep USING "&","-",p4.mcip USING "&"," - ",p4.cart USING "&"
	# Fin (@#)4-A
	CALL f9100_inserta_log_ini_fin_ef052('0701',t0.gbpmtplaz,p1.fech,'I','I')
	CALL f9100_inserta_log_ini_fin_ef052('0702',t0.gbpmtplaz,p1.fech,'I','I')
	{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion}
	CALL f0250_declarar_puntero_ef052()
	MESSAGE "Procesando... un momento por favor!!!"
	CALL f6400_carga_limites_ef052()
	RETURN TRUE
END FUNCTION

# Inicio (@#)8-A
FUNCTION f6401_solicitud_modelo_cobranza_ef052()
	DEFINE l_rpta SMALLINT
	OPEN WINDOW wtsolmod AT  12,37 WITH FORM "ef052l" ATTRIBUTE (FORM LINE 1, MESSAGE LINE LAST)
	DISPLAY BY NAME g_mode, g_desc
	WHILE TRUE
		INPUT BY NAME g_mode WITHOUT DEFAULTS
			ON KEY (INTERRUPT,CONTROL-C)
				LET INT_FLAG=TRUE
				LET l_rpta = FALSE
				EXIT INPUT
			# Inicio (@#)9-A
			{
			ON KEY (ACCEPT)
				LET INT_FLAG=TRUE
				LET l_rpta = TRUE
				EXIT INPUT
			ON KEY (CONTROL-V)
				IF INFIELD (g_mode) THEN
					CALL f0200_selec_cursor_gb900(124, 270) RETURNING g_mode, g_desc
					DISPLAY BY NAME g_mode, g_desc
				END IF
			}
			
			BEFORE FIELD g_mode
				ERROR " Digite: (0) Total / (1) Modelo 2008 / (2) Modelo 2012"
			# Fin (@#)9-A
			AFTER FIELD g_mode
				IF g_mode IS NOT NULL THEN
					SELECT gbcondesc
					  INTO g_desc
					  FROM gbcon
					 #WHERE gbconpfij = 270		# (@#)9-A
					 WHERE gbconpfij = 278		# (@#)9-A
					   AND gbconcorr = g_mode
					IF status = NOTFOUND THEN
						NEXT FIELD g_mode
					END IF
				END IF

				DISPLAY BY NAME g_desc

				LET l_rpta = TRUE
				EXIT INPUT
			AFTER INPUT
				{IF g_mode = 0 THEN
					NEXT FIELD g_mode
				END IF
				}
				IF g_desc IS NULL THEN
					NEXT FIELD g_mode
				END IF
				LET l_rpta = TRUE
				EXIT INPUT
		END INPUT
		#IF INT_FLAG THEN	# (@#)9-A
		IF l_rpta THEN
			LET INT_FLAG = FALSE
			EXIT WHILE
		END IF
	END WHILE
	CLOSE WINDOW wtsolmod
	RETURN l_rpta
END FUNCTION

FUNCTION f6402_llenar_temp_efzcb_ef052()
	DEFINE
		l_text	CHAR(1000)

#(@#)22-A Inicio
#	DELETE FROM tmp_efzcb
  CALL f7000_crear_temporal_ef052(5)
#(@#)22-A Fin
	# Inicio (@#)9-A
	{
	INSERT INTO tmp_efzcb
	SELECT efzcbczon,efzcbdzon,efzcbcsuc,efzcbdsuc,efzcbplaz
	  FROM tbsfi:efzcb
	 WHERE p1.fech BETWEEN efzcbfini AND efzcbffin
	   AND efzcbmode = g_mode
	}

	LET l_text = 
	" INSERT INTO tmp_efzcb ",
	" SELECT efzcbczon,efzcbdzon,efzcbcsuc,efzcbdsuc,efzcbplaz ",
	"  FROM tbsfi:efzcb ",
	" WHERE '",p1.fech,"' BETWEEN efzcbfini AND efzcbffin"
	IF g_mode <> 0 THEN
		#LET l_text = l_text CLIPPED, " AND efzcbmode = ",g_mode # (@#)21-A
		LET l_text = l_text CLIPPED, " AND efzcbmode = ",g_mode," AND efzcbstat = 1 " # (@#)21-A
	ELSE
		LET l_text = l_text CLIPPED, " AND efzcbstat = 1"
	END IF
	
	PREPARE q_1 FROM l_text
	EXECUTE q_1
	
	IF STATUS < 0 THEN
		ERROR "No se pudo insertar en tmp_efzcb"
		RETURN FALSE
	END IF
	# Fin (@#)9-A
	IF NOT f5090_valida_efzcb_ef052(p1.fech) THEN
		RETURN FALSE
	END IF
	INSERT INTO tmp_efzcb VALUES(0,0,0,0,50)
	INSERT INTO tmp_efzcb VALUES(0,0,0,0,88)
	RETURN TRUE
END FUNCTION
# Fin (@#)8-A

{VAT Ini 06/11/2009 Pasar Reportes a Excel}
FUNCTION f0420_pedir_formato_reporte_ef052()	
	OPEN WINDOW wtformato AT  12,37 WITH FORM "ef211b" ATTRIBUTE (FORM LINE 1, MESSAGE LINE LAST)
	DISPLAY BY NAME p5.*
		INPUT BY NAME p5.* WITHOUT DEFAULTS
			ON KEY (INTERRUPT,CONTROL-C)
				LET INT_FLAG=TRUE
				EXIT INPUT
			BEFORE FIELD tform
				IF p5.tform IS NULL THEN
					LET p5.tform = 1
				END IF
				DISPLAY BY NAME p5.tform
				ERROR " Digite: (1) Formato TXT / (2) Formato Excel "
			AFTER FIELD tform
				IF p5.tform IS NULL THEN
					LET p5.tform = 1
				END IF
				EXIT INPUT
		END INPUT
	CLOSE WINDOW wtformato	
END FUNCTION
{VAT Fin 06/11/2009 Pasar Reportes a Excel}

FUNCTION f0450_selec_tcar_ef052()
	DEFINE	l_flag	SMALLINT,
		l_ind	SMALLINT
	##
	LET p2[1].dcar = "Total Cartera"
	LET p2[2].dcar = "Sin Provisiones Anteriores"
	LET p2[3].dcar = "Sin Provisiones Totales"
	LET p2[4].dcar = "Provisiones Anteriores"
	LET p2[5].dcar = "Provisiones A¤o Actual"
	LET p2[6].dcar = "Total Provisi¢n"
	##	
	OPEN WINDOW w_ef052b AT 15,50 WITH FORM "ef052b"
		    ATTRIBUTE (FORM LINE 1,MESSAGE LINE LAST)
	CALL set_count(6)
	LET l_flag = FALSE
	DISPLAY ARRAY p2 TO s2.* ATTRIBUTE(REVERSE)
		ON KEY (CONTROL-C,INTERRUPT)
		    LET l_flag = TRUE
		    EXIT DISPLAY
		ON KEY (CONTROL-M)
		    EXIT DISPLAY
	END DISPLAY
	CLOSE WINDOW w_ef052b
	OPTIONS COMMENT LINE 24
	IF l_flag THEN
		RETURN 9
	END IF
	LET l_ind = arr_curr()
	RETURN (l_ind - 1)
END FUNCTION

FUNCTION f0450_selec_tcas_ef052()
	DEFINE  l_flag  SMALLINT,
		l_ind   SMALLINT
	##
	LET p3[1].dcar = "Total Cartera"
	LET p3[2].dcar = "Sin Castigos Anteriores"
	LET p3[3].dcar = "Sin Castigos Totales"
	LET p3[4].dcar = "Castigos Anteriores"
	LET p3[5].dcar = "Castigos A¤o Actual"
	LET p3[6].dcar = "Total Castigos"
	##
	OPEN WINDOW w_ef052b AT 15,50 WITH FORM "ef052b"
		    ATTRIBUTE (FORM LINE 1,MESSAGE LINE LAST)
	CALL set_count(6)
	LET l_flag = FALSE
	DISPLAY ARRAY p3 TO s2.* ATTRIBUTE(REVERSE)
		ON KEY (CONTROL-C,INTERRUPT)
		    LET l_flag = TRUE
		    EXIT DISPLAY
		ON KEY (CONTROL-M)
		    EXIT DISPLAY
	END DISPLAY
	CLOSE WINDOW w_ef052b
	OPTIONS COMMENT LINE 24
	IF l_flag THEN
		RETURN 9
	END IF
	LET l_ind = arr_curr()
	RETURN (l_ind - 1)
END FUNCTION



###################
# LISTADO IMPRESO #
###################

FUNCTION f1000_impreso_ef052()
	DEFINE
		l_czon	SMALLINT	# (@#)6-A
		
	LET g_impt = 0
	LET g_impv = 0
	LET g_numc = 0
	LET g_numv = 0
	LET g_ctast = 0
	LET g_ctasst= 0
	FOR j = 1 TO 6
	    LET g_tott[j].impv = 0
	    LET g_tott[j].numc = 0
	END FOR
	##
	# Inicio (@#)3-A
	IF p1.cmon = 4 THEN	# Dividir entre miles para expresar todo en miles de soles
		LET g_miles = 1000
	ELSE
		LET g_miles = 1
	END IF
	# Fin (@#)3-A
	##
	LET g_spool = "ef052.r"
	START REPORT f1100_proceso_impr_ef052 TO g_spool
	#FOREACH q_curs INTO t1.*	# (@#)6-A
	#FOREACH q_curs INTO l_czon,t1.*	# (@#)6-A		# (@#)7-A
	FOREACH q_curs INTO t1.*		# (@#)6-A	# (@#)7-A
		#OUTPUT TO REPORT f1100_proceso_impr_ef052(t1.*)	# (@#)6-A
		#OUTPUT TO REPORT f1100_proceso_impr_ef052(l_czon,t1.*)	# (@#)6-A	# (@#)7-A
		OUTPUT TO REPORT f1100_proceso_impr_ef052(t1.*)		# (@#)6-A	# (@#)7-A
	END FOREACH
	FINISH REPORT f1100_proceso_impr_ef052
END FUNCTION

REPORT f1100_proceso_impr_ef052(r)
	DEFINE	r	RECORD
			  #czon		SMALLINT,	# (@#)6-A		# (@#)7-A
			  fech		DATE,
			  csuc		SMALLINT,
			  #(@#)15-A - Inicio
			  agep		INTEGER,
			  #(@#)15-A - Fin
			  agen		SMALLINT,
			  plzo		SMALLINT,
			  plza		SMALLINT, #inicio (@#)15-A 
			  tpro		INTEGER,
			  gpro		INTEGER,
			  impt		DECIMAL(14,2),
			  numc		INTEGER
			END RECORD,
			l_fila		SMALLINT,
			l_impt, l_impv	DECIMAL(14,2),
			l_numc, l_numv	INTEGER,
			l_porc		DECIMAL(7,2),
			l_imst, l_imsv	DECIMAL(14,2),
			l_nums, l_nusv	INTEGER,
			l_form		CHAR(7),
			l_impt1, l_impv1	DECIMAL(14,2),
			l_numc1, l_numv1	INTEGER,
			l_porc1		DECIMAL(7,2),
			l1	RECORD
				plzo    SMALLINT,
				impt    DECIMAL(14,2),
				numc	INTEGER
				END RECORD,
			x	SMALLINT,
			l_pres	SMALLINT,
			l_desplaza SMALLINT,
			l_limite SMALLINT,
			l_age1   SMALLINT,	 #(@#)15-A 
			l_retl,l_agen   CHAR(50) #(@#)15-A 
		
	OUTPUT
		LEFT MARGIN 0
		TOP  MARGIN 0
		BOTTOM MARGIN 4
		PAGE LENGTH 66
		ORDER EXTERNAL BY r.csuc, r.agen, r.plzo
	FORMAT
		PAGE HEADER
		# Inicio (@#)15-A 
		LET l_age1 = 0	
		IF p1.ctpl =1 THEN
			LET l_age1 = 18	
		END IF
		# Fin (@#)15-A  
		
		IF p1.itr7 = "S" THEN
			# Inicio (@#)15-A 
			#LET g_ancho  = 242 #12
			LET g_ancho  = 242+l_age1
			# Fin (@#)15-A  
		ELSE
			# Inicio (@#)15-A 
			#LET g_ancho  = 222 #12
			LET g_ancho  = 222+l_age1
			# Fin (@#)15-A  
		END IF

		LET g_string = t0.gbpmtnemp CLIPPED
		PRINT ASCII 15
		PRINT COLUMN  1,"EFECTIVA",
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),"PAG: ",PAGENO USING "<<<<"
		LET g_string = "ATRASO DE COBRANZA x ETAPAS AL ",
				p1.fech USING "dd/mm/yyyy"
		PRINT COLUMN  1,TIME CLIPPED,
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),TODAY USING "dd-mm-yyyy"
		CASE p1.cmon
		WHEN 0
	    LET g_string = "EXPRESADO EN US $ DOLARES (INCLUYE SOLES)"
		WHEN 1
		    LET g_string = "NUEVOS SOLES"
		WHEN 2
		    LET g_string = "DOLARES AMERICANOS"
		# Inicio (@#)3-A
		WHEN 4
		    LET g_string = "EXPRESADO EN MILES DE NUEVOS SOLES (INCLUYE DOLARES)"
		# Fin (@#)3-A
		OTHERWISE
	    LET g_string = "EXPRESADO EN NUEVOS SOLES (INCLUYE DOLARES)"
		END CASE
	     PRINT COLUMN  1,"ef052.4gl",COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
		CASE p4.mcip
			WHEN 0
				LET g_string = "TOTAL (INCLUYE CREDITOS CON INTENCION DE PAGO)"
			WHEN 1
				LET g_string = "EXCLUYE CREDITOS CON INTENCION DE PAGO"
			WHEN 2
				LET g_string = "INCLUYE SOLO CREDITOS CON INTENCION DE PAGO"
		END CASE
		
		#INICIO (@#)15-A 
		IF (p1.crtl=0) THEN
		   LET l_retl="TODOS"
		ELSE
		   LET l_retl=f0412_obtener_descripcion_ef052(p1.crtl,524)
		END IF
		
		PRINT COLUMN  1,"RETAIL: ",l_retl,COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		#PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		#FIN (@#)15-A 
		{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}
		
		{VAT Ini. Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}		
		CASE p4.tges
			WHEN 0
				#LET g_string = "TOTAL (ADCs + PROCs + ProcPAA)"	#Inicio (@#) 1-A
				#Inicio (@#)8-A
				#LET g_string = "TOTAL (ADCs + P1 + P2 + P3)"		#Inicio (@#) 1-A
				LET g_string = "TOTAL (ADCs + ECob + P1 + P2 + P3)"
				#Fin (@#)8-A
			# (@#)13-A Inicio
				IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
					LET g_string = "TOTAL (ADCs + ECob + P1 + P2 )"
				END IF
			# (@#)13-A Fin				
			WHEN 1
				LET g_string = "Adm.Cartera"
			WHEN 2
				#LET g_string = "Procuracion"			#Inicio (@#) 1-A
				LET g_string = "Procuracion P1"			#Inicio (@#) 1-A
			WHEN 3
				#LET g_string = "Procuracion PAA"		#Inicio (@#) 1-A
				LET g_string = "Procuracion P2"			#Inicio (@#) 1-A
			WHEN 4
				LET g_string = "Procuracion P3"			#Inicio (@#) 1-A
				#Inicio (@#)8-A
			WHEN 5
				LET g_string = "Ejec.Cobranza"
				#Fin (@#)8-A
		END CASE
		PRINT COLUMN   1,"Tipo de Gestor: ", g_string CLIPPED;				 
		{VAT Fin Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}		
		CASE p1.msis
		WHEN "S"
		    LET g_string = "CREDITOS EFE (SAI)"
		WHEN "F"
		    #LET g_string = "CREDITOS EDPYME (SFI)"	#Inicio (@#) 1-A
		    LET g_string = "CREDITOS FINANCIERA (SFI)"	#Inicio (@#) 1-A
		OTHERWISE
		    #LET g_string = "CONSOLIDADO EFE + EDPYME (SAI + SFI)"	#Inicio (@#) 1-A
		    LET g_string = "CONSOLIDADO EFE + FINANCIERA (SAI + SFI)"	#Inicio (@#) 1-A
		END CASE
    
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		#INICIO (@#)11-A
                CASE p1.microz 
                	WHEN "I"
                		LET g_string = "MICROZONAS ITINERANTES"
                	WHEN "N"
                		LET g_string = "MICROZONAS NO ITINERANTES"
                	WHEN "D"
				LET g_string = "MICROZONAS NO DEFINIDAS" 
                	OTHERWISE
                		LET g_string = " MICROZONAS ITINERANTES Y NO ITINERANTES Y NO DEFINIDAS"
                END CASE
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
		#FIN (@#)11-A
		PRINT COLUMN   1,"Agencias: De ", p1.agen1 USING "<<<",
				 " a ", p1.agen2 USING "<<<";
		# Inicio (@#)9-A
		LET g_string = g_desc
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		# Fin (@#)9-A
		CASE p1.tdat
		WHEN "C"
		    LET g_string = "SOLO CAPITAL"
		WHEN "I"
		    LET g_string = "SOLO INTERES "
		OTHERWISE
		    LET g_string = "CAPITAL + INTERES"
		    IF p1.msis = "S" THEN
			LET g_string = g_string CLIPPED,
					" (INC. IGV DEL INTERES)"
		    END IF
		END CASE
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED

		IF p1.tcre = "T" THEN
		    CASE p1.tcuo
		    WHEN 0
			LET g_string = "TOTAL PRESTAMOS"
		    WHEN 1
			LET g_string = "CREDITOS MENSUALES"
		    WHEN 2
			LET g_string = "CREDITOS SEMANALES"
		    END CASE
		ELSE
		    CASE p1.tcr1
		    WHEN 2
			LET g_string = "Tipo de Credito: MES"
		    WHEN 3
			LET g_string = "Tipo de Credito: CONSUMO"
		    OTHERWISE
			LET g_string = "Tipo de Credito: Del ",
					p1.tcre1 USING "<<<"," al ",
					p1.tcre2 USING "<<<"
		    END CASE
		    CASE p1.tcuo
		    WHEN 1
			LET g_string = g_string CLIPPED, ", CUOTAS MENSUALES"
		    WHEN 2
			LET g_string = g_string CLIPPED, ", CUOTAS SEMANALES"
		    END CASE
		END IF

		PRINT COLUMN   1,g_string CLIPPED;
		CASE p1.tcar
		WHEN 0
		    LET g_string = "TOTAL CARTERA"
		WHEN 1
		    LET g_string = "SIN PROVISION ANIOS ANTERIORES"
		WHEN 2
		    LET g_string = "SIN PROVISION TOTAL"
		WHEN 3
		    LET g_string = "PROVISION A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = "PROVISION ANIO ACTUAL"
		WHEN 5
		    LET g_string = "TOTAL PROVISION"
		END CASE
		CASE p1.tcas
		WHEN 0
		    LET g_string = g_string CLIPPED," "
		WHEN 1
		    LET g_string = g_string CLIPPED,
				"- SIN CASTIGOS A¥OS ANTERIORES"
		WHEN 2
		    LET g_string = g_string CLIPPED
				,"- SIN CASTIGOS TOTALES"
		WHEN 3
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥O ACTUAL"
		WHEN 5
		    LET g_string = g_string CLIPPED
				,"- TOTAL CASTIGOS"
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		LET g_string = "Tipo d/Cambio: ", g_tcam USING "<&.&&&"
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
		# Inicio (@#)4-A
		LET g_string = ""
		CASE p4.cart
		    WHEN 0
			# (@#)19-A - Inicio	  
			#LET g_string = g_string CLIPPED, "TOTAL CARTERA (ELECTRODOMESTICOS + MOTOS)"
			  LET g_string = g_string CLIPPED, "TOTAL CARTERA"
		  #  WHEN 1
			#LET g_string = g_string CLIPPED, "CARTERA DE ELECTRODOMESTICOS"
		  #  WHEN 2
			#LET g_string = g_string CLIPPED, "CARTERA DE MOTOS"			 
			  OTHERWISE
			  LET g_string = g_string CLIPPED, "CARTERA DE ",p4.dcar
			  IF p4.cart = 5 THEN
			  	LET	g_string = g_string CLIPPED, " - ",p4.defe
			  END IF			  
			# (@#)19-A - Fin
		END CASE
		PRINT COLUMN 1,g_string CLIPPED;
		# Fin (@#)4-A
		
		# Inicio (@#)5-A
		LET g_string = ""
		CASE p4.diap
		    WHEN 0
			LET g_string = g_string CLIPPED, "TOTAL CARTERA (INCLUYE TODOS LOS DIAS DE PAGO DEL CREDITO)"
		    WHEN 1
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 4"
		    WHEN 5
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 9"
		    WHEN 10
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 14"
		    WHEN 15
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 19"
		    WHEN 20
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 24"
		    WHEN 25
			LET g_string = g_string CLIPPED, "DIAS DE PAGO MAYORES A ",p4.diap
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		# Fin (@#)5-A
		
		IF p1.itr7 = "S" THEN
			LET l_desplaza = 30
			LET l_pres = 217
		ELSE
			#PRINT
			LET l_pres = 187
			LET l_desplaza = 0
		END IF

	FOR i=1 TO g_ancho-1+l_desplaza PRINT "-"; END FOR PRINT "-"

	IF p1.itr7 = "S" THEN	
		PRINT COLUMN  7+l_age1,"\\", 
		      COLUMN  23+l_age1,"-------------------   T o t a l e s ",
		      COLUMN  61+l_age1,"----------------",
		      COLUMN  79+l_age1,"|  ---  de 1 a 8 dias  --- ",
		      COLUMN  74+l_desplaza+l_age1,"|  ----  1 a 30 dias  ---",
		      COLUMN 103+l_desplaza+l_age1,"|  ---  31 a 60 dias  ---",
		      COLUMN 130+l_desplaza+l_age1,"|  ---  61 a 90 dias  ---",
		      COLUMN 157+l_desplaza+l_age1,"|  ---  91 a 120 dias  --",
		      COLUMN 184+l_desplaza+l_age1,"|  ---  mas de 120 d  ---";
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_desplaza+l_age1,"|  Ctas"
		ELSE
		      PRINT 
		END IF
		
	ELSE	
		PRINT COLUMN  7+l_age1,"\\", 
		      COLUMN  23+l_age1,"-------------------   T o t a l e s ",
		      COLUMN  61+l_age1,"----------------",
		      COLUMN  79+l_age1,"|  ----  1 a 30 dias  ---",
		      COLUMN 106+l_age1,"|  ---  31 a 60 dias  ---",
		      COLUMN 133+l_age1,"|  ---  61 a 90 dias  ---",
		      COLUMN 160+l_age1,"|  ---  91 a 120 dias  --",
		      COLUMN 187+l_age1,"|  ---  mas de 120 d  ---";
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_age1,"|  Ctas"
		    ELSE
		      PRINT
		END IF
	END IF 
		PRINT COLUMN  8+l_age1,"\\", 
		      COLUMN  26+l_age1,"General",
		      COLUMN  37+l_age1,"Ctas",
		      COLUMN  45+l_age1,"Vigente",
		      COLUMN  56+l_age1,"Vencido",
		      COLUMN  67+l_age1,"%",
		      COLUMN  73+l_age1,"Ctas.";
		LET j = 79
		
		WHILE j <= l_pres
		    PRINT COLUMN  j +l_age1  ,"|     Atraso",
			  COLUMN  j+16+l_age1,"%",
			  COLUMN  j+21+l_age1,"Ctas";
		    LET j = j + 27
		END WHILE
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_desplaza+l_age1,"| Pdtvs";
		END IF
		#PRINT COLUMN 216,"Pdtvs";
		SKIP 1 LINE
		# Inicio (@#)15-A 
		IF p1.ctpl =1 THEN
			LET l_agen = "Empresa \\ Plaza - Agencia \\ Limite" 	
		ELSE   
			LET l_agen = "Agencia \\ Limite" 						
		END IF
			PRINT COLUMN   1,l_agen CLIPPED; 
			#PRINT COLUMN   1,"Agencia \\ Limite"; 
		# Fin (@#)15-A 
		IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
			p1.tdat = "T" AND p1.tcar = 1  ) OR
			(p1.msis MATCHES "[TF]" AND p1.tcre1 > 29 AND 
			# Inicio (@#)3-A
			# Si es moneda 3 o 4 deba hacer lo mismo
			#p1.cmon = 3 AND p1.tdat = "C" AND p1.tcar <= 1) THEN
			( p1.cmon = 3 OR p1.cmon = 4 ) AND p1.tdat = "C" AND p1.tcar <= 1) THEN
			# Fin (@#)3-A
		
			#PRINT COLUMN  66,g_plim[1]	USING "&.&&";	# (@#)3-A
			PRINT COLUMN  67+l_age1,g_plim[1]	USING "&.&";	# (@#)3-A
			FOR j = 2 TO 6
				# Inicio (@#)3-A
				IF p1.itr7 = "S" THEN
					IF j <> 6 THEN
						LET l_form = "##&.&"
					ELSE
						LET l_form = "##&.&&"
					END IF
				ELSE
					IF j < 6 THEN
						LET l_form = "##&.&"
					ELSE
						LET l_form = "##&.&&"
					END IF
				END IF
				# Fin (@#)3-A
				LET k = ((j - 2)* 27) + 79
				#	PRINT COLUMN k ,"M",
				#	      COLUMN k+15,g_plim[j]	USING "&.&&";
				#PRINT COLUMN k+12+l_desplaza,g_plim[j]	USING "&.&&";	# (@#)3-A
				PRINT COLUMN k+13+l_desplaza+l_age1,g_plim[j]	USING l_form;	# (@#)3-A
			END FOR
			PRINT
		ELSE
			FOR j = 2 TO 6
				LET k = ((j - 2)* 27) + 79
				PRINT COLUMN  k+l_age1,"|";
			END FOR
			PRINT
		END IF
		FOR i=1 TO g_ancho-1+l_desplaza PRINT "-"; END FOR PRINT "-"
	
	BEFORE GROUP OF r.csuc
		LET g_ctass = 0
		IF r.csuc = 99 THEN
			#NEED 3 LINES
			NEED 2 LINES
			IF g_impt > 0 AND g_impv > 0 THEN
			LET l_porc = g_impv / g_impt * 100
			ELSE
			LET l_porc = NULL
			END IF
			FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
			PRINT COLUMN   1,"SUBTOTAL",
			   COLUMN  22+l_age1,g_impt/g_miles		USING "###,###,###",	# (@#)3-A
			   COLUMN  34+l_age1,g_numc			USING "###,###",
			   COLUMN  42+l_age1,(g_impt-g_impv)/g_miles	USING "###,###,###",	# (@#)3-A
			   COLUMN  54+l_age1,g_impv/g_miles		USING "##,###,###",	# (@#)3-A
			   #COLUMN  65,l_porc		USING "##&.&&", #(@#)2-A
			   COLUMN  65+l_age1,l_porc		USING "##&.&", #(@#)2-A		# (@#)3-A
			   COLUMN  71+l_age1,g_numv		USING "###,###";

			IF p1.itr7 = "S" THEN
				LET l_limite = 6
			ELSE
				LET l_limite = 5
			END IF
	
			FOR j = 1 TO l_limite
				LET k = ((j - 1) * 27) + 79
				IF g_impt > 0 AND g_tott[j].impv > 0 THEN
				    LET l_porc = g_tott[j].impv / g_impt * 100
				ELSE
				    LET l_porc = NULL
				END IF
	
				IF p1.itr7 = "S" THEN
					#IF r.plzo <> 1 THEN	# (@#)3-A
					IF j <> 6 THEN	# (@#)3-A
						#LET l_form = "##&.&&"#cambiar a menos un amperstand #(@#)2-A
						LET l_form = "##&.&"#cambiar a menos un amperstand #(@#)2-A	# (@#)3-A
					ELSE
						LET l_form = "##&.&&"
					END IF
				    
				ELSE
					#IF r.plzo < 5 THEN	# (@#)3-A
					IF j < 5 THEN	# (@#)3-A
						#LET l_form = "##&.&&" #(@#)2-A
						LET l_form = "##&.&" #(@#)2-A		# (@#)3-A
					ELSE
						LET l_form = "##&.&&"
					END IF
				END IF
	
				PRINT COLUMN k+l_age1  ,"|",
				      #COLUMN k+3 ,g_tott[j].impv / g_miles  USING "###,###,###",	# (@#)3-A
				      COLUMN k+1+l_age1 ,g_tott[j].impv / g_miles  USING "###,###,###",	# (@#)7-A
				      COLUMN k+13+l_age1,l_porc	  USING l_form,
				      COLUMN k+19+l_age1,g_tott[j].numc  USING "##,###";
			END FOR
			IF p1.ctap = "S" THEN	
				#PRINT COLUMN 214+l_desplaza,"|",g_ctasst USING "##,###"  ##(@#)11-A
				PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctasst USING "###,###"  ##(@#)11-A
			ELSE
				PRINT
			END IF	
			#PRINT
			{FOR j = 1 TO 5
			LET k = ((j - 1) * 27) + 79
			PRINT COLUMN k,"|";
			END FOR
			PRINT}
		END IF
		##
		LET l_fila = 0
		LET l_imst = 0
		LET l_imsv = 0
		LET l_nums = 0
		LET l_nusv = 0
		FOR j = 1 TO 6
		    LET g_subt[j].impv = 0
		    LET g_subt[j].numc = 0
		    ##
		    {LET k = ((j - 1) * 27) + 79
		    PRINT COLUMN k,"|";}
		END FOR
		IF r.csuc <> 1 THEN
			PRINT
		END IF
	
	BEFORE GROUP OF r.agen
		LET g_ctasp = 0
		IF r.csuc < 98 THEN LET l_fila = l_fila + 1 END IF
		CALL f5030_calc_totales_ef052(r.agen)
		    RETURNING l_impt, l_impv, l_numc, l_numv
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		# Inicio (@#)15-A 
		IF p1.ctpl =1 THEN
			LET l_retl = f5021_busca_emp_ef052(r.plza)
			LET l_agen = l_retl[1,10],"   ",r.agen USING "###","-",f5022_buscar_descripcion_agencia_ef052(r.plza) CLIPPED
		ELSE 
			LET l_agen = f5020_busca_agen_ef052(r.agen) CLIPPED	
		END IF 
		# Fin (@#)15-A 
		PRINT 
		      # Inicio (@#)15-A 
		      COLUMN   1,l_agen CLIPPED, 
		      #COLUMN   1,f5020_busca_agen_ef052(r.agen) CLIPPED, 
		      # Fin (@#)15-A 
		      COLUMN  23+l_age1,l_impt/g_miles		USING "##,###,###",  #ok	# (@#)3-A
		      COLUMN  34+l_age1,l_numc		USING "###,###",     #ok
		      COLUMN  43+l_age1,(l_impt-l_impv)/g_miles	USING "##,###,###",	# (@#)3-A
		      COLUMN  54+l_age1,l_impv/g_miles		USING "##,###,###",#tengo menos	# (@#)3-A
		      #COLUMN  65,l_porc	USING "##&.&&",#(@#)2-A
		      COLUMN  65+l_age1,l_porc		USING "##&.&",#(@#)2-A		# (@#)3-A
		      COLUMN  71+l_age1,l_numv		USING "###,###";
		LET l_imst = l_imst + l_impt
		LET l_imsv = l_imsv + l_impv
		LET l_nums = l_nums + l_numc
		LET l_nusv = l_nusv + l_numv
		##
		LET g_impt = g_impt + l_impt
		LET g_impv = g_impv + l_impv
		LET g_numc = g_numc + l_numc
		LET g_numv = g_numv + l_numv
		##
		LET k = 1
		WHILE k < r.plzo
		    LET j = ((k -1) * 27) + 79
		    PRINT COLUMN j+l_age1,"|";
		    LET k = k + 1
		END WHILE

	ON EVERY ROW
		IF r.plzo > 0 THEN
			LET j = ((r.plzo - 1) * 27) + 79
			IF l_impt > 0 AND r.impt > 0 THEN
				LET l_porc = r.impt / l_impt * 100
			ELSE
				LET l_porc = NULL
			END IF

			IF p1.itr7 = "S" THEN
				#IF r.plzo <> 1 THEN	# (@#)3-A
				IF r.plzo <> 6 THEN	# (@#)3-A
					#LET l_form = "##&.&&"#cambiar a menos un amperstand #(@#)2-A
					LET l_form = "##&.&"#cambiar a menos un amperstand #(@#)2-A	#(@#)3-A
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
				IF r.plzo < 5 THEN
					#LET l_form = "##&.&&" #(@#)2-A
					LET l_form = "##&.&" #(@#)2-A		# (@#)3-A
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF
				
			PRINT COLUMN j+l_age1   ,"|",
			      COLUMN j+3+l_age1 ,r.impt / g_miles	USING "#,###,###",	# (@#)3-A
			      COLUMN j+13+l_age1,l_porc	USING l_form,
			      COLUMN j+19+l_age1,r.numc	USING "##,###";
			LET k = r.plzo
			LET g_subt[k].impv = g_subt[k].impv + r.impt
			LET g_subt[k].numc = g_subt[k].numc + r.numc
			##
			LET g_tott[k].impv = g_tott[k].impv + r.impt
			LET g_tott[k].numc = g_tott[k].numc + r.numc
		END IF

	AFTER GROUP OF r.agen
		LET k = r.plzo

{
		WHILE k < 6
		    LET j = (k * 27) + 79
		    PRINT COLUMN j,"|";
		    LET k = k + 1
		END WHILE
}
		LET g_ctass = g_ctass + g_ctasp
		LET g_ctast = g_ctast + g_ctasp
		LET g_ctasst = g_ctasst + g_ctasp
		IF p1.ctap = "S" THEN
			PRINT COLUMN 214+l_desplaza+l_age1,"M",g_ctasp USING "##,###" #hito2009
		ELSE
			PRINT
		END IF
		IF r.agen = 88 THEN
			FOR x = 1 TO 2
				CALL f5035_calc_totales_ef052(r.agen,x)
					RETURNING l_impt1, l_impv1, l_numc1, l_numv1
				IF l_impt1 > 0 AND l_impv1 > 0 THEN
					LET l_porc1 = l_impv1 / l_impt1 * 100
				ELSE
					LET l_porc1 = NULL
				END IF
				IF x = 1 THEN
					IF r.agen = 88 THEN
						PRINT COLUMN   3+l_age1,"O.P. CxC";
					ELSE
						PRINT COLUMN   3+l_age1,"Cred. Consumo";
					END IF
				ELSE
					IF r.agen = 88 THEN
						PRINT COLUMN   3+l_age1,"O.P. PresxArtf";
					ELSE
						PRINT COLUMN   3+l_age1,"Microcredito";
					END IF
				END IF
				PRINT COLUMN  23+l_age1,l_impt1 / g_miles                USING "##,###,###",        #bien	# (@#)3-A
				      COLUMN  34+l_age1,l_numc1                USING "###,###",           #bien
				      COLUMN  42+l_age1,(l_impt1-l_impv1) / g_miles        USING "###,###,###", #sobra		# (@#)3-A
				      COLUMN  55+l_age1,l_impv1 / g_miles                USING "#,###,###", #falta		# (@#)3-A
				      #COLUMN  65,l_porc1                USING "##&.&&",     #falta #(@#)2-A
				      COLUMN  65+l_age1,l_porc1                USING "##&.&",     #falta #(@#)2-A		#(@#)3-A
				      COLUMN  71+l_age1,l_numv1                USING "###,###";   #falta
			
				DECLARE q_88 CURSOR FOR
				SELECT plzo,SUM(impt),SUM(numc)
				FROM ef052a
				WHERE tipo = x
				AND   cloc = r.agen
				GROUP BY 1
				ORDER BY 1
				
				FOREACH q_88 INTO l1.*
			
					IF l1.plzo > 0 THEN
						LET j = ((l1.plzo - 1) * 27) + 79
						IF l_impt1 > 0 AND l1.impt > 0 THEN
							LET l_porc = l1.impt / l_impt1 * 100
						ELSE
							LET l_porc = NULL
						END IF
			
						IF p1.itr7 = "S" THEN
							#IF r.plzo <> 1  THEN	# (@#)3-A
							IF l1.plzo <> 6  THEN	# (@#)3-A
								#LET l_form = "##&.&&"#cambiar a menos un amperstand #(@#)2-A
								LET l_form = "##&.&"#cambiar a menos un amperstand #(@#)2-A	# (@#)3-A
							ELSE
								LET l_form = "##&.&&"
							END IF
						ELSE
							IF l1.plzo < 5 THEN
								#LET l_form = "##&.&&" #(@#)2-A
								LET l_form = "##&.&" #(@#)2-A		# (@#)3-A
							ELSE
								LET l_form = "##&.&" #(@#)2-A
							END IF
						END IF
						PRINT COLUMN j+l_age1   ,"|",
						      COLUMN j+3+l_age1 ,l1.impt / g_miles       USING "#,###,###",	# (@#)3-A
						      COLUMN j+13+l_age1,l_porc        USING l_form,
						      COLUMN j+19+l_age1,l1.numc        USING "##,###";
					END IF
				END FOREACH
				PRINT
			END FOR
		END IF

	AFTER GROUP OF r.csuc
		IF l_fila > 1 THEN
		#NEED 3 LINES
			NEED 2 LINES
			IF l_imst > 0 AND l_imsv > 0 THEN
				LET l_porc = l_imsv / l_imst * 100
			ELSE
				LET l_porc = NULL
			END IF
			FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
			PRINT COLUMN   1+l_age1,"Suc. ",f5050_busca_csuc_ef052(r.csuc),
				  COLUMN  23+l_age1,l_imst / g_miles		USING "##,###,###",	# (@#)3-A
				  COLUMN  34+l_age1,l_nums		USING "###,###",
				  COLUMN  42+l_age1,(l_imst-l_imsv) / g_miles	USING "###,###,###",	# (@#)3-A
				  COLUMN  54+l_age1,l_imsv / g_miles		USING "##,###,###",	# (@#)3-A
				  #COLUMN  65,l_porc		USING "##&.&&",#(@#)2-A
				  COLUMN  65+l_age1,l_porc		USING "##&.&",#(@#)2-A		#(@#)3-A
				  COLUMN  71+l_age1,l_nusv		USING "###,###";
		 
				IF p1.itr7 = "S" THEN
					LET l_limite = 6
				ELSE
					LET l_limite = 5
				END IF
				
				FOR j = 1 TO l_limite
					LET k = ((j - 1) * 27) + 79
					IF l_imst > 0 AND g_subt[j].impv > 0 THEN
						LET l_porc = g_subt[j].impv / l_imst * 100
					ELSE
						LET l_porc = NULL
					END IF
								
					IF p1.itr7 = "S" THEN
						#IF r.plzo <> 1 THEN	# (@#)3-A
						IF j <> 6  THEN	# (@#)3-A
							#LET l_form = "##&.&&"#cambiar a menos un amperstand #(@#)2-A
							LET l_form = "##&.&"#cambiar a menos un amperstand #(@#)2-A	# (@#)3-A
						ELSE
							LET l_form = "##&.&&"
						END IF
					ELSE
						#IF r.plzo = 5 THEN	# (@#)3-A
						IF j = 5 THEN	# (@#)3-A
							LET l_form = "##&.&&" #(@#)2-A
						ELSE				# (@#)7-A
							LET l_form = "##&.&"	# (@#)7-A
						END IF
					END IF
					PRINT COLUMN k+l_age1   ,"|",
					      #COLUMN k+3 ,g_subt[j].impv / g_miles USING "###,###,###",	# (@#)3-A
					      COLUMN k+1+l_age1 ,g_subt[j].impv / g_miles USING "###,###,###",	# (@#)7-A
					      COLUMN k+13+l_age1,l_porc	  USING l_form,
					      COLUMN k+19+l_age1,g_subt[j].numc  USING "##,###";
				END FOR
			IF p1.ctap = "S" THEN
				PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctass USING "##,###"
			ELSE
				PRINT
			END IF
		    #PRINT
		END IF

	ON LAST ROW
		NEED 2 LINES
		IF g_impt > 0 AND g_impv > 0 THEN
			LET l_porc = g_impv / g_impt * 100
		ELSE
			LET l_porc = NULL
		END IF
		FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
		PRINT COLUMN   1,"TOTAL COMPA¥IA",
		      COLUMN  22+l_age1,g_impt / g_miles	USING "###,###,###",		# (@#)3-A
		      COLUMN  34+l_age1,g_numc		USING "###,###",
		      COLUMN  42+l_age1,(g_impt-g_impv) / g_miles	USING "###,###,###",	# (@#)3-A
		      COLUMN  54+l_age1,g_impv / g_miles		USING "##,###,###",	# (@#)3-A
		      #COLUMN  65,l_porc	USING "##&.&&",#(@#)2-A
		      COLUMN  65+l_age1,l_porc		USING "##&.&",#(@#)2-A		#(@#)3-A
		      COLUMN  71+l_age1,g_numv		USING "###,###"; 

		IF p1.itr7 = "S" THEN
			LET l_limite = 6
		ELSE
			LET l_limite = 5
		END IF
			
		FOR j = 1 TO l_limite
			LET k = ((j - 1) * 27) + 79
			IF g_impt > 0 AND g_tott[j].impv > 0 THEN
				LET l_porc = g_tott[j].impv / g_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
						
			IF p1.itr7 = "S" THEN
				#IF r.plzo <> 1 THEN	# (@#)3-A
				IF j <> 6 THEN	# (@#)3-A
					#LET l_form = "##&.&&"#cambiar a menos un amperstand #(@#)2-A
					LET l_form = "##&.&"#cambiar a menos un amperstand #(@#)2-A	# (@#)3-A
					
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
				#IF r.plzo < 5 THEN	# (@#)3-A
				IF j < 5 THEN	# (@#)3-A
					#LET l_form = "##&.&&" #(@#)2-A
					LET l_form = "##&.&" #(@#)2-A		# (@#)3-A
				ELSE
					LET l_form = "##&.&" #(@#)2-A
				END IF
			END IF
			PRINT COLUMN k+l_age1   ,"|",
				#COLUMN k+3 ,g_tott[j].impv / g_miles	USING "###,###,###",	# (@#)3-A
				COLUMN k+1+l_age1 ,g_tott[j].impv / g_miles	USING "###,###,###",	# (@#)7-A
				COLUMN k+13+l_age1,l_porc		USING l_form,
				COLUMN k+19+l_age1,g_tott[j].numc	USING "##,###";
		END FOR
		IF p1.ctap = "S" THEN
			#PRINT COLUMN 214+l_desplaza,"|",g_ctast USING "##,###" #(@#)11-A
			PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctast USING "###,###" #(@#)11-A
		ELSE
			PRINT
		END IF
		#PRINT
	PAGE TRAILER
		PRINT ASCII 18
END REPORT

#INICIO (@#)15-A  
FUNCTION f1000_impreso_b_ef052()
	DEFINE
		l_czon	SMALLINT	
		
	LET g_impt = 0
	LET g_impv = 0
	LET g_numc = 0
	LET g_numv = 0
	LET g_ctast = 0
	LET g_ctasst= 0
	FOR j = 1 TO 6
	    LET g_tott[j].impv = 0
	    LET g_tott[j].numc = 0
	END FOR

	IF p1.cmon = 4 THEN	# Dividir entre miles para expresar todo en miles de soles
		LET g_miles = 1000
	ELSE
		LET g_miles = 1
	END IF

	LET g_spool = "ef052.r"
	START REPORT f1100_proceso_impr_b_ef052 TO g_spool
	FOREACH q_curs INTO t1.*	
		OUTPUT TO REPORT f1100_proceso_impr_b_ef052(t1.*)		
	END FOREACH
	FINISH REPORT f1100_proceso_impr_b_ef052
END FUNCTION

REPORT f1100_proceso_impr_b_ef052(r)
	DEFINE	r	RECORD
			  fech		DATE,
			  csuc		SMALLINT,
			  #(@#)15-A - Inicio
			  agep		INTEGER,
			  #(@#)15-A - Fin
			  agen		SMALLINT,
			  plzo		SMALLINT,
			  plza		SMALLINT, 
			  tpro		INTEGER,
			  gpro		INTEGER,
			  impt		DECIMAL(14,2),
			  numc		INTEGER
			END RECORD,
			l_fila		SMALLINT,
			l_impt, l_impv	DECIMAL(14,2),
			l_numc, l_numv	INTEGER,
			l_porc		DECIMAL(7,2),
			l_imst, l_imsv	DECIMAL(14,2),
			l_nums, l_nusv	INTEGER,
			l_form		CHAR(7),
			l_impt1, l_impv1	DECIMAL(14,2),
			l_numc1, l_numv1	INTEGER,
			l_porc1		DECIMAL(7,2),
			l1	RECORD
				plzo    SMALLINT,
				impt    DECIMAL(14,2),
				numc	INTEGER
				END RECORD,
			x	SMALLINT,
			l_pres	SMALLINT,
			l_desplaza SMALLINT,
			l_limite SMALLINT,
			l_age1   SMALLINT,	
			l_retl,l_agen   CHAR(50) 
		
	OUTPUT
		LEFT MARGIN 0
		TOP  MARGIN 0
		BOTTOM MARGIN 4
		PAGE LENGTH 66
		ORDER EXTERNAL BY r.csuc, r.agep, r.plzo
	FORMAT
		PAGE HEADER	
		LET l_age1 = 0	
		IF p1.ctpl =1 THEN
			LET l_age1 = 18	
		END IF
		
		IF p1.itr7 = "S" THEN
			LET g_ancho  = 242+l_age1		
		ELSE
			LET g_ancho  = 222+l_age1
		END IF

		LET g_string = t0.gbpmtnemp CLIPPED
		PRINT ASCII 15
		PRINT COLUMN  1,"EFECTIVA",
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),"PAG: ",PAGENO USING "<<<<"
		LET g_string = "ATRASO DE COBRANZA x ETAPAS AL ",
				p1.fech USING "dd/mm/yyyy"
		PRINT COLUMN  1,TIME CLIPPED,
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),TODAY USING "dd-mm-yyyy"
		CASE p1.cmon
		WHEN 0
	    LET g_string = "EXPRESADO EN US $ DOLARES (INCLUYE SOLES)"
		WHEN 1
		    LET g_string = "NUEVOS SOLES"
		WHEN 2
		    LET g_string = "DOLARES AMERICANOS"
		WHEN 4
		    LET g_string = "EXPRESADO EN MILES DE NUEVOS SOLES (INCLUYE DOLARES)"
		OTHERWISE
	    LET g_string = "EXPRESADO EN NUEVOS SOLES (INCLUYE DOLARES)"
		END CASE
	     PRINT COLUMN  1,"ef052.4gl",COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		CASE p4.mcip
			WHEN 0
				LET g_string = "TOTAL (INCLUYE CREDITOS CON INTENCION DE PAGO)"
			WHEN 1
				LET g_string = "EXCLUYE CREDITOS CON INTENCION DE PAGO"
			WHEN 2
				LET g_string = "INCLUYE SOLO CREDITOS CON INTENCION DE PAGO"
		END CASE
		
		IF (p1.crtl=0) THEN
		   LET l_retl="TODOS"
		ELSE
		   LET l_retl=f0412_obtener_descripcion_ef052(p1.crtl,524)
		END IF
		
		PRINT COLUMN  1,"RETAIL: ",l_retl,COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		
		CASE p4.tges
			WHEN 0			
				LET g_string = "TOTAL (ADCs + ECob + P1 + P2 + P3)"

				IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
					LET g_string = "TOTAL (ADCs + ECob + P1 + P2 )"
				END IF		
			WHEN 1
				LET g_string = "Adm.Cartera"
			WHEN 2
				
				LET g_string = "Procuracion P1"			
			WHEN 3		
				LET g_string = "Procuracion P2"			
			WHEN 4
				LET g_string = "Procuracion P3"			
			WHEN 5
				LET g_string = "Ejec.Cobranza"
		END CASE
		PRINT COLUMN   1,"Tipo de Gestor: ", g_string CLIPPED;					
		CASE p1.msis
		WHEN "S"
		    LET g_string = "CREDITOS EFE (SAI)"
		WHEN "F"
	
		    LET g_string = "CREDITOS FINANCIERA (SFI)"	
		OTHERWISE
	
		    LET g_string = "CONSOLIDADO EFE + FINANCIERA (SAI + SFI)"
		END CASE
    
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
	
                CASE p1.microz 
                	WHEN "I"
                		LET g_string = "MICROZONAS ITINERANTES"
                	WHEN "N"
                		LET g_string = "MICROZONAS NO ITINERANTES"
                	WHEN "D"
				LET g_string = "MICROZONAS NO DEFINIDAS" 
                	OTHERWISE
                		LET g_string = " MICROZONAS ITINERANTES Y NO ITINERANTES Y NO DEFINIDAS"
                END CASE
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
	
		PRINT COLUMN   1,"Agencias: De ", p1.agen1 USING "<<<",
				 " a ", p1.agen2 USING "<<<";
		
		LET g_string = g_desc
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		
		CASE p1.tdat
		WHEN "C"
		    LET g_string = "SOLO CAPITAL"
		WHEN "I"
		    LET g_string = "SOLO INTERES "
		OTHERWISE
		    LET g_string = "CAPITAL + INTERES"
		    IF p1.msis = "S" THEN
			LET g_string = g_string CLIPPED,
					" (INC. IGV DEL INTERES)"
		    END IF
		END CASE
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED

		IF p1.tcre = "T" THEN
		    CASE p1.tcuo
		    WHEN 0
			LET g_string = "TOTAL PRESTAMOS"
		    WHEN 1
			LET g_string = "CREDITOS MENSUALES"
		    WHEN 2
			LET g_string = "CREDITOS SEMANALES"
		    END CASE
		ELSE
		    CASE p1.tcr1
		    WHEN 2
			LET g_string = "Tipo de Credito: MES"
		    WHEN 3
			LET g_string = "Tipo de Credito: CONSUMO"
		    OTHERWISE
			LET g_string = "Tipo de Credito: Del ",
					p1.tcre1 USING "<<<"," al ",
					p1.tcre2 USING "<<<"
		    END CASE
		    CASE p1.tcuo
		    WHEN 1
			LET g_string = g_string CLIPPED, ", CUOTAS MENSUALES"
		    WHEN 2
			LET g_string = g_string CLIPPED, ", CUOTAS SEMANALES"
		    END CASE
		END IF

		PRINT COLUMN   1,g_string CLIPPED;
		CASE p1.tcar
		WHEN 0
		    LET g_string = "TOTAL CARTERA"
		WHEN 1
		    LET g_string = "SIN PROVISION ANIOS ANTERIORES"
		WHEN 2
		    LET g_string = "SIN PROVISION TOTAL"
		WHEN 3
		    LET g_string = "PROVISION A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = "PROVISION ANIO ACTUAL"
		WHEN 5
		    LET g_string = "TOTAL PROVISION"
		END CASE
		CASE p1.tcas
		WHEN 0
		    LET g_string = g_string CLIPPED," "
		WHEN 1
		    LET g_string = g_string CLIPPED,
				"- SIN CASTIGOS A¥OS ANTERIORES"
		WHEN 2
		    LET g_string = g_string CLIPPED
				,"- SIN CASTIGOS TOTALES"
		WHEN 3
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥O ACTUAL"
		WHEN 5
		    LET g_string = g_string CLIPPED
				,"- TOTAL CASTIGOS"
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		LET g_string = "Tipo d/Cambio: ", g_tcam USING "<&.&&&"
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
	
		LET g_string = ""
		CASE p4.cart
		    WHEN 0
		  # (@#)19-A - Inicio
			#LET g_string = g_string CLIPPED, "TOTAL CARTERA (ELECTRODOMESTICOS + MOTOS)"
			LET g_string = g_string CLIPPED, "TOTAL CARTERA"
		  #  WHEN 1
			#LET g_string = g_string CLIPPED, "CARTERA DE ELECTRODOMESTICOS"
		  #  WHEN 2
			#LET g_string = g_string CLIPPED, "CARTERA DE MOTOS"
			OTHERWISE
			LET g_string = g_string CLIPPED, "CARTERA DE ",p4.dcar
			IF p4.cart = 5 THEN
					LET g_string = g_string CLIPPED, " - ",p4.defe
			END IF
			# (@#)19-A - Fin
		END CASE
		PRINT COLUMN 1,g_string CLIPPED;

		LET g_string = ""
		CASE p4.diap
		    WHEN 0
			LET g_string = g_string CLIPPED, "TOTAL CARTERA (INCLUYE TODOS LOS DIAS DE PAGO DEL CREDITO)"
		    WHEN 1
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 4"
		    WHEN 5
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 9"
		    WHEN 10
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 14"
		    WHEN 15
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 19"
		    WHEN 20
			LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 24"
		    WHEN 25
			LET g_string = g_string CLIPPED, "DIAS DE PAGO MAYORES A ",p4.diap
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		
		IF p1.itr7 = "S" THEN
			LET l_desplaza = 30
			LET l_pres = 217
		ELSE
			LET l_pres = 187
			LET l_desplaza = 0
		END IF

	FOR i=1 TO g_ancho-1+l_desplaza PRINT "-"; END FOR PRINT "-"

	IF p1.itr7 = "S" THEN	
		PRINT COLUMN  7+l_age1,"\\", 
		      COLUMN  23+l_age1,"-------------------   T o t a l e s ",
		      COLUMN  61+l_age1,"----------------",
		      COLUMN  79+l_age1,"|  ---  de 1 a 8 dias  --- ",
		      COLUMN  74+l_desplaza+l_age1,"|  ----  1 a 30 dias  ---",
		      COLUMN 103+l_desplaza+l_age1,"|  ---  31 a 60 dias  ---",
		      COLUMN 130+l_desplaza+l_age1,"|  ---  61 a 90 dias  ---",
		      COLUMN 157+l_desplaza+l_age1,"|  ---  91 a 120 dias  --",
		      COLUMN 184+l_desplaza+l_age1,"|  ---  mas de 120 d  ---";
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_desplaza+l_age1,"|  Ctas"
		ELSE
		      PRINT 
		END IF
		
	ELSE	
		PRINT COLUMN  7+l_age1,"\\", 
		      COLUMN  23+l_age1,"-------------------   T o t a l e s ",
		      COLUMN  61+l_age1,"----------------",
		      COLUMN  79+l_age1,"|  ----  1 a 30 dias  ---",
		      COLUMN 106+l_age1,"|  ---  31 a 60 dias  ---",
		      COLUMN 133+l_age1,"|  ---  61 a 90 dias  ---",
		      COLUMN 160+l_age1,"|  ---  91 a 120 dias  --",
		      COLUMN 187+l_age1,"|  ---  mas de 120 d  ---";
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_age1,"|  Ctas"
		    ELSE
		      PRINT
		END IF
	END IF 
		PRINT COLUMN  8+l_age1,"\\", 
		      COLUMN  26+l_age1,"General",
		      COLUMN  37+l_age1,"Ctas",
		      COLUMN  45+l_age1,"Vigente",
		      COLUMN  56+l_age1,"Vencido",
		      COLUMN  67+l_age1,"%",
		      COLUMN  73+l_age1,"Ctas.";
		LET j = 79
		
		WHILE j <= l_pres
		    PRINT COLUMN  j +l_age1  ,"|     Atraso",
			  COLUMN  j+16+l_age1,"%",
			  COLUMN  j+21+l_age1,"Ctas";
		    LET j = j + 27
		END WHILE
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 214+l_desplaza+l_age1,"| Pdtvs";
		END IF
		SKIP 1 LINE
		IF p1.ctpl =1 THEN
			LET l_agen = "Empresa \\ Plaza - Agencia \\ Limite" 	
		ELSE   
			LET l_agen = "Agencia \\ Limite" 						
		END IF
			PRINT COLUMN   1,l_agen CLIPPED; 			
		IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
			p1.tdat = "T" AND p1.tcar = 1  ) OR
			(p1.msis MATCHES "[TF]" AND p1.tcre1 > 29 AND 
			
			( p1.cmon = 3 OR p1.cmon = 4 ) AND p1.tdat = "C" AND p1.tcar <= 1) THEN
			
			PRINT COLUMN  67+l_age1,g_plim[1]	USING "&.&";	
			FOR j = 2 TO 6
			
				IF p1.itr7 = "S" THEN
					IF j <> 6 THEN
						LET l_form = "##&.&"
					ELSE
						LET l_form = "##&.&&"
					END IF
				ELSE
					IF j < 6 THEN
						LET l_form = "##&.&"
					ELSE
						LET l_form = "##&.&&"
					END IF
				END IF
				
				LET k = ((j - 2)* 27) + 79
				
				PRINT COLUMN k+13+l_desplaza+l_age1,g_plim[j]	USING l_form;	
			END FOR
			PRINT
		ELSE
			FOR j = 2 TO 6
				LET k = ((j - 2)* 27) + 79
				PRINT COLUMN  k+l_age1,"|";
			END FOR
			PRINT
		END IF
		FOR i=1 TO g_ancho-1+l_desplaza PRINT "-"; END FOR PRINT "-"
	
	BEFORE GROUP OF r.csuc
		LET g_ctass = 0
		IF r.csuc = 99 THEN
			
			NEED 2 LINES
			IF g_impt > 0 AND g_impv > 0 THEN
			LET l_porc = g_impv / g_impt * 100
			ELSE
			LET l_porc = NULL
			END IF
			FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
			PRINT COLUMN   1,"SUBTOTAL",
			   COLUMN  22+l_age1,g_impt/g_miles		USING "###,###,###",
			   COLUMN  34+l_age1,g_numc			USING "###,###",
			   COLUMN  42+l_age1,(g_impt-g_impv)/g_miles	USING "###,###,###",	
			   COLUMN  54+l_age1,g_impv/g_miles		USING "##,###,###",	
			  
			   COLUMN  65+l_age1,l_porc		USING "##&.&", 	
			   COLUMN  71+l_age1,g_numv		USING "###,###";

			IF p1.itr7 = "S" THEN
				LET l_limite = 6
			ELSE
				LET l_limite = 5
			END IF
	
			FOR j = 1 TO l_limite
				LET k = ((j - 1) * 27) + 79
				IF g_impt > 0 AND g_tott[j].impv > 0 THEN
				    LET l_porc = g_tott[j].impv / g_impt * 100
				ELSE
				    LET l_porc = NULL
				END IF
	
				IF p1.itr7 = "S" THEN
				
					IF j <> 6 THEN	
						
						LET l_form = "##&.&"
					ELSE
						LET l_form = "##&.&&"
					END IF
				    
				ELSE
					
					IF j < 5 THEN	
					
						LET l_form = "##&.&" 
					ELSE
						LET l_form = "##&.&&"
					END IF
				END IF
	
				PRINT COLUMN k+l_age1  ,"|",
				     
				      COLUMN k+1+l_age1 ,g_tott[j].impv / g_miles  USING "###,###,###",
				      COLUMN k+13+l_age1,l_porc	  USING l_form,
				      COLUMN k+19+l_age1,g_tott[j].numc  USING "##,###";
			END FOR
			IF p1.ctap = "S" THEN	
				
				PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctasst USING "###,###"  
			ELSE
				PRINT
			END IF	
			
		END IF
		LET l_fila = 0
		LET l_imst = 0
		LET l_imsv = 0
		LET l_nums = 0
		LET l_nusv = 0
		FOR j = 1 TO 6
		    LET g_subt[j].impv = 0
		    LET g_subt[j].numc = 0

		END FOR
		IF r.csuc <> 1 THEN
			PRINT
		END IF
	
	BEFORE GROUP OF r.agep
		LET g_ctasp = 0
		IF r.csuc < 98 THEN LET l_fila = l_fila + 1 END IF
		CALL f5030_calc_totales_b_ef052(r.agen,r.plza)
		    RETURNING l_impt, l_impv, l_numc, l_numv
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF

		IF p1.ctpl =1 THEN
			LET l_retl = f5021_busca_emp_ef052(r.plza)
			LET l_agen = l_retl[1,10],"   ",r.agen USING "###","-",f5022_buscar_descripcion_agencia_ef052(r.plza) CLIPPED
		ELSE 
			LET l_agen = f5020_busca_agen_ef052(r.agen) CLIPPED	
		END IF 

		PRINT 
		      COLUMN   1,l_agen CLIPPED, 
		 
		      COLUMN  23+l_age1,l_impt/g_miles		USING "##,###,###",  
		      COLUMN  34+l_age1,l_numc		USING "###,###",    
		      COLUMN  43+l_age1,(l_impt-l_impv)/g_miles	USING "##,###,###",	
		      COLUMN  54+l_age1,l_impv/g_miles		USING "##,###,###",
		      COLUMN  65+l_age1,l_porc		USING "##&.&",
		      COLUMN  71+l_age1,l_numv		USING "###,###";
		LET l_imst = l_imst + l_impt
		LET l_imsv = l_imsv + l_impv
		LET l_nums = l_nums + l_numc
		LET l_nusv = l_nusv + l_numv
		##
		LET g_impt = g_impt + l_impt
		LET g_impv = g_impv + l_impv
		LET g_numc = g_numc + l_numc
		LET g_numv = g_numv + l_numv
		##
		LET k = 1
		WHILE k < r.plzo
		    LET j = ((k -1) * 27) + 79
		    PRINT COLUMN j+l_age1,"|";
		    LET k = k + 1
		END WHILE

	ON EVERY ROW
		IF r.plzo > 0 THEN
			LET j = ((r.plzo - 1) * 27) + 79
			IF l_impt > 0 AND r.impt > 0 THEN
				LET l_porc = r.impt / l_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
        
			IF p1.itr7 = "S" THEN
			
				IF r.plzo <> 6 THEN
				
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
				IF r.plzo < 5 THEN
				
					LET l_form = "##&.&" 
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF
				
			PRINT COLUMN j+l_age1   ,"|",
			      COLUMN j+3+l_age1 ,r.impt / g_miles	USING "#,###,###",	
			      COLUMN j+13+l_age1,l_porc	USING l_form,
			      COLUMN j+19+l_age1,r.numc	USING "##,###";
			LET k = r.plzo
			LET g_subt[k].impv = g_subt[k].impv + r.impt
			LET g_subt[k].numc = g_subt[k].numc + r.numc
			##
			LET g_tott[k].impv = g_tott[k].impv + r.impt
			LET g_tott[k].numc = g_tott[k].numc + r.numc
		END IF
        
	AFTER GROUP OF r.agep
		LET k = r.plzo
        
		LET g_ctass = g_ctass + g_ctasp
		LET g_ctast = g_ctast + g_ctasp
		LET g_ctasst = g_ctasst + g_ctasp
		IF p1.ctap = "S" THEN
			PRINT COLUMN 214+l_desplaza+l_age1,"M",g_ctasp USING "##,###" 
		ELSE
			PRINT
		END IF
		IF r.agen = 88 THEN
			FOR x = 1 TO 2
				CALL f5035_calc_totales_ef052(r.agen,x)
					RETURNING l_impt1, l_impv1, l_numc1, l_numv1
				IF l_impt1 > 0 AND l_impv1 > 0 THEN
					LET l_porc1 = l_impv1 / l_impt1 * 100
				ELSE
					LET l_porc1 = NULL
				END IF
				IF x = 1 THEN
					IF r.agen = 88 THEN
						PRINT COLUMN   3+l_age1,"O.P. CxC";
					ELSE
						PRINT COLUMN   3+l_age1,"Cred. Consumo";
					END IF
				ELSE
					IF r.agen = 88 THEN
						PRINT COLUMN   3+l_age1,"O.P. PresxArtf";
					ELSE
						PRINT COLUMN   3+l_age1,"Microcredito";
					END IF
				END IF
				PRINT COLUMN  23+l_age1,l_impt1 / g_miles                USING "##,###,###",       
				      COLUMN  34+l_age1,l_numc1                USING "###,###",         
				      COLUMN  42+l_age1,(l_impt1-l_impv1) / g_miles        USING "###,###,###", 
				      COLUMN  55+l_age1,l_impv1 / g_miles                USING "#,###,###", 
				      COLUMN  65+l_age1,l_porc1                USING "##&.&",    
				      COLUMN  71+l_age1,l_numv1                USING "###,###";  
			
				DECLARE q_088 CURSOR FOR
				SELECT plzo,SUM(impt),SUM(numc)
				FROM ef052a
				WHERE tipo = x
				AND   cloc = r.agen
				GROUP BY 1
				ORDER BY 1
				
				FOREACH q_088 INTO l1.*
			
					IF l1.plzo > 0 THEN
						LET j = ((l1.plzo - 1) * 27) + 79
						IF l_impt1 > 0 AND l1.impt > 0 THEN
							LET l_porc = l1.impt / l_impt1 * 100
						ELSE
							LET l_porc = NULL
						END IF
			
						IF p1.itr7 = "S" THEN
						
							IF l1.plzo <> 6  THEN	
								
								LET l_form = "##&.&"
							ELSE
								LET l_form = "##&.&&"
							END IF
						ELSE
							IF l1.plzo < 5 THEN
								
								LET l_form = "##&.&" 
							ELSE
								LET l_form = "##&.&" 
							END IF
						END IF
						PRINT COLUMN j+l_age1   ,"|",
						      COLUMN j+3+l_age1 ,l1.impt / g_miles       USING "#,###,###",	
						      COLUMN j+13+l_age1,l_porc        USING l_form,
						      COLUMN j+19+l_age1,l1.numc        USING "##,###";
					END IF
				END FOREACH
				PRINT
			END FOR
		END IF
        
	AFTER GROUP OF r.csuc
		IF l_fila > 1 THEN
	
			NEED 2 LINES
			IF l_imst > 0 AND l_imsv > 0 THEN
				LET l_porc = l_imsv / l_imst * 100
			ELSE
				LET l_porc = NULL
			END IF
			FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
			PRINT COLUMN   1+l_age1,"Suc. ",f5050_busca_csuc_ef052(r.csuc),
				  COLUMN  23+l_age1,l_imst / g_miles		USING "##,###,###",	
				  COLUMN  34+l_age1,l_nums		USING "###,###",
				  COLUMN  42+l_age1,(l_imst-l_imsv) / g_miles	USING "###,###,###",	
				  COLUMN  54+l_age1,l_imsv / g_miles		USING "##,###,###",					  
				  COLUMN  65+l_age1,l_porc		USING "##&.&",
				  COLUMN  71+l_age1,l_nusv		USING "###,###";
		 
				IF p1.itr7 = "S" THEN
					LET l_limite = 6
				ELSE
					LET l_limite = 5
				END IF
				
				FOR j = 1 TO l_limite
					LET k = ((j - 1) * 27) + 79
					IF l_imst > 0 AND g_subt[j].impv > 0 THEN
						LET l_porc = g_subt[j].impv / l_imst * 100
					ELSE
						LET l_porc = NULL
					END IF
								
					IF p1.itr7 = "S" THEN
					
						IF j <> 6  THEN	
							
							LET l_form = "##&.&"
						ELSE
							LET l_form = "##&.&&"
						END IF
					ELSE
						
						IF j = 5 THEN	
							LET l_form = "##&.&&" 
						ELSE				
							LET l_form = "##&.&"	
						END IF
					END IF
					PRINT COLUMN k+l_age1   ,"|",
					      COLUMN k+1+l_age1 ,g_subt[j].impv / g_miles USING "###,###,###",	
					      COLUMN k+13+l_age1,l_porc	  USING l_form,
					      COLUMN k+19+l_age1,g_subt[j].numc  USING "##,###";
				END FOR
			IF p1.ctap = "S" THEN
				PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctass USING "##,###"
			ELSE
				PRINT
			END IF
	
		END IF
        
	ON LAST ROW
		NEED 2 LINES
		IF g_impt > 0 AND g_impv > 0 THEN
			LET l_porc = g_impv / g_impt * 100
		ELSE
			LET l_porc = NULL
		END IF
		FOR i=23 TO g_ancho-1+l_desplaza PRINT COLUMN i,"-"; END FOR PRINT "-"
		PRINT COLUMN   1,"TOTAL COMPA¥IA",
		      COLUMN  22+l_age1,g_impt / g_miles	USING "###,###,###",		
		      COLUMN  34+l_age1,g_numc		USING "###,###",
		      COLUMN  42+l_age1,(g_impt-g_impv) / g_miles	USING "###,###,###",	
		      COLUMN  54+l_age1,g_impv / g_miles		USING "##,###,###",	
		      COLUMN  65+l_age1,l_porc		USING "##&.&",
		      COLUMN  71+l_age1,g_numv		USING "###,###"; 

		IF p1.itr7 = "S" THEN
			LET l_limite = 6
		ELSE
			LET l_limite = 5
		END IF
			
		FOR j = 1 TO l_limite
			LET k = ((j - 1) * 27) + 79
			IF g_impt > 0 AND g_tott[j].impv > 0 THEN
				LET l_porc = g_tott[j].impv / g_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
						
			IF p1.itr7 = "S" THEN
				IF j <> 6 THEN	
					LET l_form = "##&.&"
					
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
			
				IF j < 5 THEN	
					
					LET l_form = "##&.&" 
				ELSE
					LET l_form = "##&.&" 
				END IF
			END IF
			PRINT COLUMN k+l_age1   ,"|",
				
				COLUMN k+1+l_age1 ,g_tott[j].impv / g_miles	USING "###,###,###",	
				COLUMN k+13+l_age1,l_porc		USING l_form,
				COLUMN k+19+l_age1,g_tott[j].numc	USING "##,###";
		END FOR
		IF p1.ctap = "S" THEN
			
			PRINT COLUMN 214+l_desplaza+l_age1,"|",g_ctast USING "###,###" 
		ELSE
			PRINT
		END IF
		
	PAGE TRAILER
		PRINT ASCII 18
END REPORT
#FIN (@#)15-A  


{VAT Ini 06/11/2009 Pasar Reportes a Excel}
FUNCTION f1100_proceso_impr_excel_ef052()
		DEFINE	r,r1		RECORD
				czon	SMALLINT,	# (@#)6-A
				fech	DATE,
				csuc	SMALLINT,
				agen	SMALLINT,
				plzo	SMALLINT,
				tpro	INTEGER,
				gpro	INTEGER,
				impt	DECIMAL(14,2),
				numc	INTEGER
				END RECORD,
		l_fila		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER,
		l_porc		DECIMAL(7,2),
		l_imst, l_imsv	DECIMAL(14,2),
		l_nums, l_nusv	INTEGER,
		l_form		CHAR(7),
		l_impt1, l_impv1	DECIMAL(14,2),
		l_numc1, l_numv1	INTEGER,
		l_porc1		DECIMAL(7,2),
		l1	RECORD
			plzo    SMALLINT,
			impt    DECIMAL(14,2),
			numc	INTEGER
			END RECORD,
		x	SMALLINT,
		l_pres	SMALLINT,
		l_desplaza SMALLINT,
		l_limite SMALLINT,
		l_colspan,l_colspan1,l_agen,l_agen1,l_plzoant SMALLINT,
		l_ctasp	INTEGER,
		l_titu,l_body,l_tit_pi,l_tit_pc,l_tit_pd,l_tit_p,l_tit_z VARCHAR(255),
		l_tit_zi,l_tit_s,l_tit_sc,l_tit_si,l_tit_a,l_tit_ar,l_td,l_tdi VARCHAR(255),
		l_time DATETIME HOUR TO SECOND,
		l_HTML	CHAR(3000),		# (@#)6-A
		l_celd	SMALLINT,		# (@#)7-A
		l_var2	SMALLINT		# (@#)7-A
				
	#Definir estilos
	LET l_titu  ="style=\"color:#000000;background:#FFFFFF;border:0px;font:12px Arial;"	
	LET l_body  ="style=\"font-family:Arial, Helvetica, sans-serif;font-size:12px;\""
	LET l_tit_pi="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_pc="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_pd="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:right;\""	
	LET l_tit_p ="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_z ="style=\"background-color:#660000;color:#FFFFFF;padding:2px;text-align:right\""
	LET l_tit_zi="style=\"background-color:#660000;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_s ="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:right\""
	LET l_tit_sc="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_si="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_a ="style=\"padding:2px;text-align:left;background:#006699;color:#FFFFFF;\""
	LET l_tit_ar="style=\"padding:2px;text-align:right;background:#006699;color:#FFFFFF;\""
	LET l_td    ="style=\"text-align:right;\""
	LET l_tdi   ="style=\"text-align:left;\""
	
	LET l_time=CURRENT
	IF p1.itr7 = "S" THEN
		IF p1.ctap = "S" THEN
			LET l_colspan = 22
		ELSE
			LET l_colspan = 20
		END IF
	ELSE
		IF p1.ctap = "S" THEN
			LET l_colspan = 19
		ELSE
			LET l_colspan = 17
		END IF
	END IF
	
	# Inicio (@#)3-A
	IF p1.cmon = 4 THEN	# Dividir entre miles para expresar todo en miles de soles
		LET g_miles = 1000
	ELSE
		LET g_miles = 1
	END IF
	# Fin (@#)3-A
#INICIO (@#)11-A
{	# Inicio (@#)4-A
	LET g_spool = 'ef052.r'
	# Fin (@#)4-A}
#(@#)22-A Inicio
#	LET g_spool = "ef052.xls" #(@#)11-A
#(@#)22-A Fin
#FIN (@#)11-A
	LET g_HTML="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
	LET g_HTML=g_HTML CLIPPED, "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
	LET g_HTML=g_HTML CLIPPED, "<head>"
	# Inicio (@#)3-A
	#LET g_HTML=g_HTML CLIPPED,"<style> .fdecimal { mso-number-format:0\.00;}</style>" #(@#)2-A
	LET g_HTML=g_HTML CLIPPED,'<style> ',
					'.fdecimal { mso-number-format:0\.0;}',
					'.fdecimal2 { mso-number-format:0\.00;}',
					'.fdecimal3 { mso-number-format:\"#,##0\";}',	# (@#)7-A
				' </style>' #(@#)2-A
	# Fin (@#)3-A
	LET g_HTML=g_HTML CLIPPED, "<meta http-equiv=\"Content-TYPE\" content=\"text/html; charset=iso-8859-1\" />"
	LET g_HTML=g_HTML CLIPPED, "<title>Reporte de Recuperacion de Cartera</title>"
	LET g_HTML=g_HTML CLIPPED, "</head>"
	LET g_HTML=g_HTML CLIPPED, "<body ",l_body,">"
	LET g_HTML=g_HTML CLIPPED, "<table cellspacing=\"2px\" cellpadding=\"1xp\" >"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">EFECTIVA </th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",t0.gbpmtnemp,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">",l_time,"</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\"><strong><font color=\"#990000\">ATRASO DE COBRANZA x ETAPAS AL ",p1.fech USING "dd/mm/yyyy","</font></strong></th>"	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:right;\">",TODAY,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">ef052</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"
	CASE p1.cmon
		WHEN 0
			LET g_string = "EXPRESADO EN US $ DOLARES (INCLUYE SOLES)"
		WHEN 1
			LET g_string = "NUEVOS SOLES"
		WHEN 2
			LET g_string = "DOLARES AMERICANOS"
		# Inicio (@#)3-A
		WHEN 4
			LET g_string = "EXPRESADO EN MILES DE NUEVOS SOLES (INCLUYE DOLARES)"
		# Fin (@#)3-A
		OTHERWISE
			LET g_string = "EXPRESADO EN NUEVOS SOLES (INCLUYE DOLARES)"
	END CASE	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	CASE p4.mcip
		WHEN 0
			LET g_string = "TOTAL (INCLUYE CREDITOS CON INTENCION DE PAGO)"
		WHEN 1
			LET g_string = "EXCLUYE CREDITOS CON INTENCION DE PAGO"
		WHEN 2
			LET g_string = "INCLUYE SOLO CREDITOS CON INTENCION DE PAGO"
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	CASE p4.tges
		WHEN 0
			#LET g_string = "TOTAL (ADCs + PROCs + ProcPAA)"	#Inicio (@#) 1-A
			#Inicio (@#)8-A
			#LET g_string = "TOTAL (ADCs + P1 + P2 + P3)"		#Inicio (@#) 1-A
			LET g_string = "TOTAL (ADCs + ECob + P1 + P2 + P3)"
			#Fin (@#)8-A
		# (@#)13-A Inicio
			IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
				LET g_string = "TOTAL (ADCs + ECob + P1 + P2 )"
			END IF
		# (@#)13-A Fin			
		WHEN 1
			LET g_string = "Adm.Cartera"
		WHEN 2
			#LET g_string = "Procuracion"		#Inicio (@#) 1-A
			LET g_string = "Procuracion P1"		#Inicio (@#) 1-A
		WHEN 3
			#LET g_string = "Procuracion PAA"	#Inicio (@#) 1-A
			LET g_string = "Procuracion P2"		#Inicio (@#) 1-A
		WHEN 4						#Inicio (@#) 1-A
			#LET g_string = "Procuracion PAA"	#Inicio (@#) 1-A
			LET g_string = "Procuracion P3"		#Inicio (@#) 1-A
		WHEN 5						#Inicio (@#)8-A
			LET g_string = "Ejec.Cobranza"		#Inicio (@#)8-A
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"4\" ",l_titu CLIPPED,"text-align:left;\">Tipo de Gestor: ",g_string CLIPPED,"</th>"
	CASE p1.msis
		WHEN "S"
			LET g_string = "CREDITOS EFE (SAI)"
		WHEN "F"
			#LET g_string = "CREDITOS EDPYME (SFI)"
			LET g_string = "CREDITOS FINANCIERA (SFI)"
		OTHERWISE
			#LET g_string = "CONSOLIDADO EFE + EDPYME (SAI + SFI)"
			LET g_string = "CONSOLIDADO EFE + FINANCIERA (SAI + SFI)"
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	#INICIO (@#)11-A
                CASE p1.microz 
                	WHEN "I"
                		LET g_string = "MICROZONAS ITINERANTES"
                	WHEN "N"
                		LET g_string = "MICROZONAS NO ITINERANTES"
                	WHEN "D"
										LET g_string = "MICROZONAS NO DEFINIDAS" 
                	OTHERWISE
                		LET g_string = "MICROZONAS ITINERANTES Y NO ITINERANTES Y NO DEFINIDAS"
                END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	 #FIN (@#)11-A
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">Agencias: Del ", p1.agen1 USING "<<<"," a ", p1.agen2 USING"<<<","</th>"
	CASE p1.tcar
		WHEN 0
			LET g_string = "TOTAL CARTERA"
		WHEN 1
			LET g_string = "SIN PROVISION ANIOS ANTERIORES"
		WHEN 2
			LET g_string = "SIN PROVISION TOTAL"
		WHEN 3
			LET g_string = "PROVISION A¥OS ANTERIORES"
		WHEN 4
			LET g_string = "PROVISION A¥O ACTUAL"
		WHEN 5
			LET g_string = "TOTAL PROVISION"
		END CASE
		CASE p1.tcas
		WHEN 0
			LET g_string = g_string CLIPPED," "
		WHEN 1
			LET g_string = g_string CLIPPED,"- SIN CASTIGOS A¥OS ANTERIORES"
		WHEN 2
			LET g_string = g_string CLIPPED,"- SIN CASTIGOS TOTALES"
		WHEN 3
			LET g_string = g_string CLIPPED,"- CON CASTIGOS A¥OS ANTERIORES"
		WHEN 4
			LET g_string = g_string CLIPPED,"- CON CASTIGOS A¥O ACTUAL"
		WHEN 5
			LET g_string = g_string CLIPPED,"- TOTAL CASTIGOS"
		END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	CASE p1.tdat
		WHEN "C"
			LET g_string = "SOLO CAPITAL"
		WHEN "I"
			LET g_string = "SOLO INTERES "
		OTHERWISE
			LET g_string = "CAPITAL + INTERES"
		IF p1.msis = "S" THEN
			LET g_string = g_string CLIPPED," (INC. IGV DEL INTERES)"
		END IF
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	IF p1.tcre = "T" THEN
		CASE p1.tcuo
			WHEN 0
				LET g_string = "TOTAL PRESTAMOS"
			WHEN 1
				LET g_string = "CREDITOS MENSUALES"
			WHEN 2
				LET g_string = "CREDITOS SEMANALES"
			END CASE
	ELSE
		CASE p1.tcr1
			WHEN 2
				LET g_string = "Tipo de Credito: MES"
			WHEN 3
				LET g_string = "Tipo de Credito: CONSUMO"
			OTHERWISE
				LET g_string = "Tipo de Credito: Del ",	p1.tcre1 USING "<<<"," al ",p1.tcre2 USING "<<<"
			END CASE
		CASE p1.tcuo
			WHEN 1
				LET g_string = g_string CLIPPED, ", CUOTAS MENSUALES"
			WHEN 2
				LET g_string = g_string CLIPPED, ", CUOTAS SEMANALES"
		END CASE
	END IF
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">",g_string CLIPPED,"</th>"
	# Inicio (@#)9-A
	#LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan,">&nbsp;</th>"
	LET g_string = g_desc
	#PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	# Fin (@#)9-A
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">Tipo d/Cambio: ", g_tcam USING "<&.&&&","</th>"	
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	# Inicio (@#)4-A
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_string = ""
	CASE p4.cart
	    WHEN 0
	  # (@#)19-A - Inicio
		#LET g_string = g_string CLIPPED, "TOTAL CARTERA (ELECTRODOMESTICOS + MOTOS)"
		LET g_string = g_string CLIPPED, "TOTAL CARTERA"
	  #  WHEN 1
		#LET g_string = g_string CLIPPED, "CARTERA DE ELECTRODOMESTICOS"
	  #  WHEN 2
		#LET g_string = g_string CLIPPED, "CARTERA DE MOTOS"
		OTHERWISE
		LET g_string = g_string CLIPPED, "CARTERA DE ",p4.dcar
		IF p4.cart = 5 THEN
			 LET g_string = g_string CLIPPED, " - ",p4.defe
		END IF
		# (@#)19-A - Fin
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	# Fin (@#)4-A
	
	# Inicio (@#)5-A
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_string = ""
	CASE p4.diap
	    WHEN 0
		LET g_string = g_string CLIPPED, "TOTAL CARTERA (INCLUYE TODOS LOS DIAS DE PAGO DEL CREDITO)"
	    WHEN 1
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 4"
	    WHEN 5
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 9"
	    WHEN 10
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 14"
	    WHEN 15
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 19"
	    WHEN 20
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 24"
	    WHEN 25
		LET g_string = g_string CLIPPED, "DIAS DE PAGO MAYORES A ",p4.diap
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	# Fin (@#)5-A
	#--------------------------	
#(@#)22-A Inicio
#	LET g_Html = "echo '", g_Html CLIPPED, "' > ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	#--------------------------
	
	LET g_HTML="<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"4\" ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"6\" ",l_tit_p,">T o t a l e s</th>"
	IF p1.itr7 = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_tit_p,">de 1 a 8 dias</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,"> 1 a 30 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">31 a 60 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">61 a 90 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">91 a 120 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">mas de 120 d</th>"
	IF p1.ctap = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 2\" ",l_tit_p,">Ctas</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">General</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Vigente</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Vencido</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	IF p1.itr7 = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	IF p1.ctap = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Pdtvs</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	#LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">SUB TOTAL</th>"	# (@#)6-A
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Zona</th>"		# (@#)6-A
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Sucursal</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Agencia \</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Limite</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
		p1.tdat = "T" AND p1.tcar = 1  ) OR
		(p1.msis MATCHES "[TF]" AND p1.tcre1 > 29 AND 
		# Inicio (@#)3-A
		# Si es moneda 3 o 4 deba hacer lo mismo
		#p1.cmon = 3 AND p1.tdat = "C" AND p1.tcar <= 1) THEN
		( p1.cmon = 3 OR p1.cmon = 4 ) AND p1.tdat = "C" AND p1.tcar <= 1) THEN
		# Fin (@#)3-A
		#LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[1]	USING "&.&&","</th>"	# (@#)3-A
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[1]	USING "&.&","</th>"	# (@#)3-A
		FOR j = 2 TO 6
			# Inicio (@#)3-A
			IF p1.itr7 = "S" THEN
				IF j <> 6 THEN
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
				IF j < 6 THEN
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF
			# Fin (@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			#LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[j]	USING "&.&&","</th>"	# (@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[j]	USING l_form,"</th>"	# (@#)3-A
		END FOR
	ELSE
		LET l_colspan = 21
		FOR i = 1 TO l_colspan
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END FOR
	END IF
	IF p1.itr7 = "S" THEN
		IF p1.ctap = "S" THEN
			LET l_colspan = 6
			FOR i = 1 TO l_colspan 
				LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			END FOR
		ELSE			
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END IF
	ELSE
		IF p1.ctap = "S" THEN
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"			
		ELSE
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END IF
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	#--------------------------
#(@#)22-A Inicio
#	LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	#--------------------------
	
	DECLARE q_curs1 CURSOR FOR
		#SELECT MAX(fech),csuc,agen,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc) 		# (@#)6-A
		SELECT efzcbczon,MAX(fech),csuc,agen,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc) 	# (@#)6-A
		  #FROM ef052			# (@#)6-A
		  #FROM ef052,tmp_efzcb		# (@#)6-A
		  FROM ef052,OUTER tmp_efzcb		# (@#)7-A
		 WHERE csuc <> 98
		   AND agen = efzcbplaz		# (@#)6-A
		 GROUP BY efzcbczon,csuc, agen, plzo	# (@#)6-A
		 ORDER BY csuc, agen, plzo	# (@#)6-A
		 #GROUP BY efzcbczon,csuc, agen, plzo	# (@#)6-A
		 #ORDER BY efzcbczon,csuc, agen, plzo	# (@#)6-A

	INITIALIZE r.* TO NULL
	
	LET l_agen = 0
	LET l_plzoant = 0
	
	LET l_var2 = 0		# (@#)7-A
	LET l_celd = 13		# (@#)7-A
	FOREACH q_curs1 INTO r.*
		CALL f5030_calc_totales_ef052(r.agen)
		    RETURNING l_impt, l_impv, l_numc, l_numv
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		IF r.agen <> l_agen THEN
			IF l_agen > 0 THEN
				IF p1.ctap = "S" THEN
					IF l_colspan1 > 0 THEN
						FOR i = 1 TO l_colspan1
							LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
						END FOR
					END IF
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">M</td>"
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
					LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_tml
					OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
				ELSE
					LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_Html
          OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
				END IF
			END IF
			LET l_agen = r.agen
			IF r.agen = 50 OR r.agen = 88 THEN
				# Inicio (@#)7-A
				IF l_var2 = 0 THEN
					LET g_HTML="<tr>"
					LET g_HTML=g_HTML CLIPPED, "<td>SUBTOTAL</td><td>SUBTOTAL</td><td></td><td></td><td>=SUMA(E13:E",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(F13:F",l_celd - 1 USING "<<<<",")</td><td>=SUMA(G13:G",l_celd - 1 USING "<<<<",")</td><td>=SUMA(H13:H",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(H13:H",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(J13:J",l_celd - 1 USING "<<<<",")</td><td>=SUMA(K13:K",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(k13:K",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(M13:M",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(N13:N",l_celd - 1 USING "<<<<",")</td><td>=SUMA(N13:N",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(P13:P",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(Q13:Q",l_celd - 1 USING "<<<<",")</td><td>=SUMA(Q13:Q",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(S13:S",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(T13:T",l_celd - 1 USING "<<<<",")</td><td>=SUMA(T13:T",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(V13:V",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(W13:W",l_celd - 1 USING "<<<<",")</td><td>=SUMA(W13:W",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(Y13:Y",l_celd - 1 USING "<<<<",")</td>"
					LET g_HTML=g_HTML CLIPPED,"</tr>"
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_Html
          OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
					LET l_var2 = 1
				END IF
				# Fin (@#)7-A
				LET g_HTML="<tr>"
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">SUB TOTAL 2</td>"
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>"
			ELSE
				LET g_HTML="<tr>"
				#LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">SUB TOTAL 1</td>"	# (@#)6-A
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5040_busca_dzon_ef052(r.czon),"</td>"	# (@#)6-A
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5050_busca_csuc_ef052(r.csuc),"</td>"				
				LET l_celd = l_celd + 1 
			END IF
			LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5020_busca_agen_ef052(r.agen),"</td>"
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",l_impt / g_miles USING "-<<,<<<,<<<.&&","</td>"	#(@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_numc		USING "###,###","</td>"
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",(l_impt-l_impv) / g_miles USING "-<<,<<<,<<<.&&","</td>"	#(@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",l_impv / g_miles USING "-<<,<<<,<<<.&&","</td>"	#(@#)3-A
			# Inicio #(@#)3-A
			#LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc	USING "##&.&&","</td>" #(@#)2-A
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				ELSE
					IF r.plzo = 6 THEN
						LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				ELSE
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				END IF
			END IF
			# Fin #(@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_numv		USING "###,###","</td>"
		END IF
		
		IF r.plzo > 0 THEN				
			IF l_impt > 0 AND r.impt > 0 THEN
				LET l_porc = r.impt / l_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 1 THEN
					LET l_form = "##&.&" #(@#)2-A	# (@#)3-A
				ELSE
					IF r.plzo = 6 THEN	# (@#)3-A
						LET l_form = "##&.&&"	# (@#)3-A
					END IF	# (@#)3-A
				END IF
			ELSE
				IF r.plzo < 5 THEN
					#LET l_form = "##&.&&" #(@#)2-A
					LET l_form = "##&.&" #(@#)2-A		#(@#)3-A
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF 
			LET l_colspan = (r.plzo -(l_plzoant + 1))*3
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
			IF l_colspan > 0 THEN
				FOR i = 1 TO l_colspan
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
				END FOR
			END IF
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",r.impt / g_miles	USING "-<<,<<<,<<<.&&","</td>"	#(@#)3-A
			# Inicio #(@#)3-A
			#LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc	USING l_form,"</td>"	#(@#)3-A
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					#LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc	USING "##&.&&","</td>" #(@#)2-A
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				ELSE
					IF r.plzo = 6 THEN
						LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				ELSE
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" #(@#)2-A		#(@#)3-A
				END IF
			END IF
			# Fin #(@#)3-A
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",r.numc	USING "##,###","</td>"

			LET l_plzoant = r.plzo
			LET l_ctasp  = g_ctasp
		ELSE
			LET l_ctasp  = g_ctasp
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
			LET l_plzoant = r.plzo #(@#)10-A
		END IF
	END FOREACH
	IF p1.ctap = "S" THEN
		IF l_colspan1 > 0 THEN
			FOR i = 1 TO l_colspan1
				LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			END FOR
		END IF
		LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">M</td>"
		LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
		LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#		LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#		RUN g_Html
    OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	ELSE
		LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#		LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#		RUN g_Html
    OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	END IF
	# Inicio (@#)6-A
	## Imprimir total compañía
	CALL f1102_impr_total_compania_ef052()
	RETURNING l_HTML
		LET g_HTML=g_HTML CLIPPED,l_HTML CLIPPED
	# Fin (@#)6-A
	#--------------------------	
	LET g_Html = "</table></body></html>"
	#--------------------------	
#(@#)22-A Inicio	
#	LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	#--------------------------
END FUNCTION
{VAT Fin 06/11/2009 Pasar Reportes a Excel}
	
#INICIO (@#)15-A 
FUNCTION f1100_proceso_impr_excel_b_ef052()
		DEFINE	r,r1		RECORD
				czon	SMALLINT,	
				fech	DATE,
				csuc	SMALLINT,
				agep	INTEGER,#(@#)15-A - Inicio - Fin
				agen	SMALLINT,
				plzo	SMALLINT,
				plza	INTEGER,		
				tpro	INTEGER,
				gpro	INTEGER,
				impt	DECIMAL(14,2),
				numc	INTEGER
				END RECORD,
		l_fila		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER,
		l_porc		DECIMAL(7,2),
		l_imst, l_imsv	DECIMAL(14,2),
		l_nums, l_nusv	INTEGER,
		l_form		CHAR(7),
		l_impt1, l_impv1	DECIMAL(14,2),
		l_numc1, l_numv1	INTEGER,
		l_porc1		DECIMAL(7,2),
		l1	RECORD
			plzo    SMALLINT,
			impt    DECIMAL(14,2),
			numc	INTEGER
			END RECORD,
		x	SMALLINT,
		l_pres	SMALLINT,
		l_desplaza SMALLINT,
		l_limite SMALLINT,
		l_colspan,l_colspan1,l_agen,l_agen1,l_plzoant SMALLINT,
		l_ctasp	INTEGER,
		l_titu,l_body,l_tit_pi,l_tit_pc,l_tit_pd,l_tit_p,l_tit_z VARCHAR(255),
		l_tit_zi,l_tit_s,l_tit_sc,l_tit_si,l_tit_a,l_tit_ar,l_td,l_tdi VARCHAR(255),
		l_time DATETIME HOUR TO SECOND,
		l_HTML	CHAR(3000),	
		l_celd	SMALLINT,		
		l_var2	SMALLINT,		
		l_retl   CHAR(50),
		l_plaz  SMALLINT,
		l_txt	CHAR (550),
		l_agep	INTEGER  #(@#)15-A - Inicio - Fin
	#Definir estilos
	LET l_titu  ="style=\"color:#000000;background:#FFFFFF;border:0px;font:12px Arial;"	
	LET l_body  ="style=\"font-family:Arial, Helvetica, sans-serif;font-size:12px;\""
	LET l_tit_pi="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_pc="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_pd="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:right;\""	
	LET l_tit_p ="style=\"background-color:#000000;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_z ="style=\"background-color:#660000;color:#FFFFFF;padding:2px;text-align:right\""
	LET l_tit_zi="style=\"background-color:#660000;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_s ="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:right\""
	LET l_tit_sc="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:left;\""
	LET l_tit_si="style=\"background-color:#003366;color:#FFFFFF;padding:2px;text-align:center;\""
	LET l_tit_a ="style=\"padding:2px;text-align:left;background:#006699;color:#FFFFFF;\""
	LET l_tit_ar="style=\"padding:2px;text-align:right;background:#006699;color:#FFFFFF;\""
	LET l_td    ="style=\"text-align:right;\""
	LET l_tdi   ="style=\"text-align:left;\""
	
	LET l_time=CURRENT
	IF p1.itr7 = "S" THEN
		IF p1.ctap = "S" THEN
			LET l_colspan = 22
		ELSE
			LET l_colspan = 20
		END IF
	ELSE
		IF p1.ctap = "S" THEN
			LET l_colspan = 19
		ELSE
			LET l_colspan = 17
		END IF
	END IF
	
	IF p1.cmon = 4 THEN	# Dividir entre miles para expresar todo en miles de soles
		LET g_miles = 1000
	ELSE
		LET g_miles = 1
	END IF
#(@#)22-A Inicio
#	LET g_spool = "ef052.xls" 
#(@#)22-A Fin
	LET g_HTML="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
	LET g_HTML=g_HTML CLIPPED, "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
	LET g_HTML=g_HTML CLIPPED, "<head>"
	
	LET g_HTML=g_HTML CLIPPED,'<style> ',
					'.fdecimal { mso-number-format:0\.0;}',
					'.fdecimal2 { mso-number-format:0\.00;}',
					'.fdecimal3 { mso-number-format:\"#,##0\";}',	
				' </style>'
	LET g_HTML=g_HTML CLIPPED, "<meta http-equiv=\"Content-TYPE\" content=\"text/html; charset=iso-8859-1\" />"
	LET g_HTML=g_HTML CLIPPED, "<title>Reporte de Recuperacion de Cartera</title>"
	LET g_HTML=g_HTML CLIPPED, "</head>"
	LET g_HTML=g_HTML CLIPPED, "<body ",l_body,">"
	LET g_HTML=g_HTML CLIPPED, "<table cellspacing=\"2px\" cellpadding=\"1xp\" >"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">EFECTIVA </th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",t0.gbpmtnemp,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">",l_time,"</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\"><strong><font color=\"#990000\">ATRASO DE COBRANZA x ETAPAS AL ",p1.fech USING "dd/mm/yyyy","</font></strong></th>"	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:right;\">",TODAY,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_titu CLIPPED,"text-align:left;\">ef052</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_titu CLIPPED,"text-align:left;\">&nbsp;</th>"
	CASE p1.cmon
		WHEN 0
			LET g_string = "EXPRESADO EN US $ DOLARES (INCLUYE SOLES)"
		WHEN 1
			LET g_string = "NUEVOS SOLES"
		WHEN 2
			LET g_string = "DOLARES AMERICANOS"
		WHEN 4
			LET g_string = "EXPRESADO EN MILES DE NUEVOS SOLES (INCLUYE DOLARES)"
		OTHERWISE
			LET g_string = "EXPRESADO EN NUEVOS SOLES (INCLUYE DOLARES)"
	END CASE	
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	CASE p4.mcip
		WHEN 0
			LET g_string = "TOTAL (INCLUYE CREDITOS CON INTENCION DE PAGO)"
		WHEN 1
			LET g_string = "EXCLUYE CREDITOS CON INTENCION DE PAGO"
		WHEN 2
			LET g_string = "INCLUYE SOLO CREDITOS CON INTENCION DE PAGO"
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	CASE p4.tges
		WHEN 0			
			LET g_string = "TOTAL (ADCs + ECob + P1 + P2 + P3)"

			IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
				LET g_string = "TOTAL (ADCs + ECob + P1 + P2 )"
			END IF			
		WHEN 1
			LET g_string = "Adm.Cartera"
		WHEN 2			
			LET g_string = "Procuracion P1"		
		WHEN 3
			
			LET g_string = "Procuracion P2"		
		WHEN 4						
			LET g_string = "Procuracion P3"		
		WHEN 5						
			LET g_string = "Ejec.Cobranza"		
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"4\" ",l_titu CLIPPED,"text-align:left;\">Tipo de Gestor: ",g_string CLIPPED,"</th>"
	CASE p1.msis
		WHEN "S"
			LET g_string = "CREDITOS EFE (SAI)"
		WHEN "F"
			LET g_string = "CREDITOS FINANCIERA (SFI)"
		OTHERWISE
			LET g_string = "CONSOLIDADO EFE + FINANCIERA (SAI + SFI)"
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
                CASE p1.microz 
                	WHEN "I"
                		LET g_string = "MICROZONAS ITINERANTES"
                	WHEN "N"
                		LET g_string = "MICROZONAS NO ITINERANTES"
                	WHEN "D"
										LET g_string = "MICROZONAS NO DEFINIDAS" 
                	OTHERWISE
                		LET g_string = "MICROZONAS ITINERANTES Y NO ITINERANTES Y NO DEFINIDAS"
                END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">Agencias: Del ", p1.agen1 USING "<<<"," a ", p1.agen2 USING"<<<","</th>"
	CASE p1.tcar
		WHEN 0
			LET g_string = "TOTAL CARTERA"
		WHEN 1
			LET g_string = "SIN PROVISION ANIOS ANTERIORES"
		WHEN 2
			LET g_string = "SIN PROVISION TOTAL"
		WHEN 3
			LET g_string = "PROVISION A¥OS ANTERIORES"
		WHEN 4
			LET g_string = "PROVISION A¥O ACTUAL"
		WHEN 5
			LET g_string = "TOTAL PROVISION"
		END CASE
		CASE p1.tcas
		WHEN 0
			LET g_string = g_string CLIPPED," "
		WHEN 1
			LET g_string = g_string CLIPPED,"- SIN CASTIGOS A¥OS ANTERIORES"
		WHEN 2
			LET g_string = g_string CLIPPED,"- SIN CASTIGOS TOTALES"
		WHEN 3
			LET g_string = g_string CLIPPED,"- CON CASTIGOS A¥OS ANTERIORES"
		WHEN 4
			LET g_string = g_string CLIPPED,"- CON CASTIGOS A¥O ACTUAL"
		WHEN 5
			LET g_string = g_string CLIPPED,"- TOTAL CASTIGOS"
		END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	CASE p1.tdat
		WHEN "C"
			LET g_string = "SOLO CAPITAL"
		WHEN "I"
			LET g_string = "SOLO INTERES "
		OTHERWISE
			LET g_string = "CAPITAL + INTERES"
		IF p1.msis = "S" THEN
			LET g_string = g_string CLIPPED," (INC. IGV DEL INTERES)"
		END IF
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	IF p1.tcre = "T" THEN
		CASE p1.tcuo
			WHEN 0
				LET g_string = "TOTAL PRESTAMOS"
			WHEN 1
				LET g_string = "CREDITOS MENSUALES"
			WHEN 2
				LET g_string = "CREDITOS SEMANALES"
			END CASE
	ELSE
		CASE p1.tcr1
			WHEN 2
				LET g_string = "Tipo de Credito: MES"
			WHEN 3
				LET g_string = "Tipo de Credito: CONSUMO"
			OTHERWISE
				LET g_string = "Tipo de Credito: Del ",	p1.tcre1 USING "<<<"," al ",p1.tcre2 USING "<<<"
			END CASE
		CASE p1.tcuo
			WHEN 1
				LET g_string = g_string CLIPPED, ", CUOTAS MENSUALES"
			WHEN 2
				LET g_string = g_string CLIPPED, ", CUOTAS SEMANALES"
		END CASE
	END IF
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">",g_string CLIPPED,"</th>"
	LET g_string = g_desc
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:right;\">Tipo d/Cambio: ", g_tcam USING "<&.&&&","</th>"	
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_string = ""
	CASE p4.cart
	    WHEN 0
	  # (@#)19-A - Inicio
		#LET g_string = g_string CLIPPED, "TOTAL CARTERA (ELECTRODOMESTICOS + MOTOS)"
		LET g_string = g_string CLIPPED, "TOTAL CARTERA"
	  #  WHEN 1
		#LET g_string = g_string CLIPPED, "CARTERA DE ELECTRODOMESTICOS"
	  #  WHEN 2
		#LET g_string = g_string CLIPPED, "CARTERA DE MOTOS"
		OTHERWISE
		LET g_string = g_string CLIPPED, "CARTERA DE ",p4.dcar
		IF p4.cart = 5 THEN
			  LET g_string = g_string CLIPPED, " - ",p4.defe
		END IF
		# (@#)19-A - Fin
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 4\" ",l_titu CLIPPED,"text-align:left;\">",g_string CLIPPED,"</th>"
	IF (p1.crtl=0) THEN
	   LET l_retl="TODOS"
	ELSE
	   LET l_retl=f0412_obtener_descripcion_ef052(p1.crtl,524)
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:left;\"> RETAIL: ",l_retl CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_string = ""
	CASE p4.diap
	    WHEN 0
		LET g_string = g_string CLIPPED, "TOTAL CARTERA (INCLUYE TODOS LOS DIAS DE PAGO DEL CREDITO)"
	    WHEN 1
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 4"
	    WHEN 5
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 9"
	    WHEN 10
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 14"
	    WHEN 15
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 19"
	    WHEN 20
		LET g_string = g_string CLIPPED, "DIAS DE PAGO DEL ",p4.diap," AL 24"
	    WHEN 25
		LET g_string = g_string CLIPPED, "DIAS DE PAGO MAYORES A ",p4.diap
	END CASE
	LET g_HTML=g_HTML CLIPPED, "<th colspan=",l_colspan," ",l_titu CLIPPED,"text-align:center;\">",g_string CLIPPED,"</th>"
	LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#	LET g_Html = "echo '", g_Html CLIPPED, "' > ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	LET g_HTML="<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"4\" ",l_tit_pi,">&nbsp;</th>"
	IF p1.ctpl=1 THEN
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	END IF

	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"6\" ",l_tit_p,">T o t a l e s</th>"
	IF p1.itr7 = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 3\" ",l_tit_p,">de 1 a 8 dias</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,"> 1 a 30 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">31 a 60 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">61 a 90 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">91 a 120 dias</th>"
	LET g_HTML=g_HTML CLIPPED, "<th colspan=\"3\" ",l_tit_p,">mas de 120 d</th>"
	IF p1.ctap = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th colspan=\" 2\" ",l_tit_p,">Ctas</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	IF p1.ctpl=1 THEN
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pi,">&nbsp;</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">General</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Vigente</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Vencido</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	IF p1.itr7 = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Atraso</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">%</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Ctas.</th>"
	IF p1.ctap = "S" THEN
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Pdtvs</th>"
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	LET g_HTML=g_HTML CLIPPED, "<tr>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Zona</th>"		
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Sucursal</th>"
	IF p1.ctpl =1 THEN
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Empresa</th>"
	  LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Plaza\</th>"
	END IF
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_pc,">Agencia \</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">Limite</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
	IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
		p1.tdat = "T" AND p1.tcar = 1  ) OR
		(p1.msis MATCHES "[TF]" AND p1.tcre1 > 29 AND 		
		( p1.cmon = 3 OR p1.cmon = 4 ) AND p1.tdat = "C" AND p1.tcar <= 1) THEN	
		LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[1]	USING "&.&","</th>"	
		FOR j = 2 TO 6
			
			IF p1.itr7 = "S" THEN
				IF j <> 6 THEN
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			ELSE
				IF j < 6 THEN
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF
			
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">",g_plim[j]	USING l_form,"</th>"	
		END FOR
	ELSE
		LET l_colspan = 21
		FOR i = 1 TO l_colspan
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END FOR
	END IF
	IF p1.itr7 = "S" THEN
		IF p1.ctap = "S" THEN
			LET l_colspan = 6
			FOR i = 1 TO l_colspan 
				LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			END FOR
		ELSE			
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END IF
	ELSE
		IF p1.ctap = "S" THEN
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"			
		ELSE
			LET g_HTML=g_HTML CLIPPED, "<th ",l_tit_p,">&nbsp;</th>"
		END IF
	END IF
	LET g_HTML=g_HTML CLIPPED, "</tr>"
	#--------------------------
#(@#)22-A Inicio
#	LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	#--------------------------
	
#	DECLARE q_curs01 CURSOR FOR		
#		   SELECT efzcbczon,MAX(fech),csuc,agen,plzo, plza,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc)		
#		  FROM ef052,OUTER tmp_efzcb		
#		 WHERE csuc <> 98
#		   AND agen = efzcbplaz		
#		   GROUP BY efzcbczon,csuc, agen, plzo, plza
#		   ORDER BY csuc, agen, plzo, plza	
	
	LET l_txt = "SELECT efzcbczon,MAX(fech),csuc,agen||plza,agen,plzo,plza,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc)",
		 		" FROM ef052,OUTER tmp_efzcb", 
		 		" WHERE csuc <> 98",		 		
		 		" AND agen = efzcbplaz", 
		 		" GROUP BY efzcbczon,4,csuc, agen, plzo, plza", 
		 		" ORDER BY csuc, 4,agen, plzo, plza" 
		
	PREPARE q_txt FROM l_txt
	DECLARE q_curs01 CURSOR FOR q_txt
			
	INITIALIZE r.* TO NULL
		
	LET l_agen = 0
	LET l_agep = 0
	LET l_plzoant = 0
	
	LET l_var2 = 0		
	LET l_celd = 13		
	

	FOREACH q_curs01 INTO r.*
		CALL f5030_calc_totales_b_ef052(r.agen,r.plza)
		    RETURNING l_impt, l_impv, l_numc, l_numv
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		#IF r.agen <> l_agen  THEN
		IF r.agep <> l_agep  THEN
			#(@#)15-A - Inicio
			#IF l_agen > 0 THEN
			IF l_agep > 0 THEN			
			#(@#)15-A - Fin
				IF p1.ctap = "S" THEN
					IF l_colspan1 > 0 THEN
						FOR i = 1 TO l_colspan1
							LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
						END FOR
					END IF
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">M</td>"
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
					LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_Html
          OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
				ELSE
					LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_Html
          OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
				END IF
			END IF
			#LET l_agen = r.agen
			LET l_agep = r.agep
			LET l_plaz = r.plza
			
			IF r.agen = 50 OR r.agen = 88 THEN
				IF l_var2 = 0 THEN
					IF p1.ctpl =1 THEN
						LET g_HTML="<tr>"
						LET g_HTML=g_HTML CLIPPED, "<td>SUBTOTAL</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>"
						LET g_HTML=g_HTML CLIPPED, "<td>"
						LET g_HTML=g_HTML CLIPPED, "<td>"
						LET g_HTML=g_HTML CLIPPED, "<td>"
						LET g_HTML=g_HTML CLIPPED, "<td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(G13:G",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(H13:H",l_celd - 1 USING "<<<<",")</td><td>=SUMA(I13:I",l_celd - 1 USING "<<<<",")</td><td>=SUMA(J13:J",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(J13:J",l_celd - 1 USING "<<<<",")/SUMA(I13:I",l_celd - 1 USING "<<<<",")*100</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(L13:L",l_celd - 1 USING "<<<<",")</td><td>=SUMA(M13:M",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(M13:M",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(O13:O",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(P13:P",l_celd - 1 USING "<<<<",")</td><td>=SUMA(P13:P",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(R13:R",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(S13:S",l_celd - 1 USING "<<<<",")</td><td>=SUMA(S13:S",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(U13:U",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(V13:V",l_celd - 1 USING "<<<<",")</td><td>=SUMA(V13:V",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(X13:X",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(Y13:Y",l_celd - 1 USING "<<<<",")</td><td>=SUMA(Y13:Y",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(AA13:AA",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED,"</tr>"
					ELSE
						LET g_HTML="<tr>"
						LET g_HTML=g_HTML CLIPPED, "<td>SUBTOTAL</td><td>SUBTOTAL</td><td></td><td></td><td>=SUMA(E13:E",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(F13:F",l_celd - 1 USING "<<<<",")</td><td>=SUMA(G13:G",l_celd - 1 USING "<<<<",")</td><td>=SUMA(H13:H",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(H13:H",l_celd - 1 USING "<<<<",")/SUMA(G13:G",l_celd - 1 USING "<<<<",")*100</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(J13:J",l_celd - 1 USING "<<<<",")</td><td>=SUMA(K13:K",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(k13:K",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(M13:M",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(N13:N",l_celd - 1 USING "<<<<",")</td><td>=SUMA(N13:N",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(P13:P",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(Q13:Q",l_celd - 1 USING "<<<<",")</td><td>=SUMA(Q13:Q",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(S13:S",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(T13:T",l_celd - 1 USING "<<<<",")</td><td>=SUMA(T13:T",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(V13:V",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED, "<td>=SUMA(W13:W",l_celd - 1 USING "<<<<",")</td><td>=SUMA(W13:W",l_celd - 1 USING "<<<<",")/SUMA(E13:E",l_celd - 1 USING "<<<<",")*100</td><td>=SUMA(Y13:Y",l_celd - 1 USING "<<<<",")</td>"
						LET g_HTML=g_HTML CLIPPED,"</tr>"
					END IF
#(@#)22-A Inicio
#					LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#					RUN g_Html
          OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
					LET l_var2 = 1
				END IF
				LET g_HTML="<tr>"
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">SUB TOTAL 2</td>"
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>"
			ELSE
				LET g_HTML="<tr>"
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5040_busca_dzon_ef052(r.czon),"</td>"	
				LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5050_busca_csuc_ef052(r.csuc),"</td>"				
				LET l_celd = l_celd + 1 
			END IF
			IF p1.ctpl =1 THEN
			  LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5021_busca_emp_ef052(r.plza),"</td>"
			  LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",r.agen,"</td>"
			  LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5022_buscar_descripcion_agencia_ef052(r.plza),"</td>"
			ELSE
			  LET g_HTML=g_HTML CLIPPED, "<td ",l_tdi,">",f5020_busca_agen_ef052(r.agen),"</td>"
			END IF		
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",l_impt / g_miles USING "-<<,<<<,<<<.&&","</td>"	
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_numc		USING "###,###","</td>"
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",(l_impt-l_impv) / g_miles USING "-<<,<<<,<<<.&&","</td>"	
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",l_impv / g_miles USING "-<<,<<<,<<<.&&","</td>"	
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" 
				ELSE
					IF r.plzo = 6 THEN
						LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" 
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" 
				END IF
			END IF
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_numv		USING "###,###","</td>"
		END IF
		
		IF r.plzo > 0 THEN				
			IF l_impt > 0 AND r.impt > 0 THEN
				LET l_porc = r.impt / l_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 1 THEN
					LET l_form = "##&.&" 
				ELSE
					IF r.plzo = 6 THEN	
						LET l_form = "##&.&&"	
					END IF	
				END IF
			ELSE
				IF r.plzo < 5 THEN					
					LET l_form = "##&.&" 
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF 
			LET l_colspan = (r.plzo -(l_plzoant + 1))*3
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
			IF l_colspan > 0 THEN
				FOR i = 1 TO l_colspan
					LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
				END FOR
			END IF
			LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal3\" ",l_td,">",r.impt / g_miles	USING "-<<,<<<,<<<.&&","</td>"	
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>" 
				ELSE
					IF r.plzo = 6 THEN
						LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" 
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					LET g_HTML=g_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>" 
				END IF
			END IF
			LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",r.numc	USING "##,###","</td>"

			LET l_plzoant = r.plzo
			LET l_ctasp  = g_ctasp
		ELSE
			LET l_ctasp  = g_ctasp
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
			LET l_plzoant = r.plzo 
		END IF
	END FOREACH
	IF p1.ctap = "S" THEN
		IF l_colspan1 > 0 THEN
			FOR i = 1 TO l_colspan1
				LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			END FOR
		END IF
		LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">M</td>"
		LET g_HTML=g_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
		LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#		LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#		RUN g_Html
    OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	ELSE
		LET g_HTML=g_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio		
#		LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#		RUN g_Html
    OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	END IF
	## Imprimir total compañía
	CALL f1102_impr_total_compania_ef052()
	RETURNING l_HTML
		LET g_HTML=g_HTML CLIPPED,l_HTML CLIPPED
	#--------------------------	
	LET g_Html = "</table></body></html>"
	#--------------------------	
#(@#)22-A Inicio
#	LET g_Html = "echo '", g_Html CLIPPED, "' >> ", g_spool
#	RUN g_Html
  OUTPUT TO REPORT imprime_rep_detallado(g_HTML)
#(@#)22-A Fin
	#--------------------------
END FUNCTION
#FIN (@#)15-A  

###################################################################
## Reporte para caso SISMO EAY
###################################################################
FUNCTION f1010_impreso_sismo_ef052()
	DEFINE
		l_czon	SMALLINT	# (@#)6-A

	LET g_impt = 0
	LET g_impv = 0
	LET g_numc = 0
	LET g_numv = 0
	LET g_ctast = 0
	LET g_ctasst= 0
	FOR j = 1 TO 5
	    LET g_tott[j].impv = 0
	    LET g_tott[j].numc = 0
	END FOR
	##
	LET g_spool = "ef052a.r"
	START REPORT f1110_proceso_impr_sismo_ef052 TO g_spool
	#FOREACH q_curs2 INTO t1.*	# (@#)6-A
	#FOREACH q_curs INTO l_czon,t1.*	# (@#)6-A			# (@#)7-A
	FOREACH q_curs INTO t1.*			# (@#)7-A
		#OUTPUT TO REPORT f1110_proceso_impr_sismo_ef052(t1.*)		# (@#)6-A
		#OUTPUT TO REPORT f1110_proceso_impr_sismo_ef052(l_czon,t1.*)		# (@#)6-A			# (@#)7-A
		OUTPUT TO REPORT f1110_proceso_impr_sismo_ef052(t1.*)			# (@#)7-A
	END FOREACH
	FINISH REPORT f1110_proceso_impr_sismo_ef052
END FUNCTION

REPORT f1110_proceso_impr_sismo_ef052(r)
	DEFINE	r		RECORD
				  #czon		SMALLINT,	# (@#)6-A		# (@#)7-A
				  fech		DATE,
				  csuc		SMALLINT,
				  #(@#)15-A - Inicio
				  agep		INTEGER,
				  #(@#)15-A - Fin
				  agen		SMALLINT,
				  plzo		SMALLINT,
				  plza		SMALLINT,	# (@#)15-A 
				  tpro		INTEGER,
				  gpro		INTEGER,
				  impt		DECIMAL(14,2),
				  numc		INTEGER
				END RECORD,
		l_fila		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER,
		l_porc		DECIMAL(7,2),
		l_imst, l_imsv	DECIMAL(14,2),
		l_imstp,l_imsvp	DECIMAL(14,2),
		l_nums, l_nusv	INTEGER,
		l_numsp,l_nusvp	INTEGER,
		l_form		CHAR(7),
		l_impt1, l_impv1	DECIMAL(14,2),
		l_numc1, l_numv1	INTEGER,
		l_porc1		DECIMAL(7,2),
		l1	RECORD
			plzo    SMALLINT,
			impt    DECIMAL(14,2),
			numc	INTEGER
			END RECORD,
		x	SMALLINT
	OUTPUT
		LEFT MARGIN 0
		TOP  MARGIN 0
		BOTTOM MARGIN 4
		PAGE LENGTH 66
		ORDER EXTERNAL BY r.csuc, r.agen,r.gpro, r.tpro, r.plzo
	FORMAT
		PAGE HEADER
		LET g_ancho  = 222 #12
		LET g_string = t0.gbpmtnemp CLIPPED
		PRINT ASCII 15
		PRINT COLUMN  1,"EFECTIVA",
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),"PAG: ",PAGENO USING "<<<<"
		LET g_string = "ATRASO DE COBRANZA x ETAPAS AL ",
				p1.fech USING "dd/mm/yyyy"
		PRINT COLUMN  1,TIME CLIPPED,
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED,
		      COLUMN (g_ancho-9),TODAY USING "dd-mm-yyyy"
		CASE p1.cmon
		WHEN 0
		    LET g_string = "EXPRESADO EN US $ DOLARES (INCLUYE SOLES)"
		WHEN 1
		    LET g_string = "NUEVOS SOLES"
		WHEN 2
		    LET g_string = "DOLARES AMERICANOS"
		OTHERWISE
		    LET g_string = "EXPRESADO EN NUEVOS SOLES (INCLUYE DOLARES)"
		END CASE
		PRINT COLUMN  1,"ef052.4gl",
		      COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		CASE p1.msis
		WHEN "S"
		    LET g_string = "CREDITOS EFE (SAI)"
		WHEN "F"
		    #LET g_string = "CREDITOS EDPYME (SFI)"		#CEMO (@#)1-A
		    LET g_string = "CREDITOS FINANCIERA (SFI)"		#CEMO (@#)1-A
		OTHERWISE
		    #LET g_string = "CONSOLIDADO EFE + EDPYME (SAI + SFI)"	#CEMO (@#)1-A
		    LET g_string = "CONSOLIDADO EFE + FINANCIERA (SAI + SFI)"	#CEMO (@#)1-A
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED
		PRINT COLUMN   1,"Agencias: De 60 a 66";
		CASE p1.tdat
		WHEN "C"
		    LET g_string = "SOLO CAPITAL"            
		WHEN "I"
		    LET g_string = "SOLO INTERES "             
		OTHERWISE
		    LET g_string = "CAPITAL + INTERES"
		    IF p1.msis = "S" THEN
			LET g_string = g_string CLIPPED,
					" (INC. IGV DEL INTERES)"
		    END IF
		END CASE
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
		IF p1.tcre = "T" THEN
		    CASE p1.tcuo
		    WHEN 0
			LET g_string = "TOTAL PRESTAMOS"
		    WHEN 1
			LET g_string = "CREDITOS MENSUALES"
		    WHEN 2
			LET g_string = "CREDITOS SEMANALES"
		    END CASE
		ELSE
		    CASE p1.tcr1
		    WHEN 2
			LET g_string = "Tipo de Credito: MES"
		    WHEN 3
			LET g_string = "Tipo de Credito: CONSUMO"
		    OTHERWISE
			LET g_string = "Tipo de Credito: Del ",
					p1.tcre1 USING "<<<"," al ",
					p1.tcre2 USING "<<<"
		    END CASE
		    CASE p1.tcuo
		    WHEN 1
			LET g_string = g_string CLIPPED, ", CUOTAS MENSUALES"
		    WHEN 2
			LET g_string = g_string CLIPPED, ", CUOTAS SEMANALES"
		    END CASE
		END IF
		PRINT COLUMN   1,g_string CLIPPED;
		CASE p1.tcar
		WHEN 0
		    LET g_string = "TOTAL CARTERA"
		WHEN 1
		    LET g_string = "SIN PROVISION A¥OS ANTERIORES"
		WHEN 2
		    LET g_string = "SIN PROVISION TOTAL"
		WHEN 3
		    LET g_string = "PROVISION A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = "PROVISION A¥O ACTUAL"
		WHEN 5
		    LET g_string = "TOTAL PROVISION"
		END CASE
		CASE p1.tcas
		WHEN 0
		    LET g_string = g_string CLIPPED," "
		WHEN 1
		    LET g_string = g_string CLIPPED,
				"- SIN CASTIGOS A¥OS ANTERIORES"
		WHEN 2
		    LET g_string = g_string CLIPPED
				,"- SIN CASTIGOS TOTALES"
		WHEN 3
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥OS ANTERIORES"
		WHEN 4
		    LET g_string = g_string CLIPPED
				,"- CON CASTIGOS A¥O ACTUAL"
		WHEN 5
		    LET g_string = g_string CLIPPED
				,"- TOTAL CASTIGOS"
		END CASE
		PRINT COLUMN ((g_ancho-length(g_string))/2),g_string CLIPPED;
		LET g_string = "Tipo d/Cambio: ", g_tcam USING "<&.&&&"
		PRINT COLUMN (g_ancho-LENGTH(g_string)+1),g_string CLIPPED
		FOR i=1 TO g_ancho-1 PRINT "-"; END FOR PRINT "-"
		PRINT COLUMN   7,"\\",
		      COLUMN  23,"-------------------   T o t a l e s ",
		      COLUMN  61,"----------------",
		      COLUMN  79,"|  ----  1 a 30 dias  ---",
		      COLUMN 106,"|  ---  31 a 60 dias  ---",
		      COLUMN 133,"|  ---  61 a 90 dias  ---",
		      COLUMN 160,"|  ---  91 a 120 dias  --",
		      COLUMN 187,"|  ---  mas de 120 d  ---";
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 217,"Ctas"
		ELSE
		      PRINT
		END IF
		PRINT COLUMN   8,"\\",
		      COLUMN  26,"General",
		      COLUMN  37,"Ctas",
		      COLUMN  45,"Vigente",
		      COLUMN  56,"Vencido",
		      COLUMN  67,"%",
		      COLUMN  73,"Ctas.";
		LET j = 79
		WHILE j <= 187
		    PRINT COLUMN  j   ,"|     Atraso",
			  COLUMN  j+16,"%",
			  COLUMN  j+21,"Ctas";
		    LET j = j + 27
		END WHILE
		IF p1.ctap = "S" THEN	
		      PRINT COLUMN 216,"Pdtvs";
		END IF
		#PRINT COLUMN 216,"Pdtvs";
		SKIP 1 LINE
		PRINT COLUMN   1,"Agencia \\ Limite";
		IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
		    p1.cmon = 0   AND p1.tdat = "T" AND p1.tcar = 1  ) OR
		   (p1.msis MATCHES "[TF]" AND p1.tcre1 > 29 AND 
		    # Inicio (@#)3-A
		    # Si es moneda 3 o 4 deba hacer lo mismo
		    #p1.cmon = 3 AND p1.tdat = "C" AND p1.tcar <= 1) THEN
		    ( p1.cmon = 3 OR p1.cmon = 4 ) AND p1.tdat = "C" AND p1.tcar <= 1) THEN
		    # Fin (@#)3-A

		    PRINT COLUMN  66,g_plim[1]	USING "&.&&";
		    FOR j = 2 TO 6
			LET k = ((j - 2)* 27) + 79
			PRINT COLUMN k   ,"|",
			      COLUMN k+15,g_plim[j]	USING "&.&&";
		    END FOR
		    PRINT
		ELSE
		    FOR j = 2 TO 6
			LET k = ((j - 2)* 27) + 79
			PRINT COLUMN  k,"|";
		    END FOR
		    PRINT
		END IF
		FOR i=1 TO g_ancho-1 PRINT "-"; END FOR PRINT "-"
	BEFORE GROUP OF r.agen
		LET g_ctass = 0
		##
		LET l_fila = 0
		LET l_imst = 0
		LET l_imsv = 0
		LET l_nums = 0
		LET l_nusv = 0
		FOR j = 1 TO 5
		    LET g_subt[j].impv = 0
		    LET g_subt[j].numc = 0
		    ##
		    {LET k = ((j - 1) * 27) + 79
		    PRINT COLUMN k,"|";}
		END FOR
		IF r.csuc <> 1 THEN
			PRINT
		END IF

	BEFORE GROUP OF r.gpro
		LET l_imstp = 0 
		LET l_imsvp = 0
		LET l_numsp = 0
		LET l_nusvp = 0
		FOR j = 1 TO 5
			LET g_subp[j].impv = 0
			LET g_subp[j].numc = 0
		END FOR
	BEFORE GROUP OF r.tpro
		LET g_ctasp = 0
		IF r.csuc < 98 THEN LET l_fila = l_fila + 1 END IF
		CALL f5030_calc_totales_prod_ef052(r.agen,r.tpro)
		    RETURNING l_impt, l_impv, l_numc, l_numv
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		PRINT COLUMN   1,f5030_busca_trpo_ef052(r.tpro) CLIPPED,
		      COLUMN  23,l_impt		USING "##,###,###",
		      COLUMN  34,l_numc		USING "###,###",
		      COLUMN  42,l_impt-l_impv	USING "#,###,###",
		      COLUMN  54,l_impv		USING "#,###,###",
		      #COLUMN  64,l_porc		USING "##&.&&", #(@#)2-A
		      COLUMN  64,l_porc		USING "##&.&", #(@#)2-A	#(@#)3-A
		      COLUMN  70,l_numv		USING "###,###";
		LET l_imst = l_imst + l_impt
		LET l_imsv = l_imsv + l_impv
		LET l_nums = l_nums + l_numc
		LET l_nusv = l_nusv + l_numv
		##
		LET g_impt = g_impt + l_impt
		LET g_impv = g_impv + l_impv
		LET g_numc = g_numc + l_numc
		LET g_numv = g_numv + l_numv
		##
		LET l_imstp = l_imstp + l_impt
		LET l_imsvp = l_imsvp + l_impv
		LET l_numsp = l_numsp + l_numc
		LET l_nusvp = l_nusvp + l_numv
		##
		LET k = 1
		WHILE k < r.plzo
		    LET j = ((k -1) * 27) + 79
		    PRINT COLUMN j,"|";
		    LET k = k + 1
		END WHILE
	ON EVERY ROW
		IF r.plzo > 0 THEN
		LET j = ((r.plzo - 1) * 27) + 79
		IF l_impt > 0 AND r.impt > 0 THEN
		    LET l_porc = r.impt / l_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		IF r.plzo < 5 THEN
		    LET l_form = "##&.&&" #(@#)2-A
		ELSE
		    LET l_form = "##&.&&"
		END IF
		PRINT COLUMN j   ,"|",
		      COLUMN j+3 ,r.impt	USING "#,###,###",
		      COLUMN j+13,l_porc	USING l_form,
		      COLUMN j+19,r.numc	USING "##,###";
		LET k = r.plzo
		LET g_subt[k].impv = g_subt[k].impv + r.impt
		LET g_subt[k].numc = g_subt[k].numc + r.numc
		##
		LET g_tott[k].impv = g_tott[k].impv + r.impt
		LET g_tott[k].numc = g_tott[k].numc + r.numc
		##
		LET g_subp[k].impv = g_subp[k].impv + r.impt
		LET g_subp[k].numc = g_subp[k].numc + r.numc
		END IF
	AFTER GROUP OF r.tpro
		LET k = r.plzo
		WHILE k < 5
		    LET j = (k * 27) + 79
		    PRINT COLUMN j,"|";
		    LET k = k + 1
		END WHILE
		LET g_ctass = g_ctass + g_ctasp
		LET g_ctast = g_ctast + g_ctasp
		LET g_ctasst = g_ctasst + g_ctasp
		IF p1.ctap = "S" THEN
			PRINT COLUMN 215,g_ctasp USING "##,###"
		ELSE
			PRINT
		END IF
	AFTER GROUP OF r.gpro
		#IF l_fila > 1 THEN
		    #NEED 3 LINES
		    NEED 2 LINES
		    IF l_imstp > 0 AND l_imsvp > 0 THEN
			LET l_porc = l_imsvp / l_imstp * 100
		    ELSE
			LET l_porc = NULL
		    END IF
		    FOR i=23 TO g_ancho-1 PRINT COLUMN i,"-"; END FOR PRINT "-"
		    IF r.gpro = 1 THEN
			LET g_string = "SUB.TOT. EJECUTADO" 
		    ELSE
			LET g_string = "SUB.TOT. NO EJECUTADO" 
		    END IF
		    PRINT COLUMN   1,g_string 		CLIPPED,
			  COLUMN  23,l_imstp		USING "##,###,###",
			  COLUMN  34,l_numsp		USING "###,###",
			  COLUMN  42,l_imstp-l_imsvp	USING "#,###,###",
			  COLUMN  54,l_imsvp		USING "#,###,###",
			  #COLUMN  64,l_porc		USING "##&.&&",#(@#)2-A
			  COLUMN  64,l_porc		USING "##&.&",#(@#)2-A		#(@#)3-A
			  COLUMN  70,l_nusvp		USING "###,###";
		    FOR j = 1 TO 5
			LET k = ((j - 1) * 27) + 79
			IF l_imst > 0 AND g_subp[j].impv > 0 THEN
			    LET l_porc = g_subp[j].impv / l_imst * 100
			ELSE
			    LET l_porc = NULL
			END IF
			IF j < 5 THEN
			    LET l_form = "##&.&&" #(@#)2-A
			ELSE
			    LET l_form = "##&.&&"
			END IF
			PRINT COLUMN k   ,"|",
			      COLUMN k+3 ,g_subp[j].impv  USING "#,###,###",
			      COLUMN k+13,l_porc	  USING l_form,
			      COLUMN k+19,g_subp[j].numc  USING "##,###";
		    END FOR
		    PRINT ""
		#END IF
	AFTER GROUP OF r.agen
		IF l_fila > 1 THEN
		    #NEED 3 LINES
		    NEED 2 LINES
		    IF l_imst > 0 AND l_imsv > 0 THEN
			LET l_porc = l_imsv / l_imst * 100
		    ELSE
			LET l_porc = NULL
		    END IF
		    FOR i=23 TO g_ancho-1 PRINT COLUMN i,"-"; END FOR PRINT "-"
		    PRINT COLUMN   1,"SUB TOTAL ",f5020_busca_agen_ef052(r.agen) CLIPPED,
			  COLUMN  23,l_imst		USING "##,###,###",
			  COLUMN  34,l_nums		USING "###,###",
			  COLUMN  42,l_imst-l_imsv	USING "#,###,###",
			  COLUMN  54,l_imsv		USING "#,###,###",
			  COLUMN  64,l_porc		USING "##&.&&",#(@#)2-A
			  COLUMN  70,l_nusv		USING "###,###";
		    FOR j = 1 TO 5
			LET k = ((j - 1) * 27) + 79
			IF l_imst > 0 AND g_subt[j].impv > 0 THEN
			    LET l_porc = g_subt[j].impv / l_imst * 100
			ELSE
			    LET l_porc = NULL
			END IF
			IF j < 5 THEN
			    #LET l_form = "##&.&&" #(@#)2-A
			    LET l_form = "##&.&" #(@#)2-A		#(@#)3-A
			ELSE
			    LET l_form = "##&.&&"
			END IF
			PRINT COLUMN k   ,"|",
			      COLUMN k+3 ,g_subt[j].impv  USING "#,###,###",
			      COLUMN k+13,l_porc	  USING l_form,
			      COLUMN k+19,g_subt[j].numc  USING "##,###";
		    END FOR
		    IF p1.ctap = "S" THEN
			PRINT COLUMN 215,g_ctass USING "##,###"
		    ELSE
			PRINT
		    END IF
		    #PRINT
		END IF
	ON LAST ROW
		NEED 2 LINES
		IF g_impt > 0 AND g_impv > 0 THEN
		    LET l_porc = g_impv / g_impt * 100
		ELSE
		    LET l_porc = NULL
		END IF
		FOR i=23 TO g_ancho-1 PRINT COLUMN i,"-"; END FOR PRINT "-"
		PRINT COLUMN   1,"TOTAL ",
		      COLUMN  23,g_impt		USING "##,###,###",
		      COLUMN  34,g_numc		USING "###,###",
		      COLUMN  42,g_impt-g_impv	USING "##,###,###",
		      COLUMN  54,g_impv		USING "#,###,###",
		      #COLUMN  64,l_porc	USING "##&.&&",#(@#)2-A
		      COLUMN  64,l_porc		USING "##&.&",#(@#)2-A		#(@#)3-A
		      COLUMN  70,g_numv		USING "###,###";
		FOR j = 1 TO 5
		    LET k = ((j - 1) * 27) + 79
		    IF g_impt > 0 AND g_tott[j].impv > 0 THEN
			LET l_porc = g_tott[j].impv / g_impt * 100
		    ELSE
			LET l_porc = NULL
		    END IF
		    IF j < 5 THEN
			LET l_form = "##&.&&" #(@#)2-A
		    ELSE
			LET l_form = "##&.&&"
		    END IF
		    PRINT COLUMN k   ,"|",
			  COLUMN k+3 ,g_tott[j].impv	USING "#,###,###",
			  COLUMN k+13,l_porc		USING l_form,
			  COLUMN k+19,g_tott[j].numc	USING "##,###";
		END FOR
		IF p1.ctap = "S" THEN
			PRINT COLUMN 215,g_ctast USING "##,###"
		ELSE
			PRINT
		END IF
		#PRINT
	PAGE TRAILER
		PRINT ASCII 18
END REPORT

#####################
# CONSULTA DE DATOS #
##################### 

FUNCTION f5010_ver_sucursal_ef052(l_agen)
	DEFINE  l_agen          SMALLINT,
		l_csuc          SMALLINT
	SELECT DISTINCT efsuccsuc INTO l_csuc
		FROM efsuc
		WHERE efsucagen = l_agen
	IF status = NOTFOUND THEN
		LET l_csuc = 0
	END IF
	RETURN l_csuc
END FUNCTION

FUNCTION f5011_ver_grupo_prod(l_tpro)
	DEFINE  l_tpro          SMALLINT,
		l_gpro          SMALLINT

	IF l_tpro >=1 AND  l_tpro <=9 THEN
	    LET l_gpro = 1
	ELSE
	    LET l_gpro = 2
	END IF
	RETURN l_gpro
END FUNCTION

FUNCTION f5020_busca_agen_ef052(l_agen)
	DEFINE	l_agen		SMALLINT,
		l_desc		CHAR(20)
	SELECT gbcondesc[1,20] INTO l_desc
		FROM gbcon
		WHERE gbconpfij = 71
		  AND gbconcorr = l_agen
	IF status = NOTFOUND THEN
		LET l_desc = " "
	END IF
	IF l_agen = 50 THEN
		LET l_desc = "OFICINA LIMA" 
	END IF
	RETURN l_desc
END FUNCTION

#INICIO (@#)15-A  
FUNCTION f5021_busca_emp_ef052(l_plza)
	DEFINE	l_desc	CHAR(20),
		l_plza	SMALLINT,
		l_creg  SMALLINT
	# (@#)18-A - Inicio
	LET l_creg = 0
			
	SELECT NVL(COUNT(*),0) INTO  l_creg
	FROM gbcon
	WHERE gbconpfij = 335
	AND gbconcorr = l_plza	
	AND gbconcorr <> 0
	IF l_creg = 0 OR l_creg IS NULL THEN
#(@#)22-A Inicio
	  SQL DROP TABLE IF EXISTS tmp_gbofi END SQL
	  EXECUTE s_gbofi2 USING l_plza
#(@#)22-A Fin	  
	# (@#)18-A - Fin 		
	  SELECT gbcondesc[1,20] INTO l_desc
		FROM gbcon
#(@#)22-A Inicio
#		WHERE gbconpfij = 524
    WHERE gbconpfij = g_gbconpfij524
#		AND gbconcorr in (select distinct gboficemp from gbofi where gbofinofi =l_plza)  
    AND gbconcorr in (select distinct gboficemp from tmp_gbofi)
#(@#)22-A Inicio
		IF STATUS = NOTFOUND THEN
		   LET l_desc = " "
		END IF
	# (@#)18-A - Inicio
	ELSE
		SELECT gbcondesc[1,20] INTO l_desc
		FROM gbcon
		WHERE gbconpfij = 524
		AND gbconcorr = 8
		  
		IF STATUS = NOTFOUND THEN
		   LET l_desc = " "
		END IF
	END IF
	# (@#)18-A - Fin
	RETURN l_desc
END FUNCTION

FUNCTION f5030_calc_totales_b_ef052(l_agen,l_plaz)
DEFINE  	l_agen		SMALLINT,
		l_plaz		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		  AND agen = l_agen
		  AND plza = l_plaz
		  AND plzo NOT IN(1)
  ELSE
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		   AND agen = l_agen
		   AND plza = l_plaz
		   AND plzo NOT IN(6)
  END IF

	IF l_numc IS NULL THEN LET l_numc = 0 END IF
	IF l_impt IS NULL THEN LET l_impt = 0 END IF


  IF p1.itr7 = "S" THEN
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		     AND agen = l_agen
		     AND plza = l_plaz
		     AND plzo IN(2,3,4,5,6)
  
  ELSE
  
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		    AND agen = l_agen
		    AND plza = l_plaz
		    AND plzo IN(1,2,3,4,5)
  END IF
  
	IF l_numv IS NULL THEN LET l_numv = 0 END IF
	IF l_impv IS NULL THEN LET l_impv = 0 END IF

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo IN (0,2)
	AND agen = l_agen
	AND plza = l_plaz
  ELSE
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo between 0 AND 1
	AND agen = l_agen
	AND plza = l_plaz
  END IF
	RETURN l_impt, l_impv, l_numc, l_numv
END FUNCTION

FUNCTION f5022_buscar_descripcion_agencia_ef052(l_agen)
DEFINE	l_agen	INTEGER,
	l_desc	CHAR(20)		
	
	LET l_desc = " "
	SELECT GBOFIDESC[1,20]
	  INTO l_desc
	  FROM GBOFI 
	 WHERE GBOFINOFI = l_agen	

	IF STATUS = NOTFOUND THEN
		LET l_desc = " "
	END IF
	RETURN l_desc
END FUNCTION

#FIN (@#)15-A  

FUNCTION f5030_busca_trpo_ef052(l_tpro)
	DEFINE	l_tpro	SMALLINT,
		l_desc	CHAR(20)

	CASE l_tpro
	    WHEN 1  LET l_desc = "PRODUCTO 1"
	    WHEN 2  LET l_desc = "PRODUCTO 2"
	    WHEN 3  LET l_desc = "PRODUCTO 3"
	    WHEN 4  LET l_desc = "PRODUCTO 4"
	    WHEN 5  LET l_desc = "PRODUCTO 5"
	    WHEN 6  LET l_desc = "PRODUCTO 6"
	    WHEN 12 LET l_desc = "PRODUCTO 2"
	    WHEN 13 LET l_desc = "PRODUCTO 3"
	    WHEN 14 LET l_desc = "PRODUCTO 4"
	    WHEN 15 LET l_desc = "PRODUCTO 5"
	    WHEN 16 LET l_desc = "PRODUCTO 6"
	    WHEN 20 LET l_desc = "SIN MARCAR"
	    OTHERWISE LET l_desc = "NO DETERMINADO"
	END CASE

	RETURN l_desc
END FUNCTION

FUNCTION f5030_calc_totales_prod_ef052(l_agen,l_tpro)
	DEFINE	l_agen		SMALLINT,
		l_tpro		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052b
		WHERE fech = p1.fech
		  AND agen = l_agen
		  AND tpro = l_tpro
	IF l_numc IS NULL THEN LET l_numc = 0 END IF
	IF l_impt IS NULL THEN LET l_impt = 0 END IF
	SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		FROM ef052b
		WHERE fech = p1.fech
		  AND agen = l_agen
		  AND tpro = l_tpro
		  AND plzo > 0
	IF l_numv IS NULL THEN LET l_numv = 0 END IF
	IF l_impv IS NULL THEN LET l_impv = 0 END IF

	SELECT SUM(numc) INTO g_ctasp
	FROM ef052b
	WHERE fech = p1.fech
	AND   plzo between 0 AND 1
	AND   agen = l_agen
	AND   tpro = l_tpro

	RETURN l_impt, l_impv, l_numc, l_numv
END FUNCTION


FUNCTION f5030_calc_totales_ef052(l_agen)

	DEFINE  l_agen		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		  AND agen = l_agen
		  AND plzo NOT IN(1)
  ELSE
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		   AND agen = l_agen
		   AND plzo NOT IN(6)
  END IF

	IF l_numc IS NULL THEN LET l_numc = 0 END IF
	IF l_impt IS NULL THEN LET l_impt = 0 END IF


  IF p1.itr7 = "S" THEN
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		     AND agen = l_agen
		    AND plzo IN(2,3,4,5,6)
  
  ELSE
  
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		    AND agen = l_agen
		    AND plzo IN(1,2,3,4,5)
  END IF


	IF l_numv IS NULL THEN LET l_numv = 0 END IF
	IF l_impv IS NULL THEN LET l_impv = 0 END IF

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo IN (0,2)
	AND agen = l_agen
  ELSE
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo between 0 AND 1
	AND agen = l_agen
  END IF
	RETURN l_impt, l_impv, l_numc, l_numv
END FUNCTION



FUNCTION f5035_calc_totales_ef052(l_cloc, l_tipo)
	DEFINE l_tipo	SMALLINT,
		l_cloc	SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER

	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
	FROM ef052a
	WHERE tipo = l_tipo
	AND   cloc = l_cloc
	AND plzo NOT IN(6) 
	IF l_numc IS NULL THEN LET l_numc = 0 END IF
	IF l_impt IS NULL THEN LET l_impt = 0 END IF

	SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
	FROM ef052a
	WHERE tipo = l_tipo
		AND   cloc = l_cloc
	AND plzo IN(1,2,3,4,5) 

	IF l_numv IS NULL THEN LET l_numv = 0 END IF
	IF l_impv IS NULL THEN LET l_impv = 0 END IF
	RETURN l_impt, l_impv, l_numc, l_numv
END FUNCTION

FUNCTION f5050_busca_csuc_ef052(l_csuc)
	DEFINE  l_csuc          SMALLINT,
		l_desc          CHAR(11)
	SELECT DISTINCT efsucdesc INTO l_desc
		FROM efsuc
		WHERE efsuccsuc = l_csuc
	IF status = NOTFOUND THEN
		LET l_desc = " "
	END IF
	RETURN l_desc
END FUNCTION

#####################
# RUTINAS GENERALES #
#####################

FUNCTION f6000_limpiar_campos_ef052()
	INITIALIZE t1.*,p1.*,p5.* TO NULL
	INITIALIZE m1.o1,m1.o2,m1.o3,m1.o4 TO NULL
	DISPLAY BY NAME m1.*
END FUNCTION

FUNCTION f6050_empresa_ef052()
	SELECT * INTO t0.* FROM gbpmt
	IF status = NOTFOUND OR status < 0 THEN
		RETURN FALSE
	END IF
	CALL f6656_nombre_empresa_gb000(g_user) RETURNING t0.gbpmtnemp,t0.gbpmtplaz,g_plaz
	RETURN TRUE
END FUNCTION

FUNCTION f6100_cabecera_ef052()
	DEFINE	l_string 	CHAR(33),
		l_empres 	CHAR(33),
		l_sistem 	CHAR(16),
		l_opcion 	CHAR(33),
		l_col    	SMALLINT

	# DISPLAY DEL SISTEMA (16 caracteres)
	LET     l_string = "EFECTIVA"
	LET     l_col = ((16 - length(l_string)) / 2)
	LET     l_sistem = " "
	LET     l_sistem[l_col+1,16-l_col] = l_string
	DISPLAY l_sistem AT 4,2

	# DISPLAY DEL NOMBRE DE LA EMPRESA (33 caracteres)
	LET     l_string = t0.gbpmtnemp CLIPPED
	LET     l_col = ((33 - length(l_string)) / 2)
	LET     l_empres = " "
	LET     l_empres[l_col+1,33-l_col] = l_string
	DISPLAY l_empres AT 4,24

	# DISPLAY DE LA FECHA
	DISPLAY t0.gbpmtfdia AT 4,66

	# DISPLAY DE LA OPCION (33 caracteres)
	LET     l_string = "ATRASO DE COBRANZA x ETAPAS"
	LET     l_col = ((33 - length(l_string)) / 2)
	LET     l_opcion = " "
	LET     l_opcion[l_col+1,33-l_col] = l_string
	DISPLAY l_opcion AT 5,24
END FUNCTION

FUNCTION f6200_carga_menu_ef052()
	LET m1.d1 = "Generar e imprimir"
	LET m1.d2 = "Ver en Pantalla"
	LET m1.d3 = "Repetir Impresion"
	LET m1.d4 = "Volver Menu anterior"
END FUNCTION

FUNCTION f6300_carga_csuc_ef052()
	CREATE TEMP TABLE efsuc
		(
		efsucagen       SMALLINT,
		efsuccsuc       SMALLINT,
		efsucdesc       CHAR(15)
		)
		WITH NO LOG;
	CREATE INDEX efsuc_00 ON efsuc (efsuccsuc, efsucagen)
	{
	LOAD FROM "/u/tbase/LOCALES1.TXT"
		INSERT INTO efsuc
	}
	INSERT INTO efsuc
		SELECT adspaagen, adspasucu, gbcondesc
		FROM adspa, gbcon
		WHERE gbconpfij = 121
		AND gbconcorr = adspasucu

	UPDATE efsuc SET efsuccsuc = 98
		WHERE efsucagen IN (100, 200, 300)
	UPDATE efsuc SET efsuccsuc = 99
		WHERE efsucagen IN (50, 88)
END FUNCTION

FUNCTION f6400_carga_limites_ef052()
	IF (p1.msis = "T" AND p1.tcre1 = 1  AND p1.tcre2 = 29 AND
	    p1.tdat = "T" AND p1.tcar = 1) THEN
	    LET g_plim[1] = 0.00
	    LET g_plim[2] = 2.90
	    LET g_plim[3] = 0.90
	    LET g_plim[4] = 0.40
	    LET g_plim[5] = 1.00
	    LET g_plim[6] = 0.00
	# Inicio (@#)3-A
	# Se comente a solicitud del lider usuario: OOP cambio los objetivos y se parametrizaron
	# en el prefijo 89 de la tabla de parametros: efpar
	    {
	    CASE MONTH(p1.fech)
		WHEN 1  LET g_plim[6] = 0.26
		WHEN 2  LET g_plim[6] = 0.52
		WHEN 3  LET g_plim[6] = 0.78
		WHEN 4  LET g_plim[6] = 1.02
		WHEN 5  LET g_plim[6] = 1.21
		WHEN 6  LET g_plim[6] = 1.46
		WHEN 7  LET g_plim[6] = 1.61
		WHEN 8  LET g_plim[6] = 1.87
		WHEN 9  LET g_plim[6] = 2.13
		WHEN 10 LET g_plim[6] = 2.34
		WHEN 11 LET g_plim[6] = 2.40
		WHEN 12 LET g_plim[6] = 2.40
	    END CASE
		}
	SELECT efparflo1 INTO g_plim[6]
	  FROM efpar
	 WHERE efparpfij = 89
	   AND efparstat = 1
	   AND efparcor1 = MONTH(p1.fech)
	# Fin (@#)3-A
		#inicio (@#)12-A
		IF p4.cart = 2 THEN
			LET g_plim[1] = 0.00
			SELECT elclpatrm1,elclpatrm2,elclpatrm3,elclpatrm4,elclpatrm5
				INTO g_plim[2],g_plim[3],g_plim[4],g_plim[5],g_plim[6]
			FROM elclpa
			WHERE elclpatcre = p4.cart
			AND elclpaanio = YEAR(p1.fech)
			AND elclpacmes = MONTH(p1.fech)
			AND elclpastat = 1

		END IF
		#fin (@#)12-A
	ELSE
	    ##  Microcredito
	    LET g_plim[1] = 0.00
	    LET g_plim[2] = 2.00
	    LET g_plim[3] = 1.00
	    LET g_plim[4] = 1.10
	    LET g_plim[5] = 0.70
	    CASE MONTH(p1.fech)
		WHEN 1  LET g_plim[6] = 0.20
		WHEN 2  LET g_plim[6] = 0.20
		OTHERWISE
		    LET g_plim[6] = 0.20
		    FOR j = 3 TO 12
			LET g_plim[6] = g_plim[6] + 0.10
		    END FOR
	    END CASE
	    #inicio (@#)12-A
		IF p4.cart = 2 THEN
			LET g_plim[1] = 0.00
			SELECT elclpatrm1,elclpatrm2,elclpatrm3,elclpatrm4,elclpatrm5
				INTO g_plim[2],g_plim[3],g_plim[4],g_plim[5],g_plim[6]
			FROM elclpa
			WHERE elclpatcre = p4.cart
			AND elclpaanio = YEAR(p1.fech)
			AND elclpacmes = MONTH(p1.fech)
			AND elclpastat = 1

		END IF
		#fin (@#)12-A
	END IF
	FOR j = 2 TO 6
	    LET g_plim[1] = g_plim[1] + g_plim[j]
	END FOR
END FUNCTION

#################
# OTRAS RUTINAS #
#################
#(@#)22-A Inicio
FUNCTION f7000_crear_temporal_ef052(l_numtemp)
DEFINE l_numtemp SMALLINT

  CASE l_numtemp
    WHEN 1
      SQL
        DROP TABLE IF EXISTS ef052
      END SQL
#(@#)22-A Fin
      CREATE TEMP TABLE ef052
      	(
      		fech	DATE,
      		csuc	SMALLINT,
      		#(@#)15-A - Inicio
      		agep	INTEGER,
      		#(@#)15-A - Fin
      		agen  SMALLINT,
      		plzo  SMALLINT,
      		#inicio (@#)15-A 
      		plza  SMALLINT,
      		#fin (@#)15-A 
      		tpro	SMALLINT,
      		gpro	SMALLINT,
      		impt  DECIMAL(14,2),
      		numc	INTEGER
      	) WITH NO LOG;
      	
      CREATE INDEX ef052_00 ON ef052 (csuc, agen, plzo)
    
    WHEN 2  #(@#)22-A
      SQL
        DROP TABLE IF EXISTS ef052a
      END SQL
      
      CREATE TEMP TABLE ef052a
      	(
      		cloc    SMALLINT,
      		tipo    SMALLINT,
      		plzo    SMALLINT,
      		impt    DECIMAL(14,2),
      		numc	INTEGER
      	) WITH NO LOG;
      
      CREATE INDEX ef052a_00 ON ef052a (tipo,plzo)
      
    WHEN 3 #(@#)22-A
      SQL
        DROP TABLE IF EXISTS ef052b
      END SQL
          
      CREATE TEMP TABLE ef052b
      	(
      		fech	DATE,
      		csuc	SMALLINT,
      		#(@#)15-A - Inicio
      		agep	INTEGER,
      		#(@#)15-A - Fin			
      		agen  SMALLINT,
      		#inicio (@#)15-A 
      		plza  SMALLINT,
      		#fin (@#)15-A 
      		plzo  SMALLINT,
      		tpro	SMALLINT,
      		gpro	SMALLINT,
      		impt  DECIMAL(14,2),
      		numc	INTEGER
      	) WITH NO LOG;
      
      CREATE INDEX ef052b_00 ON ef052b(csuc, agen, plzo,tpro)
    WHEN 4 #(@#)22-A
      SQL
        DROP TABLE IF EXISTS ef052q
      END SQL
      
      CREATE TEMP TABLE ef052q
      (
        fech	DATE,
      	csuc	SMALLINT,
        agen  SMALLINT,
        plzo  SMALLINT,
      	tpro	SMALLINT,
      	gpro	SMALLINT,
        impt  DECIMAL(14,2),
      	numc	INTEGER
      )WITH NO LOG;
      ##
      # Inicio (@#)6-A
#(@#)22-A Inicio
    WHEN 5
      SQL
        DROP TABLE IF EXISTS tmp_efzcb
      END SQL
#(@#)22-A Fin
      SELECT efzcbczon,efzcbdzon,efzcbcsuc,efzcbdsuc,efzcbplaz
        FROM tbsfi:efzcb
       WHERE efzcbstat = 0
      INTO TEMP tmp_efzcb WITH NO LOG
      ##
      CREATE INDEX tmp_efzcb_01 ON tmp_efzcb (efzcbczon)
      CREATE INDEX tmp_efzcb_02 ON tmp_efzcb (efzcbcsuc)
      CREATE INDEX tmp_efzcb_03 ON tmp_efzcb (efzcbplaz)
      # Fin (@#)6-A
  END CASE
END FUNCTION

FUNCTION f7100_genera_archivo_ef052()
	DEFINE	l_agen	SMALLINT,
		l_plzo	SMALLINT,
		l_impt  DECIMAL(14,2),
		l1	RECORD
			cloc    SMALLINT,
			tipo    SMALLINT,
			plzo    SMALLINT,
			impt    DECIMAL(14,2),
			numc	INTEGER
			END RECORD,
		l_tpro	SMALLINT
		#(@#)17-A - Inicio
		,l_age1	SMALLINT
		#(@#)17-A - Fin
	##
#(@#)22-A - Inicio
#	DELETE FROM ef052
  CALL f7000_crear_temporal_ef052(1)
#	DELETE FROM ef052a
  CALL f7000_crear_temporal_ef052(2)
#	DELETE FROM ef052b
	CALL f7000_crear_temporal_ef052(3)
#(@#)22-A - Fin	
	CALL f0200_declarar_efrd1_ef052()
	LET l_agen = 0
	#(@#)17-A - Inicio
	LET l_age1 = 0
	#(@#)17-A - Fin
	LET l_plzo = -1
	LET l_tpro = -1

	FOREACH q_cur1 INTO t2.*
	    #(@#)17-A - Inicio
	    IF p1.ctpl = 1 THEN
		    IF t2.efrd1age1 <> l_age1 THEN
			IF l_age1 <> 0 THEN
				INSERT INTO ef052 VALUES (t1.*)
			END IF
			LET l_age1 = t2.efrd1age1
			LET l_agen = t2.efrd1agen
			LET l_plzo = t2.efrd1plzo
			LET l_tpro = t2.efrd1tpro
			LET t1.fech = t2.efrd1fech
			LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
			LET t1.agen = t2.efrd1agen
			LET t1.plzo = t2.efrd1plzo
			LET t1.plza = t2.efrd1age1
			LET t1.agep = 0
			IF t1.plzo = 7 THEN 
				LET t1.plzo = 6
				LET l_plzo = 6
			END IF
			LET t1.tpro = t2.efrd1tpro
			LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
			LET t1.impt = 0
			LET t1.numc = 0
		    END IF
	    ELSE
	    #(@#)17-A - Fin
	    IF t2.efrd1agen <> l_agen THEN
		IF l_agen <> 0 THEN
			INSERT INTO ef052 VALUES (t1.*)
			#INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		##inicio (@#)15-A 
		LET t1.plza = t2.efrd1age1
		LET t1.agep = 0
		##fin (@#)15-A 
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	    #(@#)17-A - Inicio
	    END IF
	    #(@#)17-A - Fin
	    IF t2.efrd1plzo <> l_plzo THEN
		IF l_plzo <> -1 THEN
		    INSERT INTO ef052 VALUES (t1.*)

		    #INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		IF l_plzo = 7 THEN 
			LET l_plzo = 6
		END IF
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		##inicio (@#)15-A 
		LET t1.plza = t2.efrd1age1
		##fin (@#)15-A 
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF 
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	 IF t2.efrd1tpro <> l_tpro THEN
		IF l_tpro <> -1 THEN
		    INSERT INTO ef052 VALUES (t1.*)
		    #INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		##inicio (@#)15-A 
		LET t1.plza = t2.efrd1age1
		##fin (@#)15-A 
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	    CASE p1.tdat
	    WHEN "C"
		LET l_impt = t2.efrd1capi
	    WHEN "I"
		LET l_impt = t2.efrd1inte
	    OTHERWISE
		LET l_impt = t2.efrd1capi + t2.efrd1inte + t2.efrd1carg
	    END CASE
	    IF p1.cmon = 0 AND t2.efrd1cmon = 1 THEN
		LET l_impt = f0100_redondeo_gb000(l_impt/g_tcam,2)
	    END IF
	    # Inicio (@#)3-A
	    # Si es moneda 3 o 4 deba hacer lo mismo
	    #IF p1.cmon = 3 AND t2.efrd1cmon = 2 THEN
	    IF ( p1.cmon = 3 OR p1.cmon = 4 ) AND t2.efrd1cmon = 2 THEN
	    # Fin (@#)3-A
		LET l_impt = f0100_redondeo_gb000(l_impt*g_tcam,2)
	    END IF
	    LET t1.impt = t1.impt + l_impt
	    LET t1.numc = t1.numc + t2.efrd1numc
	    # Desgregando CxC y Prestamos de Artefactos de la 88
	   IF l_agen = 88 THEN
		IF t2.efrd1tcre <> 996 THEN
			LET l1.tipo = 1
		ELSE
			LET l1.tipo = 2
		END IF
		LET l1.cloc = l_agen
		LET l1.plzo = l_plzo
		LET l1.impt = l_impt
		LET l1.numc = t2.efrd1numc
		#INSERT INTO ef052a VALUES (l1.*)
	 END IF		
	END FOREACH
	IF l_agen <> 0 THEN
	    INSERT INTO ef052 VALUES (t1.*)
  END IF

	UNLOAD to "ef052.txt"
	select * from ef052
	ORDER BY agen, plzo 

	#para ef052a
	FOREACH q_cur222 INTO t2.*
	    IF t2.efrd1agen <> l_agen THEN
		IF l_agen <> 0 THEN
		    #INSERT INTO ef052 VALUES (t1.*)
		    INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		##inicio (@#)15-A 
		LET t1.plza = t2.efrd1age1
		##fin (@#)15-A 
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	    IF t2.efrd1plzo <> l_plzo THEN
		IF l_plzo <> -1 THEN
		    #INSERT INTO ef052 VALUES (t1.*)

		    INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		IF l_plzo = 7 THEN 
			LET l_plzo = 6
		END IF
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	    IF t2.efrd1tpro <> l_tpro THEN
		IF l_tpro <> -1 THEN
		    #INSERT INTO ef052 VALUES (t1.*)

		    INSERT INTO ef052b VALUES (t1.*)
		END IF
		LET l_agen = t2.efrd1agen
		LET l_plzo = t2.efrd1plzo
		LET l_tpro = t2.efrd1tpro
		##
		LET t1.fech = t2.efrd1fech
		LET t1.csuc = f5010_ver_sucursal_ef052(l_agen)
		LET t1.agen = t2.efrd1agen
		LET t1.plzo = t2.efrd1plzo
		##inicio (@#)15-A 
		LET t1.plza = t2.efrd1age1
		##fin (@#)15-A 
		IF t1.plzo = 7 THEN 
			LET t1.plzo = 6
			LET l_plzo = 6
		END IF
		LET t1.tpro = t2.efrd1tpro
		LET t1.gpro = f5011_ver_grupo_prod(t1.tpro)
		LET t1.impt = 0
		LET t1.numc = 0
	    END IF
	    CASE p1.tdat
	    WHEN "C"
		LET l_impt = t2.efrd1capi
	    WHEN "I"
		LET l_impt = t2.efrd1inte
	    OTHERWISE
		LET l_impt = t2.efrd1capi + t2.efrd1inte + t2.efrd1carg
	    END CASE
	    IF p1.cmon = 0 AND t2.efrd1cmon = 1 THEN
		LET l_impt = f0100_redondeo_gb000(l_impt/g_tcam,2)
	    END IF
	    # Inicio (@#)3-A
	    # Si es moneda 3 o 4 deba hacer lo mismo
	    #IF p1.cmon = 3 AND t2.efrd1cmon = 2 THEN
	    IF ( p1.cmon = 3 OR p1.cmon = 4 ) AND t2.efrd1cmon = 2 THEN
	    # Fin (@#)3-A
		LET l_impt = f0100_redondeo_gb000(l_impt*g_tcam,2)
	    END IF
	    LET t1.impt = t1.impt + l_impt
	    LET t1.numc = t1.numc + t2.efrd1numc
	    # Desgregando CxC y Prestamos de Artefactos de la 88
	   IF l_agen = 88 THEN
		IF t2.efrd1tcre <> 996 THEN
			LET l1.tipo = 1
		ELSE
			LET l1.tipo = 2
		END IF
		LET l1.cloc = l_agen
		LET l1.plzo = l_plzo
		LET l1.impt = l_impt
		LET l1.numc = t2.efrd1numc
		INSERT INTO ef052a VALUES (l1.*)
	 END IF		
	END FOREACH
	IF l_agen <> 0 THEN
	    INSERT INTO ef052b VALUES (t1.*)
	END IF
	
	UNLOAD to "ef052.txt"
	SELECT * from ef052
	
	UNLOAD to "ef052a.txt"
	SELECT * from ef052a
	
	UNLOAD to "ef052b.txt"
	SELECT * from ef052b

END FUNCTION

FUNCTION MueveParaReporte2()

  UPDATE ef052xq
  SET efrd1plzo=200
  WHERE efrd1plzo=7

  UPDATE ef052xq
  SET efrd1plzo=7
  WHERE efrd1plzo=5

  UPDATE ef052xq
  SET efrd1plzo=5
  WHERE efrd1plzo=4

  UPDATE ef052xq
  SET efrd1plzo=4
  WHERE efrd1plzo=3

  UPDATE ef052xq
  SET efrd1plzo=3
  WHERE efrd1plzo=2

  UPDATE ef052xq
  SET efrd1plzo=2
  WHERE efrd1plzo=1

  UPDATE ef052xq
  SET efrd1plzo=1
  WHERE efrd1plzo=200

END FUNCTION

# Inicio (@#)6-A
FUNCTION f5090_valida_efzcb_ef052(l_fech)
	DEFINE	l_fech          DATE,
		l_numr          SMALLINT
	##
	## No se procesa reporte si tmp_efzcb no tiene registros
	SELECT COUNT(*) INTO l_numr
		FROM tmp_efzcb
	IF l_numr = 0 THEN
	    MESSAGE "No Existe Información Zonas para Fecha ",l_fech USING "dd-mm-yyyy"
	    RETURN FALSE
	END IF
	##
	## No se procesa reporte si alguna plaza de tmp_efzcb tiene mas de un registro
	SELECT efzcbplaz,COUNT(*) numr
		FROM tmp_efzcb
		GROUP BY 1
		HAVING COUNT(*) > 1
		INTO TEMP tmp_efzcb_plaz WITH NO LOG
	##
	LET l_numr = 0
	SELECT COUNT(*) INTO l_numr
		FROM tmp_efzcb_plaz
	IF l_numr > 0 THEN
	    MESSAGE "Información Zonas Inconsistente para Fecha ",l_fech USING "dd-mm-yyyy"
	    DROP TABLE tmp_efzcb_plaz
	    RETURN FALSE
	END IF
	##
	DROP TABLE tmp_efzcb_plaz
	RETURN TRUE
	##
END FUNCTION

FUNCTION f5040_busca_dzon_ef052(l_czon)
	DEFINE	l_czon          SMALLINT,
		l_desc          CHAR(20)
	##
	SELECT DISTINCT efzcbdzon[1,7] INTO l_desc
		FROM tmp_efzcb
		WHERE efzcbczon = l_czon
	IF status = NOTFOUND THEN
		LET l_desc = "SIN ZON"
	END IF
	##
	RETURN l_desc
	##
END FUNCTION

FUNCTION f1102_impr_total_compania_ef052()
	DEFINE	r,r1		RECORD
				czon	SMALLINT,
				fech	DATE,
				csuc	SMALLINT,
				agen	SMALLINT,
				plzo	SMALLINT,
				tpro	INTEGER,
				gpro	INTEGER,
				impt	DECIMAL(14,2),
				numc	INTEGER
				END RECORD,
		l_fila		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER,
		l_porc		DECIMAL(7,2),
		l_imst, l_imsv	DECIMAL(14,2),
		l_nums, l_nusv	INTEGER,
		l_form		CHAR(7),
		l_impt1, l_impv1	DECIMAL(14,2),
		l_numc1, l_numv1	INTEGER,
		l_porc1		DECIMAL(7,2),
		l1	RECORD
			plzo    SMALLINT,
			impt    DECIMAL(14,2),
			numc	INTEGER
			END RECORD,
		x	SMALLINT,
		l_pres	SMALLINT,
		l_desplaza SMALLINT,
		l_limite SMALLINT,
		l_colspan,l_colspan1,l_agen,l_agen1,l_plzoant SMALLINT,
		l_ctasp	INTEGER,
		l_titu,l_body,l_tit_pi,l_tit_pc,l_tit_pd,l_tit_p,l_tit_z VARCHAR(255),
		l_tit_zi,l_tit_s,l_tit_sc,l_tit_si,l_tit_a,l_tit_ar,l_td,l_tdi VARCHAR(255),
		l_HTML	CHAR(3000)
	
	DECLARE q_curs3 CURSOR FOR
		SELECT 1,MAX(fech),1,1,plzo,SUM(tpro),SUM(gpro),SUM(impt),SUM(numc)
		  #FROM ef052,tmp_efzcb	# 	(@#)7-A
		  FROM ef052,OUTER tmp_efzcb	# (@#)7-A
		 WHERE csuc <> 98
		   AND agen = efzcbplaz
		 GROUP BY plzo
		 ORDER BY plzo
		
		
	INITIALIZE r.* TO NULL
	
	LET l_agen = 0
	LET l_plzoant = 0
	
	FOREACH q_curs3 INTO r.*
		LET l_HTML = ""
		CALL f5030_calc_totales_total_compania_ef052()
		    RETURNING l_impt, l_impv, l_numc, l_numv
		 		 
		IF l_impt > 0 AND l_impv > 0 THEN
		    LET l_porc = l_impv / l_impt * 100
		ELSE
		    LET l_porc = NULL 
		END IF
		IF r.agen <> l_agen THEN
			IF l_agen > 0 THEN
				IF p1.ctap = "S" THEN
					IF l_colspan1 > 0 THEN
						FOR i = 1 TO l_colspan1
							LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
						END FOR
					END IF
					LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">M</td>"
					LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
					LET l_HTML=l_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET l_HTML = "echo '", l_HTML CLIPPED, "' >> ", g_spool
					RUN l_HTML
#(@#)22-A Fin
				ELSE
					LET l_HTML=l_HTML CLIPPED, "</tr>"
#(@#)22-A Inicio
#					LET l_HTML = "echo '", l_HTML CLIPPED, "' >> ", g_spool
					RUN l_HTML
#(@#)22-A Fin
				END IF
			END IF
			LET l_agen = r.agen
			IF r.agen = 50 OR r.agen = 88 THEN
				LET l_HTML="<tr>"
				LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">SUB TOTAL 2</td>"
				LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>"
			ELSE
				LET l_HTML="<tr>"
				LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">TOTAL CIA</td>"
				LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>"
				#inicio (@#)15-A 
				IF p1.ctpl =1 THEN
				 LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>" 
				 LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">&nbsp;</td>" 
				END IF
				#fin (@#)15-A 
			END IF
			LET l_HTML=l_HTML CLIPPED, "<td ",l_tdi,">CIA</td>"
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_impt / g_miles	USING "#,###,###,###","</td>"
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_numc		USING "##,###,###","</td>"
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",(l_impt-l_impv) / g_miles	USING "###,###,###","</td>"
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_impv / g_miles		USING "###,###,###","</td>"
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					IF r.plzo = 6 THEN
						LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>"
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>"
				END IF
			END IF
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_numv		USING "###,###","</td>"
		END IF
		
		IF r.plzo > 0 THEN				
			IF l_impt > 0 AND r.impt > 0 THEN
				LET l_porc = r.impt / l_impt * 100
			ELSE
				LET l_porc = NULL
			END IF
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 1 THEN
					LET l_form = "##&.&"
				ELSE
					IF r.plzo = 6 THEN
						LET l_form = "##&.&&"
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET l_form = "##&.&"
				ELSE
					LET l_form = "##&.&&"
				END IF
			END IF
			LET l_colspan = (r.plzo -(l_plzoant + 1))*3
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
			IF l_colspan > 0 THEN
				FOR i = 1 TO l_colspan
					LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
				END FOR
			END IF
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",r.impt / g_miles	USING "###,###,###","</td>"
			IF p1.itr7 = "S" THEN
				IF r.plzo <> 6 THEN
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					IF r.plzo = 6 THEN
						LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>"
					END IF
				END IF
			ELSE
				IF r.plzo < 5 THEN
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal\" ",l_td,">",l_porc,"</td>"
				ELSE
					LET l_HTML=l_HTML CLIPPED, "<td class=\"fdecimal2\" ",l_td,">",l_porc,"</td>"
				END IF
			END IF
			LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",r.numc	USING "#,###,###","</td>"

			LET l_plzoant = r.plzo
			LET l_ctasp  = g_ctasp
		ELSE
			LET l_ctasp  = g_ctasp
			IF p1.ctap = "S" THEN
				IF p1.itr7 = "S" THEN
					LET l_colspan1 = (6 - r.plzo)*3
				ELSE	
					LET l_colspan1 = (5 - r.plzo)*3
				END IF
			END IF
		END IF
#(@#)22-A Inicio
#		LET l_HTML = "echo '", l_HTML CLIPPED, "' >> ", g_spool
#		RUN l_HTML
    OUTPUT TO REPORT imprime_rep_detallado(l_HTML)
#(@#)22-A Fin
	END FOREACH
	{
	IF p1.ctap = "S" THEN
		IF l_colspan1 > 0 THEN
			FOR i = 1 TO l_colspan1
				LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">&nbsp;</td>"
			END FOR
		END IF
		LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">M</td>"
		LET l_HTML=l_HTML CLIPPED, "<td ",l_td,">",l_ctasp USING "##,###","</td>"
		LET l_HTML=l_HTML CLIPPED, "</tr>"
		LET l_HTML = "echo '", l_HTML CLIPPED, "' >> ", g_spool
		RUN l_HTML
	ELSE
		LET l_HTML=l_HTML CLIPPED, "</tr>"
		LET l_HTML = "echo '", l_HTML CLIPPED, "' >> ", g_spool
		RUN l_HTML
	END IF
	}
	RETURN l_HTML
END FUNCTION

FUNCTION f5030_calc_totales_total_compania_ef052()
	DEFINE	l_agen		SMALLINT,
		l_impt, l_impv	DECIMAL(14,2),
		l_numc, l_numv	INTEGER

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		  #AND agen NOT IN (50,88)	# (@#)7-A
		  AND plzo NOT IN(1)
  ELSE
	SELECT SUM(numc), SUM(impt) INTO l_numc, l_impt
		FROM ef052
		WHERE fech = p1.fech
		  #AND agen NOT IN (50,88)	# (@#)7-A
		    AND plzo NOT IN(6)
  END IF

	IF l_numc IS NULL THEN LET l_numc = 0 END IF
	IF l_impt IS NULL THEN LET l_impt = 0 END IF


  IF p1.itr7 = "S" THEN
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		    #AND agen NOT IN (50,88)	# (@#)7-A
		    AND plzo IN(2,3,4,5,6)
  
  ELSE
  
	  SELECT SUM(numc), SUM(impt) INTO l_numv, l_impv
		  FROM ef052
		  WHERE fech = p1.fech
		    #AND agen NOT IN (50,88)	# (@#)7-A
		    AND plzo IN(1,2,3,4,5)
  END IF


	IF l_numv IS NULL THEN LET l_numv = 0 END IF
	IF l_impv IS NULL THEN LET l_impv = 0 END IF

  IF p1.itr7 = "S" THEN
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo IN (0,2)
	#AND agen NOT IN (50,88)		# (@#)7-A
  ELSE
	SELECT SUM(numc) INTO g_ctasp
	FROM ef052
	WHERE fech = p1.fech
	AND   plzo between 0 AND 1
	#AND agen NOT IN (50,88)		# (@#)7-A
  END IF
	RETURN l_impt, l_impv, l_numc, l_numv

END FUNCTION

# Fin (@#)6-A

{Ini #Filtro de Compromiso Intencion de Pago# ATE-20090730}
FUNCTION f0410_pedir_datos_aux_ef052()
	DEFINE 
		l_fec1 DATE	
	OPEN WINDOW wextras AT 12,37 WITH FORM "ef052k" ATTRIBUTE (FORM LINE 1, MESSAGE LINE LAST)
	IF p4.cart = 0 THEN
		LET p4.dcar = "TODOS"
		LET p4.tefe = NULL 
		LET p4.defe = NULL 
	END IF
	DISPLAY BY NAME p4.*
	INPUT BY NAME p4.* WITHOUT DEFAULTS
		ON KEY (INTERRUPT,CONTROL-C)
			LET INT_FLAG=TRUE
			EXIT INPUT
		# (@#)19-A - Inicio
		ON KEY (CONTROL-V)
			IF INFIELD(cart) THEN
				CALL f0200_selecionar_concepto_ef451(7,176)
				RETURNING p4.cart,p4.dcar
				DISPLAY BY NAME p4.cart,p4.dcar
			END IF
			IF INFIELD(tefe) THEN
				CALL f0200_selecionar_concepto_ef451(7,365)
				RETURNING p4.tefe,p4.defe
				DISPLAY BY NAME p4.tefe,p4.defe
			END IF
		# (@#)19-A - Fin
		{VAT Ini. Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}
		BEFORE FIELD tges
			IF p4.tges IS NULL THEN
				LET p4.tges = 0
			END IF
			DISPLAY BY NAME p4.tges
			#ERROR "Digite: (0) Total / (1) ADCs / (2) PROCs / (3) ProcPAA"
			# Inicio (@#)8-A
			#ERROR "Digite: (0)Total /(1)ADCs /(2)ProcP1 /(3)ProcP2 /(4)ProcP3"		#CEMO (@#) 1-A	#CEMO (@#)8-A
			ERROR "Digite: (0)Total /(1)ADCs /(2)ProcP1 /(3)ProcP2 /(4)ProcP3 /(5)ECob"			#CEMO (@#)8-A
			# Fin (@#)8-A
	                # (@#)13-A Inicio
	                	IF f5005_mostrar_procurador3_ef451(p1.fech) THEN
	                		LET p4.ocpu = "(0,1,2,3,4,5)"
	                	ELSE
	                		LET p4.ocpu = "(0,1,2,3,5)"
	                		ERROR "Digite: (0)Total /(1)ADCs /(2)ProcP1 /(3)ProcP2/(5)ECob"
	                	END IF
	                	DISPLAY BY NAME p4.ocpu
	                # (@#)13-A Fin			
		AFTER FIELD tges
			IF p4.tges IS NULL THEN
				LET p4.tges = 0
				DISPLAY BY NAME p4.tges
			END IF
			IF p4.tges > 0 THEN
				SELECT efparfec1 INTO l_fec1 
				FROM tbsfi:efpar WHERE efparpfij = 42 
				AND efparstat = 1 
				AND efparplaz = 0 
				IF p1.fech<l_fec1 THEN
					LET p4.tges=1
					DISPLAY BY NAME p4.tges
					ERROR "Opcion disponible a partir de ", l_fec1 USING "dd/mm/yyyy" SLEEP 2
					LET INT_FLAG=TRUE
				END IF
			END IF
		{VAT Fin Filtro de Reporteo por Tipo de Gestor(ADCs/Proc/ProcPAA) 29/09/2009}
		# (@#)13-A Inicio
			IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
				IF p4.tges = 4 THEN
					LET p4.tges = NULL
					DISPLAY BY NAME p4.tges
					NEXT FIELD tges
				END IF
			END IF
		# (@#)13-A Fin			
		{VAT Ini. Filtro de Reporteo por Zona o Cobrador(ADC/PROCs) 02/09/2009}		
		BEFORE FIELD trep
			ERROR "OPCION NO DISPONIBLE"
			LET p4.trep = 1
			DISPLAY BY NAME p4.trep	
			NEXT FIELD mcip
			{VAT 02/09/2009 - SE COMENTA ESTA FUNCIONALIDAD XQ NO SE PEDIRA ESTE DATO X EL MOMENTO
			ERROR "Digite: (1) Por Zona / (2) Por Cobrador (ADC/PROCs)"
		AFTER FIELD trep
			NEXT FIELD mcip
			#IF p4.trep IS NULL THEN
			#	LET p4.trep = 1
			#	DISPLAY BY NAME p4.trep				
			#END IF
			{IF p4.trep = 2 THEN
				SELECT efparfec1 INTO l_fec1 
				FROM tbsfi:efpar WHERE efparpfij = 42 
				AND efparstat = 1 
				AND efparplaz = 0 
				IF p1.fech<l_fec1 THEN
					LET p4.trep=1
					DISPLAY BY NAME p4.trep
					ERROR "Opcion disponible a partir de ", l_fec1 USING "dd/mm/yyyy" SLEEP 2
					LET INT_FLAG=TRUE
				END IF
			END IF}
		BEFORE FIELD mcip
			IF p4.mcip IS NULL THEN
				LET p4.mcip=0
			END IF
			DISPLAY BY NAME p4.mcip
			ERROR "Digite: (0) Total / (1) Sin Prest.CIP / (2) Solo Prest.CIP" 
		{VAT Fin. Filtro de Reporteo por Zona o Cobrador(ADC/PROCs) 02/09/2009}
		AFTER FIELD mcip
			IF p4.mcip IS NULL THEN
				LET p4.mcip=0
				DISPLAY BY NAME p4.mcip
			END IF
			IF p4.mcip=1 OR p4.mcip=2 THEN
				{VAT Ini. Filtro de  fecha a partir de la cual existira esta data en la tabla 02/09/2009}	
				SELECT efparfec1 INTO l_fec1 
				FROM tbsfi:efpar WHERE efparpfij = 41 
				AND efparstat = 1 
				AND efparplaz = 0 
				IF p1.fech<l_fec1 THEN
					LET p4.mcip=0
					DISPLAY BY NAME p4.mcip
					ERROR "Opcion disponible a partir de ", l_fec1 USING "dd/mm/yyyy" SLEEP 2
				{VAT Ini. Filtro de  fecha a partir de la cual existira esta data en la tabla 02/09/2009}	
						LET INT_FLAG=TRUE
				END IF
			END IF
		# (@#)13-A Inicio
			IF NOT f5005_mostrar_procurador3_ef451(p1.fech) THEN
				IF p4.tges = 4 THEN
					LET p4.tges = NULL
					DISPLAY BY NAME p4.tges
					NEXT FIELD tges
				END IF
			END IF
		# (@#)13-A Fin				
		# Inicio (@#)4-A
		BEFORE FIELD cart
			#ERROR "Digite: (0) Total / (1) Electrodomesticos / (2) Motos" 																					# (@#)19-A
			ERROR "Seleccione Tipo de Negocio <CONTROL - V>" 																												# (@#)19-A
		AFTER FIELD cart
			# (@#)19-A - Inicio
			#IF p4.cart IS NULL THEN
			#	LET p4.cart = 1
			#	DISPLAY BY NAME p4.cart
			#	ERROR "Ingrese el Tipo de Cartera" SLEEP 2
			#	NEXT FIELD cart
			#END IF
			# (@#)19-A - Din
		# Fin (@#)4-A	
		# (@#)19-A - Incio	
			IF p4.cart IS NULL THEN
				LET p4.cart = 0
				DISPLAY BY NAME p4.cart
			END IF
			IF p4.cart IS NOT NULL THEN
				IF p4.cart = 0 THEN
					LET p4.dcar = "TODOS"
				ELSE
					LET p4.dcar = f9000_busca_concepto_gb000(176,p4.cart)
				END IF
				IF p4.dcar IS NULL THEN
					ERROR "No existe codigo de Linea de Negocio"
					LET p4.cart = NULL
					LET p4.dcar = NULL
					DISPLAY BY NAME p4.cart,p4.dcar
					NEXT FIELD cart
				END IF
				DISPLAY BY NAME p4.cart,p4.dcar
			END IF
			BEFORE FIELD tefe			
			IF p4.cart = 5 THEN  
				ERROR "Seleccione Tipo de Efectivo <CONTROL - V>"							
			ELSE
				IF p1.tcuo = 1 THEN
					NEXT FIELD diap
				ELSE
					LET p4.diap = 0
					EXIT INPUT
				END IF
			END IF			
			AFTER FIELD tefe			
			IF p4.tefe IS NULL THEN
				LET p4.tefe = 0
				DISPLAY BY NAME p4.tefe
			END IF
			IF p4.tefe IS NOT NULL THEN
				IF p4.tefe = 0 THEN
					LET p4.defe = "TODOS"
				ELSE
					LET p4.defe = f9000_busca_concepto_gb000(365,p4.tefe)
				END IF
				IF p4.defe IS NULL THEN
					ERROR "No existe codigo de Linea de Negocio"
					LET p4.tefe = NULL
					LET p4.defe = NULL
					DISPLAY BY NAME p4.tefe,p4.defe
					NEXT FIELD tefe
				END IF
				DISPLAY BY NAME p4.tefe,p4.defe
			END IF
		# (@#)19-A - Fin
		# Inicio (@#)5-A
		# Solo si es Cuota Mensual pide dia de pago del prestmo
			IF p1.tcuo = 1 THEN
				NEXT FIELD diap
			ELSE
				LET p4.diap = 0
				EXIT INPUT
			END IF
		BEFORE FIELD diap
			ERROR "Digite Dia de Pago del Prestamo (0/1/5/10/15/20/25) "
		AFTER FIELD diap
			IF p4.diap IS NULL THEN
				LET p4.diap = 0
				DISPLAY BY NAME p4.diap
				ERROR "Ingrese el Dia de Pago del Prestamo" SLEEP 2
				NEXT FIELD diap
			END IF
		# Fin (@#)5-A
	END INPUT
	CLOSE WINDOW wextras
	IF INT_FLAG=TRUE THEN
		LET INT_FLAG=FALSE
		RETURN FALSE
	ELSE
		RETURN TRUE
	END IF
END FUNCTION
{Fin #Filtro de Compromiso Intencion de Pago# ATE-20090730}

#inicio (@#)15-A 
FUNCTION f0412_obtener_descripcion_ef052(l_cod,l_prf)
DEFINE	l_cod	SMALLINT,
	l_prf	SMALLINT,
	l_sql	CHAR(800),
	l_des  char(100)
	SELECT gbcondesc INTO l_des FROM gbcon where gbconcorr= l_cod and gbconpfij=l_prf and gbconcorr<>0
	RETURN l_des
END FUNCTION
#fin (@#)15-A 

{VAT Ini. 05/10/2009 Insercion en tabla efcbl log de ejecucion}
FUNCTION f9100_inserta_log_ini_fin_ef052(l_nrut,l_plaz,l_fdia,l_treg,l_tlog)
	DEFINE  l_nrut  CHAR(04),
		l_plaz  SMALLINT,
		l_fdia  DATE,
		l_treg  CHAR(01),
		l_tlog  CHAR(01),
		l_fsis  DATE,
		l_hsis  CHAR(08)
	##
	LET l_fsis = TODAY
	LET l_hsis = TIME
	IF l_treg = 'I' THEN LET g_ntri = 0 END IF
	INSERT INTO tbsfi:efcbl VALUES (0,g_proc,l_nrut,l_plaz,l_fdia,g_tpmt,l_treg,10,p1.agen1,10,p1.agen2,0,0,
					'',l_tlog,g_user,l_fsis,l_hsis,t0.gbpmtplaz,t0.gbpmttcof,g_ntri,'R')
	LET g_ntri = SQLCA.SQLERRD[2]
	##
END FUNCTION
{VAT Fin 05/10/2009 Insercion en tabla efcbl log de ejecucion}

#(@#)16-A Inicio
FUNCTION f1120_procesar_mensaje_ef052()
DEFINE 	l_mens	CHAR(700)

	LET l_mens= "CONSOLIDADO DE ATRASO X ETAPAS \n",
			"INPUTS: \n",
			"Sistema: ",p1.msis,"\n",
                	"Tipo de Filtro: ",p1.tfilt," \n",
                	"Agent/Plaza: Del ",p1.agen1 USING "<<<"," al ",p1.agen2 USING "<<<"," \n",
                	"Moneda: ",p1.cmon USING "<<<"," \n",
                	"A Fecha: ",p1.fech,"\n",
                	"Credito: ",p1.tcre," \n",
                	"Tipo: ",p1.tcr1," \n",
                	"Inicial : Del ",p1.tcre1 USING "<<<"," al ",p1.tcre2 USING "<<<","\n",
                	"Cuota: ",p1.tcuo,"\n",
                	"Agencias: Del ",p1.agen1 USING "<<<"," al ",p1.agen2 USING "<<<","\n",
                	"Tipo Gestor: ",p4.tges,"\n",
                	"Ver Prest.CIP: ",p4.mcip,"\n",
                	"Cartera de: ",p4.cart,"\n",
                	"Dia Pago Credito: ",p4.diap USING "<<<","\n",
                	"Valores: ",p1.tdat,"\n",
                	"Tipo Reporte: ",p1.tcar USING "<<<","\n",
                	"Tip. Castigo : ",p1.tcas USING "<<<","\n",
                	"Tip. Microz. : ",p1.microz,"\n",
                	"Ctas Prdtvs : ",p1.ctap USING "<<<","\n",
                	"Incluir : ",p1.itr7,"\n",
                	"Modelo Cob.: ",g_mode USING "<<<","\n",
                	"\n Envio del Reporte: ",TODAY," ,Hora:", TIME,"\n"
	RETURN l_mens	                	
END FUNCTION                	
#(@#)16-A Fin

#(@#)22-A Inicio
------------------------------------------------------------------------------------------
REPORT imprime_rep_detallado(l_sHTML)
------------------------------------------------------------------------------------------
DEFINE l_sHTML	CHAR(10000)   # VARIABLE PARA ALMACENAR UNA CADENA HTML
   OUTPUT
      page   length 1
      left   margin 0
      bottom margin 0
      top    margin 0

	 FORMAT ON EVERY ROW
	 PRINT COLUMN 000, l_sHTML CLIPPED

END REPORT
#(@#)22-A Fin

{
## Impresora
	 1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890
      \               -------------------   T o t a l e s   ----------------  |
       \                 General    Ctas    Vigente    Vencido    %     Ctas  |
Agencia \ Limite                                                 7.6          |
--------------------------------------------------------------------------------
X-------(20)-------X  ##,###,### ###,###  #,###,###  #,###,### ##&.& ###,###  |

	 9         0         1         2         3         4         5         6
12345678901234567890123456789012345678901234567890123456789012345678901234567890
 ----  1 a 30 dias  ---  |  ---  31 a 60 dias  ---  |  ---  61 a 90 dias  ---  |
    Atraso    %    Ctas  |     Atraso    %    Ctas  |     Atraso    %    Ctas  |
	     2.3         |              1.1         |              0.8         |
--------------------------------------------------------------------------------
 #,###,### ##&.& ##,###  |  #,###,### ##&.& ##,###  |  #,###,### ##&.& ##,###  |

	 7         8         9         0         1
123456789012345678901234567890123456789012345678901
  ---  91 a 120 dias  --  |  ---  mas de 120 d  ---
     Atraso    %    Ctas  |     Atraso    %    Ctas
	      1.0         |              2.4       
---------------------------------------------------
  #,###,### ##&.& ##,###  |  #,###,### ##&.& ##,###
}

