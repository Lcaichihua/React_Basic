USE [PLAN1Desarrollo]
GO
/****** Object:  User [plan1userses]    Script Date: 09/12/2019 03:24:15 p.m. ******/
CREATE USER [plan1userses] FOR LOGIN [plan1userses] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [SES\SES-PROY-PLAN]    Script Date: 09/12/2019 03:24:15 p.m. ******/
CREATE USER [SES\SES-PROY-PLAN] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [SESDIGITAL\T-DSQL-PLANI-OWN]    Script Date: 09/12/2019 03:24:15 p.m. ******/
CREATE USER [SESDIGITAL\T-DSQL-PLANI-OWN] FOR LOGIN [SESDIGITAL\T-DSQL-PLANI-OWN] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [userprplandes]    Script Date: 09/12/2019 03:24:15 p.m. ******/
CREATE USER [userprplandes] FOR LOGIN [userprplandes] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [plan1userses]
GO
ALTER ROLE [db_owner] ADD MEMBER [SES\SES-PROY-PLAN]
GO
ALTER ROLE [db_owner] ADD MEMBER [SESDIGITAL\T-DSQL-PLANI-OWN]
GO
ALTER ROLE [db_owner] ADD MEMBER [userprplandes]
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_BUSCA_ERROR]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_BUSCA_ERROR]
( @nCodRda int ,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @BASICO VARCHAR(50), @JUDICIAL VARCHAR(50)
 BEGIN 
set  @JUDICIAL= @BASICO +10
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_CalculodePlanilla_11_26_33_5_10_2019]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_CalculodePlanilla_11_26_33_5_10_2019]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @APORTE decimal(10,2), @ASIGFAM decimal(10,2), @BASIPAGO decimal(10,2), @COVA decimal(10,2), @DESAFP decimal(10,2), @DESCUENTO decimal(10,2), @DESEPS decimal(10,2), @DESONP decimal(10,2), @DESPRI decimal(10,2), @DFALTADOS int, @DIAMES int, @DTRAB int, @ESSALUD decimal(10,2), @FONPEN decimal(10,2), @H125 int, @HINC int, @HODI int, @INGRESO decimal(10,2), @MOV decimal(10,2), @PENFALTAS decimal(10,2), @PHINC decimal(10,2), @REFRIGER decimal(10,2), @REMBASIC decimal(10,2)
 BEGIN 
 
 /* Remuneracion basica*/ 
SET @REMBASIC = ( SELECT CSUEBAS  FROM det_persona_planilla WHERE cCodRda =@nCodRda ) 
 /* Dias Trabajados*/ 
SET @DTRAB =( SELECT  ISNULL(DTRAB,0)  FROM Resumen_const_personas WHERE NCODRDA = @nCodRda AND CPERCAL = @CPERCAL) 
 /* DIAS DEL MES*/ 
