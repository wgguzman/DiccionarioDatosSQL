DECLARE @pBaseDatos	 VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas	 VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	 INT = 1;
DECLARE @pTablas	 INT = 1701581100 --1589580701 --, 1701581100, 1573580644;;

-- Documentación de campos de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema			INT				
	 , IDTabla				INT
	 , Tabla				VARCHAR(MAX) 
	 , IDColumna			INT 
	 , Columna				VARCHAR(MAX) 
	 , TipoDato				VARCHAR(MAX) 
	 , Tamanio				VARCHAR(MAX) 
	 , PrecisionDato		VARCHAR(MAX) 
	 , PermiteNulos			BIT 
	 , AutoIncremental		BIT 
	 , Semilla				VARCHAR(MAX) 
	 , Calculado			BIT 
	 , EsLLavePrimaria		BIT 
	 , Enmascarado			BIT 
	 , FuncionMascara		VARCHAR(MAX) 
	 , NombreValorDefecto	VARCHAR(MAX) 
	 , ValorDefecto			VARCHAR(MAX) 
	 , DescripcionColumna	VARCHAR(MAX) 
	 , Etiqueta				VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDTabla 
										   , Tabla 
										   , IDColumna 
										   , Columna 
										   , TipoDato 
										   , Tamanio 
										   , PrecisionDato 
										   , PermiteNulos 
										   , AutoIncremental 
										   , Semilla 
										   , Calculado 
										   , EsLLavePrimaria 
										   , Enmascarado 
										   , FuncionMascara 
										   , NombreValorDefecto 
										   , ValorDefecto 
										   , DescripcionColumna	
										   , Etiqueta ) 
			 SELECT IDEsquema			= CONVERT(INT, E.SCHEMA_ID)
				  , IDTabla				= CONVERT(INT, T.OBJECT_ID)
				  , Tabla				= CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDColumna			= CONVERT(INT, C.COLUMN_ID)
				  , Columna				= CONVERT(VARCHAR(MAX), C.NAME)
				  , TipoDato			= CONVERT(VARCHAR(MAX), S.NAME) 
				  , Tamanio				= CONVERT(VARCHAR(MAX), C.MAX_LENGTH) 
				  , PrecisionDato		= CONVERT(VARCHAR(MAX), CASE WHEN C.PRECISION != 0 THEN C.PRECISION ELSE NULL END) 
				  , PermiteNulos		= C.IS_NULLABLE 
				  , AutoIncremental		= C.IS_IDENTITY 
				  , Semilla				= ''('' + CONVERT(VARCHAR(MAX), I.SEED_VALUE) + '', '' + CONVERT(VARCHAR(MAX), I.INCREMENT_VALUE) + '')''
				  , Calculado			= C.IS_COMPUTED 
				  , EsLLavePrimaria		= IX.IS_PRIMARY_KEY 
				  , Enmascarado			= C.IS_MASKED
				  , FuncionMascara		= CONVERT(VARCHAR(MAX), M.MASKING_FUNCTION)
				  , NombreValorDefecto	= CONVERT(VARCHAR(MAX), V.NAME)
				  , ValorDefecto		= CONVERT(VARCHAR(MAX), V.DEFINITION)
				  , DescripcionColumna	= CONVERT(VARCHAR(MAX), D.VALUE) 
				  , Etiqueta			= CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams'' 
			  INNER JOIN ' + @pBaseDatos + '.SYS.COLUMNS C
			     ON T.OBJECT_ID = C.OBJECT_ID 
			  INNER JOIN ' + @pBaseDatos + '.SYS.SYSTYPES S
			     ON C.SYSTEM_TYPE_ID = S.XTYPE 
				AND S.NAME			 != ''sysname''
			   LEFT JOIN (SELECT OBJECT_ID		 = I.OBJECT_ID
							   , COLUMN_ID		 = IC.COLUMN_ID
							   , IS_PRIMARY_KEY  = I.IS_PRIMARY_KEY
							FROM ' + @pBaseDatos + '.SYS.INDEXES I
						   INNER JOIN ' + @pBaseDatos + '.SYS.INDEX_COLUMNS IC
							  ON I.OBJECT_ID	  = IC.OBJECT_ID
							 AND I.INDEX_ID		  = IC.INDEX_ID
							 AND I.IS_PRIMARY_KEY = 1
							 AND I.IS_DISABLED	  = 0) IX
				 ON IX.OBJECT_ID = T.OBJECT_ID
		        AND IX.COLUMN_ID = C.COLUMN_ID 
			   LEFT JOIN ' + @pBaseDatos + '.SYS.DEFAULT_CONSTRAINTS V
			     ON V.SCHEMA_ID		   = E.SCHEMA_ID
				AND V.PARENT_OBJECT_ID = T.OBJECT_ID
				AND V.PARENT_COLUMN_ID = C.COLUMN_ID
			   LEFT JOIN ' + @pBaseDatos + '.SYS.MASKED_COLUMNS M
				 ON M.OBJECT_ID = T.OBJECT_ID
		        AND M.COLUMN_ID = C.COLUMN_ID 
			   LEFT JOIN ' + @pBaseDatos + '.SYS.IDENTITY_COLUMNS I
				 ON I.OBJECT_ID = T.OBJECT_ID
		        AND I.COLUMN_ID = C.COLUMN_ID 
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = T.OBJECT_ID
			    AND D.MINOR_ID   = C.COLUMN_ID
				AND D.NAME		 NOT LIKE ''MS_Diagram%'' 
			    AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema 
	 , IDTabla 
	 , Tabla 
	 , IDColumna 
	 , Columna 
	 , TipoDato 
	 , Tamanio 
	 , PrecisionDato 
	 , PermiteNulos 
	 , AutoIncremental 
	 , Semilla 
	 , Calculado 
	 , EsLLavePrimaria 
	 , Enmascarado 
	 , FuncionMascara 
	 , NombreValorDefecto 
	 , ValorDefecto 
	 , DescripcionColumna 
	 , Etiqueta 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;
