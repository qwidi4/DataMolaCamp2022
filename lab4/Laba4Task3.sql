                
CREATE UNIQUE INDEX udx_t1 ON t1( t_pad );
SELECT blocks 
    from user_segments 
        where segment_name = 'T1';
        
SELECT count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct  from t1;

SET autotrace ON;

SELECT * FROM t1 where t_pad = '1'   
                
