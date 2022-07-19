EXPLAIN PLAN FOR
SELECT/*+ USE_HASH(e, d) */ *
    FROM EMP e, DEPT d
        WHERE e.deptno = d.deptno;

SELECT * FROM table (DBMS_XPLAN.DISPLAY);