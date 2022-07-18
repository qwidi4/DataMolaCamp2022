CREATE TABLE t2 AS
    SELECT TRUNC( rownum / 100 ) id, rpad( rownum,100 ) t_pad
        FROM dual
        CONNECT BY rownum < 100000;
        
CREATE INDEX t2_ind_id ON t2 (id);

CREATE TABLE t1 AS
    SELECT MOD( rownum, 100 ) id, rpad( rownum,100 ) t_pad
        FROM dual
        CONNECT BY rownum < 100000;
        
CREATE INDEX t1_idx1 ON t1 ( id );

exec dbms_stats.gather_table_stats(user, 't1', method_opt=>'for all columns size 1', cascade=>true);
exec dbms_stats.gather_table_stats(user, 't2', method_opt=>'for all columns size 1', cascade=>true);

select 
    t.table_name||'.'||i.index_name idx_name,
    i.clustering_factor,
    t.blocks,
    t.num_rows
        from user_indexes i, user_tables t
            where i.table_name=t.table_name
                and t.table_name in ('T1', 'T2');
