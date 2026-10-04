DECLARE @pBaseDatos              VARCHAR(MAX) = 'SGA_Soporte';
DECLARE @pEtiquetas              VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas               INT = 1;
DECLARE @pTablas                 INT = 60071500;

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
      IDEsquema              INT 
    , IDTabla                INT
    , Tabla                  VARCHAR(MAX) 
    , IDColumna              INT 
    , Columna                VARCHAR(MAX) 
    , TipoLlave              VARCHAR(MAX) 
    , NombreLlave            VARCHAR(MAX) 
    , TablaReferenciaFK      VARCHAR(MAX) 
    , ColumnaReferenciaFK    VARCHAR(MAX) 
    , TipoBorradoFK          VARCHAR(MAX) 
    , TipoActualizacionFK    VARCHAR(MAX) 
    , Etiqueta               VARCHAR(MAX) 
    , DescripcionLlave       VARCHAR(MAX)
    , FormulaCheck           VARCHAR(MAX)  
);

SET @vSQL = '
INSERT INTO #DiccionarioTemp (
      IDEsquema 
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
    , FormulaCheck
)
SELECT 
      IDEsquema             = CONVERT(INT, E.SCHEMA_ID)
    , IDTabla               = CONVERT(INT, T.OBJECT_ID)
    , Tabla                 = CONVERT(VARCHAR(MAX), T.NAME)
    , IDColumna             = CONVERT(INT, C.COLUMN_ID)
    , Columna               = CONVERT(VARCHAR(MAX), C.NAME)
    , TipoLlave             = CONVERT(VARCHAR(MAX), L.TIPOLLAVE)
    , NombreLlave           = CONVERT(VARCHAR(MAX), L.NOMBRELLAVE)
    , TablaReferenciaFK     = CONVERT(VARCHAR(MAX), TR.NAME)
    , ColumnaReferenciaFK   = CONVERT(VARCHAR(MAX), CR.NAME)
    , TipoBorradoFK         = CONVERT(VARCHAR(MAX), F.BORRADO_FK)
    , TipoActualizacionFK   = CONVERT(VARCHAR(MAX), F.ACTUALIZADO_FK)
    , Etiqueta              = CONVERT(VARCHAR(MAX), D.NAME)
    , DescripcionLlave      = CONVERT(VARCHAR(MAX), D.VALUE)
    , FormulaCheck          = CONVERT(VARCHAR(MAX), CHK.definition)   -- CHECK FORMULA
FROM ' + @pBaseDatos + '.sys.schemas E
INNER JOIN ' + @pBaseDatos + '.sys.tables T  
        ON E.schema_id = T.schema_id
       AND T.name != ''sysdiagrams''
INNER JOIN ' + @pBaseDatos + '.sys.columns C
        ON T.object_id = C.object_id
LEFT JOIN (
        SELECT 
              ESQUEMA        = K.table_schema
            , TABLA          = K.table_name
            , TIPOLLAVE      = K.constraint_type
            , COLUMNA        = U.column_name
            , NOMBRELLAVE    = K.constraint_name
        FROM ' + @pBaseDatos + '.INFORMATION_SCHEMA.table_constraints K
        INNER JOIN ' + @pBaseDatos + '.INFORMATION_SCHEMA.constraint_column_usage U
                ON K.constraint_catalog = U.constraint_catalog
               AND K.constraint_schema  = U.constraint_schema
               AND K.constraint_name    = U.constraint_name
) L
        ON L.ESQUEMA = E.name
       AND L.TABLA   = T.name
       AND L.COLUMNA = C.name
LEFT JOIN (
        SELECT 
              FOREIGNKEY             = F.name
            , IDESQUEMA             = F.schema_id
            , IDTABLA               = F.parent_object_id
            , IDCOLUMNA             = FC.parent_column_id
            , IDTABLAREFERENCIA     = F.referenced_object_id
            , IDCOLUMNAREFERENCIA   = FC.referenced_column_id
            , BORRADO_FK            = F.delete_referential_action_desc
            , ACTUALIZADO_FK        = F.update_referential_action_desc
        FROM ' + @pBaseDatos + '.sys.foreign_keys F
        INNER JOIN ' + @pBaseDatos + '.sys.foreign_key_columns FC
                ON F.object_id = FC.constraint_object_id
) F
        ON F.FOREIGNKEY = L.NOMBRELLAVE
       AND F.IDESQUEMA = T.schema_id
       AND F.IDTABLA   = C.object_id
       AND F.IDCOLUMNA = C.column_id
LEFT JOIN ' + @pBaseDatos + '.sys.objects TR
        ON TR.object_id = F.IDTABLAREFERENCIA
LEFT JOIN ' + @pBaseDatos + '.sys.columns CR
        ON CR.object_id = F.IDTABLAREFERENCIA
       AND CR.column_id = F.IDCOLUMNAREFERENCIA
LEFT JOIN ' + @pBaseDatos + '.sys.objects O
        ON L.NOMBRELLAVE = O.name
LEFT JOIN ' + @pBaseDatos + '.sys.extended_properties D
        ON D.major_id = O.object_id
       AND D.minor_id = 0
       AND D.name NOT LIKE ''MS_Diagram%''
       AND D.class_desc = ''OBJECT_OR_COLUMN''
LEFT JOIN ' + @pBaseDatos + '.sys.check_constraints CHK
        ON CHK.parent_object_id = T.object_id
       AND CHK.name = L.NOMBRELLAVE   -- CHECK asociado al constraint
';

EXEC (@vSQL);

SELECT 
      IDEsquema          
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
    , FormulaCheck
FROM #DiccionarioTemp 
WHERE IDEsquema IN (@pEsquemas)
  AND IDTabla   IN (@pTablas)
  AND (ISNULL(Etiqueta, '') = '' OR Etiqueta IN (@pEtiquetas))
ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;


