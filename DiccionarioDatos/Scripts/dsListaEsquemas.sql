DECLARE @pBaseDatos	VARCHAR(MAX) = 'EjemploDB';

-- Lista de los esquemas una bases de datos.
DECLARE @vSQL VARCHAR(MAX) = '';
SET @vSQL = 'SELECT IDEsquema = E.SCHEMA_ID
		      	  , Esquema	  = E.NAME
		       FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
		      WHERE E.NAME NOT IN (''guest'', ''INFORMATION_SCHEMA'', ''sys'')
		        AND E.NAME NOT LIKE ''db__%''
	          ORDER BY E.NAME;'

EXEC (@vSQL); 
