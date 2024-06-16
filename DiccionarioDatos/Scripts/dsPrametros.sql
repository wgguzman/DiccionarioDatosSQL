﻿DECLARE @pBaseDatos	VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEtiquetas	VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas	INT = 1;
DECLARE @pObjetos INT = 2015502409

-- Parámetros de los procedimientos y funciones de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema		INT 
	 , Esquema			VARCHAR(MAX) 
	 , IDObjeto			INT 
	 , Objeto			VARCHAR(MAX) 
	 , TipoObjeto		VARCHAR(MAX) 
	 , IDParametro		INT 
	 , Parametro		VARCHAR(MAX) 
	 , TipoDato			VARCHAR(MAX) 
	 , TamanioParametro VARCHAR(MAX) 
	 , EsSalida			BIT
	 , Descripcion		VARCHAR(MAX)				
	 , Etiqueta			VARCHAR(MAX)	
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , Esquema 
										   , IDObjeto 
										   , Objeto 	 			
										   , TipoObjeto 
										   , IDParametro 
										   , Parametro 
										   , TipoDato 
										   , TamanioParametro 
										   , EsSalida
										   , Descripcion	
										   , Etiqueta 										   
										   ) 
			 SELECT IDEsquema		 = CONVERT(INT, E.SCHEMA_ID)
				  , Esquema			 = CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDObjeto		 = CONVERT(INT, O.OBJECT_ID)
				  , Objeto			 = CONVERT(VARCHAR(MAX), O.NAME) 
				  , TipoObjeto	     = CONVERT(VARCHAR(MAX), O.TYPE) 
				  , IDParametro		 = CONVERT(INT, P.PARAMETER_ID)
				  , Parametro		 = CASE P.PARAMETER_ID WHEN 0 THEN ''Return'' ELSE CONVERT(VARCHAR(MAX), P.NAME) END
				  , TipoDato		 = CONVERT(VARCHAR(MAX), TYPE_NAME(P.USER_TYPE_ID))
				  , TamanioParametro = CASE P.MAX_LENGTH WHEN -1 THEN ''MAX'' ELSE CONVERT(VARCHAR(MAX), P.MAX_LENGTH) END
				  , EsSalida		 = P.IS_OUTPUT 
				  , Descripcion		 = CONVERT(VARCHAR(MAX), D.VALUE) 
				  , Etiqueta		 = CONVERT(VARCHAR(MAX), D.NAME) 
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.OBJECTS O
				 ON E.SCHEMA_ID = o.SCHEMA_ID
				AND O.TYPE IN (''P'', ''AF'', ''FN'', ''FS'', ''FT'', ''IF'', ''TF'')
				AND O.NAME NOT LIKE ''%DIAGRAM%''
			   LEFT JOIN ' + @pBaseDatos + '.SYS.PARAMETERS P
			     ON P.OBJECT_ID = O.OBJECT_ID
			   LEFT JOIN ' + @pBaseDatos + '.SYS.EXTENDED_PROPERTIES D 
			     ON D.MAJOR_ID   = O.OBJECT_ID
			    AND D.MINOR_ID   = P.PARAMETER_ID
				AND D.NAME		 NOT LIKE ''MS_Diagram%'';'
 EXEC (@vSQL); 

SELECT IDEsquema 
	 , Esquema 
	 , IDObjeto 
	 , Objeto 
	 , TipoObjeto 
	 , IDParametro 
	 , Parametro 
	 , TipoDato 
	 , TamanioParametro 
	 , EsSalida 
	 , Descripcion	
	 , Etiqueta 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDObjeto  IN (@pObjetos)
 ORDER BY Esquema, Objeto, IDParametro;

DROP TABLE #DiccionarioTemp;