SET @DIAMES =( SELECT CONVERT(INT ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 7 ) 
 /* Horas por dia*/ 
SET @HODI = (SELECT CONVERT(INT ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 11) 
 /* DIAS FALTA*/ 
SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* Horas de Incumplimineto*/ 
SET @HINC = (SELECT ISNULL(HRIM,0) FROM RESUMEN_CONST_PERSONAS
WHERE nCodRDA = @NCODRDA AND cPerCal = @CPERCAL) 
 /* Penalidad horas incumplidas*/ 
SET @PHINC = (@REMBASIC/(@DIAMES*@HODI)) * @HINC 
 /* penalidad falta*/ 
SET @PENFALTAS  = (@REMBASIC/@DIAMES) * @DFALTADOS 
 /* Horas Extras de 1.25*/ 
SET @H125 = (SELECT ISNULL(H125,0) FROM RESUMEN_CONST_PERSONAS WHERE nCodRDA = @NCODRDA AND cPerCal = @CPERCAL) 
 /* Basico a Pagar*/ 
SET @BASIPAGO = @REMBASIC - @PENFALTAS - @PHINC + (@H125 * @REMBASIC*0.0125) 
 /* Descuento de AFP*/ 
SET @DESAFP =  (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 12 ) 
 /* Descuento de ONP*/ 
SET @DESONP =  (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 13 ) 
 /* Descuento de EPS*/ 
SET @DESEPS = ( SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 3 ) 
 /* Asignacion Familiar*/ 
SET @ASIGFAM = (SELECT CASE   WHEN NHIJOS > 0 THEN (select  CAST(cMaeValor AS DECIMAL(10, 2))AS cMaeValor  from maestros where nMaeId =5)
           ELSE 0
           END AS ASIGFAM 
           FROM det_persona_planilla WHERE cCodRda = @nCodRda ); 
 /* Fondo de Pensiones (AFP)*/ 
SET @FONPEN = (SELECT CASE                WHEN nTipPen = 1 THEN @DESAFP
           WHEN nTipPen = 2 THEN @DESONP
           ELSE 0
           END AS MontoPension 
           FROM det_persona_planilla WHERE cCodRda = @nCodRda ) * @BASIPAGO ; 
 /* Comision Variable (AFP)*/ 
SET @COVA = (SELECT CONVERT(DECIMAL (10,4) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 14 ) * @BASIPAGO 
 /* Descuento de PRIMA SEGURO*/ 
SET @DESPRI = ( SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 15 ) * @BASIPAGO 
 /* Essalud*/ 
SET @ESSALUD = (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 2 ) * @REMBASIC ; 
 /* Refrigerio*/ 
SET @REFRIGER= (select  Refrigerio from [Resumen_const_personas] where ncodRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* Movilidad*/ 
SET @MOV =  (select  Movilidad from [Resumen_const_personas] where ncodRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* ingresos*/ 
SET @INGRESO = @ASIGFAM +@REFRIGER + @BASIPAGO + @MOV 
 /* descuentos*/ 
SET @DESCUENTO =  @FONPEN + @COVA + @DESPRI 
 /* aportes*/ 
SET @APORTE = @ESSALUD
SELECT  '81'+'*'+CONVERT(VARCHAR, @REMBASIC ) +' | '+ '22'+'*'+CONVERT(VARCHAR, @DTRAB ) +' | '+ '6'+'*'+CONVERT(VARCHAR, @DIAMES ) +' | '+ '85'+'*'+CONVERT(VARCHAR, @HODI ) +' | '+ '7'+'*'+CONVERT(VARCHAR, @DFALTADOS ) +' | '+ '29'+'*'+CONVERT(VARCHAR, @HINC ) +' | '+ '86'+'*'+CONVERT(VARCHAR, @PHINC ) +' | '+ '77'+'*'+CONVERT(VARCHAR, @PENFALTAS  ) +' | '+ '30'+'*'+CONVERT(VARCHAR, @H125 ) +' | '+ '19'+'*'+CONVERT(VARCHAR, @BASIPAGO ) +' | '+ '83'+'*'+CONVERT(VARCHAR, @DESAFP ) +' | '+ '84'+'*'+CONVERT(VARCHAR, @DESONP ) +' | '+ '89'+'*'+CONVERT(VARCHAR, @DESEPS ) +' | '+ '8'+'*'+CONVERT(VARCHAR, @ASIGFAM ) +' | '+ '54'+'*'+CONVERT(VARCHAR, @FONPEN ) +' | '+ '48'+'*'+CONVERT(VARCHAR, @COVA ) +' | '+ '90'+'*'+CONVERT(VARCHAR, @DESPRI ) +' | '+ '18'+'*'+CONVERT(VARCHAR, @ESSALUD ) +' | '+ '21'+'*'+CONVERT(VARCHAR, @REFRIGER) +' | '+ '20'+'*'+CONVERT(VARCHAR, @MOV ) +' | '+ '74'+'*'+CONVERT(VARCHAR, @INGRESO ) +' | '+ '75'+'*'+CONVERT(VARCHAR, @DESCUENTO ) +' | '+ '76'+'*'+CONVERT(VARCHAR, @APORTE ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_CalculodePlanilla_11_3_55_3_10_2019]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_CalculodePlanilla_11_3_55_3_10_2019]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @APORTE decimal(10,2), @ASIGFAM decimal(10,2), @BASIPAGO decimal(10,2), @COVA decimal(10,2), @DESAFP decimal(10,2), @DESCUENTO decimal(10,2), @DESEPS decimal(10,2), @DESONP decimal(10,2), @DESPRI decimal(10,2), @DFALTADOS int, @DIAMES int, @DTRAB int, @ESSALUD decimal(10,2), @FONPEN decimal(10,2), @H125 int, @HINC int, @HODI int, @INGRESO decimal(10,2), @MOV decimal(10,2), @PENFALTAS decimal(10,2), @PHINC decimal(10,2), @REFRIGER decimal(10,2), @REMBASIC decimal(10,2)
 BEGIN 
 
 /* Remuneracion basica*/ 
SET @REMBASIC = ( SELECT CSUEBAS  FROM det_persona_planilla WHERE cCodRda =@nCodRda ) 
 /* Dias Trabajados*/ 
SET @DTRAB =( SELECT  ISNULL(DTRAB,0)  FROM Resumen_const_personas WHERE NCODRDA = @nCodRda AND CPERCAL = @CPERCAL) 
 /* DIAS DEL MES*/ 
SET @DIAMES =( SELECT CONVERT(INT ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 7 ) 
 /* Horas por dia*/ 
SET @HODI = (SELECT CONVERT(INT ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 11) 
 /* DIAS FALTA*/ 
SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* Horas de Incumplimineto*/ 
SET @HINC = (SELECT ISNULL(HRIM,0) FROM RESUMEN_CONST_PERSONAS
WHERE nCodRDA = @NCODRDA AND cPerCal = @CPERCAL) 
 /* Penalidad horas incumplidas*/ 
SET @PHINC = (@REMBASIC/(@DIAMES*@HODI)) * @HINC 
 /* penalidad falta*/ 
SET @PENFALTAS  = (@REMBASIC/@DIAMES) * @DFALTADOS 
 /* Horas Extras de 1.25*/ 
SET @H125 = (SELECT ISNULL(H125,0) FROM RESUMEN_CONST_PERSONAS WHERE nCodRDA = @NCODRDA AND cPerCal = @CPERCAL) 
 /* Basico a Pagar*/ 
SET @BASIPAGO = @REMBASIC - @PENFALTAS - @PHINC + (@H125 * @REMBASIC*0.0125) 
 /* Descuento de AFP*/ 
SET @DESAFP =  (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 12 ) 
 /* Descuento de ONP*/ 
SET @DESONP =  (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 13 ) 
 /* Descuento de EPS*/ 
SET @DESEPS = ( SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 3 ) 
 /* Asignacion Familiar*/ 
SET @ASIGFAM = (SELECT CASE   WHEN NHIJOS > 0 THEN (select  CAST(cMaeValor AS DECIMAL(10, 2))AS cMaeValor  from maestros where nMaeId =5)
           ELSE 0
           END AS ASIGFAM 
           FROM det_persona_planilla WHERE cCodRda = @nCodRda ); 
 /* Fondo de Pensiones (AFP)*/ 
SET @FONPEN = (SELECT CASE                WHEN nTipPen = 1 THEN @DESAFP
           WHEN nTipPen = 2 THEN @DESONP
           ELSE 0
           END AS MontoPension 
           FROM det_persona_planilla WHERE cCodRda = @nCodRda ) * @BASIPAGO ; 
 /* Comision Variable (AFP)*/ 
SET @COVA = (SELECT CONVERT(DECIMAL (10,4) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 14 ) * @BASIPAGO 
 /* Descuento de PRIMA SEGURO*/ 
SET @DESPRI = ( SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 15 ) * @BASIPAGO 
 /* Essalud*/ 
SET @ESSALUD = (SELECT CONVERT(DECIMAL (10,2) ,CMAEVALOR) FROM MAESTROS  WHERE NMAEID = 2 ) * @REMBASIC ; 
 /* Refrigerio*/ 
SET @REFRIGER= (select  Refrigerio from [Resumen_const_personas] where ncodRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* Movilidad*/ 
SET @MOV =  (select  Movilidad from [Resumen_const_personas] where ncodRDA = @NCODRDA AND CPERCAL = @CPERCAL) 
 /* ingresos*/ 
SET @INGRESO = @ASIGFAM +@REFRIGER + @BASIPAGO + @MOV 
 /* descuentos*/ 
SET @DESCUENTO =  @FONPEN + @COVA + @DESPRI 
 /* aportes*/ 
SET @APORTE = @ESSALUD
SELECT  '81'+'*'+CONVERT(VARCHAR, @REMBASIC ) +' | '+ '22'+'*'+CONVERT(VARCHAR, @DTRAB ) +' | '+ '6'+'*'+CONVERT(VARCHAR, @DIAMES ) +' | '+ '85'+'*'+CONVERT(VARCHAR, @HODI ) +' | '+ '7'+'*'+CONVERT(VARCHAR, @DFALTADOS ) +' | '+ '29'+'*'+CONVERT(VARCHAR, @HINC ) +' | '+ '86'+'*'+CONVERT(VARCHAR, @PHINC ) +' | '+ '77'+'*'+CONVERT(VARCHAR, @PENFALTAS  ) +' | '+ '30'+'*'+CONVERT(VARCHAR, @H125 ) +' | '+ '19'+'*'+CONVERT(VARCHAR, @BASIPAGO ) +' | '+ '83'+'*'+CONVERT(VARCHAR, @DESAFP ) +' | '+ '84'+'*'+CONVERT(VARCHAR, @DESONP ) +' | '+ '89'+'*'+CONVERT(VARCHAR, @DESEPS ) +' | '+ '8'+'*'+CONVERT(VARCHAR, @ASIGFAM ) +' | '+ '54'+'*'+CONVERT(VARCHAR, @FONPEN ) +' | '+ '48'+'*'+CONVERT(VARCHAR, @COVA ) +' | '+ '90'+'*'+CONVERT(VARCHAR, @DESPRI ) +' | '+ '18'+'*'+CONVERT(VARCHAR, @ESSALUD ) +' | '+ '21'+'*'+CONVERT(VARCHAR, @REFRIGER) +' | '+ '20'+'*'+CONVERT(VARCHAR, @MOV ) +' | '+ '74'+'*'+CONVERT(VARCHAR, @INGRESO ) +' | '+ '75'+'*'+CONVERT(VARCHAR, @DESCUENTO ) +' | '+ '76'+'*'+CONVERT(VARCHAR, @APORTE ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_Cerrar_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ----------------------------------------------------------------------
--  SISTEMA 	   : PLN
--  SUBSISTEMA     : PLN
--  NOMBRE 	       : SPS_SES_PLN_MANT_Variable
--  AUTOR 	       : Larry Caichihua - SES xd
--  FECHA CREACIÓN : 17/07/2019 
--  DESCRIPCION    : Cerrar Planilla.
-- -----------------------------------------------------------------------
--  FECHA         MODIFICACIÓN                                EMPLEADO
-- -----------------------------------------------------------------------
Create procedure [dbo].[SPS_SES_PLN_Cerrar_Planilla]( 
	@nAccion		INT = 0,
	@cPercal  char(6)
	 	--select * from Ejecucion_Planilla 
) 
AS
BEGIN

	

	IF @nAccion = 1	--Cerrar Planilla
	BEGIN
		UPDATE	[dbo].Ejecucion_Planilla
		SET						
				cFlgCie = 0
				
		WHERE	cPerCal = @cPercal 
	END


	
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_EjecutarCalculoPlanilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_EjecutarCalculoPlanilla](
	 @periodo char(6) ,
	@colaboradores	XML  
)
AS
/*
DECLARE @SQL nVARCHAR(MAX) ,@NombreProc varchar(max) 
	 ,@codrda int = 4 ,@per_d varchar(max) ='032019' 
	
	
	set @NombreProc = ( SELECT top 1  b.cNomProc FROM CONFIGURACioN A INNER JOIN DET_CONFIGURACION B ON A.nconfid= B.nconfId  where a.cflgAct = '1')



	SET @SQL = @NombreProc +' '+CONVERT(VARCHAR(10)+@codrda)+','+CHAR(39)+@per_d+CHAR(39)

	EXEC sp_executesql @SQL */
	--exec SPS_SES_PLN_CalculodePlanilla18_31_18_2_10_2019 4,'032019'

	
		--+  @nCodRda + ', ' + @cPerCal
	
DECLARE  @sueneto decimal (10,2) ,@ObtengoCodConfig INT, @hDoc INT = 0  ,
@ingresos decimal(10,2) =0.00 ,@ingresos_totales decimal(10,2) =0.00 ,
@descuentos decimal(10,2) =0.00 ,@descuentos_totales decimal(10,2) =0.00 ,
@aportes decimal(10,2) =0.00 ,@aportes_totales decimal(10,2) =0.00 ,
 @mont_ing varchar(max) ,@mont_desc varchar(max) ,@mont_aport varchar(max) ,
 @SQL nVARCHAR(MAX) ,@NombreProc varchar(max) 
 
 
	BEGIN


	/*insertar cabecera */


	
	/* INICIO extrael xml */

	

	SET @ObtengoCodConfig = ((select ISNULL(MAX(nConfId),1) from Configuracion)) ;

	EXEC sp_xml_PrepareDocument @hDoc OUT, @colaboradores

                               SELECT ROW_NUMBER() 
                                               OVER(ORDER BY CodRDA, nTipCola ) AS ROW,
                               CodRDA, nTipCola
                               INTO #TABLA_DATOSCOLABORADOR_DOC
                               FROM OpenXml(@hDoc, 'Tabla/Datos') 
                               WITH     
                               (
                               CodRDA INT,
                               nTipCola INT
                               )



	/* FIN extraer xml */
		
	set @NombreProc = ( SELECT top 1  b.cNomProc FROM CONFIGURACioN A INNER JOIN DET_CONFIGURACION B ON A.nconfid= B.nconfId  where a.cflgAct = '1') ;


 DECLARE emp_cursor CURSOR FOR     
 select CodRDA, nTipCola from #TABLA_DATOSCOLABORADOR_DOC  
order by CodRDA;    
  
OPEN emp_cursor    
  
  declare @codrda int  , @nTipCola int 
	FETCH NEXT FROM emp_cursor     
	INTO @codrda,@nTipCola     
     
  
WHILE @@FETCH_STATUS = 0  
  
BEGIN    
create table #tmp ( concepto  varchar(max));
insert #tmp
EXEC  @NombreProc  @codrda,@periodo ;

declare @var varchar(max)= (select concepto from  #tmp );
/* seugndo paso */ 
create table #tmpo (concepto  varchar(max)) ;
insert #tmpo SELECT * FROM STRING_SPLIT(@var, '|') ;
		SELECT
		concepto = SUBSTRING(concepto, 0, CHARINDEX('*', concepto)),
		dato = SUBSTRING(concepto, CHARINDEX('*', concepto) + 1, LEN(concepto))  into #conceptos_dato FROM #tmpo

alter table  #conceptos_dato  add id int NOT NULL IDENTITY(1, 1);

/************  INICIO insercion del detalle ejecuccion    ************ */

 set @mont_ing = ( select dato from #conceptos_dato where concepto = 74 )
 set @ingresos = (SELECT CAST(@mont_ing AS DECIMAL(10, 2)))
  set @mont_desc = (select dato from #conceptos_dato where concepto = 75 )
 set @descuentos = (SELECT CAST(@mont_desc AS DECIMAL(10, 2)))
  set @mont_aport= ( select dato from #conceptos_dato where concepto = 76 )
 set @aportes = (SELECT CAST(@mont_aport AS DECIMAL(10, 2)))



set @ingresos_totales = @ingresos_totales + @ingresos ;
set @descuentos_totales = @descuentos_totales + @descuentos ;
set @aportes_totales = @aportes_totales + @aportes ;
/************  FIN  insercion del detalle ejecuccion    ************ */
  drop table #tmpo  -- eliminando las temporales
  drop table #conceptos_dato
  --drop table #TABLA_DATOSCOLABORADOR_DOC
  drop table #tmp


    FETCH NEXT FROM emp_cursor     
INTO @codrda,@nTipCola  


END     
CLOSE emp_cursor;    
DEALLOCATE emp_cursor;
/* devolviendo totales */
select CAST(@ingresos_totales AS DECIMAL(10, 2)) as ingresos , CAST(@descuentos_totales
AS DECIMAL(10, 2))  as descuentos ,CAST(@aportes_totales  AS DECIMAL(10, 2)) as aportes
/*
prueba 
	 select * from Det_Persona_Planilla  where cCodRDA = 3   
 exec [[SPS_SES_PLN_EjecutarCalculoPlanilla]] '012019','<Tabla><Datos CodRDA="1" nTipCola="0" /><Datos CodRDA="3" nTipCola="0" /><Datos CodRDA=  "4  " nTipCola=  "0  " /><Datos CodRDA=  "5  " nTipCola=  "0  " /></Tabla>' ;
 -- select * from Det_Ejecucion_Planilla 
 */

	END

	  
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_INS_ConfigMacro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPS_SES_PLN_INS_ConfigMacro](
	@nAccion	INT,
	@nIdEmp		INT,
	@nIdMac		INT,
	@nCodTCta	INT,
	@nCodBco	INT,
	@cDesMac	VARCHAR(100),
	@cAbrMac	VARCHAR(30),
	@proceso	NVARCHAR(MAX),
	@cNomProc	VARCHAR(100),
	@nUsuIVig	INT,
	@nUsuFVig	INT,
	@nUsuAct	INT,
	@cFlgAct	CHAR(1),
	@xmlCadenaDetalle		XML,
	@xmlCadenaTipo		XML,
	@xmlCadenaValor		XML
)

AS

DECLARE @hDoc INT = 0, @hDoc2 INT = 0,@hDoc3 INT = 0, @SQL NVARCHAR(MAX)
BEGIN
	EXEC sp_xml_PrepareDocument @hDoc OUT, @xmlCadenaDetalle
	EXEC sp_xml_PrepareDocument @hDoc2 OUT, @xmlCadenaTipo
	EXEC sp_xml_PrepareDocument @hDoc3 OUT, @xmlCadenaValor
	DECLARE @ObtengoMacroId INT, @variables VARCHAR(600)  , @concepto_variable  varchar(max), @TipoEjecucion VARCHAR(25)
	-- INICIAMOS LA TRANSACCION
	Begin Tran Tadd
	-- Primer try 
	Begin Try 
	IF(@nAccion = 1)
	BEGIN
		INSERT INTO Cab_Macro(nIdEmp,nCodTCta,nCodBco, cDesMac,cAbrMac, dtFecMod,nUsuIVig,
					dtIniVig,nUsuFVig,dtFinVig,nUsuIns,dtFecIns,nUsuMod,cFlgAct)
		VALUES(@nIdEmp,@nCodTCta,@nCodBco,@cDesMac,@cAbrMac,'',@nUsuIVig,GETDATE(),
					@nUsuFVig,'',@nUsuAct,GETDATE(),'',@cFlgAct)
		SET @ObtengoMacroId = @@IDENTITY
		SET @TipoEjecucion = 'CREATE PROC '
	END
	IF(@nAccion = 2)
	BEGIN
		UPDATE Cab_Macro 
			SET nCodTCta = @nCodTCta,
				nCodBco = @nCodBco,
				cDesMac = @cDesMac,
				cAbrMac = @cAbrMac,
				dtFecMod = GETDATE(),
				nUsuMod = @nUsuAct,
				nUsuIVig = @nUsuIVig,
				nUsuFVig = @nUsuFVig,
				cFlgAct = @cFlgAct
			WHERE nIdMac = @nIdMac
		SET @ObtengoMacroId = @nIdMac
		DELETE FROM Det_Macro WHERE nIdMac = @ObtengoMacroId
		SET @TipoEjecucion = 'ALTER PROC '
	END
	SELECT ROW_NUMBER() 
			OVER(ORDER BY nIdDMac,nConId,cNomCam,cTipDat,nOrdPre,cNomCab) AS ROW,
		nIdDMac,nConId,cNomCam, cTipDat, nOrdPre,cNomCab
		INTO #TABLA_MACROS_DOC
		FROM OpenXml(@hDoc, 'Tabla/campos') 
		WITH	
		(	
		nIdDMac	INT,
		nConId	INT,
		cNomCam VARCHAR(50),
		cTipDat VARCHAR(20),
		nOrdPre INT,
		cNomCab	VARCHAR(30)
		)
		SELECT ROW_NUMBER() 
			OVER(ORDER BY cVarNom, cVarTipDat ) AS ROW,
		cVarNom, cVarTipDat 
		INTO #TABLA_VARIABLES_DOC
		FROM OpenXml(@hDoc2, 'Tabla2/Variables') 
		WITH	
		(	
		cVarNom VARCHAR(25),
		cVarTipDat VARCHAR(25)
		)
		SELECT 
		nConId, cConTip, cVarNom 
		INTO #TABLA_CONCEPTOS_DOC
		FROM OpenXml(@hDoc3, 'Tabla3/Conceptos') 
		WITH	
		(
		nConId INT,
		cConTip CHAR(1),
		cVarNom  VARCHAR(max)  

		)
		INSERT INTO Det_Macro
				(nIdEmp,nIdMac,nCodTCta,nIdDMac,cNomCam,cTipDat,nOrdPre,cNomCab,nUsuIns,dtFecIns,nUsuMod,dtFecMod,cFlgAct, nConId, cMacDes)
		SELECT @nIdEmp,@ObtengoMacroId,@nCodTCta,nIdDMac,cNomCam,cTipDat,nOrdPre,cNomCab,@nUsuAct, GETDATE(), 0, '', @cFlgAct, TM.nConId, cVarNom
		FROM #TABLA_MACROS_DOC TM INNER JOIN #TABLA_CONCEPTOS_DOC TC ON TM.nConId = TC.nConId
		DROP TABLE #TABLA_MACROS_DOC
		SET @variables = (SELECT DISTINCT cVarNom = STUFF(( SELECT ', ' + CONCAT(CONVERT(VARCHAR,cVarNom),' ' + cVarTipDat) AS [text()] FROM #TABLA_VARIABLES_DOC 
		FOR XML PATH('')),1,1,'') FROM #TABLA_VARIABLES_DOC )
		SET @concepto_variable =  (SELECT DISTINCT cVarNom =  
			STUFF(( SELECT ' +'  + CHAR(39) + ' | ' + CHAR(39) + '+ ' + CONCAT(char(39) +  CONVERT(VARCHAR,nConId)+ CHAR(39), '+'+CHAR(39)+'*'+CHAR(39)+'+' +  'CONVERT(VARCHAR,' +
			(SELECT SUBSTRING(	  cVarNom,
			CHARINDEX('SET',cVarNom)+3,
			CHARINDEX('=',cVarNom)-4) )+ ')' ) AS [text()] FROM #TABLA_CONCEPTOS_DOC FOR XML PATH('')),1,1,'') FROM #TABLA_CONCEPTOS_DOC )

		SET @concepto_variable = 'SELECT ' + STUFF(@concepto_variable,1,7,'') + ' AS DFAL' ;
		SET @variables = 'DECLARE '+ @variables ;
		SET @SQL = @TipoEjecucion +  @cNomProc + CHAR(13) + CHAR(10) +
		+ '( '+ '@nCodRda int  =0,'+ CHAR(13) + CHAR(10) +
		' @cPerCal varchar(6)'+ CHAR(13) + CHAR(10) +
		' ) '+
		' AS ' + CHAR(13) + CHAR(10) +
		 @variables + CHAR(13) + CHAR(10) +
		 ' BEGIN ' + CHAR(13) + CHAR(10) +	
				@proceso + CHAR(13) + CHAR(10)+
			 @concepto_variable + CHAR(13) + CHAR(10) + 
			' END' 
		SELECT @SQL
		EXEC sp_executesql @SQL 
		DROP TABLE #TABLA_VARIABLES_DOC  
		DROP TABLE #TABLA_CONCEPTOS_DOC 
		COMMIT TRAN Tadd 
		End try
		Begin Catch
			return 'el error es '+ERROR_MESSAGE();
			-- capturando el error  ; 
        Rollback TRAN Tadd
		End Catch 
END		



GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_INS_ConfigProcesos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 

exec [SPS_SES_PLN_INS_ConfigProcesos] 2 , 1 , 8758 , '1' , 'SPS_SES_PLN_CalculodePlanilla ', 'select  1 as dfal' ,
	'<Tabla><Variables cVarNom="@DFALTADOS" cVarTipDat="int " />
<Variables cVarNom=" @PENFALTAS" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @FONPEN" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @DESFAL" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @ASIGFAM" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @REMBASIC" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @ESSALUD" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @REFRIGER" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @INGRESO" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @DESCUENTO" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @APORTE" cVarTipDat="decimal(10,2) " />
</Tabla>' ,

	'<Tabla2>
	<Conceptos nConId="7 " cConTip=" P " cVarNom="   &#xA;SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = @NCODRDA) &#xA; " />
	<Conceptos nConId=" 12 " cConTip=" D " cVarNom="  &#xA;SET @FONPEN = (0.15)*( SELECT NSUENETO  FROM det_persona_planilla WHERE cCodRda =@ncodrda)&#xA; " />
	<Conceptos nConId=" 77 " cConTip=" D " cVarNom="  &#xA;SET @PENFALTAS  = (50.00) &#xA; " />
	<Conceptos nConId=" 16 " cConTip=" D " cVarNom="  &#xA;SET  @DESFAL = ( @DFALTADOS *@PENFALTAS )&#xA;&#xA;  " />
	<Conceptos nConId=" 8 " cConTip=" I " cVarNom="   &#xA;SET @ASIGFAM = 85.00 &#xA;  " />
	<Conceptos nConId=" 19 " cConTip=" I " cVarNom="  &#xA;SET @REMBASIC = ( SELECT NSUENETO  FROM det_persona_planilla WHERE cCodRda =@nCodRda) &#xA; " />
	<Conceptos nConId=" 18 " cConTip=" A " cVarNom="  &#xA;SET @ESSALUD = (SELECT CASE                                        WHEN nTipSalud = 1 THEN 0.09&#xA;WHEN nTipSalud = 2 THEN 0.07&#xA;ELSE 0&#xA; END AS MontoSalud &#xA; FROM det_persona_planilla WHERE cCodRda = @nCodRda ) * @REMBASIC ; &#xA;&#xA;  \" />
	<Conceptos nConId=" 21 " cConTip=" I " cVarNom="  &#xA;SET @REFRIGER= 250.00 &#xA;&#xA; " />
	<Conceptos nConId=" 74 " cConTip=" T " cVarNom="  &#xA;SET @INGRESO = @ASIGFAM +@REFRIGER +@REMBASIC&#xA; " />
	<Conceptos nConId=" 75 " cConTip=" T " cVarNom="  &#xA;SET @DESCUENTO =  @DESFAL &#xA; " />
	<Conceptos nConId=" 76 " cConTip=" T " cVarNom="  &#xA;SET @APORTE =@ESSALUD" />
	</Tabla2>'


	*/
CREATE PROC [dbo].[SPS_SES_PLN_INS_ConfigProcesos](
	@nIdEmp		INT = 0,
	@nProId		INT = 0,
	@nUsuAct	INT = 0,
	@cFlgAct	CHAR(1) = '',
	@cNomProc	VARCHAR(100) = '',
	@proceso	VARCHAR(max),
	--@nConCod	INT = 0,
	@cadena		XML,
	@cadena_detalle	XML
)
AS
DECLARE @hDoc INT = 0, @hDoc2 INT = 0   , @SQL NVARCHAR(MAX) 
	BEGIN
	EXEC sp_xml_PrepareDocument @hDoc OUT, @cadena ;
	EXEC sp_xml_PrepareDocument @hDoc2 OUT, @cadena_detalle ;
	DECLARE @ObtengoCodConfig INT,@ObtengoCodConfigDet INT , @nombreProcedure VARCHAR(100), @variables VARCHAR(600)  , @concepto_variable  varchar(max)

	-- INICIAMOS LA TRANSACCION
		 Begin Tran Tadd

	-- Primer try 
		 Begin Try 

		INSERT INTO Configuracion (nIdEmp, nProId, nUsuIns, dtFecIns, nUsuMod, dtFecMod, cFlgAct)
		VALUES (@nIdEmp, @nProId, @nUsuAct, GETDATE(), 0, '', @cFlgAct)

		

		SET @ObtengoCodConfig = (select ISNULL(MAX(nConfId),1) from Configuracion) 
	 	--SET @ObtengoCodConfigDet = ((select ISNULL(MAX(nCoDId),0) from det_configuracion) +1) 
		--SET @nombre_proc = @cNomProc + (SELECT ( SELECT REPLACE(CONVERT(CHAR(10), GetDate(), 103), '/', '') + ( select 
  --replace(CONVERT (varchar(8),GetDate(), 108),':','') )))  

	

		SELECT ROW_NUMBER() 
			OVER(ORDER BY cVarNom, cVarTipDat ) AS ROW,
		cVarNom, cVarTipDat 
		INTO #TABLA_VARIABLES_DOC
		FROM OpenXml(@hDoc, 'Tabla/Variables') 
		WITH	
		(	
		cVarNom VARCHAR(25),
		cVarTipDat VARCHAR(25)
		)


		SELECT 
		IDENTITY (INT,1, 1) AS nCoDId,nConId, cConTip, cVarNom 
		INTO #TABLA_CONCEPTOS_DOC
		FROM OpenXml(@hDoc2, 'Tabla2/Conceptos') 
		WITH	
		(
			
		nConId INT,
		cConTip CHAR(1),
		cVarNom  VARCHAR(max)  

		)
		select * from  #TABLA_CONCEPTOS_DOC 
		

		INSERT INTO Det_Configuracion
		(nIdEmp, nConfId,cNomProc, nProId,nUsuIns ,dtFecIns,nUsuMod, dtFecMod,cFlgAct , nCoDId ,cContip, nConCod, cConfDes) 
		SELECT  
		@nIdEmp,@ObtengoCodConfig,@cNomProc,@nProId,@nUsuAct,GETDATE() , 0 ,'',@cFlgAct,nCoDId,cConTip,nConId,cVarNom  FROM  #TABLA_CONCEPTOS_DOC
		

		

		SET @variables = (SELECT DISTINCT cVarNom = STUFF(( SELECT ', ' + CONCAT(CONVERT(VARCHAR,cVarNom),' ' + cVarTipDat) AS [text()] FROM #TABLA_VARIABLES_DOC 
		FOR XML PATH('')),1,1,'') FROM #TABLA_VARIABLES_DOC )

		SET @concepto_variable =  (SELECT DISTINCT cVarNom =  
			STUFF(( SELECT ' +'  + CHAR(39) + ' | ' + CHAR(39) + '+ ' + CONCAT(char(39) +  CONVERT(VARCHAR,nConId)+ CHAR(39), '+'+CHAR(39)+'*'+CHAR(39)+'+' +  'CONVERT(VARCHAR,' +
			(SELECT SUBSTRING(	  cVarNom,
			CHARINDEX('SET',cVarNom)+3,
			CHARINDEX('=',cVarNom)-4) )+ ')' ) AS [text()] FROM #TABLA_CONCEPTOS_DOC FOR XML PATH('')),1,1,'') FROM #TABLA_CONCEPTOS_DOC )
	--print @concepto_variable ;



		set @concepto_variable = 'SELECT ' + STUFF(@concepto_variable,1,7,'') + ' AS DFAL' ;
		--print @concepto_variable ;
		SET @variables = 'DECLARE '+ @variables ;

		SET @SQL = 'CREATE PROC ' +  @cNomProc + CHAR(13) + CHAR(10) +
		+ '( '+ '@nCodRda int  =0,'+ CHAR(13) + CHAR(10) +
		' @cPerCal varchar(6)'+ CHAR(13) + CHAR(10) +
		--' @idEjecucion int ' +char(13) + char(10) + 
		' ) '+
		' AS ' + CHAR(13) + CHAR(10) +
		 @variables + CHAR(13) + CHAR(10) +
		 ' BEGIN ' + CHAR(13) + CHAR(10) +	
				@proceso + CHAR(13) + CHAR(10) + 
			 @concepto_variable + CHAR(13) + CHAR(10) + 
			' END' 
		EXEC sp_executesql @SQL 
		DROP TABLE #TABLA_VARIABLES_DOC  
		DROP TABLE #TABLA_CONCEPTOS_DOC 
		COMMIT TRAN Tadd 
		
		 End try
		  Begin Catch

      return 'el error es '+ERROR_MESSAGE();
	  -- capturando el error  ; 
        Rollback TRAN Tadd

    End Catch 

	END
	 /*
	  
	 SELECT * FROM CONCEPTO 
 
DECLARE @PALABRA  VARCHAR(MAX)   
SET @PALABRA = CHARINDEX('= ','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)') 


--SELECT @PALABRA 

SELECT 
SUBSTRING(	  'SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)',
CHARINDEX('SET','SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')+3,
CHARINDEX('=','SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')-4)

SELECT  CHARINDEX('SET','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')+4
SELECT CHARINDEX('=','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')-4
go





SELECT cContip , nConCod ,cConfDes    
into #T 
from Det_Configuracion ;


DECLARE @concepto_variable VARCHAR(MAX)  
 
SET @concepto_variable = (SELECT DISTINCT cVarNom =  
	STUFF(( SELECT ', ' + CONCAT(CONVERT(VARCHAR,nConCod),' ' +  
	(SELECT 
SUBSTRING(	  cConfDes,
CHARINDEX('SET',cConfDes)+3,
CHARINDEX('=',cConfDes)-4) )) AS [text()] FROM #T FOR XML PATH('')),1,1,'') FROM #T )
SELECT  'SELECT ' + @concepto_variable 
-- select * from det_configuracion 
 DROP TABLE #T 
	

	truncate table configuracion ;
	truncate table det_configuracion  ;
	 drop proc SPS_SES_PLN_CalculodePlanilla ;
	  
	*/ 


	
	



GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_INS_EjecMacro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [dbo].[SPS_SES_PLN_INS_EjecMacro] 1,0,1,26,2,1,8722,'1',3540,'<Tabla><Datos CodRDA="1" /><Datos CodRDA="2" /><Datos CodRDA="3" /></Tabla>'
CREATE PROC [dbo].[SPS_SES_PLN_INS_EjecMacro](
	@Accion		INT,
	@nIdEjec	INT,
	@nIdEmp		INT,  
	@nMacId		INT,
	@nTplId		INT,
	@nCodTCta	INT, 
	@nUsuAct	INT,
	@cFlgAct	INT,
	@nTotal		VARCHAR(20),
	@nDatXML	xml
)
AS
DECLARE @hDoc INT = 0, @cPerCal VARCHAR(6), @NombreProc VARCHAR(70), @nCodDMac	INT
	BEGIN
		EXEC sp_xml_PrepareDocument @hDoc OUT, @nDatXML
		DECLARE @ObtengoCodEjec INT,@ObtengoCodEjecDet INT 
		SET @ObtengoCodEjec = (select ISNULL(MAX(nIdEje),0) from Ejecucion_Macro) + 1  
		SET @cPerCal = CONCAT(YEAR(GETDATE()),MONTH(GETDATE()))

		SELECT 
		IDENTITY (INT,1, 1) AS nCodDEjec,CodRDA
		INTO #TABLA_DATOSCOLABORADOR_DOC
		FROM OpenXml(@hDoc, 'Tabla/Datos') 
		WITH	
		(
		CodRDA INT
		)

		IF(@Accion = 1)
		BEGIN
			INSERT INTO Ejecucion_Macro (nIdEmp, nIdEje, nIdMac, nCodTCta, cPerCal, cFlgCie, nUsuCie, 
					dtFecCie, nUsuIns, dtFecIns, nUsuMod, dtFecMod, cFlgAct,nTotal,NroEjecuciones)
			VALUES (@nIdEmp, @ObtengoCodEjec, @nMacId, @nCodTCta, @cPerCal, '1',0, '' , @nUsuAct,GETDATE(),0,'',@cFlgAct,CAST(@nTotal AS DECIMAL(10,2)),1)



			--INSERT INTO Det_Ejecucion_Macro (nIdEmp, nIdEje, nIdMac, nIdDMac, nIdDEje,nCodRda, cDatImp)
			--SELECT @nIdEmp, @ObtengoCodEjec, @nMacId, nIdDMac, nCodDEjec, CodRDA, cDatMac FROM #TABLA_DATOSCOLABORADOR_DOC
		END
		IF(@Accion = 2)
		BEGIN
			UPDATE Ejecucion_Macro SET nIdMac = @nMacId,
									   cFlgCie = '1',
									   nUsuCie = 0,
									   nUsuMod = @nUsuAct,
									   dtFecMod = GETDATE(),
									   nTotal = CAST(@nTotal AS DECIMAL(10,2)),
									   NroEjecuciones = NroEjecuciones + 1
			 WHERE nIdEmp = @nIdEmp AND nIdEje = @nIdEjec
			 IF(@nMacId != (SELECT nIdMac FROM EJECUCION_MACRO WHERE nIdEje = @nIdEjec))
			 BEGIN
				DELETE FROM DET_EJECUCION_MACRO WHERE nIdEje = @nIdEjec
			 END
			-- INSERT INTO Det_Ejecucion_Macro (nIdEmp, nIdEje, nIdMac, nIdDMac, nIdDEje,nCodRda, cDatImp)
			--SELECT @nIdEmp, @ObtengoCodEjec, @nMacId, nIdDMac, nCodDEjec, CodRDA, cDatMac FROM #TABLA_DATOSCOLABORADOR_DOC
		END

		SET @NombreProc = 'SPS_SES_PLN_' + (SELECT LTRIM(RTRIM(REPLACE(cDesMac,' ',''))) FROM CAB_MACRO WHERE nIdMac = @nMacId)


		 DECLARE emp_cursor CURSOR FOR     
		 select CodRDA, nCodDEjec from #TABLA_DATOSCOLABORADOR_DOC  
		order by CodRDA;    
		  
		OPEN emp_cursor    
		  
		  declare @codrda int  , @nCodDEjec int 
			FETCH NEXT FROM emp_cursor     
			INTO @codrda,@nCodDEjec    
		     
		  
		WHILE @@FETCH_STATUS = 0  
		  
		BEGIN    
		create table #tmp ( concepto  varchar(max));
		insert #tmp
		exec @NombreProc @codrda,@cPerCal ;
		
		declare @var varchar(max)= (select concepto from  #tmp );
		/* seugndo paso */ 
		create table #tmpo (concepto  varchar(max)) ;
		insert #tmpo SELECT * FROM STRING_SPLIT(@var, '|') ;
				SELECT
				concepto = SUBSTRING(concepto, 0, CHARINDEX('*', concepto)),
				dato = SUBSTRING(concepto, CHARINDEX('*', concepto) + 1, LEN(concepto)),
				codigoDetalle = (SELECT nIdDMac FROM DET_MACRO WHERE nIdMac = @nMacId AND nConId = SUBSTRING(concepto, 0, CHARINDEX('*', concepto))) into #conceptos_dato FROM #tmpo
		
		alter table  #conceptos_dato  add id int NOT NULL IDENTITY(1, 1);
		
		/************  INICIO insercion del detalle ejecuccion    ************ */

		 INSERT INTO Det_Ejecucion_Macro (nIdEmp, nIdEje, nIdMac, nIdDMac, nIdDEje,nCodRda, cDatImp)
			SELECT @nIdEmp, @ObtengoCodEjec, @nMacId, codigoDetalle, @nCodDEjec, @codrda, dato FROM #conceptos_dato
		
		/************  FIN  insercion del detalle ejecuccion    ************ */
		  drop table #tmpo  -- eliminando las temporales
		  drop table #conceptos_dato
		  drop table #tmp
		
		
		    FETCH NEXT FROM emp_cursor     
		INTO @codrda,@nCodDEjec  
		
		
		END     
		CLOSE emp_cursor;    
		DEALLOCATE emp_cursor;

		DROP TABLE #TABLA_DATOSCOLABORADOR_DOC

END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_INS_EjecucionPlanilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPS_SES_PLN_INS_EjecucionPlanilla](
	@nIdEmp int ,
	@nTplId int ,
	@periodo char(6) ,
	@colaboradores	XML ,
	@nProId int ,
	@nUsuAct int , 
	@cFlgAct char(1) 

)AS
DECLARE  @sueneto decimal (10,2) ,@ObtengoCodConfig INT, @hDoc INT = 0  ,
@ingresos decimal(10,2) =0.00 ,@ingresos_totales decimal(10,2) =0.00 ,
@descuentos decimal(10,2) =0.00 ,@descuentos_totales decimal(10,2) =0.00 ,
@aportes decimal(10,2) =0.00 ,@aportes_totales decimal(10,2) =0.00 ,
 @mont_ing varchar(max) ,@mont_desc varchar(max) ,@mont_aport varchar(max) ,
  @NombreProc varchar(max) 
 
 
	BEGIN


	/*insertar cabecera */


	
	
	INSERT INTO [dbo].[Ejecucion_Planilla]
           ([nIdEmp]
           ,[nIdPla]
           ,[nTplId]
           ,[cPerCal]
           ,[cFlgCie]
           ,[dtFecCie]
           ,[nUsuCie]
           ,[nUsuIns]
           ,[dtFecIns]
           ,[nUsuMod]
           ,[dtFecMod]
           ,[cFlgAct]
           ,[nProid])
     VALUES
           (@nIdEmp
           ,1
           ,@nTplId
           ,@periodo
           ,'1' -- observado
           ,GETDATE() --observado
           ,1111 --observado
           ,@nUsuAct
           ,GETDATE()
           ,0
           ,''
           ,@cFlgAct
           ,@nProId)
	/* INICIO extrael xml */

	
	SET @ObtengoCodConfig = (select ISNULL(MAX(nIdEje),1) from ejecucion_planilla) ;
	

	EXEC sp_xml_PrepareDocument @hDoc OUT, @colaboradores

                               SELECT ROW_NUMBER() 
                                               OVER(ORDER BY CodRDA, nTipCola ) AS ROW,
                               CodRDA, nTipCola
                               INTO #TABLA_DATOSCOLABORADOR_DOC
                               FROM OpenXml(@hDoc, 'Tabla/Datos') 
                               WITH     
                               (
                               CodRDA INT,
                               nTipCola INT
                               )



	/* FIN extraer xml */

	set @NombreProc = ( SELECT top 1  b.cNomProc FROM CONFIGURACioN A INNER JOIN DET_CONFIGURACION B ON A.nconfid= B.nconfId  where a.cflgAct = '1') ;
 DECLARE emp_cursor CURSOR FOR     
 select CodRDA, nTipCola from #TABLA_DATOSCOLABORADOR_DOC  
order by CodRDA;    
  
OPEN emp_cursor    
  
  declare @codrda int  , @nTipCola int 
	FETCH NEXT FROM emp_cursor     
	INTO @codrda,@nTipCola     
     
  
WHILE @@FETCH_STATUS = 0  
  
BEGIN    
create table #tmp ( concepto  varchar(max));
insert #tmp
exec @NombreProc @codrda,@periodo ;

declare @var varchar(max)= (select concepto from  #tmp );
/* seugndo paso */ 
create table #tmpo (concepto  varchar(max)) ;
insert #tmpo SELECT * FROM STRING_SPLIT(@var, '|') ;
		SELECT
		concepto = SUBSTRING(concepto, 0, CHARINDEX('*', concepto)),
		dato = SUBSTRING(concepto, CHARINDEX('*', concepto) + 1, LEN(concepto))  into #conceptos_dato FROM #tmpo

alter table  #conceptos_dato  add id int NOT NULL IDENTITY(1, 1);

/************  INICIO insercion del detalle ejecuccion    ************ */

 set @mont_ing = ( select dato from #conceptos_dato where concepto = 74 )
 set @ingresos = (SELECT CAST(@mont_ing AS DECIMAL(18, 2)))
  set @mont_desc = (select dato from #conceptos_dato where concepto = 75 )
 set @descuentos = (SELECT CAST(@mont_desc AS DECIMAL(18, 2)))
  set @mont_aport= ( select dato from #conceptos_dato where concepto = 76 )
 set @aportes = (SELECT CAST(@mont_aport AS DECIMAL(18, 2)))

INSERT INTO [dbo].[Det_Ejecucion_Planilla]
           ([nIdEje]
           ,[nIdEmp]
           ,[nIdPla]
           ,[nTplId]
           ,[nCodRda]
           ,[nUsuIns]
           ,[dtFecIns]
           ,[nUsuMod]
           ,[dtFecMod]
           ,[cFlgAct]
		   ,[IdDEje]
		   ,[nConId]
           ,[cDatImp] )
     SELECT 
			@ObtengoCodConfig
           ,1
           ,1
           ,@nTplId
           ,@codrda
           ,1111
           ,GETDATE()
           ,1111
           ,GETDATE()
           ,1
		   ,id
		   ,concepto
		   ,dato from #conceptos_dato ;

set @ingresos_totales = @ingresos_totales + @ingresos ;
set @descuentos_totales = @descuentos_totales + @descuentos ;
set @aportes_totales = @aportes_totales + @aportes ;
/************  FIN  insercion del detalle ejecuccion    ************ */
  drop table #tmpo  -- eliminando las temporales
  drop table #conceptos_dato
  drop table #tmp


    FETCH NEXT FROM emp_cursor     
INTO @codrda,@nTipCola  


END     
CLOSE emp_cursor;    
DEALLOCATE emp_cursor;
/* devolviendo totales */
select @ingresos_totales as ingresos , @descuentos_totales as descuentos ,@aportes_totales as aportes
/*
prueba 
	 select * from Det_Persona_Planilla  where cCodRDA = 3   
 exec [SPS_SES_PLN_INS_EjecucionPlanilla] '012019','<Tabla><Datos CodRDA="1" nTipCola="0" /><Datos CodRDA="3" nTipCola="0" /><Datos CodRDA=  "4  " nTipCola=  "0  " /><Datos CodRDA=  "5  " nTipCola=  "0  " /></Tabla>' ;
 -- select * from Det_Ejecucion_Planilla 
 */

	END/*
IF @nAccion = 2	-- Cerrar Planilla :v 
		BEGIN 
		update Ejecucion_Planilla set cFlgCie = 0 where  cPercal  =  @periodo 

		/* select * from Det_Ejecucion_Planilla 
		select * from Ejecucion_Planilla */
		END 

	END  */
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_LisEjecutarCalculoPlanilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_LisEjecutarCalculoPlanilla]
(
	@Accion INT,
	@AÑO CHAR(4) = '', 
	@MES CHAR(2) = '',
	
	@NtpoColab	INT = 0 
	
)
AS
	BEGIN
	
	
		
	IF(@Accion = 1)
		BEGIN
			
			SELECT vCodPrs AS CodRDA, CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno) AS cNombreCompleto,
			vDocNro AS DNI,nTpoColab as ntpoColab, PL.cNroCta as cNroCta, PL.cNroCtaInter, PL.nCodTCta, cDesTCta,
			 PL.nCodHabBco as nCodBco,cDesBco, PL.nCodCtsBco ,nSueNeto
			FROM RDA2Desarrollo..Persona P JOIN Det_Persona_Planilla PL 
			ON P.vCodPrs = PL.cCodRDA JOIN Tipo_Cuenta TC ON PL.nCodTCta = TC.nCodTCta 
			JOIN Bancos B ON PL.nCodHabBco = B.nCodBco  
			 where      vCodPrs 
			 NOT IN (
			 select DISTINCT  a.ncodrda from det_ejecucion_planilla  a  
		inner join ejecucion_planilla b on a.nIdEje=b.nIdEje 
		inner join RDA2Desarrollo..Persona P ON P.vCodPrs = a.nCodRDA 
		where  b.cpercal =@MES+@AÑO  
			 
			 )  and  ( @NtpoColab = 0 OR P.nTpoColab = @NtpoColab)
						
		END 
	IF(@Accion = 2)
		BEGIN
			SELECT a.nIdEmp ,a.nIdEje ,a.nIdPla ,a.nTplId ,b.cTplDes ,a.cPerCal ,a.cFlgCie ,  FORMAT(a.dtFecCie ,'dd/MM/yyyy') as dtFecCie
			 ,a.nUsuCie ,a.nUsuIns , FORMAT(a.dtFecIns ,'dd/MM/yyyy') as dtFecIns ,a.nUsuMod ,a.dtFecMod ,a.cFlgAct ,a.nProid ,c.cProNom
			    from Ejecucion_Planilla a  inner join tipo_planilla b on a.nTplId = b.nTplId  
				inner join  Proceso c  on  a.nProid = c.nProId where a.nProId = 2 ;
				 -- select * from proceso  
				 /*
				  update Ejecucion_Planilla  set nProId = 2 
				 */
		END
	IF(@Accion = 3) -- FORMAT(x ,'dd/MM/yyyy')
		BEGIN
			SELECT nTplId, cTplDes FROM Tipo_Planilla ; 
		END
	IF (@Accion = 4)
	BEGIN
		SELECT nTplId,cTplDes FROM Tipo_Planilla

	END
	IF(@Accion = 5)
	BEGIN
		SELECT cPerCal, EP.nTplId, TP.cTplDes, EP.nProId, P.cProNom, FORMAT(EP.dtFecIns,'dd/MM/yyyy') AS dtFecIns,cFlgCie, FORMAT(dtFecCie,'dd/MM/yyyy') AS dtFecCie FROM Ejecucion_Planilla EP
		INNER JOIN Proceso P ON EP.nProid = P.nProId
		INNER JOIN Tipo_Planilla TP ON EP.nTplId = TP.nTplId 
		WHERE EP.cFlgAct = 1
	END

	IF(@Accion = 6) -- lista de detalle de personas ejecutadas 
	BEGIN
		select DISTINCT  a.ncodrda as CodRDA , CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno) as cNombreCompleto from det_ejecucion_planilla  a  
		inner join ejecucion_planilla b on a.nIdEje=b.nIdEje 
		inner join RDA2Desarrollo..Persona P ON P.vCodPrs = a.nCodRDA 
		where  b.cpercal = @MES +@año   and    b.cPerCal = @MES+@AÑO AND a.nTplId= @NtpoColab
		                                                         
		--exec [SPS_SES_PLN_LisEjecutarCalculoPlanilla]  7,2019,11,02
		-- SELECT * FROM  	 ejecucion_planilla
		-- 
		
	END

	IF(@Accion = 7) -- Ver estado del periodo 
	BEGIN
		select DISTINCT cFlgCie from Ejecucion_Planilla where cpercal =@MES+@AÑO 
		--	select  * from Ejecucion_Planilla where cpercal ='112019' 
		-- update ejecucion_planilla set cFlgCie = 1 

	END
END


GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_LisEjecutarMacro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [dbo].[SPS_SES_PLN_LisEjecutarMacro] 1,'2019','10',0,0
CREATE PROC [dbo].[SPS_SES_PLN_LisEjecutarMacro]
(
	@Accion		INT,
	@AÑO		CHAR(4) = '', 
	@MES		VARCHAR(20) = '',
	@nIdMac		INT = 0,
	@nIdTpl		INT = 0
)
AS
	BEGIN
	IF(@Accion = 1)
		BEGIN
			SELECT nIdEje,C.nIdMac as nIdMac,NroEjecuciones,C.cDesMac as cDesMac,B.nCodBco as nCodBco,
			B.cDesBco as cDesBco,T.nCodTCta as nCodTCta,T.cDesTCta as cDesTCta, FORMAT(E.dtFecIns,'dd/MM/yyyy') AS dtFecCie, E.cFlgAct, CAST(nTotal AS VARCHAR(20)) AS nTotal
			FROM Ejecucion_Macro E
			INNER JOIN Cab_Macro C ON E.nIdMac = C.nIdMac 
			INNER JOIN Tipo_Cuenta T on C.nCodTCta = T.nCodTCta
			INNER JOIN Bancos B on C.nCodBco = B.nCodBco 
			WHERE (@AÑO = '' OR YEAR(E.dtFecIns) = @AÑO) AND (@MES = '' OR MONTH(E.dtFecIns) = @MES)
		END
	IF(@Accion = 2)
		BEGIN
			SELECT nIdMac, cDesMac FROM Cab_Macro
		END
	IF(@Accion = 4)
		BEGIN
			SELECT cNomCam, nIdDMac FROM Det_Macro WHERE nIdMac =  @nIdMac
		END
	IF(@Accion = 6)
		BEGIN
			SELECT DISTINCT nCodRda FROM Det_Ejecucion_Macro WHERE nIdMac = @nIdMac
		END
END




GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListaGenerales]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SPS_SES_PLN_ListaGenerales] 10 ,0,0,0
CREATE PROC [dbo].[SPS_SES_PLN_ListaGenerales](

@Accion INT = 0,
@nIdTpl	INT =0,
@nIdMac	INT  =0,
@nConfId INT = 0
)
AS
BEGIN
	

	IF @Accion = 1 --LISTA DE VARIABLES
	BEGIN
		SELECT	nVarId,cVarNom,cVarDes,cVarTipDat ,cVarFor
		 FROM	[dbo].[Variable] WHERE cFlgAct = '1' 
	END
		
	IF @Accion = 2 --LISTA DE CONCEPTOS
	BEGIN
		SELECT nConId, cConDes ,cConTip,cConCod 
		FROM [dbo].Concepto WHERE cFlgAct = '1' AND cConEst = 'N'

	END


	IF @Accion = 3 --LISTA DE FORMULAS
	BEGIN
		SELECT nForId, cForDes, cConDes ,cForFor
		FROM Formula F INNER JOIN Concepto C
		ON F.nConId = C.nConId
		WHERE F.cFlgAct = '1' ORDER BY F.dtFecIns
	END
		
	IF @Accion = 4 -- LISTA DE Configuraciones
	BEGIN
		
		SELECT DISTINCT conf.nConfId  as 'nConfId',cProNom as  'cProNom', conf.cFlgAct ,conf.nProId, cNomProc 
		from [dbo].Configuracion conf 
		inner join [dbo].proceso pro  
		 on  pro.nProId = conf.nProId 
		 INNER JOIN Det_Configuracion DC
		 ON conf.nConfId = DC.nConfId


	/*SELECT nConfId, ('/* '+cConDes+ ' */ '+cConfDes) AS Cuerpo  FROM Det_Configuracion DC 
	INNER JOIN Concepto C ON DC.nConCod = C.nConId WHERE nConfId = 12*/



	END
	IF @Accion = 5 -- LISTA DE Procesos
	BEGIN
		SELECT  nProId ,cProNom ,cProAbr
		from [dbo].Proceso WHERE cFlgAct = '1' 
	END
	IF @Accion = 6 --LISTA DE COLABORADORES SIN PROCESAR
	BEGIN
		SELECT vCodPrs as nCodRda, CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno) AS cNombreCompleto,
			vDocNro, PL.cNroCta as cNroCta, PL.cNroCtaInter, PL.nCodTCta, cDesTCta,
			PL.nCodHabBco as nCodBco,cDesBco, PL.nCodCtsBco, nSueNeto, nSueNeto AS sueldo
			FROM RDA2Desarrollo..Persona P JOIN Det_Persona_Planilla PL ON P.vCodPrs = PL.cCodRDA 
										   JOIN Tipo_Cuenta TC ON PL.nCodTCta = TC.nCodTCta
										   JOIN Bancos B ON PL.nCodHabBco = B.nCodBco 
			WHERE vCodPrs NOT IN (SELECT DISTINCT nCodRda FROM Det_Ejecucion_Macro WHERE nIdMac = @nIdMac) 
						  AND (@nIdTpl = 0 OR P.nTpoPersona = @nIdTpl)
	END
	IF(@Accion = 7)
		BEGIN
			SELECT nTplId, cTplDes FROM Tipo_Planilla
		END

	IF ( @Accion = 8 )--LISTA DE COLABORADORES PROCESADOS
	BEGIN
		SELECT vCodPrs as nCodRda, CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno) AS cNombreCompleto,
			vDocNro, PL.cNroCta as cNroCta, PL.cNroCtaInter, PL.nCodTCta, cDesTCta,
			PL.nCodHabBco as nCodBco,cDesBco, PL.nCodCtsBco, nSueNeto, nSueNeto AS sueldo
			FROM RDA2Desarrollo..Persona P JOIN Det_Persona_Planilla PL ON P.vCodPrs = PL.cCodRDA 
										   JOIN Tipo_Cuenta TC ON PL.nCodTCta = TC.nCodTCta
										   JOIN Bancos B ON PL.nCodHabBco = B.nCodBco 
			WHERE vCodPrs IN (SELECT DISTINCT nCodRda FROM Det_Ejecucion_Macro WHERE nIdMac = @nIdMac) 
						  AND (@nIdTpl = 0 OR P.nTpoPersona = @nIdTpl) 
	END
	

	if  @Accion = 9 -- LISTA DE CONFIGURACIONES
	BEGIN
	SELECT nConfId 
	 , cConDes as des_desc, cConfDes as des_concepto
	  FROM Det_Configuracion DC 
	INNER JOIN Concepto C ON DC.nConCod = C.nConId WHERE   (@nConfId  = 0 OR nConfId = @nConfId ) order by ncodid
	
	END 

	IF( @Accion = 10) -- LISTA DE COLABORADORES
	BEGIN
		SELECT vCodPrs as nCodRda, CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno) AS cNombreCompleto,
			vDocNro, PL.cNroCta as cNroCta, PL.cNroCtaInter, PL.nCodTCta, cDesTCta,
			PL.nCodHabBco as nCodBco,cDesBco, PL.nCodCtsBco, nSueNeto, nSueNeto AS sueldo
			FROM RDA2Desarrollo..Persona P JOIN Det_Persona_Planilla PL ON P.vCodPrs = PL.cCodRDA 
										   JOIN Tipo_Cuenta TC ON PL.nCodTCta = TC.nCodTCta
										   JOIN Bancos B ON PL.nCodHabBco = B.nCodBco 
	END
END





GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListaProcesos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListaProcesos](
	@Accion INT
)
AS
BEGIN
	IF @Accion = 1
	BEGIN
		SELECT	nProId,
				cProNom,
				cProAbr,
				cProDes,
				cFlgAct
		FROM Proceso
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListarCabMacro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListarCabMacro](
	@Accion		INT,
	@nIdMac		INT
)
AS
BEGIN
	IF(@Accion = 1)
	BEGIN
		SELECT nIdMac, B.nCodBco AS 'nCodBco', TC.nCodTCta AS 'nCodTCta',
		cDesMac, cDesBco, cDesTCta, cAbrMac, CM.cFlgAct AS 'cFlgAct' FROM Cab_Macro CM 
		INNER JOIN Bancos B ON CM.nCodBco = B.nCodBco 
		INNER JOIN Tipo_Cuenta TC ON CM.nCodTCta = TC.nCodTCta
	END
	IF(@Accion = 2)
	BEGIN
		SELECT nCodBco, cDesBco FROM Bancos WHERE cFlgAct = '1'
	END
	IF(@Accion = 3)
	BEGIN
		SELECT nCodTCta, cDesTCta FROM Tipo_Cuenta WHERE cFlgAct = '1'
	END
	IF(@Accion = 4)
	BEGIN
		SELECT nIdDMac, cNomCam, nOrdPre as 'orden' FROM Det_Macro WHERE nIdMac = @nIdMac
	END
	IF(@Accion = 5)
	BEGIN
		SELECT nConId, cConDes ,cConTip
		FROM [dbo].Concepto WHERE cFlgAct = '1' AND cConEst = 'S'
	END
	IF(@Accion = 6)
	BEGIN
		SELECT nIdDMac,cConDes,cMacDes FROM DET_MACRO DM INNER JOIN CONCEPTO C ON DM.nConId = C.nConId WHERE nIdMac = @nIdMac
	END
END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListarConfiguraciones]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListarConfiguraciones](

@Accion INT
)
AS
BEGIN
	

	IF @Accion = 1
	BEGIN
		SELECT conf.nConfId ,conf.nProId ,pro.cProNom ,pro.cProAbr 
		from [dbo].Proceso pro inner JOIN [dbo].Configuracion conf  on pro.nProId =conf.nProId
	END
	
		
	IF @Accion = 2
	BEGIN
		SELECT conf.nConfId ,conf.nProId ,pro.cProNom ,pro.cProAbr 
		from [dbo].Proceso pro inner JOIN [dbo].Configuracion conf  on pro.nProId =conf.nProId
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListarFormulas]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListarFormulas](
	@Accion INT
)
AS
BEGIN
	IF @Accion = 1
	BEGIN
		SELECT nForId, F.cForDes, cForFor, cConDes, cConCod,F.nConId, F.cFlgAct as 'cFlgAct' 
		FROM Formula F INNER JOIN Concepto C
		ON F.nConId = C.nConId ORDER BY F.dtFecIns
	END

	IF @Accion = 2
	BEGIN
		SELECT nConId, cConCod, cConDes FROM Concepto
	END
END
/*
select * from formula 	;
select * from concepto  ;
*/
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListarTipoContratos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListarTipoContratos](

@Accion INT
)
AS
BEGIN
	

	IF @Accion = 1
	BEGIN
		SELECT	a.nTcId,a.cTcDes,b.nTplId,b.cTplDes,a.cFlgAct ,a.dtFecIns   
		FROM	[dbo].[Tipo_Contrato] a 
		inner join Tipo_Planilla b on a.nTplId = b.nTplId
		 --SELECT * FROM TIPO_C	ONTRATO
	END
	IF @Accion = 2 
	BEGIN
		SELECT nTplId,cTplDes FROM Tipo_Planilla
		-- select * from tipo_contrato
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ListarVariables]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ListarVariables](

@Accion INT
)
AS
BEGIN
	

	IF @Accion = 1
	BEGIN
		SELECT	nVarId,cVarNom,cVarDes,cVarFor,cFlgAct ,cVarTipDat
		FROM	[dbo].[Variable]
	END
		
	IF @Accion = 2
	BEGIN
		SELECT	nVarId,cVarNom,cVarDes
		FROM	[dbo].[Variable]
	END
	IF @Accion = 3
	BEGIN
		SELECT IIF(name = 'decimal','decimal(10,2)',name) as 'TipoVariable' FROM sys.types
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_Macroprueba]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_Macroprueba]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @DOCCOL varchar(100), @NOCOL varchar(100), @NROCINT varchar(100), @NROCTA varchar(100)
 BEGIN 
/* Nombre */
SET @NOCOL = (SELECT VNOMBRES FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
 /* Cuenta */ 
SET @NROCTA = (SELECT DP.CNROCTA FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
/* DNI */
SET @DOCCOL = (SELECT VDOCNRO FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
 /* Cuenta Interbancaria */
SET @NROCINT = (SELECT DP.CNROCTAINTER FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
SELECT  '94'+'*'+CONVERT(VARCHAR, @NOCOL ) +' | '+ '95'+'*'+CONVERT(VARCHAR, @NROCTA ) +' | '+ '93'+'*'+CONVERT(VARCHAR, @DOCCOL ) +' | '+ '96'+'*'+CONVERT(VARCHAR, @NROCINT ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_Macroprueba2]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_Macroprueba2]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @DOCCOL varchar(100), @NOCOL varchar(100), @NROCTA varchar(100)
 BEGIN 
/* Nombre */
SET @NOCOL = (SELECT VNOMBRES FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
 /* Cuenta */ 
SET @NROCTA = (SELECT DP.CNROCTA FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
/* DNI */
SET @DOCCOL = (SELECT VDOCNRO FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
SELECT  '94'+'*'+CONVERT(VARCHAR, @NOCOL ) +' | '+ '95'+'*'+CONVERT(VARCHAR, @NROCTA ) +' | '+ '93'+'*'+CONVERT(VARCHAR, @DOCCOL ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_Macroprueba3]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_Macroprueba3]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @NOCOL varchar(100)
 BEGIN 
/* Nombre */ 
SET @NOCOL = (SELECT VNOMBRES FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
SELECT  '94'+'*'+CONVERT(VARCHAR, @NOCOL ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_MacroPrueba4]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_MacroPrueba4]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @DOCCOL varchar(100), @NOCOL varchar(100), @NROCINT varchar(100), @NROCTA varchar(100)
 BEGIN 
 
 /* DNI*/ 
SET @DOCCOL = (SELECT VDOCNRO FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA) 
 /* Nombre*/ 
SET @NOCOL = (SELECT VNOMBRES FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA) 
 /* Cuenta*/ 
SET @NROCTA = (SELECT DP.CNROCTA FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA =  P.VCODPRS WHERE DP.CCODRDA = @NCODRDA) 
 /* Cuenta Interbancaria*/ 
SET @NROCINT = (SELECT DP.CNROCTAINTER FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
SELECT  '93'+'*'+CONVERT(VARCHAR, @DOCCOL ) +' | '+ '94'+'*'+CONVERT(VARCHAR, @NOCOL ) +' | '+ '95'+'*'+CONVERT(VARCHAR, @NROCTA ) +' | '+ '96'+'*'+CONVERT(VARCHAR, @NROCINT ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_MANT_TipoContrato]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ----------------------------------------------------------------------
--  SISTEMA 	   : PLN
--  SUBSISTEMA     : PLN
--  NOMBRE 	       : SPS_SES_PLN_MANT_Variable
--  AUTOR 	       : Larry Caichihua - SES
--  FECHA CREACIÓN : 17/07/2019 
--  DESCRIPCION    : Mantenimiento de tipos de variables.
-- -----------------------------------------------------------------------
--  FECHA         MODIFICACIÓN                                EMPLEADO
-- -----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SPS_SES_PLN_MANT_TipoContrato]( 
	@nAccion		INT = 0,
	@nTcId			INT = 0,	
	@nIdEmp			INT = 0,
	@cTcDes		VARCHAR(200) ='',
	@nTplId			INT = 0,
	@cUsuIns		INT = 0 ,
	@cFlgAct		CHAR(1)
	
) 
AS
BEGIN

	IF @nAccion = 1	--Nueva Variable
	BEGIN
		INSERT INTO [dbo].[Tipo_Contrato] ( nIdEmp,cTcDes ,nTplId,nUsuIns,dtFecIns ,nUsuMod ,dtFecMod , cFlgAct) 
		VALUES	(@nIdEmp,@cTcDes,@nTplId,@cUsuIns , GETDATE() ,0,'', @cFlgAct)
	END

	IF @nAccion = 2	--Editar Variable
	BEGIN
		UPDATE	[dbo].[Tipo_Contrato]
		SET		
				cTcDes = @cTcDes,
				nTplId = @nTplId,
				nUsuMod = @cUsuIns ,
				dtFecMod = GETDATE(),
				cFlgAct = @cFlgAct
				
		WHERE	nTcId = @nTcId 
	END


	
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_MANT_Variable]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ----------------------------------------------------------------------
--  SISTEMA 	   : PLN
--  SUBSISTEMA     : PLN
--  NOMBRE 	       : SPS_SES_PLN_MANT_Variable
--  AUTOR 	       : Larry Caichihua - SES
--  FECHA CREACIÓN : 17/07/2019 
--  DESCRIPCION    : Mantenimiento de Variables.
-- -----------------------------------------------------------------------
--  FECHA         MODIFICACIÓN                                EMPLEADO
-- -----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SPS_SES_PLN_MANT_Variable]( 
	@nAccion		INT = 0,
	@nVarId			INT = 0,	
	@nIdEmp			INT = 0,
	@cVarNom		VARCHAR(10) ='',
	@cVarDes		VARCHAR(100) ='',
	@cVarFor		VARCHAR(300) ='',
	@cUsuIns		INT = 0 ,
	@cFlgAct		CHAR(1),
	@cVarTipDat		VARCHAR(25) = ''
) 
AS
BEGIN

	IF @nAccion = 1	--Nueva Variable
	BEGIN
		INSERT INTO [dbo].[Variable] ( nIdEmp,cVarNom ,cVarDes,cVarFor,cUsuIns ,dtFecIns ,nUsuMod ,dtFecMod , cFlgAct,cVarTipDat) 
		VALUES	(@nIdEmp,@cVarNom,@cVarDes,@cVarFor,@cUsuIns , GETDATE() ,0,'', @cFlgAct,@cVarTipDat)
	END

	IF @nAccion = 2	--Editar Variable
	BEGIN
		UPDATE	[dbo].Variable
		SET		
				cVarNom = @cVarNom,
				cVarDes = @cVarDes,
				cVarFor = @cVarFor,
				nUsuMod = @cUsuIns ,
				dtFecMod = GETDATE(),
				cFlgAct = @cFlgAct,
				cVarTipDat = @cVarTipDat
		WHERE	nVarId = @nVarId 
	END


	/*IF @nAccion = 3	-- Elimina una Variable
	BEGIN 
		UPDATE dbo.Variable  set cFlgAct = @cFlgAct where nVarId = @nVarId 
		 
	END */
END

GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_MantFormulas]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_MantFormulas](
	@nAccion		INT,
	@nIdEmp			INT = 0,
	@nForId			INT = 0,
	@nConId			INT = 0,
	@cForDes		VARCHAR(100) = '',
	@cForFor		VARCHAR(300) = '',
	@nUsuAct		INT = 0,
	@cFlgAct		VARCHAR(20)
)
AS
BEGIN
	IF @nAccion = 1	--Nueva Formula
	BEGIN
		INSERT INTO Formula (nIdEmp, nConId, cForDes,cForFor,nUsuIns,dtFecIns,nUsuMod,dtFecMod,cFlgAct) 
		VALUES	(@nIdEmp,@nConId,@cForDes,@cForFor,@nUsuAct,GETDATE(),0,'',@cFlgAct) 
	END

	IF @nAccion = 2	--Nuevo Proceso
	BEGIN
		UPDATE Formula 
		SET nConId = @nConId,
			cForDes = @cForDes,
			cForFor = @cForFor,
			nUsuMod = @nUsuAct,
			dtFecMod = GETDATE(),
			cFlgAct = @cFlgAct
		WHERE nForId = @nForId
	END

	--IF @nAccion = 3	-- Elimina un Proceso
	--BEGIN
	--	IF(@flag = 'ACTIVO')
	--	BEGIN
	--		UPDATE Proceso
	--		SET cFlgAct = '0'
	--		WHERE nProId = @nProId
	--	END
	--	ELSE
	--	BEGIN
	--		UPDATE Proceso
	--		SET cFlgAct = '1'
	--		WHERE nProId = @nProId
	--	END
	--END
END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_MantProcesos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_MantProcesos](
	@nAccion		INT,
	@nIdEmp			INT = 0,
	@nProId			INT = 0,
	@cProNom		VARCHAR(50) = '',
	@cProAbr		VARCHAR(20) = '',
	@cProDes		VARCHAR(100) = '',
	@nUsuAct		INT = 0,
	@cFlgAct		VARCHAR(20)
)
AS
BEGIN
	IF @nAccion = 1	--Nuevo Proceso
	BEGIN
		INSERT INTO Proceso (nIdEmp,cProNom,cProAbr,cProDes,nUsuIns,dtFecIns,nUsuMod,dtFecMod,cFlgAct) 
		VALUES	(@nIdEmp,@cProNom,@cProAbr,@cProDes,@nUsuAct,GETDATE(),0,'',@cFlgAct)
	END

	IF @nAccion = 2	--Nuevo Proceso
	BEGIN
		UPDATE Proceso 
		SET cProNom = @cProNom,
			cProAbr = @cProAbr,
			cProDes = @cProDes,
			nUsuMod = @nUsuAct,
			dtFecMod = GETDATE(),
			cFlgAct = @cFlgAct
		WHERE nProId = @nProId
	END

	--IF @nAccion = 3	-- Elimina un Proceso
	--BEGIN
	--	IF(@flag = 'ACTIVO')
	--	BEGIN
	--		UPDATE Proceso
	--		SET cFlgAct = '0'
	--		WHERE nProId = @nProId
	--	END
	--	ELSE
	--	BEGIN
	--		UPDATE Proceso
	--		SET cFlgAct = '1'
	--		WHERE nProId = @nProId
	--	END
	--END
END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_PagodeHaberes]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_PagodeHaberes]
( @nCodRda int  =0,
 @cPerCal varchar(6)
 )  AS 
DECLARE  @DOCCOL varchar(100), @NOCOL varchar(100)
 BEGIN 
/* Nombre */
SET @NOCOL = (SELECT VNOMBRES FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
/* DNI */
SET @DOCCOL = (SELECT VDOCNRO FROM DET_PERSONA_PLANILLA DP INNER JOIN RDA2DESARROLLO..PERSONA P ON DP.CCODRDA = P.VCODPRS WHERE DP.CCODRDA = @NCODRDA)
SELECT  '94'+'*'+CONVERT(VARCHAR, @NOCOL ) +' | '+ '93'+'*'+CONVERT(VARCHAR, @DOCCOL ) AS DFAL
 END
GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_ReporteMacro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPS_SES_PLN_ReporteMacro](
	@nMacId		INT,
	@Accion		INT,
	@nDatXML	xml
)
AS
DECLARE @hDoc INT = 0
	BEGIN
		EXEC sp_xml_PrepareDocument @hDoc OUT, @nDatXML

		SELECT ROW_NUMBER() 
			OVER(ORDER BY CodRDA ) AS ROW,
		CodRDA
		INTO #TABLA_DATOSCOLABORADOR_DOC
		FROM OpenXml(@hDoc, 'Tabla/Datos') 
		WITH	
		(	
		CodRDA INT
		)

		SELECT DISTINCT DM.nOrdPre AS 'nOrdPre', nCodRda,cNomCam, cDatImp
		FROM Det_Ejecucion_Macro DE INNER JOIN DET_MACRO DM ON DE.nIdDMac = DM.nIdDMac
		WHERE DM.nIdMac = @nMacId AND DE.nIdMac = @nMacId AND nCodRda IN (SELECT CodRDA FROM #TABLA_DATOSCOLABORADOR_DOC)
		ORDER BY nCodRda,DM.nOrdPre

		DROP TABLE #TABLA_DATOSCOLABORADOR_DOC
END


GO
/****** Object:  StoredProcedure [dbo].[SPS_SES_PLN_UPD_ConfigProcesos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 

exec [SPS_SES_PLN_INS_ConfigProcesos] 2 , 1 , 8758 , '1' , 'SPS_SES_PLN_CalculodePlanilla ', 'select  1 as dfal' ,
	'<Tabla><Variables cVarNom="@DFALTADOS" cVarTipDat="int " />
<Variables cVarNom=" @PENFALTAS" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @FONPEN" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @DESFAL" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @ASIGFAM" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @REMBASIC" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @ESSALUD" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @REFRIGER" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @INGRESO" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @DESCUENTO" cVarTipDat="decimal(10,2) " />
<Variables cVarNom=" @APORTE" cVarTipDat="decimal(10,2) " />
</Tabla>' ,

	'<Tabla2>
	<Conceptos nConId="7 " cConTip=" P " cVarNom="   &#xA;SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = @NCODRDA) &#xA; " />
	<Conceptos nConId=" 12 " cConTip=" D " cVarNom="  &#xA;SET @FONPEN = (0.15)*( SELECT NSUENETO  FROM det_persona_planilla WHERE cCodRda =@ncodrda)&#xA; " />
	<Conceptos nConId=" 77 " cConTip=" D " cVarNom="  &#xA;SET @PENFALTAS  = (50.00) &#xA; " />
	<Conceptos nConId=" 16 " cConTip=" D " cVarNom="  &#xA;SET  @DESFAL = ( @DFALTADOS *@PENFALTAS )&#xA;&#xA;  " />
	<Conceptos nConId=" 8 " cConTip=" I " cVarNom="   &#xA;SET @ASIGFAM = 85.00 &#xA;  " />
	<Conceptos nConId=" 19 " cConTip=" I " cVarNom="  &#xA;SET @REMBASIC = ( SELECT NSUENETO  FROM det_persona_planilla WHERE cCodRda =@nCodRda) &#xA; " />
	<Conceptos nConId=" 18 " cConTip=" A " cVarNom="  &#xA;SET @ESSALUD = (SELECT CASE                                        WHEN nTipSalud = 1 THEN 0.09&#xA;WHEN nTipSalud = 2 THEN 0.07&#xA;ELSE 0&#xA; END AS MontoSalud &#xA; FROM det_persona_planilla WHERE cCodRda = @nCodRda ) * @REMBASIC ; &#xA;&#xA;  \" />
	<Conceptos nConId=" 21 " cConTip=" I " cVarNom="  &#xA;SET @REFRIGER= 250.00 &#xA;&#xA; " />
	<Conceptos nConId=" 74 " cConTip=" T " cVarNom="  &#xA;SET @INGRESO = @ASIGFAM +@REFRIGER +@REMBASIC&#xA; " />
	<Conceptos nConId=" 75 " cConTip=" T " cVarNom="  &#xA;SET @DESCUENTO =  @DESFAL &#xA; " />
	<Conceptos nConId=" 76 " cConTip=" T " cVarNom="  &#xA;SET @APORTE =@ESSALUD" />
	</Tabla2>'


	*/
CREATE PROC [dbo].[SPS_SES_PLN_UPD_ConfigProcesos](
	@nIdEmp			INT = 0,
	@nConfId		INT = 0,
	@proceso		VARCHAR(max),
	@cNomProc		VARCHAR(100),
	@nProId			INT = 0,
	@nUsuAct		INT = 0,
	@cFlgAct		CHAR(1),
	@cadena			XML,
	@cadena_detalle	XML
)
AS
DECLARE @hDoc INT = 0, @hDoc2 INT = 0   , @SQL NVARCHAR(MAX) 
	BEGIN
	EXEC sp_xml_PrepareDocument @hDoc OUT, @cadena ;
	EXEC sp_xml_PrepareDocument @hDoc2 OUT, @cadena_detalle ;
	DECLARE @ObtengoCodConfig INT,@ObtengoCodConfigDet INT , @nombreProcedure VARCHAR(100), @variables VARCHAR(600)  , @concepto_variable  varchar(max)

	-- INICIAMOS LA TRANSACCION
		 Begin Tran Tadd

	-- Primer try 
		 Begin Try 

			UPDATE Configuracion
			SET nIdEmp = @nIdEmp,
				nProId = @nProId,
				nUsuMod = @nUsuAct,
				dtFecMod = GETDATE(),
				cFlgAct = @cFlgAct
		WHERE nConfId = @nConfId

		

		--SET @ObtengoCodConfig = (select ISNULL(MAX(nConfId),1) from Configuracion) 
	 	--SET @ObtengoCodConfigDet = ((select ISNULL(MAX(nCoDId),0) from det_configuracion) +1) 
		--SET @nombre_proc = @cNomProc + (SELECT ( SELECT REPLACE(CONVERT(CHAR(10), GetDate(), 103), '/', '') + ( select 
  --replace(CONVERT (varchar(8),GetDate(), 108),':','') )))  

	

	
		SELECT ROW_NUMBER() 
			OVER(ORDER BY cVarNom) AS ROW,
		cVarNom, cVarTipDat 
		INTO #TABLA_VARIABLES_DOC
		FROM OpenXml(@hDoc, 'Tabla/Variables') 
		WITH	
		(	
		cVarNom VARCHAR(25),
		cVarTipDat VARCHAR(25)
		)

		SELECT 
			
		IDENTITY (INT,1, 1) AS nCoDId,nConId, cConTip, cVarNom 
		INTO #TABLA_CONCEPTOS_DOC
		FROM OpenXml(@hDoc2, 'Tabla2/Conceptos') 
		WITH	
		(
			
		nConId INT,
		cConTip CHAR(1),
		cVarNom  VARCHAR(max)  

		)
		
			DELETE Det_Configuracion WHERE nConfId = @nConfId

			INSERT INTO Det_Configuracion
		(nIdEmp, nConfId,cNomProc, nProId,nUsuIns ,dtFecIns,nUsuMod, dtFecMod,cFlgAct , nCoDId ,cContip, nConCod, cConfDes) 
		SELECT  
		@nIdEmp,@nConfId,@cNomProc,@nProId,@nUsuAct,GETDATE() , 0 ,'',@cFlgAct,nCoDId,cConTip,nConId,cVarNom  FROM  #TABLA_CONCEPTOS_DOC




		

		SET @variables = (SELECT DISTINCT cVarNom = STUFF(( SELECT ', ' + CONCAT(CONVERT(VARCHAR,cVarNom),' ' + cVarTipDat) AS [text()] FROM #TABLA_VARIABLES_DOC 
		FOR XML PATH('')),1,1,'') FROM #TABLA_VARIABLES_DOC )

		SET @concepto_variable =  (SELECT DISTINCT cVarNom =  
			STUFF(( SELECT ' +'  + CHAR(39) + ' | ' + CHAR(39) + '+ ' + CONCAT(char(39) +  CONVERT(VARCHAR,nConId)+ CHAR(39), '+'+CHAR(39)+'*'+CHAR(39)+'+' +  'CONVERT(VARCHAR,' +
			(SELECT SUBSTRING(	  cVarNom,
			CHARINDEX('SET',cVarNom)+3,
			CHARINDEX('=',cVarNom)-4) )+ ')' ) AS [text()] FROM #TABLA_CONCEPTOS_DOC FOR XML PATH('')),1,1,'') FROM #TABLA_CONCEPTOS_DOC )
	--print @concepto_variable ;



		set @concepto_variable = 'SELECT ' + STUFF(@concepto_variable,1,7,'') + ' AS DFAL' ;
		--print @concepto_variable ;
		SET @variables = 'DECLARE '+ @variables ;

		SET @SQL = 'ALTER PROC ' +  @cNomProc + CHAR(13) + CHAR(10) +
		+ '( '+ '@nCodRda int  =0,'+ CHAR(13) + CHAR(10) +
		' @cPerCal varchar(6)'+ CHAR(13) + CHAR(10) +
		--' @idEjecucion int ' +char(13) + char(10) + 
		' ) '+
		' AS ' + CHAR(13) + CHAR(10) +
		 @variables + CHAR(13) + CHAR(10) +
		 ' BEGIN ' + CHAR(13) + CHAR(10) +	
				@proceso + CHAR(13) + CHAR(10) + 
			 @concepto_variable + CHAR(13) + CHAR(10) + 
			' END' 
		EXEC sp_executesql @SQL 
		DROP TABLE #TABLA_VARIABLES_DOC  
		DROP TABLE #TABLA_CONCEPTOS_DOC 
		COMMIT TRAN Tadd 
		
		 End try
		  Begin Catch

      return 'el error es '+ERROR_MESSAGE();
	  -- capturando el error  ; 
        Rollback TRAN Tadd

    End Catch 

	END
	 /*
	  
	 SELECT * FROM CONCEPTO 
 
DECLARE @PALABRA  VARCHAR(MAX)   
SET @PALABRA = CHARINDEX('= ','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)') 


--SELECT @PALABRA 

SELECT 
SUBSTRING(	  'SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)',
CHARINDEX('SET','SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')+3,
CHARINDEX('=','SET @DFALT = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')-4)

SELECT  CHARINDEX('SET','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')+4
SELECT CHARINDEX('=','SET @DFALTADOS = ( SELECT DFALT FROM [Resumen_const_personas] WHERE NCODRDA = 4)')-4
go





SELECT cContip , nConCod ,cConfDes    
into #T 
from Det_Configuracion ;


DECLARE @concepto_variable VARCHAR(MAX)  
 
SET @concepto_variable = (SELECT DISTINCT cVarNom =  
	STUFF(( SELECT ', ' + CONCAT(CONVERT(VARCHAR,nConCod),' ' +  
	(SELECT 
SUBSTRING(	  cConfDes,
CHARINDEX('SET',cConfDes)+3,
CHARINDEX('=',cConfDes)-4) )) AS [text()] FROM #T FOR XML PATH('')),1,1,'') FROM #T )
SELECT  'SELECT ' + @concepto_variable 
-- select * from det_configuracion 
 DROP TABLE #T 
	

	truncate table configuracion ;
	truncate table det_configuracion  ;
	 drop proc SPS_SES_PLN_CalculodePlanilla ;
	  
	*/ 


	
	



GO
/****** Object:  StoredProcedure [dbo].[USP_BOLT_OBT_InfoBoleta]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[USP_BOLT_OBT_InfoBoleta] '062019',2,1,'<Tabla><Datos CodRDA="3" /><Datos CodRDA="4" /><Datos CodRDA="5" /></Tabla>'
CREATE PROC [dbo].[USP_BOLT_OBT_InfoBoleta](
		@cPerCal	CHAR(6) = '',
		@nTipPln	INT = 0,
		@nIdEmp		INT = 0,
		@CodigoCol	XML = ''
) 
AS
DECLARE @hDoc INT = 0
	BEGIN
		EXEC sp_xml_PrepareDocument @hDoc OUT, @CodigoCol
		SELECT ROW_NUMBER() 
			OVER(ORDER BY CodRDA ) AS ROW,
		CodRDA
		INTO #TABLA_DATOSCOLABORADOR_DOC
		FROM OpenXml(@hDoc, 'Tabla/Datos') 
		WITH	
		(	
		CodRDA INT
		)
		SELECT '<?xml version="1.0" encoding="utf-8"?><Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">'+'<Encabezado>'+
					  '<Periodo><Codigo>per</Codigo><Valor>'+@cPerCal+'</Valor></Periodo>'+
					  '<RazonSocial><Codigo>Raz</Codigo><Valor>'+UPPER(ISNULL(cRazSoc,''))+'</Valor></RazonSocial>'+'<Telefono>'+ISNULL(cNroFij,'')+'</Telefono>'+
					  '<RUC><Codigo>ruc</Codigo><Valor>'+ISNULL(cNumRuc,'')+'</Valor></RUC>'+'<Direccion>'+ISNULL(cDirec,'')+'</Direccion>'+'<IdDocumento>'+'B001-251022063'+'</IdDocumento>'+'</Encabezado>'+
					  '<DatosTrabajador>'+'<CodigoTrabajador><Codigo>cod</Codigo><Valor>'+CAST(DP.cCodRDA AS VARCHAR)+'</Valor>	</CodigoTrabajador>'+
					  '<NombreCompleto><Codigo>nom</Codigo><Valor>'+ISNULL(CONCAT(vNombres, ' ' ,vApePaterno, ' ' ,vApeMaterno),'')+'</Valor></NombreCompleto>'+
					  '<NroDocumento><Codigo>doc</Codigo><Valor>'+ISNULL(vDocNro,'')+'</Valor></NroDocumento>'+
					  '<SituacionEspecial>'+''+'</SituacionEspecial>'+'<FechaIngreso><Codigo>fing</Codigo><Valor>'+ISNULL(CAST(FORMAT(dtFchIngreso,'dd/MM/yyyy') AS VARCHAR),'')+'</Valor></FechaIngreso>'+
					  '<Categoria><Codigo>cat</Codigo><Valor>'+UPPER(ISNULL(TP.cTplDes,''))+'</Valor></Categoria>'+
					  '<FechaCese><Codigo>fces</Codigo><Valor>'+ISNULL(CAST(FORMAT(dtFchCese,'dd/MM/yyyy') AS VARCHAR),'')+'</Valor></FechaCese>'+'</DatosTrabajador>'+
					  '<DatosResumen><SueldoBasico><Codigo>sbas</Codigo><Valor>'+CAST(ISNULL(DP.cSueBas,0.00) AS VARCHAR)+'</Valor></SueldoBasico>'+
					  '<DiasTrabajados><Codigo>dtra</Codigo><Valor>'+CAST(ISNULL(RC.DTRAB,0) AS VARCHAR)+'</Valor></DiasTrabajados>'+
					  '<DiasFalta><Codigo>dfal</Codigo><Valor>'+CAST(ISNULL(RC.DFALT,0) AS VARCHAR)+'</Valor></DiasFalta>'+
					  '<DiasDescansoMedico><Codigo>ddme</Codigo><Valor>'+CAST(ISNULL(RC.DEME,0) AS VARCHAR)+'</Valor></DiasDescansoMedico>'+
					  '<DiasSubsidiados><Codigo>dsub</Codigo><Valor>'+CAST(ISNULL(RC.DSUB,0) AS VARCHAR)+'</Valor></DiasSubsidiados>'+
					  '<DiasVacaciones><Codigo>dvac</Codigo><Valor>'+CAST(ISNULL(RC.DVAC,0) AS VARCHAR)+'</Valor></DiasVacaciones>'+
					  '<DiasVacacionesComp><Codigo>dcvac</Codigo><Valor>'+CAST(ISNULL(RC.DCVAC,0) AS VARCHAR)+'</Valor></DiasVacacionesComp>'+
					  '<DiasLSG><Codigo>dlsg</Codigo><Valor>'+CAST(ISNULL(RC.DLSG,0) AS VARCHAR)+'</Valor></DiasLSG>'+
					  '<DiasLP><Codigo>dlp</Codigo><Valor>'+CAST(ISNULL(RC.DLP,0) AS VARCHAR)+'</Valor></DiasLP>'+
					  '<HorasTardanzas><Codigo>hrtrd</Codigo><Valor>'+CAST(ISNULL(RC.HRTRD,0) AS VARCHAR)+'</Valor></HorasTardanzas>'+
					  '<HorasIncompletas><Codigo>hrim</Codigo><Valor>'+CAST(ISNULL(RC.HRIM,0) AS VARCHAR)+'</Valor></HorasIncompletas>'+
					  '<HorasExtras125><Codigo>h125</Codigo><Valor>'+CAST(ISNULL(RC.H125,0) AS VARCHAR)+'</Valor></HorasExtras125>'+
					  '<HorasExtras135><Codigo>h135</Codigo><Valor>'+CAST(ISNULL(RC.H135,0) AS VARCHAR)+'</Valor></HorasExtras135>'+
					  '<HorasExtras200><Codigo>h200</Codigo><Valor>'+CAST(ISNULL(RC.H200,0) AS VARCHAR)+'</Valor></HorasExtras200></DatosResumen>'+
					  '<Detalles>'+ dbo.FNC_SFC_DetalleBoleta(DP.cCodRDA,@nIdEmp,@cPerCal)+'</Detalles>'+'</Invoice>' AS cXmlResult, DP.cCodRDA as nCodTrab
					  FROM Empresa E INNER JOIN Tipo_Planilla TP ON E.nIdEmp = TP.nIdEmp 
									 INNER JOIN Det_Persona_Planilla DP ON E.nIdEmp = DP.nIdEmp
									 INNER JOIN RDA2Desarrollo..Persona P ON DP.cCodRDA = P.vCodPrs AND TP.nTplId = P.nTpoPersona
									 INNER JOIN Resumen_const_personas RC ON P.vCodPrs = RC.nCodRDA AND RC.cPerCal = @cPerCal
					  WHERE E.nIdEmp = @nIdEmp AND DP.cCodRDA IN (SELECT CodRDA FROM #TABLA_DATOSCOLABORADOR_DOC) AND (@nTipPln = 0 OR TP.nTplId = @nTipPln)


	END

GO
/****** Object:  UserDefinedFunction [dbo].[FNC_SFC_DetalleBoleta]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE FUNCTION [dbo].[FNC_SFC_DetalleBoleta](    
@CODTRAB INT,
@IDEMP	 INT,
@PERIODO	CHAR(6)
)    
RETURNS VARCHAR(MAX)    
AS    
BEGIN    
DECLARE @DETALLE VARCHAR(MAX) = '',   
@TOTALINGRESOS DECIMAL(10,2) = 0.00,
@TOTALDESC DECIMAL(10,2) = 0.00,
@TOTALAPAGAR DECIMAL(10,2) = 0.00
--@TD BIT = 0;    
--IF EXISTS (SELECT 1    
--FROM DETIMPORTESOL DS      
--JOIN DOCSVENTA D    
--ON DS.NUMSOL = D.NUMSOL    
--AND DS.NUMSOLFACT = D.NUMSOLFACT    
--WHERE D.NROCOR = @NROCOR)    
--BEGIN    
--SET @TD = 1;    
--END    
SET @DETALLE = '<Detalle>'

SELECT @DETALLE = @DETALLE +    
'<Ingresos><Descripcion>'+ C.cConDes + '</Descripcion>' + '<Valor>'+ cDatImp +'</Valor></Ingresos>'
							FROM Det_Ejecucion_Planilla DP JOIN Concepto C
							ON DP.nConId = C.nConId 
							JOIN Ejecucion_Planilla EP
							ON DP.nIdEje = EP.nIdEje
							WHERE DP.nCodRda = @CODTRAB AND DP.nIdEmp = @IDEMP AND C.cConTip = 'I' AND EP.cPerCal = @PERIODO AND cDatImp <> '0.00'

SELECT @DETALLE = @DETALLE +    
'<Descuentos><Descripcion>'+ C.cConDes + '</Descripcion>' + '<Valor>'+ cDatImp +'</Valor></Descuentos>'
							FROM Det_Ejecucion_Planilla DP JOIN Concepto C
							ON DP.nConId = C.nConId 
							JOIN Ejecucion_Planilla EP
							ON DP.nIdEje = EP.nIdEje
							WHERE DP.nCodRda = @CODTRAB AND DP.nIdEmp = @IDEMP AND C.cConTip = 'D' AND EP.cPerCal = @PERIODO

SELECT @DETALLE = @DETALLE +    
'<Aportes><Descripcion>'+ C.cConDes + '</Descripcion>' + '<Valor>'+ cDatImp +'</Valor></Aportes>'
							FROM Det_Ejecucion_Planilla DP JOIN Concepto C
							ON DP.nConId = C.nConId 
							JOIN Ejecucion_Planilla EP
							ON DP.nIdEje = EP.nIdEje
							WHERE DP.nCodRda = @CODTRAB AND DP.nIdEmp = @IDEMP AND C.cConTip = 'A' AND EP.cPerCal = @PERIODO


SET @DETALLE = @DETALLE + '</Detalle>'

SET @TOTALINGRESOS = (SELECT SUM(CAST(cDatImp AS DECIMAL(10, 2)))
							FROM Det_Ejecucion_Planilla DP JOIN Concepto C
							ON DP.nConId = C.nConId 
							JOIN Ejecucion_Planilla EP
							ON DP.nIdEje = EP.nIdEje
							WHERE DP.nCodRda = @CODTRAB AND DP.nIdEmp = @IDEMP AND C.cConTip = 'I' AND EP.cPerCal = @PERIODO)

SET @TOTALDESC = (SELECT SUM(CAST(cDatImp AS DECIMAL(10, 2)))
							FROM Det_Ejecucion_Planilla DP JOIN Concepto C
							ON DP.nConId = C.nConId 
							JOIN Ejecucion_Planilla EP
							ON DP.nIdEje = EP.nIdEje
							WHERE DP.nCodRda = @CODTRAB AND DP.nIdEmp = @IDEMP AND C.cConTip = 'D' AND EP.cPerCal = @PERIODO)

SET @TOTALAPAGAR = @TOTALINGRESOS - @TOTALDESC
  
SELECT @DETALLE = @DETALLE + '<TotalDetalle>' +    
'<TotalIngresos><Codigo>ting</Codigo><Valor>'+ISNULL(CAST(@TOTALINGRESOS AS VARCHAR),0)+'</Valor></TotalIngresos>'+    
'<TotalDescuentos><Codigo>tdes</Codigo><Valor>'+ISNULL(CAST(@TOTALDESC AS VARCHAR),0)+'</Valor></TotalDescuentos>'+    
'<TotalApagar><Codigo>tapa</Codigo><Valor>'+ISNULL(CAST(@TOTALAPAGAR AS VARCHAR),0)+'</Valor></TotalApagar>'+'</TotalDetalle>'
RETURN @DETALLE;    
END  

GO
/****** Object:  Table [dbo].[Bancos]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bancos](
	[nIdEmp] [int] NOT NULL,
	[nCodBco] [int] IDENTITY(1,1) NOT NULL,
	[cDesBco] [varchar](100) NOT NULL,
	[cAbrBco] [varchar](30) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nCodBco] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodBco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cab_Macro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cab_Macro](
	[nIdEmp] [int] NOT NULL,
	[nIdMac] [int] IDENTITY(1,1) NOT NULL,
	[nCodTCta] [int] NOT NULL,
	[nCodBco] [int] NOT NULL,
	[cDesMac] [varchar](100) NOT NULL,
	[cAbrMac] [varchar](30) NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[nUsuIVig] [int] NOT NULL,
	[dtIniVig] [datetime] NOT NULL,
	[nUsuFVig] [int] NOT NULL,
	[dtFinVig] [datetime] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[cFlgAct] [varchar](1) NOT NULL,
 CONSTRAINT [Cab_Macro_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdMac] ASC,
	[nCodBco] ASC,
	[nCodTCta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cab_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cab_Planilla](
	[nIdEmp] [int] NOT NULL,
	[nIdPla] [int] NOT NULL,
	[nTplId] [int] NOT NULL,
	[cDesPla] [varchar](100) NOT NULL,
	[cAbrPla] [varchar](30) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[nUsuIVig] [int] NOT NULL,
	[dtVigIni] [varchar](1) NOT NULL,
	[nUsuFVig] [int] NOT NULL,
	[dtFinVig] [datetime] NOT NULL,
	[cFlgVig] [char](1) NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Cab_Planilla_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdPla] ASC,
	[nTplId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cab_Sistema_Pensiones]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cab_Sistema_Pensiones](
	[nIdEmp] [int] NOT NULL,
	[nIdCPen] [int] NOT NULL,
	[cDesPen] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [varchar](1) NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Cab_Sistema_Pensiones_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdCPen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cab_Sistema_Salud]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cab_Sistema_Salud](
	[nIdEmp] [int] NOT NULL,
	[IdCSal] [int] NOT NULL,
	[cDesSal] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Cab_Sistema_Salud_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[IdCSal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Concepto]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Concepto](
	[nIdEmp] [int] NOT NULL,
	[nConId] [int] IDENTITY(1,1) NOT NULL,
	[cConDes] [varchar](80) NULL,
	[cConCod] [varchar](10) NOT NULL,
	[cConTip] [char](1) NOT NULL,
	[cConTco] [char](1) NOT NULL,
	[cConEst] [char](1) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nConId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nConId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Configuracion]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Configuracion](
	[nIdEmp] [int] NOT NULL,
	[nConfId] [int] IDENTITY(1,1) NOT NULL,
	[nProId] [int] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nConfId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nConfId] ASC,
	[nProId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Configuracion]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Configuracion](
	[nIdEmp] [int] NOT NULL,
	[nConfId] [int] NOT NULL,
	[nCoDId] [int] NOT NULL,
	[nProId] [int] NOT NULL,
	[cContip] [char](1) NOT NULL,
	[nConCod] [int] NOT NULL,
	[cConfDes] [varchar](max) NULL,
	[cNomProc] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nConDdId_det] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nConfId] ASC,
	[nCoDId] ASC,
	[nProId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Ejecucion_Macro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Ejecucion_Macro](
	[nIdEmp] [int] NOT NULL,
	[nIdEje] [int] NOT NULL,
	[nIdMac] [int] NOT NULL,
	[nIdDMac] [int] NOT NULL,
	[nIdDEje] [int] NOT NULL,
	[nCodRda] [int] NOT NULL,
	[cDatImp] [varchar](100) NOT NULL,
 CONSTRAINT [Det_Ejecucion_Macro_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdEje] ASC,
	[nIdMac] ASC,
	[nIdDMac] ASC,
	[nCodRda] ASC,
	[nIdDEje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Ejecucion_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Det_Ejecucion_Planilla](
	[nIdEje] [int] NOT NULL,
	[IdDEje] [int] NOT NULL,
	[nIdEmp] [int] NOT NULL,
	[nIdPla] [int] NOT NULL,
	[nTplId] [int] NOT NULL,
	[nCodRda] [int] NOT NULL,
	[nConId] [int] NOT NULL,
	[cDatImp] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Det_Ejecucion_Planilla_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEje] ASC,
	[IdDEje] ASC,
	[nIdEmp] ASC,
	[nIdPla] ASC,
	[nTplId] ASC,
	[nCodRda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Ejecucion_Proceso]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Ejecucion_Proceso](
	[nIdEmp] [int] NOT NULL,
	[nCodEje] [int] NOT NULL,
	[nConId] [int] NOT NULL,
	[nCodEjedet] [int] IDENTITY(1,1) NOT NULL,
	[dtFecIni] [datetime] NOT NULL,
	[dtFecFin] [datetime] NOT NULL,
	[nUsuEje] [int] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nCodEjedet] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodEje] ASC,
	[nConId] ASC,
	[nCodEjedet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Macro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Macro](
	[nIdEmp] [int] NOT NULL,
	[nIdMac] [int] NOT NULL,
	[nCodTCta] [int] NOT NULL,
	[nIdDMac] [int] NOT NULL,
	[cNomCam] [varchar](50) NOT NULL,
	[cTipDat] [varchar](20) NOT NULL,
	[nOrdPre] [int] NOT NULL,
	[cNomCab] [varchar](30) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[nConId] [int] NULL,
	[cMacDes] [varchar](max) NULL,
 CONSTRAINT [Det_Macro_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdMac] ASC,
	[nCodTCta] ASC,
	[nIdDMac] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Persona_concepto]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Persona_concepto](
	[nIdEmp] [int] NOT NULL,
	[nCodRDA] [int] NOT NULL,
	[nConId] [int] NOT NULL,
	[nImpCon] [decimal](10, 2) NOT NULL,
	[cPerCal] [varchar](6) NOT NULL,
 CONSTRAINT [Det_Persona_concept] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodRDA] ASC,
	[nConId] ASC,
	[cPerCal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Persona_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Persona_Planilla](
	[nIdEmp] [int] NOT NULL,
	[nComPerId] [int] IDENTITY(1,1) NOT NULL,
	[cCodRDA] [int] NOT NULL,
	[nCodTCta] [int] NOT NULL,
	[nCodHabBco] [int] NOT NULL,
	[nCodCtsBco] [int] NOT NULL,
	[cNroCta] [varchar](30) NOT NULL,
	[cNroCtaInter] [varchar](30) NOT NULL,
	[cSueBas] [numeric](10, 2) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[nSueNeto] [decimal](10, 2) NULL,
	[nHijos] [int] NULL,
	[nTipPen] [int] NULL,
 CONSTRAINT [nComPerId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nComPerId] ASC,
	[cCodRDA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Planilla](
	[nIdEmp] [int] NOT NULL,
	[nIdPla] [int] NOT NULL,
	[nTplId] [int] NOT NULL,
	[nIdDPla] [int] IDENTITY(1,1) NOT NULL,
	[cNomCam] [varchar](50) NOT NULL,
	[cTipDat] [varchar](20) NOT NULL,
	[nOrdPre] [int] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Det_Planilla_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdPla] ASC,
	[nTplId] ASC,
	[nIdDPla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Sistema_Pensiones]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Sistema_Pensiones](
	[nIdEmp] [int] NOT NULL,
	[nIdCPen] [int] NOT NULL,
	[nIdDPen] [varchar](1) NOT NULL,
	[nComVar] [decimal](18, 2) NOT NULL,
	[nComFij] [decimal](18, 2) NOT NULL,
	[nComFon] [decimal](18, 2) NOT NULL,
	[nUsuIVig] [int] NOT NULL,
	[dtVigIni] [datetime] NOT NULL,
	[nUsuFVig] [int] NOT NULL,
	[dtFecFVig] [datetime] NOT NULL,
	[cFlgVig] [char](1) NOT NULL,
 CONSTRAINT [Det_Sistema_Pensiones_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdCPen] ASC,
	[nIdDPen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Det_Sistema_Salud]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Det_Sistema_Salud](
	[nIdEmp] [int] NOT NULL,
	[IdCSal] [int] NOT NULL,
	[nIdDSal] [int] NOT NULL,
	[nTipApo] [int] NOT NULL,
	[nImpApl] [decimal](18, 2) NOT NULL,
	[nUsuIVig] [int] NOT NULL,
	[dtVigIni] [datetime] NOT NULL,
	[nUsuFVig] [int] NOT NULL,
	[dtVigFin] [int] NOT NULL,
	[cFlgVig] [char](1) NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [Det_Sistema_Salud_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[IdCSal] ASC,
	[nIdDSal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DetEmpresa]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DetEmpresa](
	[nIdEmp] [int] NOT NULL,
	[nIdDEmp] [int] IDENTITY(1,1) NOT NULL,
	[cRepLeg] [varchar](100) NOT NULL,
	[cNumFij] [varchar](15) NOT NULL,
	[cNroTe1] [varchar](15) NOT NULL,
	[cNroTe2] [varchar](15) NOT NULL,
	[cCorEle] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nIdDEmp] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdDEmp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Ejecucion_Macro]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ejecucion_Macro](
	[nIdEmp] [int] NOT NULL,
	[nIdEje] [int] NOT NULL,
	[nIdMac] [int] NOT NULL,
	[nCodTCta] [int] NOT NULL,
	[cPerCal] [char](6) NOT NULL,
	[cFlgCie] [char](1) NOT NULL,
	[nUsuCie] [int] NOT NULL,
	[dtFecCie] [datetime] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[nTotal] [decimal](10, 2) NULL,
	[NroEjecuciones] [int] NULL,
 CONSTRAINT [Ejecucion_Macro_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdEje] ASC,
	[nIdMac] ASC,
	[nCodTCta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Ejecucion_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ejecucion_Planilla](
	[nIdEmp] [int] NOT NULL,
	[nIdEje] [int] IDENTITY(1,1) NOT NULL,
	[nIdPla] [int] NOT NULL,
	[nTplId] [int] NOT NULL,
	[cPerCal] [char](6) NOT NULL,
	[cFlgCie] [char](1) NOT NULL,
	[dtFecCie] [datetime] NOT NULL,
	[nUsuCie] [int] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NULL,
	[cFlgAct] [char](1) NOT NULL,
	[nProid] [int] NULL,
 CONSTRAINT [Ejecucion_Planilla_pk] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdEje] ASC,
	[nIdPla] ASC,
	[nTplId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Ejecucion_Proceso]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ejecucion_Proceso](
	[nIdEmp] [int] NOT NULL,
	[nCodEje] [int] IDENTITY(1,1) NOT NULL,
	[nConId] [int] NOT NULL,
	[cPerCal] [varchar](6) NOT NULL,
	[cFlgCie] [char](1) NOT NULL,
	[nUsuCie] [int] NOT NULL,
	[dtFecCie] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nCodEje] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodEje] ASC,
	[nConId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Empresa]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Empresa](
	[nIdEmp] [int] IDENTITY(1,1) NOT NULL,
	[cRazSoc] [varchar](100) NOT NULL,
	[cNomCom] [varchar](100) NOT NULL,
	[cNumRuc] [varchar](15) NOT NULL,
	[cNroFij] [varchar](15) NOT NULL,
	[cCorEle] [varchar](100) NOT NULL,
	[cPagWeb] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[cDirec] [varchar](70) NULL,
 CONSTRAINT [nIdEmp] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Formula]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Formula](
	[nIdEmp] [int] NOT NULL,
	[nForId] [int] IDENTITY(1,1) NOT NULL,
	[nConId] [int] NOT NULL,
	[cForDes] [varchar](100) NOT NULL,
	[cForFor] [varchar](300) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nForId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nForId] ASC,
	[nConId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Maestros]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Maestros](
	[nIdEmp] [int] NOT NULL,
	[nMaeId] [int] IDENTITY(1,1) NOT NULL,
	[cMaeDes] [varchar](50) NOT NULL,
	[cMaeValor] [varchar](20) NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[fec_vig] [datetime] NULL,
 CONSTRAINT [nMaeId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nMaeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Proceso]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Proceso](
	[nIdEmp] [int] NOT NULL,
	[nProId] [int] IDENTITY(1,1) NOT NULL,
	[cProNom] [varchar](50) NOT NULL,
	[cProAbr] [varchar](20) NOT NULL,
	[cProDes] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nProId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nProId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Resumen_const_personas]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Resumen_const_personas](
	[nIdEmp] [int] NOT NULL,
	[nCodRes] [int] IDENTITY(1,1) NOT NULL,
	[nCodRDA] [int] NOT NULL,
	[DTRAB] [int] NOT NULL,
	[DFALT] [int] NOT NULL,
	[HRIM] [int] NOT NULL,
	[cPerCal] [char](6) NOT NULL,
	[DEME] [char](1) NULL,
	[Refrigerio] [varchar](100) NULL,
	[DSUB] [int] NULL,
	[DVAC] [int] NULL,
	[DCVAC] [int] NULL,
	[DLSG] [int] NULL,
	[DLP] [int] NULL,
	[HRTRD] [decimal](10, 2) NULL,
	[H125] [int] NULL,
	[H135] [int] NULL,
	[H200] [int] NULL,
	[Movilidad] [varchar](50) NULL,
 CONSTRAINT [Resumen_const_per] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodRes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tablas_Sistema]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tablas_Sistema](
	[nIdEmp] [int] NOT NULL,
	[nIdTab] [int] NOT NULL,
	[cNomTec] [varchar](30) NOT NULL,
	[cNombre] [varchar](30) NOT NULL,
	[cDesTab] [varchar](100) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [date] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [date] NOT NULL,
	[cFlAct] [char](1) NOT NULL,
 CONSTRAINT [nIdTab] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nIdTab] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tipo_Contrato]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tipo_Contrato](
	[nIdEmp] [int] NOT NULL,
	[nTcId] [int] IDENTITY(1,1) NOT NULL,
	[cTcDes] [varchar](200) NOT NULL,
	[nTplId] [int] NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[nTcId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tipo_Cuenta]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tipo_Cuenta](
	[nIdEmp] [int] NOT NULL,
	[nCodTCta] [int] IDENTITY(1,1) NOT NULL,
	[cDesTCta] [varchar](30) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[cUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nCodTCta] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nCodTCta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tipo_Planilla]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tipo_Planilla](
	[nIdEmp] [int] NOT NULL,
	[nTplId] [int] IDENTITY(1,1) NOT NULL,
	[cTplDes] [varchar](30) NOT NULL,
	[nTplDtr] [numeric](2, 0) NOT NULL,
	[cTplEst] [char](1) NOT NULL,
	[nUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
 CONSTRAINT [nTplId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nTplId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Variable]    Script Date: 09/12/2019 03:24:15 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Variable](
	[nIdEmp] [int] NOT NULL,
	[nVarId] [int] IDENTITY(1,1) NOT NULL,
	[cVarNom] [varchar](10) NOT NULL,
	[cVarDes] [varchar](100) NOT NULL,
	[cVarFor] [varchar](300) NOT NULL,
	[cUsuIns] [int] NOT NULL,
	[dtFecIns] [datetime] NOT NULL,
	[nUsuMod] [int] NOT NULL,
	[dtFecMod] [datetime] NOT NULL,
	[cFlgAct] [char](1) NOT NULL,
	[cVarTipDat] [varchar](25) NULL,
 CONSTRAINT [nVarId] PRIMARY KEY CLUSTERED 
(
	[nIdEmp] ASC,
	[nVarId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
