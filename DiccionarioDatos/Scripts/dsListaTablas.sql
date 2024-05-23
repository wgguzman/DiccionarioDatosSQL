DECLARE @pBaseDatos		VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEsquemas		INT = 1;
DECLARE @MostrarTablas	BIT = 1;

-- Lista las tablas de una base de datos.

DROP TABLE IF EXISTS #DiccionarioTemp;

IF(@MostrarTablas = 1)
BEGIN
	CREATE TABLE #DiccionarioTemp(
	       IDEsquema INT 
	     , IDTabla	 INT 
	     , Tabla	 VARCHAR(MAX)
		);
	
	DECLARE @vSQL VARCHAR(MAX) = '';
	SET @vSQL = 'INSERT INTO #DiccionarioTemp( IDEsquema
											 , IDTabla
											 , Tabla)
			     SELECT IDEsquema = CONVERT(INT, T.SCHEMA_ID)
			     	  , IDTabla	  = CONVERT(INT, T.OBJECT_ID)
			     	  , Tabla	  = CONVERT(VARCHAR(MAX), T.NAME)
			       FROM ' + @pBaseDatos + '.SYS.TABLES T
			      WHERE T.NAME != ''sysdiagrams'';'

	EXEC (@vSQL); 
	
	SELECT IDEsquema
		 , IDTabla
		 , Tabla
	  FROM #DiccionarioTemp 
	 WHERE IDEsquema IN (@pEsquemas)
	 ORDER BY Tabla;
	
	DROP TABLE #DiccionarioTemp; 
END 
ELSE
	SELECT IDTabla = 0
		 , Tabla   = 'NO MOSTRAR';