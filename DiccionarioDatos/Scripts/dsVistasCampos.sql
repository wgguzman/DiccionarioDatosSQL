DECLARE @pBaseDatos	 VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas	 VARCHAR(MAX) = 'Notas';
DECLARE @pEsquemas	 INT = 1;
DECLARE @pVistas	 INT = 981578535;

-- Documentación de campos de las vistas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema			INT				
	 , IDVista				INT
	 , Vista				VARCHAR(MAX) 
	 , IDColumna			INT 
	 , Columna				VARCHAR(MAX) 
	 , TipoDato				VARCHAR(MAX) 
	 , Tamanio				VARCHAR(MAX) 
	 , PrecisionDato		VARCHAR(MAX) 
	 , PermiteNulos			BIT 
	 , DescripcionColumna	VARCHAR(MAX) 
	 , Etiqueta				VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDVista 
										   , Vista 
										   , IDColumna 
										   , Columna 
										   , TipoDato 
										   , Tamanio 
										   , PrecisionDato 
										   , PermiteNulos 
										   , DescripcionColumna	
										   , Etiqueta ) 
			 SELECT IDEsquema			= CONVERT(INT, E.SCHEMA_ID)
				  , IDVista				= CONVERT(INT, T.OBJECT_ID)
				  , Vista				= CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDColumna			= CONVERT(INT, C.COLUMN_ID)
				  , Columna				= CONVERT(VARCHAR(MAX), C.NAME)
				  , TipoDato			= CONVERT(VARCHAR(MAX), S.NAME) 
				  , Tamanio				= CONVERT(VARCHAR(MAX), C.MAX_LENGTH) 
				  , PrecisionDato		= CONVERT(VARCHAR(MAX), CASE WHEN C.PRECISION != 0 THEN C.PRECISION ELSE NULL END) 
				  , PermiteNulos		= C.IS_NULLABLE 
				  , DescripcionColumna	= CONVERT(VARCHAR(MAX), D.VALUE) 
				  , Etiqueta			= CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.VIEWS T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams'' 
			  INNER JOIN ' + @pBaseDatos + '.SYS.COLUMNS C
			     ON T.OBJECT_ID = C.OBJECT_ID 
			  INNER JOIN ' + @pBaseDatos + '.SYS.SYSTYPES S
			     ON C.SYSTEM_TYPE_ID = S.XTYPE 
				AND S.NAME			 != ''sysname''
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = T.OBJECT_ID
			    AND D.MINOR_ID   = C.COLUMN_ID
				AND D.NAME		 NOT LIKE ''MS_Diagram%''
			    AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema 
	 , IDVista 
	 , Vista 
	 , IDColumna 
	 , Columna 
	 , TipoDato 
	 , Tamanio 
	 , PrecisionDato 
	 , PermiteNulos 
	 , DescripcionColumna 
	 , Etiqueta 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDVista   IN (@pVistas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;
