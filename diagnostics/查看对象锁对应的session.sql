select b.OBJECT_NAME, a.*
  from v$locked_object a, all_objects b
 where a.OBJECT_ID = b.OBJECT_ID
   and b.OBJECT_NAME like 'WF%'
