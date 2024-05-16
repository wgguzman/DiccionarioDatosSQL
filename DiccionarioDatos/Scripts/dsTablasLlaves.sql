DECLARE @pBaseDatos				VARCHAR(MAX) = 'SGA_Soporte';
DECLARE @pEtiquetas				VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas				INT = 1;
DECLARE @pTablas				INT = 2060586429--1589580701 --, 1701581100, 1573580644;

-- Documentación de las llaves de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	  IDEsquema			 INT 
	, IDTabla				INT
	, Tabla				VARCHAR(MAX) 
	, IDColumna			INT 
	, Columna				VARCHAR(MAX) 
	, TipoLlave			 VARCHAR(MAX) 
	, NombreLlave		 VARCHAR(MAX) 
	, TablaReferenciaFK	 VARCHAR(MAX) 
	, ColumnaReferenciaFK VARCHAR(MAX) 
	, TipoBorradoFK		 VARCHAR(MAX) 
	, TipoActualizacionFK VARCHAR(MAX) 
	, Etiqueta			 VARCHAR(MAX) 
	, DescripcionLlave	 VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDTabla 
										   , Tabla
										   , IDColumna 
										   , Columna
										   , TipoLlave 
										   , NombreLlave 
										   , TablaReferenciaFK 
										   , ColumnaReferenciaFK 
										   , TipoBorradoFK 
										   , TipoActualizacionFK 
										   , Etiqueta 
										   , DescripcionLlave) 
			 SELECT IDEsquema			 = CONVERT(INT, E.SCHEMA_ID) 
			      , IDTabla				 = CONVERT(INT, T.OBJECT_ID) 
				  , Tabla				 = CONVERT(VARCHAR(MAX), T.NAME) 
				  , IDColumna			 = CONVERT(INT, C.COLUMN_ID)
				  , Columna				 = CONVERT(VARCHAR(MAX), C.NAME)
			      , TipoLlave			 = CONVERT(VARCHAR(MAX), L.TIPOLLAVE) 
			      , NombreLlave			 = CONVERT(VARCHAR(MAX), L.NOMBRELLAVE) 
			      , TablaReferenciaFK	 = CONVERT(VARCHAR(MAX), TR.NAME) 
			      , ColumnaReferenciaFK	 = CONVERT(VARCHAR(MAX), CR.NAME) 
			      , TipoBorradoFK		 = CONVERT(VARCHAR(MAX), F.BORRADO_FK) 
			      , TipoActualizacionFK	 = CONVERT(VARCHAR(MAX), F.ACTUALIZADO_FK) 
			      , Etiqueta			 = CONVERT(VARCHAR(MAX), D.NAME) 
			      , DescripcionLlave	 =  CONVERT(VARCHAR(MAX), D.VALUE) 
			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.TABLES T  
			     ON E.SCHEMA_ID = T.SCHEMA_ID
			    AND T.NAME != ''sysdiagrams'' 
			  INNER JOIN ' + @pBaseDatos + '.SYS.COLUMNS C
			     ON T.OBJECT_ID = C.OBJECT_ID 
			  INNER JOIN (SELECT ESQUEMA	  = K.TABLE_SCHEMA 
			       	 		   , TABLA		  = K.TABLE_NAME 
			       	 		   , TIPOLLAVE	  = K.CONSTRAINT_TYPE 
			       	 		   , COLUMNA	  = U.COLUMN_NAME 
			       	 		   , NOMBRELLAVE = K.CONSTRAINT_NAME 
			       	 		FROM ' + @pBaseDatos + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS K 
			       	 	   INNER JOIN ' + @pBaseDatos + '.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U 
			       	 		  ON K.CONSTRAINT_CATALOG = U.CONSTRAINT_CATALOG 
			       	 		  AND K.CONSTRAINT_SCHEMA = U.CONSTRAINT_SCHEMA 
			       	 		  AND k.CONSTRAINT_NAME   = U.CONSTRAINT_NAME) L 
			     ON L.ESQUEMA = E.NAME
			    AND L.TABLA	  = T.NAME
			    AND L.COLUMNA = C.NAME
			   LEFT JOIN (SELECT FOREIGNKEY			 = F.NAME 
							   , IDESQUEMA			 = F.SCHEMA_ID 
           	       	  		   , IDTABLA			 = F.PARENT_OBJECT_ID 
           	       	  		   , IDCOLUMNA			 = FC.PARENT_COLUMN_ID 
           	       	  		   , IDTABLAREFERENCIA   = F.REFERENCED_OBJECT_ID 
           	       	  		   , IDCOLUMNAREFERENCIA = FC.REFERENCED_COLUMN_ID 
           	       	  		   , BORRADO_FK			 = F.DELETE_REFERENTIAL_ACTION_DESC 
           	       	  		   , ACTUALIZADO_FK		 = F.UPDATE_REFERENTIAL_ACTION_DESC 
			       	  		FROM ' + @pBaseDatos + '.SYS.FOREIGN_KEYS F
			       	  	   INNER JOIN ' + @pBaseDatos + '.SYS.FOREIGN_KEY_COLUMNS FC 
			       	  		  ON F.OBJECT_ID = FC.CONSTRAINT_OBJECT_ID) F
			     ON F.FOREIGNKEY = L.NOMBRELLAVE
		        AND F.IDESQUEMA	 = T.SCHEMA_ID
		        AND F.IDTABLA    = C.OBJECT_ID
		        AND F.IDCOLUMNA  = C.COLUMN_ID 
		       LEFT JOIN  ' + @pBaseDatos + '.SYS.OBJECTS TR
		         ON TR.OBJECT_ID = F.IDTABLAREFERENCIA
		       LEFT JOIN ' + @pBaseDatos + '.SYS.COLUMNS CR
		      	 ON CR.OBJECT_ID = F.IDTABLAREFERENCIA
		        AND CR.COLUMN_ID = F.IDCOLUMNAREFERENCIA							 
		       LEFT JOIN ' + @pBaseDatos + '.SYS.OBJECTS O
		         ON L.NOMBRELLAVE = O.NAME									 
		       LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
		      	 ON D.MAJOR_ID   = O.OBJECT_ID
		        AND D.MINOR_ID   = 0
				AND D.NAME		 NOT LIKE ''MS_Diagram%'' 
		        AND D.CLASS_DESC = ''OBJECT_OR_COLUMN'';'
EXEC (@vSQL); 

SELECT IDEsquema			 
	 , IDTabla			 
	 , Tabla 
	 , IDColumna 
	 , Columna 
	 , TipoLlave 
	 , NombreLlave 
	 , TablaReferenciaFK 
	 , ColumnaReferenciaFK 
	 , TipoBorradoFK 
	 , TipoActualizacionFK 
	 , Etiqueta	
	 , DescripcionLlave 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDTabla   IN (@pTablas)
   AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
 ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;

