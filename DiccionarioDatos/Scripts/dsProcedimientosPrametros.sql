DECLARE @pBaseDatos				VARCHAR(MAX) = 'EjemploDB';
DECLARE @pEtiquetas				VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas				INT = 1;
DECLARE @pProcedimientos INT = 1061578820

-- Documentación de los parámetros de los procedimientos de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	IDEsquema		 INT, 
	Esquema			 VARCHAR(MAX),
	IDProcedimiento	 INT, 
	Procedimiento	 VARCHAR(MAX), 
	IDParametro		 INT, 
	Parametro		 VARCHAR(MAX), 
	TipoDato		 VARCHAR(MAX), 
	TamanioParametro VARCHAR(MAX), 
	EsSalida		 BIT	
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema		 	
										   , Esquema			 		
										   , IDProcedimiento	 				
										   , Procedimiento	 			
										   , IDParametro		 
										   , Parametro		 
										   , TipoDato	 
										   , TamanioParametro 
										   , EsSalida		 
										   ) 
			 SELECT IDEsquema		 = CONVERT(INT, E.SCHEMA_ID)
				  , Esquema			 = CONVERT(VARCHAR(MAX), E.NAME) 
				  , IDProcedimiento	 = CONVERT(INT, O.OBJECT_ID)
				  , Procedimiento	 = CONVERT(VARCHAR(MAX), O.NAME) 
				  , IDParametro		 = CONVERT(INT, P.PARAMETER_ID)
				  , Parametro		 = CONVERT(VARCHAR(MAX), P.NAME)
				  , TipoDato		 = CONVERT(VARCHAR(MAX), TYPE_NAME(P.USER_TYPE_ID))
				  , TamanioParametro = CASE P.MAX_LENGTH WHEN -1 THEN ''MAX'' ELSE CONVERT(VARCHAR(MAX), P.MAX_LENGTH) END
				  , EsSalida		 = P.IS_OUTPUT
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.PROCEDURES O
				 ON E.SCHEMA_ID = O.SCHEMA_ID
				AND O.NAME		NOT LIKE ''%DIAGRAM%''
			   LEFT JOIN ' + @pBaseDatos + '.SYS.PARAMETERS P 
			     ON P.OBJECT_ID = O.OBJECT_ID;'
 
EXEC (@vSQL); 

SELECT IDEsquema		 
	 , Esquema			 
	 , IDProcedimiento	 
	 , Procedimiento	 
	 , IDParametro		 
	 , Parametro		 
	 , TipoDato		 
	 , TamanioParametro 
	 , EsSalida		 
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDProcedimiento IN (@pProcedimientos)
 ORDER BY Esquema, Procedimiento, IDParametro;

DROP TABLE #DiccionarioTemp;

