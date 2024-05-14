select trig.object_id, 
    trig.name as trigger_name,
    case when is_instead_of_trigger = 1 then 'Instead of'
        else 'After' end as [activation],
    (case when objectproperty(trig.object_id, 'ExecIsUpdateTrigger') = 1 
            then 'Update ' else '' end
    + case when objectproperty(trig.object_id, 'ExecIsDeleteTrigger') = 1 
            then 'Delete ' else '' end
    + case when objectproperty(trig.object_id, 'ExecIsInsertTrigger') = 1 
            then 'Insert ' else '' end
    ) as [event],
    case when trig.[type] = 'TA' then 'Assembly (CLR) trigger'
        when trig.[type] = 'TR' then 'SQL trigger' 
        else '' end as [type],
    case when is_disabled = 1 then 'Disabled'
        else 'Active' end as [status],
    object_definition(trig.object_id) as [definition]
from SGA_SOPORTE.sys.triggers trig
    inner join SGA_SOPORTE.sys.objects tab
        on trig.parent_id = tab.object_id
order by schema_name(tab.schema_id) + '.' + tab.name, trig.name;