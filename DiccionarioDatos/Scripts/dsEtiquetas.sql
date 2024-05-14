DECLARE @pBaseDatos	VARCHAR(MAX) = 'EjemploDB';

-- Lista las etiquetas de los comentarios de los objetos.

DECLARE @vSQL VARCHAR(MAX) = '';

SET @vSQL = 'SELECT DISTINCT Etiqueta = D.NAME
			   FROM ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D
			  WHERE D.NAME NOT LIKE ''MS_Diagram%'' 
			  ORDER BY D.NAME;'

EXEC (@vSQL); 