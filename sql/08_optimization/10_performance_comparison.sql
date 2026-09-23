-- PHASE 8 - STEP 8.10 - PERFORMANCE COMPARISON
-- Values below are captured from the live PostgreSQL EXPLAIN outputs.

SELECT * FROM (VALUES
 ('W01', 'fraud filtering', '19,752.361 ms; Seq Scan; read 1,147,458', '6.192 ms; Index Only Scan; hit 13,638/read 81', '-19,746.169 ms; KEEP partial composite'),
 ('W02', 'TransactionDT range', '20,130.136 ms; Seq Scan; read 1,147,458', '692.512 ms; Bitmap Heap/Index Scan; hit 3/read 33,141', '-19,437.624 ms; KEEP TransactionDT index'),
 ('W03', 'amount threshold', '20,123.351 ms; Seq Scan; read 1,147,458', '20,600.453 ms; Seq Scan; hit 42/read 1,147,416', '+477.102 ms; NO MATERIAL BENEFIT'),
 ('W04', 'fact-to-identity join', '21,633.889 ms; Hash Join; read 1,166,917', '21,323.775 ms; Hash Join; read 1,166,917', '-310.114 ms; NO MATERIAL BENEFIT fact identity index'),
 ('W05', 'fraud plus time', '21,074.952 ms; Seq Scan; read 1,147,458', '388.803 ms; Index Scan; hit 202/read 2,434', '-20,686.149 ms; KEEP partial composite'),
 ('W06', 'fraud plus identity', '20,864.217 ms; Seq Scan; read 1,147,458', '2,652.829 ms; Index Scan; hit 3,494/read 15,738', '-18,211.388 ms; KEEP partial fraud index')
) AS comparison(workload_id, workload, before_evidence, after_evidence, decision);
