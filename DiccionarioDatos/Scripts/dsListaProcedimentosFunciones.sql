DECLARE @pBaseDatos				VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEsquemas				INT = 1;

-- Lista de los procedimientos almacenados y las funciones de una base de datos.

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema INT 
	 , IDObjeto	 INT
	 , Objeto	 VARCHAR(MAX)
	);
	
DECLARE @vSQL VARCHAR(MAX) = '';
SET @vSQL = 'INSERT INTO #DiccionarioTemp ( IDEsquema
										  , IDObjeto
										  , Objeto)
				SELECT IDEsquema = CONVERT(INT, O.SCHEMA_ID)
					 , IDObjeto	 = CONVERT(INT, O.OBJECT_ID)
					 , Objeto	 = CONVERT(VARCHAR(MAX), O.NAME)
				  FROM ' + @pBaseDatos + '.SYS.OBJECTS O
			     WHERE O.TYPE IN (''P'', ''AF'', ''FN'', ''FS'', ''FT'', ''IF'', ''TF'')
				   AND O.NAME NOT LIKE ''%DIAGRAM%'';'
	
EXEC (@vSQL); 
	
SELECT IDEsquema 
	 , IDObjeto 
	 , Objeto 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas) 
 ORDER BY Objeto; 
	
DROP TABLE #DiccionarioTemp; 
