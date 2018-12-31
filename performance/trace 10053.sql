alter session set events '10053 trace name context forever, level 1';

SELECT *
  FROM PO.RCV_TRANSACTIONS_INTERFACE RTI
 WHERE RTI.PROCESSING_STATUS_CODE = 'RUNNING'
;

exit;

