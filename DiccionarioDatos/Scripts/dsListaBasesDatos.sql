-- Lista las bases de datos de un server.

-- Lista Bases de datos del server.
SELECT IDBaseDatos = DB.DATABASE_ID
	 , BaseDatos   = DB.NAME
  FROM MASTER.SYS.DATABASES DB
 WHERE DB.NAME NOT IN ('master', 'tempdb', 'model', 'msdb')
 ORDER BY DB.NAME;
