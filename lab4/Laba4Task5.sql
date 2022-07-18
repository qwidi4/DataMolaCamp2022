create table employees (  
  empno    number(4,0),  
  ename    varchar2(10),  
  job      varchar2(9),  
  mgr      number(4,0),  
  hiredate date,  
  sal      number(7,2),  
  comm     number(7,2),  
  deptno   number(2,0),  
  constraint pk_emp primary key (empno)
);
commit;

INSERT INTO employees  VALUES (7839, 'KING',   'PRESIDENT', null, '17-11-1981',     5000, null, 10);
INSERT INTO employees  VALUES (7698, 'BLAKE',  'MANAGER',   7839, '01-05-1981',     2850, null, 30);
INSERT INTO employees  VALUES (7782, 'CLARK',  'MANAGER',   7839, '09-06-1981',     2450, null, 10);
INSERT INTO employees  VALUES (7566, 'JONES',  'MANAGER',   7839, '02-04-1981',     2975, null, 20);
INSERT INTO employees  VALUES (7788, 'SCOTT',  'ANALYST',   7566, '19-04-1987',     3000, null, 20);
INSERT INTO employees  VALUES (7902, 'FORD',   'ANALYST',   7566, '03-12-1981',     3000, null, 20);
INSERT INTO employees  VALUES (7369, 'SMITH',  'CLERK',     7902, '17-12-1980',      800, null, 20);
INSERT INTO employees  VALUES (7499, 'ALLEN',  'SALESMAN',  7698, '20-02-1981',     1600,  300, 30);
INSERT INTO employees  VALUES (7521, 'WARD',   'SALESMAN',  7698, '22-02-1981',     1250,  500, 30);
INSERT INTO employees  VALUES (7654, 'MARTIN', 'SALESMAN',  7698, '28-09-1981',     1250, 1400, 30);
INSERT INTO employees  VALUES (7844, 'TURNER', 'SALESMAN',  7698, '08-09-1981',     1500,    0, 30);
INSERT INTO employees  VALUES (7876, 'ADAMS',  'CLERK',     7788, '23-05-1987',     1100, null, 20);
INSERT INTO employees  VALUES (7900, 'JAMES',  'CLERK',     7698, '03-12-1981',      950, null, 30);
INSERT INTO employees  VALUES (7934, 'MILLER', 'CLERK',     7782, '23-01-1982',     1300, null, 10);
commit;


CREATE INDEX idx_emp01 ON employees
      ( empno, ename, job );

SELECT blocks 
    from user_segments 
        where segment_name = 'EMPLOYEES';


SELECT count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct 
    from employees;  
    
set autotrace on;
SELECT /*+INDEX_SS(emp idx_emp01)*/ emp.* FROM employees emp where ename = 'SCOTT';

set autotrace on  
SELECT emp.* FROM employees emp WHERE ename = 'SCOTT';