SELECT blocks 
    from user_segments 
        where segment_name = 'T2';
        
SELECT count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct  from t2;

SET autotrace ON
SELECT * FROM t2 where id = '1';

