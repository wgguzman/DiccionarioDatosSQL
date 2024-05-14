
DECLARE @pBaseDatos VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	INT = 1;
DECLARE @pVistas	INT = 981578535;

-- Documentación de las vistas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema	INT				
	 , Esquema		VARCHAR(MAX)
	 , IDVista		INT
	 , Vista		VARCHAR(MAX)
	 , Descripcion	VARCHAR(MAX)				
	 , Etiqueta		VARCHAR(MAX)	
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema			
										   , Esquema				
										   , IDVista				
										   , Vista				
										   , Descripcion	
										   , Etiqueta ) 
			 SELECT IDEsquema	= CONVERT(INT, E.SCHEMA_ID)
				  , Esquema		= CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDVista		= CONVERT(INT, T.OBJECT_ID)
				  , Vista		= CONVERT(VARCHAR(MAX), T.NAME) 
				  , Descripcion = CONVERT(VARCHAR(MAX), D.VALUE)
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.VIEWS T  
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
	 , IDVista		
	 , Vista		
	 , Descripcion 
	 , Etiqueta	
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDVista   IN (@pVistas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY Esquema, Vista, Etiqueta;

DROP TABLE #DiccionarioTemp;
