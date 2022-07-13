DROP TABLE t;
commit;

CREATE TABLE t (
	x INT PRIMARY KEY,
	y CLOB,
	z BLOB
	) SEGMENT CREATION DEFERRED;
commit;

select segment_name, segment_type from user_segments; 

SELECT DBMS_METADATA.GET_DDL('TABLE','T') FROM dual;

DROP TABLE T;
commit;