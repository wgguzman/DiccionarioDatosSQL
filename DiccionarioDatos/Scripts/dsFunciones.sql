
DECLARE @pBaseDatos			VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas			VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas			INT = 1;
DECLARE @MostrarFunciones	BIT = 1;
DECLARE @pFunciones			INT = 1013578649

-- Documentación de las funciones de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema	INT 
	 , Esquema		VARCHAR(MAX) 
	 , IDFuncion	INT 
	 , Funcion		VARCHAR(MAX) 
     , TipoFuncion	VARCHAR(MAX)
	 , Descripcion	VARCHAR(MAX) 
	 , Etiqueta		VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema			
										   , Esquema				
										   , IDFuncion				
										   , Funcion
										   , TipoFuncion 
										   , Descripcion	
										   , Etiqueta ) 
			 SELECT IDEsquema	= CONVERT(INT, E.SCHEMA_ID)
				  , Esquema		= CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDFuncion	= CONVERT(INT, O.OBJECT_ID)
				  , Funcion		= CONVERT(VARCHAR(MAX), O.NAME) 
				  , TipoFuncion = CONVERT(VARCHAR(MAX), O.TYPE_DESC)
				  , Descripcion	= CONVERT(VARCHAR(MAX), D.VALUE)
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME)
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.OBJECTS O
				 ON E.SCHEMA_ID = o.SCHEMA_ID
				AND O.TYPE IN (''AF'', ''FN'', ''FS'', ''FT'', ''IF'', ''TF'')
				AND O.NAME NOT LIKE ''%DIAGRAM%''
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = O.OBJECT_ID
			    AND D.MINOR_ID   = 0
				AND D.NAME		 NOT LIKE ''MS_Diagram%'' 
			    AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema 
	 , Esquema 
	 , IDFuncion 
	 , Funcion 
	 , TipoFuncion 
	 , Descripcion 
	 , Etiqueta 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
   AND IDFuncion IN (@pFunciones)
 ORDER BY Esquema, Funcion, Etiqueta;

DROP TABLE #DiccionarioTemp;
