DECLARE @pBaseDatos		  VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEsquemas		  INT = 1;
DECLARE @MostrarFunciones BIT = 1;

-- Lista de funciones de una base de datos.

DROP TABLE IF EXISTS #DiccionarioTemp;

IF(@MostrarFunciones = 1)
BEGIN
	CREATE TABLE #DiccionarioTemp(
		   IDEsquema	INT 
		 , IDFuncion	INT
		 , Funcion		VARCHAR(MAX)
		);
		
	DECLARE @vSQL VARCHAR(MAX) = '';
	SET @vSQL = 'INSERT INTO #DiccionarioTemp( IDEsquema
											 , IDFuncion
											 , Funcion)
				 SELECT IDEsquema   = CONVERT(INT, O.SCHEMA_ID)
					  , IDFuncion   = CONVERT(INT, O.OBJECT_ID)
					  , Funcion	    = CONVERT(VARCHAR(MAX), O.NAME)
				   FROM ' + @pBaseDatos + '.SYS.OBJECTS O
				  WHERE O.TYPE IN (''AF'', ''FN'', ''FS'', ''FT'', ''IF'', ''TF'')
				    AND O.NAME NOT LIKE ''%DIAGRAM%'';'
	
	EXEC (@vSQL); 
	
	SELECT IDEsquema   
		 , IDFuncion   
		 , Funcion	    
	  FROM #DiccionarioTemp 
	 WHERE IDEsquema IN (@pEsquemas)
	 ORDER BY Funcion;
	
	DROP TABLE #DiccionarioTemp;
END 
ELSE
	SELECT IDFuncion = 0
		 , Funcion   = 'NO MOSTRAR';
