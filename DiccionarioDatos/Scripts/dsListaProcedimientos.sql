
DECLARE @pBaseDatos				VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEsquemas				INT = 1;
DECLARE @MostrarProcedimientos	BIT = 1;

-- Lista de los procedimientos almacenados de una base de datos.

DROP TABLE IF EXISTS #DiccionarioTemp;

IF(@MostrarProcedimientos = 1)
BEGIN
	CREATE TABLE #DiccionarioTemp(
		   IDEsquema		INT 
		 , IDProcedimiento	INT
		 , Procedimiento	VARCHAR(MAX)
		);
	
	DECLARE @vSQL VARCHAR(MAX) = '';
	SET @vSQL = 'INSERT INTO #DiccionarioTemp( IDEsquema
											 , IDProcedimiento
											 , Procedimiento)
				 SELECT IDEsquema		= CONVERT(INT, O.SCHEMA_ID)
					  , IDProcedimiento	= CONVERT(INT, O.OBJECT_ID)
					  , Procedimiento	= CONVERT(VARCHAR(MAX), O.NAME)
				   FROM ' + @pBaseDatos + '.SYS.PROCEDURES O
				  WHERE O.NAME NOT LIKE ''%DIAGRAM%'';'
	
	EXEC (@vSQL); 
	
	SELECT IDEsquema 
		 , IDProcedimiento 
		 , Procedimiento 
	  FROM #DiccionarioTemp 
	 WHERE IDEsquema IN (@pEsquemas) 
	 ORDER BY Procedimiento; 
	
	DROP TABLE #DiccionarioTemp; 
END 
ELSE
	SELECT IDProcedimiento = 0
		 , Procedimiento   = 'NO MOSTRAR';
