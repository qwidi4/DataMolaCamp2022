create table t 
  ( a int, 
    b varchar2(4000) default rpad('*',4000,'*'), 
    c varchar2(4000) default rpad('*',4000,'*') 
   );
   
insert into t (a) values ( 1); 
insert into t (a) values ( 2); 
insert into t (a) values ( 3); 
commit; 
delete from t where a = 2 ; 
commit; 
insert into t (a) values ( 4); 
commit; 

SELECT a FROM t;

DROP TABLE t;