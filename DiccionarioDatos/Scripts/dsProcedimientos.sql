
DECLARE @pBaseDatos		 VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas		 VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas		 INT = 1;
DECLARE @pProcedimientos INT = 1061578820

-- Documentación de los procedimientos de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema		INT 
	 , Esquema			VARCHAR(MAX) 
	 , IDProcedimiento	INT 
	 , Procedimiento	VARCHAR(MAX)  
	 , Descripcion		VARCHAR(MAX)  
	 , Etiqueta			VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema			
										   , Esquema				
										   , IDProcedimiento				
										   , Procedimiento				
										   , Descripcion	
										   , Etiqueta ) 
			 SELECT IDEsquema		 = CONVERT(INT, E.SCHEMA_ID)
				  , Esquema			 = CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDProcedimiento	 = CONVERT(INT, O.OBJECT_ID)
				  , Procedimiento	 = CONVERT(VARCHAR(MAX), O.NAME) 
				  , Descripcion		 = CONVERT(VARCHAR(MAX), D.VALUE)
				  , Etiqueta		 = CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.PROCEDURES O
				 ON E.SCHEMA_ID = O.SCHEMA_ID
				AND O.NAME		NOT LIKE ''%DIAGRAM%''
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = O.OBJECT_ID
			    AND D.MINOR_ID   = 0
				AND D.NAME		 NOT LIKE ''MS_Diagram%'' 
			    AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema		 
	 , Esquema			 
	 , IDProcedimiento	 
	 , Procedimiento	 
	 , Descripcion		 
	 , Etiqueta		 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
   AND IDProcedimiento IN (@pProcedimientos)
 ORDER BY Esquema, Procedimiento, Etiqueta;

DROP TABLE #DiccionarioTemp;
