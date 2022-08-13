--задание 1
CREATE TABLESPACE geo_denormalized_t
DATAFILE '/oracle/u02/oradata/NMartinovichdb/db_geo_denormalized_t.dat'
SIZE 150M
AUTOEXTEND ON NEXT 50M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE USER SB_MBackUp 
IDENTIFIED BY "%PWD%"
DEFAULT TABLESPACE geo_denormalized_t;

GRANT CONNECT,RESOURCE TO SB_MBackUp;
GRANT SELECT ANY TABLE TO SB_MBackUp;

ALTER USER SB_MBackUp QUOTA UNLIMITED ON geo_denormalized_t;

CREATE TABLE SB_MBackUp.geo_denormalized_tab
TABLESPACE geo_denormalized_t
AS  
SELECT pgid.cid
     , pgid.pid
     , pgid.link_type_id
     , pgid.id_type
     , pgid.lev_count
     , pgid.geo_path
     , cnt.country_id
     , cnt.region_desc AS country_name
     , prt.part_desc
     , reg.region_desc
  FROM (  SELECT country_geo_id
               , SUM ( region ) AS region_geo_id
               , SUM ( contenet ) AS contenet_geo_id
            FROM (    SELECT CONNECT_BY_ROOT ( child_geo_id ) AS country_geo_id
                           , parent_geo_id
                           , link_type_id
                           , DECODE ( link_type_id, 2, parent_geo_id ) AS contenet
                           , DECODE ( link_type_id, 3, parent_geo_id ) AS region
                        FROM u_dw_references.w_geo_object_links
                  CONNECT BY PRIOR parent_geo_id = child_geo_id
                  START WITH child_geo_id IN (SELECT DISTINCT geo_id
                                                FROM u_dw_references.cu_countries))
        GROUP BY country_geo_id) geo
       LEFT JOIN u_dw_references.cu_countries cnt
          ON ( geo.country_geo_id = cnt.geo_id )
       LEFT JOIN u_dw_references.cu_geo_regions reg
          ON ( geo.region_geo_id = reg.geo_id )
                 LEFT JOIN u_dw_references.cu_geo_parts prt
          ON ( geo.contenet_geo_id = prt.geo_id )
        RIGHT OUTER JOIN 
        (SELECT child_geo_id,
        LPAD ( ' ', 2 * LEVEL, ' ' ) || child_geo_id AS cid
    , parent_geo_id AS pid
    , link_type_id
    , DECODE ( LEVEL,  1, 'ROOT',  2, 'BRANCH',  'LEAF' ) AS id_type
    , DECODE ( ( SELECT COUNT ( * )
                 FROM u_dw_references.t_geo_object_links a
                 WHERE a.parent_geo_id = b.child_geo_id )
                            , 0, NULL, ( SELECT COUNT ( * )
                            FROM u_dw_references.t_geo_object_links a
                            WHERE a.parent_geo_id = b.child_geo_id ) ) AS lev_count
    , SYS_CONNECT_BY_PATH ( parent_geo_id, ':' ) AS geo_path
             FROM u_dw_references.t_geo_object_links b
       CONNECT BY PRIOR child_geo_id = parent_geo_id
ORDER SIBLINGS BY child_geo_id) pgid
ON geo.country_geo_id=pgid.cid;

SELECT * FROM SB_MBackUp.geo_denormalized_tab;



---задание 2

DROP TABLE DM_EMPLOYEES;
CREATE TABLE DM_EMPLOYEES(
EMPLOYEE_ID NUMBER,
FIRST_NAME VARCHAR(20),
LAST_NAME VARCHAR(20),
PHONE VARCHAR(20),
EMAIL VARCHAR(40), 
STORE_ID NUMBER,
NAME_POSITION VARCHAR(30),
SALARY NUMBER,
position_parent   NUMBER,
position_child    NUMBER
);

INSERT INTO DM_EMPLOYEES VALUES(1, 'IGOR', 'KARPUK', '+375295483190', 'IGOR.KARPUK@MAIL.RU', 4, 'manager', 750, NULL, 1 );
INSERT INTO DM_EMPLOYEES VALUES(2, 'VLADIMIR', 'PASECHKIN', '+375293383112' , 'VLADIMIR.PASECHKIN@MAIL.RU', 2, 'consultant', 650, 1, 10 );
INSERT INTO DM_EMPLOYEES VALUES(3, 'EKATERINA', 'VLASOVA', '+375294561234' , 'EKATERINA.VLASOVA@MAIL.RU' , 2, 'cashier', 650, 10, 100 );
INSERT INTO DM_EMPLOYEES VALUES(4, 'MARIYA', 'EGOROVA', '+375293567321', 'MARIYA.EGOROVA@MAIL.RU', 2, 'cashier', 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(5, 'DARYA', 'MYS', '+375293384298', 'DARYA.MYS@MAIL.RU', 2, 'cashier', 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(6, 'ANDREW', 'POLON', '+375294926830' , 'ANDREW.POLON@MAIL.RU', 2, 'cashier', 650, 10, 100 );
INSERT INTO DM_EMPLOYEES VALUES(7, 'VLADISLAV', 'ULYANOV', '+375291737083', 'VLADISLAV.ULYANOV@MAIL.RU', 2, 'consultant', 650, 1, 10  );
INSERT INTO DM_EMPLOYEES VALUES(8, 'IRINA', 'GORA', '+375295820400', 'IRINA.GORA@MAIL.RU', 2, 'cashier', 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(9, 'VIKTORIA', 'BOBR', '+375293008992', 'VIKTORIA.BOBR@MAIL.RU', 2, 'cashier', 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(10, 'EGOR', 'MIRONOV', '+375293896781', 'EGOR.MIRONOV@MAIL.RU', 2, 'consultant', 650, 1, 10  );


SELECT * FROM DM_EMPLOYEES;

SELECT /*+inline gather_plan_statistics */
    level   
    ,   lpad(' ', 2*(level-1)) || NAME_POSITION  job_title
    ,   first_name || '  ' || last_name as employee_name
    ,   CONNECT_BY_ROOT NAME_POSITION AS root
    ,   SYS_CONNECT_BY_PATH(NAME_POSITION, ':') path
FROM DM_EMPLOYEES 
WHERE CONNECT_BY_ROOT NAME_POSITION='manager'
CONNECT BY NOCYCLE PRIOR position_child = position_parent
START WITH position_parent  IS NULL ;
