DECLARE @pBaseDatos	VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas	VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	INT = 1;

-- Documentación de los esquemas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema	INT 
	 , Esquema		VARCHAR(MAX) 
	 , Descripcion	VARCHAR(MAX)
	 , Etiqueta		VARCHAR(MAX)
	);

SET @vSQL = 'INSERT INTO #DiccionarioTemp (IDEsquema, Esquema, Descripcion, Etiqueta)
			 SELECT IDEsquema	= CONVERT(INT, E.SCHEMA_ID)
				  , Esquema		= CONVERT(VARCHAR(MAX), E.NAME)
		 		  , Descripcion = CONVERT(VARCHAR(MAX), D.VALUE)
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME)
			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D
  			     ON E.SCHEMA_ID  = D.MAJOR_ID
				AND D.NAME		 NOT LIKE ''MS_Diagram%''
			    AND D.CLASS_DESC = ''SCHEMA'';'

EXEC (@vSQL); 

SELECT IDEsquema	
	 , Esquema		
	 , Descripcion 
	 , Etiqueta	
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY Esquema, Etiqueta;

DROP TABLE #DiccionarioTemp;
