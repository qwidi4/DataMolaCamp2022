CREATE cluster emp_dept_cluster( deptno NUMBER( 2 ) ) 
    SIZE 1024  
    STORAGE( INITIAL 100K NEXT 50K );
commit;
    
CREATE INDEX idxcl_emp_dept on cluster emp_dept_cluster;
commit;

CREATE TABLE dept 
  (deptno NUMBER( 2 ) PRIMARY KEY, dname  VARCHAR2( 14 ),
  loc    VARCHAR2( 13 )) 
  cluster emp_dept_cluster ( deptno );
commit;

CREATE TABLE emp
  (empno NUMBER PRIMARY KEY, ename VARCHAR2( 10 ),
  job   VARCHAR2( 9 ), mgr   NUMBER, hiredate DATE,
  sal    NUMBER, comm   NUMBER, deptno NUMBER( 2 ) REFERENCES dept( deptno ))
  cluster emp_dept_cluster ( deptno ) ;
commit;

INSERT INTO dept VALUES (10,'ACCOUNTING','NEW YORK'); 
INSERT INTO dept VALUES (20,'RESEARCH','DALLAS'); 
INSERT INTO dept VALUES (30,'SALES','CHICAGO');  
INSERT INTO dept VALUES (40,'OPERATIONS','BOSTON');

INSERT INTO EMP VALUES (7369,'SMITH','CLERK',7902,'1980-12-17',800,NULL,20); 
INSERT INTO EMP VALUES (7499,'ALLEN','SALESMAN',7698,'1981-02-20',1600,300,30);
INSERT INTO EMP VALUES (7521,'WARD','SALESMAN',7698,'1981-02-22',1250,500,30); 
INSERT INTO EMP VALUES (7566,'JONES','MANAGER',7839,'1981-04-02',2975,NULL,20); 
INSERT INTO EMP VALUES (7654,'MARTIN','SALESMAN',7698,'1981-09-28',1250,1400,30); 
INSERT INTO EMP VALUES (7698,'BLAKE','MANAGER',7839,'1981-05-01',2850,NULL,30); 
INSERT INTO EMP VALUES (7782,'CLARK','MANAGER',7839,'1981-06-09',2450,NULL,10); 
INSERT INTO EMP VALUES (7788,'SCOTT','ANALYST',7566,'1987-07-13',3000,NULL,20); 
INSERT INTO EMP VALUES (7839,'KING','PRESIDENT',NULL,'1981-11-07',5000,NULL,10); 
INSERT INTO EMP VALUES (7844,'TURNER','SALESMAN',7698,'1981-09-08',1500,0,30); 
INSERT INTO EMP VALUES (7876,'ADAMS','CLERK',7788,'1987-07-13',1100,NULL,20); 
INSERT INTO EMP VALUES (7900,'JAMES','CLERK',7698,'1981-12-03',950,NULL,30); 
INSERT INTO EMP VALUES (7902,'FORD','ANALYST',7566,'1981-12-03',3000,NULL,20); 
INSERT INTO EMP VALUES (7934,'MILLER','CLERK',7782,'1982-01-23',1300,NULL,10);
commit;

EXPLAIN PLAN FOR
SELECT * FROM(
     SELECT dept_blk, emp_blk, 
            CASE 
            WHEN dept_blk <> emp_blk THEN '*' 
		    END flag,
		    deptno
       FROM
      ( SELECT dbms_rowid.rowid_block_number( dept.rowid ) dept_blk, dbms_rowid.rowid_block_number( emp.rowid ) emp_blk, dept.deptno
          FROM emp , dept
          WHERE emp.deptno = dept.deptno )
              )
ORDER BY deptno;

SELECT * FROM table (DBMS_XPLAN.DISPLAY(format => 'ADVANCED'));



