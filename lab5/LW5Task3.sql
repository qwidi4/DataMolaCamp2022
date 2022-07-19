
EXPLAIN PLAN FOR
SELECT/*+ USE_MERGE(e, d) */ *
    FROM EMP e, DEPT d
        WHERE e.deptno = d.deptno;

SELECT * FROM table (DBMS_XPLAN.DISPLAY);