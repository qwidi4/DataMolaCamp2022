EXPLAIN PLAN FOR
SELECT *
    FROM EMP
    where deptno in 
        (SELECT deptno FROM DEPT);
SELECT * FROM table (DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR       
SELECT *
    FROM DEPT
    where deptno IN 
        (SELECT deptno FROM EMP);
SELECT * FROM table (DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR       
SELECT *
    FROM DEPT
    where deptno IN 
        (SELECT /*+MERGE_SJ*/ deptno FROM EMP);
SELECT * FROM table (DBMS_XPLAN.DISPLAY);