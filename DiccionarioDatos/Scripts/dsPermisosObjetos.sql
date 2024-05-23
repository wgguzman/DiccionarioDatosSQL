DECLARE @pBaseDatos	 VARCHAR(MAX) = 'sga_soporte';
DECLARE @pEsquemas	 INT = 1;
DECLARE @pObjetos	 INT = 818974144;

-- Permisos de los objetos.

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
	   IDEsquema			INT 				
	 , IDObjeto				INT 
	 , Objeto				VARCHAR(MAX) 
	 , IDRol				INT 
	 , Rol					VARCHAR(MAX) 
	 , Permisos				VARCHAR(MAX) 
	);
SET @vSQL = 'INSERT INTO #DiccionarioTemp (  IDEsquema 
										   , IDObjeto 
										   , Objeto 
										   , IDRol 
										   , Rol 
										   , Permisos) 
			 SELECT IDEsquema = CONVERT(INT, E.SCHEMA_ID)
				  , IDObjeto  = CONVERT(INT, O.OBJECT_ID)
				  , Objeto	  = CONVERT(VARCHAR(MAX), O.NAME) 
				  , IDRol	  = CONVERT(INT, P.GRANTEE_PRINCIPAL_ID)
				  , Rol		  = CONVERT(VARCHAR(MAX), R.NAME)
				  , Permisos  = CONVERT(VARCHAR(MAX), P.PERMISOS) 
 			   FROM ' + @pBaseDatos + '.SYS.SCHEMAS E
			  INNER JOIN ' + @pBaseDatos + '.SYS.OBJECTS O
				 ON E.SCHEMA_ID = O.SCHEMA_ID
			    AND O.NAME != ''sysdiagrams'' 
			  INNER JOIN (SELECT DISTINCT 
							     CLASS
							   , MAJOR_ID
							   , MINOR_ID
							   , GRANTEE_PRINCIPAL_ID
							   , PERMISOS = STUFF (( SELECT DISTINCT '', '' + D.PERMISSION_NAME  
							   						   FROM ' + @pBaseDatos + '.SYS.DATABASE_PERMISSIONS D
							   						  WHERE D.CLASS					= M.CLASS  
							   						    AND D.MAJOR_ID				= M.MAJOR_ID
							   						    AND D.MINOR_ID				= M.MINOR_ID
							   						    AND D.GRANTEE_PRINCIPAL_ID	= M.GRANTEE_PRINCIPAL_ID
							   						    FOR XML PATH('''')
							   						   ), 1, 1, '''')
						    FROM ' + @pBaseDatos + '.SYS.DATABASE_PERMISSIONS M ) P
				 ON O.OBJECT_ID = P.MAJOR_ID
			  INNER JOIN ' + @pBaseDatos + '.SYS.DATABASE_PRINCIPALS R
				 ON P.GRANTEE_PRINCIPAL_ID = R.PRINCIPAL_ID;'
EXEC (@vSQL); 

SELECT IDEsquema 
	 , IDObjeto 
	 , Objeto 
	 , IDRol 
	 , Rol 
	 , Permisos
  FROM #DiccionarioTemp 
 WHERE IDEsquema IN (@pEsquemas)
   AND IDObjeto  IN (@pObjetos)
 ORDER BY IDObjeto, Rol;

DROP TABLE #DiccionarioTemp;
