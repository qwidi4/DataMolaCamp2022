create cluster hash_emp_dept_cluster
( deptno NUMBER( 2 ) )
 hashkeys 100
 size 500
 STORAGE( INITIAL 10K NEXT 5K );

CREATE TABLE dept
  (
    deptno NUMBER( 2 ) PRIMARY KEY, dname  VARCHAR2( 14 ), loc    VARCHAR2( 13 ))
  cluster hash_emp_dept_cluster ( deptno ) ;
 
 CREATE TABLE emp
  (
    empno NUMBER PRIMARY KEY, ename VARCHAR2( 10 ), job   VARCHAR2( 9 )
  , mgr   NUMBER, hiredate DATE, sal    NUMBER, comm   NUMBER
  , deptno NUMBER( 2 ) REFERENCES dept( deptno ) )
  cluster hash_emp_dept_cluster ( deptno ) ;
commit;

INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO dept VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');

INSERT INTO emp VALUES (7839, 'KING',   'PRESIDENT', null, '17-11-1981',     5000, null, 10);
INSERT INTO emp VALUES (7698, 'BLAKE',  'MANAGER',   7839, '01-05-1981',     2850, null, 30);
INSERT INTO emp VALUES (7782, 'CLARK',  'MANAGER',   7839, '09-06-1981',     2450, null, 10);
INSERT INTO emp VALUES (7566, 'JONES',  'MANAGER',   7839, '02-04-1981',     2975, null, 20);
INSERT INTO emp VALUES (7788, 'SCOTT',  'ANALYST',   7566, '19-04-1987',     3000, null, 20);
INSERT INTO emp VALUES (7902, 'FORD',   'ANALYST',   7566, '03-12-1981',     3000, null, 20);
INSERT INTO emp VALUES (7369, 'SMITH',  'CLERK',     7902, '17-12-1980',     800, null, 20);
INSERT INTO emp VALUES (7499, 'ALLEN',  'SALESMAN',  7698, '20-02-1981',     1600,  300, 30);
INSERT INTO emp VALUES (7521, 'WARD',   'SALESMAN',  7698, '22-02-1981',     1250,  500, 30);
INSERT INTO emp VALUES (7654, 'MARTIN', 'SALESMAN',  7698, '28-09-1981',     1250, 1400, 30);
INSERT INTO emp VALUES (7844, 'TURNER', 'SALESMAN',  7698, '08-09-1981',     1500,    0, 30);
INSERT INTO emp VALUES (7876, 'ADAMS',  'CLERK',     7788, '23-05-1987',     1100, null, 20);
INSERT INTO emp VALUES (7900, 'JAMES',  'CLERK',     7698, '03-12-1981',     950, null, 30);
INSERT INTO emp VALUES (7934, 'MILLER', 'CLERK',     7782, '23-01-1982',     1300, null, 10);
commit;

SELECT *
   FROM(
     SELECT dept_blk, emp_blk, 
    CASE 
     WHEN dept_blk <> emp_blk THEN '*' 
    END flag, deptno
       FROM(
         SELECT dbms_rowid.rowid_block_number( dept.rowid ) dept_blk, dbms_rowid.rowid_block_number( emp.rowid ) emp_blk, dept.deptno
           FROM emp , dept
          WHERE emp.deptno = dept.deptno))
ORDER BY deptno;

EXPLAIN PLAN FOR
SELECT * FROM(
     SELECT dept_blk, emp_blk, 
            CASE 
			 WHEN dept_blk <> emp_blk THEN '*' 
		    END flag,
		    deptno
       FROM(
         SELECT dbms_rowid.rowid_block_number( dept.rowid ) dept_blk, dbms_rowid.rowid_block_number( emp.rowid ) emp_blk, dept.deptno
           FROM emp , dept
          WHERE emp.deptno = dept.deptno))
ORDER BY deptno;

SELECT * FROM table (DBMS_XPLAN.DISPLAY(format => 'ADVANCED'));

DROP TABLE emp;
DROP TABLE DEPT;
DROP CLUSTER hash_emp_dept_cluster;
commit;