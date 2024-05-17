DECLARE @pBaseDatos				VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEsquemas				INT = 1;
DECLARE @pTablas				INT = 917578307 --, 1701581100, 1573580644;;

-- Documentación de los triggers de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema  INT 
	 , IDTabla	  INT 
	 , Tabla	  VARCHAR(MAX) 
	 , IDTigger	  INT 
	 , [Trigger]  VARCHAR(MAX) 
	 , Tipo		  VARCHAR(MAX) 
	 , Eventos	  VARCHAR(MAX) 
	 , Estado	  BIT 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDTabla 
										   , Tabla 
										   , IDTigger
										   , [Trigger] 
										   , Tipo
										   , Eventos
										   , Estado) 
			 SELECT IDEsquema = CONVERT(INT, E.SCHEMA_ID) 
				  , IDTabla	  = CONVERT(INT, T.OBJECT_ID) 
				  , Tabla	  = CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDTigger  = CONVERT(INT, O.OBJECT_ID) 
				  , [Trigger] = CONVERT(VARCHAR(MAX), O.NAME ) 
				  , Tipo	  = CASE O.is_instead_of_trigger WHEN 1 THEN ''Instead Of'' ELSE ''After'' END
				  , Eventos	  = R.TIPO
				  , Estado	  = CASE O.IS_DISABLED WHEN 0 THEN 1 ELSE 0 END
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
				 ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams''
			 INNER JOIN ' + @pBaseDatos + '.SYS.TRIGGERS O
			    ON O.PARENT_ID = T.OBJECT_ID
			 INNER JOIN ( SELECT IDTRIGGER = E.OBJECT_ID
							   , TIPO =STUFF (( SELECT DISTINCT '', '' + D.TYPE_DESC  
													FROM ' + @pBaseDatos + '.SYS.TRIGGER_EVENTS D
													 FOR XML PATH('''')
											  ), 1, 1, '''')
							FROM ' + @pBaseDatos + '.SYS.TRIGGER_EVENTS E
						   GROUP BY E.OBJECT_ID ) R
			    ON R.IDTRIGGER = O.OBJECT_ID;'

EXEC (@vSQL); 

SELECT IDEsquema
	 , IDTabla 
	 , Tabla 
	 , IDTigger 
	 , [Trigger] 
	 , Tipo 
	 , Eventos 
     , Estado 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
 ORDER BY [Trigger];

DROP TABLE #DiccionarioTemp;
