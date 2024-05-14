
DECLARE @pBaseDatos VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	INT = 1;
DECLARE @pTablas	INT = 1109578991;

-- Documentación de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema	INT				
	 , Esquema		VARCHAR(MAX)
	 , IDTabla		INT
	 , Tabla		VARCHAR(MAX)
	 , Descripcion	VARCHAR(MAX)				
	 , Etiqueta		VARCHAR(MAX)	
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema			
										   , Esquema				
										   , IDTabla				
										   , Tabla				
										   , Descripcion	
										   , Etiqueta ) 
			 SELECT IDEsquema	= CONVERT(INT, E.SCHEMA_ID)
				  , Esquema		= CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDTabla		= CONVERT(INT, T.OBJECT_ID)
				  , Tabla		= CONVERT(VARCHAR(MAX), T.NAME) 
				  , Descripcion = CONVERT(VARCHAR(MAX), D.VALUE)
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams'' 
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = T.OBJECT_ID
			    AND D.MINOR_ID   = 0
				AND D.NAME		 NOT LIKE ''MS_Diagram%'' 
			    AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema	
	 , Esquema		
	 , IDTabla		
	 , Tabla		
	 , Descripcion 
	 , Etiqueta	
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY Esquema, Tabla, Etiqueta;

DROP TABLE #DiccionarioTemp;
