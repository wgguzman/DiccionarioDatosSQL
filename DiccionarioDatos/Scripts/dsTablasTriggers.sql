DECLARE @pBaseDatos	VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEtiquetas	VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	INT = 1;
DECLARE @pTablas	INT = 818974144 --, 1701581100, 1573580644;;

-- Documentación de los triggers de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema	INT 
	 , IDTabla		INT 
	 , Tabla		VARCHAR(MAX) 
	 , IDTigger		INT 
	 , [Trigger]	VARCHAR(MAX) 
	 , Tipo			VARCHAR(MAX) 
	 , Eventos		VARCHAR(MAX) 
	 , Estado		BIT 
	 , Etiqueta		VARCHAR(MAX) 
	 , Descripcion	VARCHAR(MAX)
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDTabla 
										   , Tabla 
										   , IDTigger
										   , [Trigger] 
										   , Tipo
										   , Eventos
										   , Estado 
										   , Etiqueta 
										   , Descripcion) 
			 SELECT IDEsquema	= CONVERT(INT, E.SCHEMA_ID) 
				  , IDTabla		= CONVERT(INT, T.OBJECT_ID) 
				  , Tabla		= CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDTigger	= CONVERT(INT, O.OBJECT_ID) 
				  , [Trigger]	= CONVERT(VARCHAR(MAX), O.NAME ) 
				  , Tipo		= CASE O.is_instead_of_trigger WHEN 1 THEN ''Instead Of'' ELSE ''After'' END
				  , Eventos		= R.TIPO
				  , Estado		= CASE O.IS_DISABLED WHEN 0 THEN 1 ELSE 0 END
				  , Etiqueta	= CONVERT(VARCHAR(MAX), D.NAME) 
				  , Descripcion	= CONVERT(VARCHAR(MAX), D.VALUE) 
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams''
			 INNER JOIN ' + @pBaseDatos + '.SYS.TRIGGERS O
			    ON O.PARENT_ID = T.OBJECT_ID
			 INNER JOIN ( SELECT IDTRIGGER = E.OBJECT_ID
							   , TIPO =STUFF (( SELECT DISTINCT '', '' + D.TYPE_DESC  
													FROM ' + @pBaseDatos + '.SYS.TRIGGER_EVENTS D
												   WHERE D.OBJECT_ID = E.OBJECT_ID
													 FOR XML PATH('''')
											  ), 1, 1, '''')
							FROM ' + @pBaseDatos + '.SYS.TRIGGER_EVENTS E
						   GROUP BY E.OBJECT_ID ) R
			    ON R.IDTRIGGER = O.OBJECT_ID
	          LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D
		        ON D.MAJOR_ID   = R.IDTRIGGER
			   AND D.NAME		NOT LIKE ''MS_Diagram%''
		       AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'

EXEC (@vSQL); 

SELECT IDEsquema
	 , IDTabla 
	 , Tabla 
	 , IDTigger 
	 , [Trigger] 
	 , Tipo 
	 , Eventos 
     , Estado 
	 , Etiqueta 
	 , Descripcion
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY [Trigger], Etiqueta;

DROP TABLE #DiccionarioTemp;
