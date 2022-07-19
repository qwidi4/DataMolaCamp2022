SELECT *
    FROM EMP e
    LEFT OUTER JOIN 
    DEPT d
        on e.deptno = d.deptno;




SELECT *
    FROM EMP e
    RIGHT OUTER JOIN 
    DEPT d
        on e.deptno = d.deptno;


