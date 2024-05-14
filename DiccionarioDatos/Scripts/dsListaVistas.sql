
DECLARE @pBaseDatos		VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEsquemas		INT = 1;
DECLARE @pMostrarVistas	BIT = 1;

-- Lista las vistas de una base de datos.

DROP TABLE IF EXISTS #DiccionarioTemp;

IF(@pMostrarVistas = 1)
BEGIN
	CREATE TABLE #DiccionarioTemp(
		   IDEsquema INT 
		 , IDVista	 INT
		 , Vista	 VARCHAR(MAX)
		);
	
	DECLARE @vSQL VARCHAR(MAX) = '';
	SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema
											   , IDVista
											   , Vista)
				 SELECT IDEsquema = CONVERT(INT, T.SCHEMA_ID)
					  , IDVista	  = CONVERT(INT, T.OBJECT_ID)
					  , Vista	  = CONVERT(VARCHAR(MAX), T.NAME)
				   FROM ' + @pBaseDatos + '.SYS.VIEWS T
				  WHERE T.NAME != ''sysdiagrams'';'

	EXEC (@vSQL); 
	
	SELECT IDEsquema 
		 , IDVista 
		 , Vista 
	  FROM #DiccionarioTemp 
	 WHERE IDEsquema IN (@pEsquemas) 
	 ORDER BY Vista; 
	
	DROP TABLE #DiccionarioTemp; 
END 
ELSE
	SELECT IDVista = 0
		 , Vista   = 'NO MOSTRAR';