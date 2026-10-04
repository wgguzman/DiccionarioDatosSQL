DECLARE @pBaseDatos				VARCHAR(MAX) = 'SGA_Soporte';
DECLARE @pEtiquetas				VARCHAR(MAX) = 'MS_Description';
DECLARE @pEsquemas				INT = 1;
DECLARE @pTablas				INT = 60071500 --, 1701581100, 1573580644;;

-- Documentación de los indices de las tablas de una base de datos. 

DECLARE @vSQL VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #DiccionarioTemp;

CREATE TABLE #DiccionarioTemp(
       IDEsquema         INT 
     , IDTabla           INT 
     , Tabla             VARCHAR(MAX) 
     , IDColumna         INT 
     , Columna           VARCHAR(MAX) 
     , IDIndice          INT 
     , Indice            VARCHAR(MAX) 
     , TipoIndice        VARCHAR(MAX) 
     , Inactivo          BIT 
     , Unico             BIT
     , Etiqueta          VARCHAR(MAX) 
     , DescripcionIndice VARCHAR(MAX)
);

SET @vSQL = '
INSERT INTO #DiccionarioTemp (
       IDEsquema 
     , IDTabla 
     , Tabla 
     , IDColumna 
     , Columna 
     , IDIndice
     , Indice 
     , TipoIndice 
     , Inactivo
     , Unico
     , Etiqueta 
     , DescripcionIndice)
SELECT 
      E.schema_id
    , T.object_id
    , T.name
    , C.column_id
    , C.name
    , I.index_id
    , I.name
    , CASE  
          WHEN I.is_primary_key = 1        THEN ''PRIMARY KEY''
          WHEN I.is_unique_constraint = 1  THEN ''UNIQUE''
          ELSE ''INDEX''
      END
    , I.is_disabled
    , I.is_unique

    , COALESCE(DIdx.name, DKey.name)
    , COALESCE(CONVERT(VARCHAR(MAX), DIdx.value),
               CONVERT(VARCHAR(MAX), DKey.value))

FROM ' + @pBaseDatos + '.sys.schemas E
INNER JOIN ' + @pBaseDatos + '.sys.tables T
        ON E.schema_id = T.schema_id
INNER JOIN ' + @pBaseDatos + '.sys.columns C
        ON C.object_id = T.object_id
INNER JOIN ' + @pBaseDatos + '.sys.indexes I
        ON I.object_id = T.object_id
       AND I.index_id > 0
       AND I.is_hypothetical = 0
       AND I.is_primary_key = 0
INNER JOIN ' + @pBaseDatos + '.sys.index_columns IC
        ON IC.object_id = I.object_id
       AND IC.index_id  = I.index_id
       AND IC.column_id = C.column_id

-- Comentario del índice
LEFT JOIN ' + @pBaseDatos + '.sys.extended_properties DIdx
       ON DIdx.major_id   = I.object_id
      AND DIdx.minor_id   = I.index_id
      AND DIdx.class_desc = ''INDEX''
      AND DIdx.name       = ''' + @pEtiquetas + '''

-- Comentario del UNIQUE KEY (constraint)
LEFT JOIN ' + @pBaseDatos + '.sys.key_constraints KC
       ON KC.parent_object_id = T.object_id
      AND KC.unique_index_id  = I.index_id
LEFT JOIN ' + @pBaseDatos + '.sys.extended_properties DKey
       ON DKey.major_id   = KC.object_id
      AND DKey.minor_id   = 0
      AND DKey.class_desc = ''OBJECT_OR_COLUMN''
      AND DKey.name       = ''' + @pEtiquetas + '''';

EXEC(@vSQL);

SELECT *
FROM #DiccionarioTemp
WHERE IDEsquema = @pEsquemas
  AND IDTabla   = @pTablas
ORDER BY IDColumna, Etiqueta;

DROP TABLE #DiccionarioTemp;
