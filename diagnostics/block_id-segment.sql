SELECT OWNER, SEGMENT_NAME
  FROM DBA_EXTENTS
 WHERE FILE_ID = &FILE_ID
   AND &BLOCK_ID BETWEEN BLOCK_ID AND BLOCK_ID + BLOCKS
   ;
