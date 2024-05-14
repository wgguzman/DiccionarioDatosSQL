DECLARE @pBaseDatos	VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas	VARCHAR(MAX) = 'MS_Description';

-- Documentación de una base de datos.

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   BaseDatos	VARCHAR(MAX)
	 , Descripcion	VARCHAR(MAX)
	 , Etiqueta		VARCHAR(MAX)
	);

SET @vSQL = 'INSERT INTO #DiccionarioTemp (BaseDatos, Descripcion, Etiqueta)
			 SELECT BaseDatos	= CONVERT(VARCHAR(MAX), ''' + @pBaseDatos + ''')
				  , Descripcion = CONVERT(VARCHAR(MAX), D.VALUE) 
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME)
			   FROM MASTER.SYS.DATABASES DB
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D
			     ON D.CLASS_DESC = ''DATABASE''
				AND D.NAME		 NOT LIKE ''MS_Diagram%''
			  WHERE DB.NAME = ''' + @pBaseDatos + ''';'
EXEC (@vSQL);

SELECT BaseDatos	
	 , Descripcion 
	 , Etiqueta	
  FROM #DiccionarioTemp 
 WHERE ISNULL(Etiqueta, '') = ''
	OR Etiqueta IN (@pEtiquetas)
 ORDER BY BaseDatos, Etiqueta;

DROP TABLE #DiccionarioTemp;
