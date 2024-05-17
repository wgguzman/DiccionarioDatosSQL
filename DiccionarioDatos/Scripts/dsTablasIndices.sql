DECLARE @pBaseDatos				VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEtiquetas				VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas				INT = 1;
DECLARE @pTablas				INT = 1030450895 --, 1701581100, 1573580644;;

-- Documentación de los indices de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema		 INT 
	 , IDTabla			 INT 
	 , Tabla			 VARCHAR(MAX) 
	 , IDColumna		 INT 
	 , Columna			 VARCHAR(MAX) 
	 , IDIndice			 INT 
	 , Indice			 VARCHAR(MAX) 
	 , TipoIndice		 VARCHAR(MAX) 
	 , Inactivo			 BIT 
	 , Unico			 BIT
	 , Etiqueta			 VARCHAR(MAX) 
	 , DescripcionIndice VARCHAR(MAX)
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDTabla 
										   , Tabla 
										   , IDColumna 
										   , Columna 
										   , IDIndice
										   , Indice 
										   , TipoIndice 
										   , Inactivo
										   , Unico
										   , Etiqueta 
										   , DescripcionIndice) 
			 SELECT IDEsquema			= CONVERT(INT, E.SCHEMA_ID) 
				  , IDTabla				= CONVERT(INT, T.OBJECT_ID) 
				  , Tabla				= CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDColumna			= CONVERT(INT, C.COLUMN_ID) 
				  , Columna				= CONVERT(VARCHAR(MAX), C.NAME) 
				  , IDIndice			= CONVERT(INT, I.INDEX_ID) 
				  , Indice				= CONVERT(VARCHAR(MAX), I.NAME ) 
				  , TipoIndice			= CONVERT(VARCHAR(MAX), CASE WHEN I.IS_PRIMARY_KEY = 1 THEN ''PRIMARY KEY'' WHEN I.IS_UNIQUE_CONSTRAINT = 1 THEN ''UNIQUE'' ELSE ''INDEX'' END) 
				  , Inactivo			= I.IS_DISABLED  
				  , Unico				= I.IS_UNIQUE 
				  , Etiqueta			= CONVERT(VARCHAR(MAX), D.NAME) 
				  , DescripcionIndice	= CONVERT(VARCHAR(MAX), D.VALUE) 
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams'' 
			  INNER JOIN ' + @pBaseDatos + '.SYS.COLUMNS C
			     ON C.OBJECT_ID = T.OBJECT_ID 
			  INNER JOIN ' + @pBaseDatos + '.SYS.INDEXES I
			     ON I.OBJECT_ID = C.OBJECT_ID
			  INNER JOIN ' + @pBaseDatos + '.SYS.INDEX_COLUMNS IC
				 ON IC.INDEX_ID		 = I.INDEX_ID
			    AND IC.OBJECT_ID	 = I.OBJECT_ID
				AND IC.COLUMN_ID	 = C.COLUMN_ID
				AND I.IS_PRIMARY_KEY = 0
			  INNER JOIN ' + @pBaseDatos + '.SYS.OBJECTS O
 			     ON O.NAME = I.NAME
		       LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D
		      	 ON D.MAJOR_ID   = O.OBJECT_ID
				AND D.NAME		 NOT LIKE ''MS_Diagram%''
		        AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema 
	 , IDTabla 
	 , Tabla 
	 , IDColumna 
	 , Columna 
	 , IDIndice 
	 , Indice 
	 , TipoIndice 
	 , Inactivo 
	 , Unico 
	 , Etiqueta 
	 , DescripcionIndice 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;
