SELECT * FROM dba_tablespaces

CREATE USER SA_CUSTOMERS
  IDENTIFIED BY "%PWD%"
    DEFAULT TABLESPACE TS_SA_CUSTOMER_DATA_01; 
GRANT CONNECT,CREATE VIEW,RESOURCE TO SA_CUSTOMERS;

CREATE USER DW_CL
  IDENTIFIED BY "%PWD%"
    DEFAULT TABLESPACE ts_dw_cl;  
GRANT CONNECT,CREATE VIEW,RESOURCE TO DW_CL;



DROP TABLE SA_CUSTOMERS
CREATE TABLE SA_CUSTOMERS
(
    customer_id   NUMBER,
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(50 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    age           NUMBER(3) NOT NULL)
TABLESPACE TS_SA_CUSTOMER_DATA_01;

CREATE USER U_STORE
  IDENTIFIED BY "%PWD%"
    DEFAULT TABLESPACE TS_SA_DIM_STORE_01; 
GRANT CONNECT,CREATE VIEW,RESOURCE TO U_STORE;

DROP TABLE SA_STORE
CREATE TABLE SA_STORE 
(
    STORE_ID          NUMBER,
    STORE_PHONE       VARCHAR2(40 BYTE) NOT NULL,
    STORE_NAME        VARCHAR2(50 BYTE) NOT NULL)
TABLESPACE TS_SA_DIM_STORE_01;

CREATE USER U_PRODUCT
  IDENTIFIED BY "%PWD%"
    DEFAULT TABLESPACE TS_SA_DIM_PROD_01;  
GRANT CONNECT,CREATE VIEW,RESOURCE TO U_PRODUCT;

CREATE TABLE SA_PRODUCT 
( 
    PRODUCT_ID        NUMBER,
    PRODUCT_NAME      VARCHAR2(40 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL)
TABLESPACE TS_SA_DIM_PROD_01;



drop TABLE DW_CL_CUSTOMERS_DATA ;
CREATE TABLE DW_CL_CUSTOMERS_DATA 
(
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(50 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    age           NUMBER(3) NOT NULL)
TABLESPACE ts_DW_CL;

drop TABLE DW_CL_STORE_DATA  ;
CREATE TABLE DW_CL_STORE_DATA 
(
    STORE_PHONE       VARCHAR2(40 BYTE) NOT NULL,
    STORE_NAME        VARCHAR2(50 BYTE) NOT NULL,
    INSERT_DATE       DATE NOT NULL)
TABLESPACE ts_DW_CL;

DROP TABLE DW_CL_PRODUCT_DATA;
CREATE TABLE DW_CL_PRODUCT_DATA 
(
    PRODUCT_NAME      VARCHAR2(40 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL)
TABLESPACE ts_DW_CL;



-----------------------------------------------
DROP PACKAGE pkg_etl_customers_cl
CREATE OR REPLACE PACKAGE pkg_etl_customers_cl
AS  
   PROCEDURE load_CLEAN_CUSTOMER;
END pkg_etl_customers_cl;


CREATE OR REPLACE PACKAGE body pkg_etl_customers_cl
AS  
  PROCEDURE load_CLEAN_CUSTOMER
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT FIRST_NAME
                       , LAST_NAME
                       , EMAIL
                       , PHONE
                       , AGE
           FROM sa_customers.TS_SA_CUSTOMER_DATA_01
           WHERE FIRST_NAME IS NOT NULL 
           AND EMAIL IS NOT NULL
           AND PHONE IS NOT NULL
           AND AGE IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO ts_DW_CL.DW_CL_CUSTOMERS_DATA( 
                        FIRST_NAME
                       , LAST_NAME
                       , EMAIL
                       , PHONE
                       , AGE)
              VALUES ( i.FIRST_NAME
                     , i.LAST_NAME
                     , i.EMAIL
                     , i.PHONE
                     , i.age);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_CUSTOMER;
END pkg_etl_customers_cl;
---------------------------------------

CREATE OR REPLACE PACKAGE pkg_etl_store_cl
AS  
   PROCEDURE load_CLEAN_STORE;
END pkg_etl_store_cl;


CREATE OR REPLACE PACKAGE body pkg_etl_store_cl
AS  
  PROCEDURE load_CLEAN_STORE
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT STORE_PHONE,
                         STORE_NAME
           FROM sa_store.TS_SA_DIM_STORE_01
           WHERE STORE_PHONE IS NOT NULL 
           AND STORE_NAME IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO ts_DW_CL.DW_CL_STORE_DATA( 
                        STORE_PHONE,
                         STORE_NAME)
              VALUES ( i.STORE_PHONE
                     , i.STORE_NAME);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_STORE;
END pkg_etl_store_cl;
--------------------------------------------

CREATE OR REPLACE PACKAGE pkg_etl_products_cl
AS  
   PROCEDURE load_CLEAN_product;
END pkg_etl_products_cl;

CREATE OR REPLACE PACKAGE BODY pkg_etl_products_cl
AS PROCEDURE load_CLEAN_product
   AS
      CURSOR c_v
      IS
         SELECT DISTINCT product_NAME
                       , COLOR
                       , PRICE
           FROM SA_PRODUCT.TS_SA_DIM_PROD_01
           WHERE product_NAME IS NOT NULL 
           AND COLOR IS NOT NULL
           AND PRICE IS NOT NULL;
   BEGIN
      FOR i IN c_v LOOP
         INSERT INTO ts_DW_CL.DW_CL_PRODUCT_DATA( 
                        product_NAME
                       , COLOR
                       , PRICE)
              VALUES ( i.product_NAME
                       , i.COLOR
                       , i.PRICE);

         EXIT WHEN c_v%NOTFOUND;
      END LOOP;

      COMMIT;
   END load_CLEAN_product;
END pkg_etl_products_cl;


BEGIN
    Pkg_etl_customers_cl.load_CLEAN_CUSTOMER;
    pkg_etl_products_cl.load_CLEAN_product;
    pkg_etl_store_cl.load_CLEAN_store;
END;

--====================================================================================
----------------------DW LAYER-----------------------------------------------
--================================================================================
DROP TABLE DW_CUSTOMERS_DATA;
CREATE TABLE DW_CUSTOMERS_DATA 
(
    CUSTOMER_ID   NUMBER(10) NOT NULL,
    first_name    VARCHAR2(40 BYTE) NOT NULL,
    last_name     VARCHAR2(40 BYTE) NOT NULL,
    email         VARCHAR2(50 BYTE) NOT NULL,
    phone         VARCHAR2(40 BYTE) NOT NULL,
    age           NUMBER(3) NOT NULL)
TABLESPACE ts_DW_DATA_01;

ALTER TABLE DW_CUSTOMERS_DATA
   ADD CONSTRAINT PK_DW_CUSTOMERS_DATA PRIMARY KEY (CUSTOMER_ID);

DROP SEQUENCE SEQ_CUSTOMERS;
CREATE SEQUENCE SEQ_CUSTOMERS
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 --------------------------------------------
 DROP TABLE DW_STORE_DATA;
CREATE TABLE DW_STORE_DATA 
(
    STORE_ID          NUMBER(10) NOT NULL,
    STORE_PHONE       VARCHAR2(40 BYTE) NOT NULL,
    STORE_NAME        VARCHAR2(50 BYTE) NOT NULL)
TABLESPACE ts_DW_DATA_01;

ALTER TABLE DW_STORE_DATA
   ADD CONSTRAINT PK_DW_STORE_DATA PRIMARY KEY (STORE_ID);

DROP SEQUENCE SEQ_STORES;
CREATE SEQUENCE SEQ_STORES
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 ------------------------------------------------------------------------
 
 CREATE TABLE DW_PRODUCT_DATA 
(
    PRODUCT_ID          NUMBER(10) NOT NULL,
    PRODUCT_NAME      VARCHAR2(40 BYTE) NOT NULL,
    COLOR             VARCHAR2(40 BYTE) NOT NULL,
    PRICE             FLOAT NOT NULL)
TABLESPACE ts_DW_DATA_01;

ALTER TABLE DW_PRODUCT_DATA
   ADD CONSTRAINT PK_DW_PRODUCT_DATA PRIMARY KEY (PRODUCT_ID);

DROP SEQUENCE SEQ_PRODUCTS;
CREATE SEQUENCE SEQ_PRODUCTS
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 -------------------------------------------------------------------------
 
 CREATE OR REPLACE PACKAGE pkg_etl_customers_dw_stage
AS  
   PROCEDURE load_CUSTOMERS_DW;
END pkg_etl_customers_dw_stage;

CREATE OR REPLACE PACKAGE BODY pkg_etl_customers_dw_stage
AS PROCEDURE load_CUSTOMERS_DW
AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
	   CUSTOMER_FIRST_NAME CURSOR_VARCHAR;
	   CUSTOMER_LAST_NAME CURSOR_VARCHAR;
	   CUSTOMER_EMAIL CURSOR_VARCHAR;
	   CUSTOMER_PHONE CURSOR_VARCHAR;
       CUSTOMER_AGE CURSOR_NUMBER;
       CUSTOMER_FIRST_NAME_STAGE CURSOR_VARCHAR;
	   CUSTOMER_LAST_NAME_STAGE CURSOR_VARCHAR;
       CUSTOMER_ID CURSOR_NUMBER;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.FIRST_NAME AS FIRST_NAME_source_CL
                 , source_CL.LAST_NAME AS LAST_NAME_source_CL
                 , source_CL.EMAIL AS EMAIL
	             , source_CL.PHONE AS PHONE
	             , source_CL.AGE AS AGE
	             , stage.FIRST_NAME AS FIRST_NAME_stage
                 , stage.LAST_NAME AS LAST_NAME_STAGE
                 , STAGE.CUSTOMER_ID AS CUSTOMER_ID
	          FROM (SELECT DISTINCT *
                           FROM ts_dw_CL.DW_CL_CUSTOMERS_DATA) source_CL
                     LEFT JOIN
                        DW_CUSTOMERS_DATA stage
                     ON (source_CL.FIRST_NAME = stage.FIRST_NAME AND source_CL.LAST_NAME = stage.LAST_NAME );

	
	   FETCH ALL_INF
	   BULK COLLECT INTO CUSTOMER_FIRST_NAME, CUSTOMER_LAST_NAME, CUSTOMER_EMAIL, 
       CUSTOMER_PHONE, CUSTOMER_AGE, CUSTOMER_FIRST_NAME_STAGE, 
       CUSTOMER_LAST_NAME_STAGE, CUSTOMER_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN CUSTOMER_ID.FIRST .. CUSTOMER_ID.LAST LOOP
	      IF ( CUSTOMER_ID ( i ) IS NULL ) THEN
	         INSERT INTO DW_CUSTOMERS_DATA ( CUSTOMER_ID
                                             ,first_name
                                             ,last_name
                                             ,email
                                             ,phone
                                             ,age)
	              VALUES ( SEQ_CUSTOMERS.NEXTVAL
	                     , CUSTOMER_FIRST_NAME( i )
                         , CUSTOMER_LAST_NAME( i )
                         , CUSTOMER_EMAIL( i )
                         , CUSTOMER_PHONE( i )
                         , CUSTOMER_AGE( i )
	                     , NULL );
	
	         COMMIT;
	      ELSIF ( CUSTOMER_PHONE ( i )<> CUSTOMER_PHONE ( i )) THEN
	         UPDATE DW_CUSTOMERS_DATA
	            SET EMAIL = CUSTOMER_EMAIL ( i )
                   ,PHONE = CUSTOMER_PHONE( i )
                   ,AGE = CUSTOMER_AGE( i )
                   ,UPDATE_DATE = SYSDATE
	          WHERE DW_CUSTOMERS_DATA.CUSTOMER_ID = CUSTOMER_ID ( i );
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_CUSTOMERS_DW;
END pkg_etl_customers_dw_stage;
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_etl_products_dw_stage
AS  

   PROCEDURE load_PRODUCTS_DW;
END pkg_etl_products_dw_stage;


CREATE OR REPLACE PACKAGE BODY pkg_etl_products_dw_stage
AS PROCEDURE load_PRODUCTS_DW
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
        PRODUCT_NAME_SOURCE      CURSOR_VARCHAR;
        COLOR             CURSOR_VARCHAR;
        PRICE             CURSOR_FLOAT;
        PRODUCT_NAME      CURSOR_VARCHAR;
        PRODUCT_ID        CURSOR_NUMBER;
        
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.PRODUCT_NAME AS PRODUCT_NAME_source_CL
	             , source_CL.COLOR AS COLOR
                 , source_CL.PRICE AS PRICE
	             , stage.PRODUCT_NAME AS PRODUCT_NAME_stage
                 , STAGE.PRODUCT_ID AS PRODUCT_ID
	          FROM (SELECT DISTINCT *
                           FROM ts_dw_CL.DW_CL_PRODUCT_DATA) source_CL
                     LEFT JOIN
                        DW_PRODUCT_DATA stage
                     ON (source_CL.PRODUCT_NAME = stage.PRODUCT_NAME);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO PRODUCT_NAME_SOURCE
                             ,COLOR
                             ,PRICE
                             ,PRODUCT_NAME
                             ,PRODUCT_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN PRODUCT_ID.FIRST .. PRODUCT_ID.LAST LOOP
	      IF ( PRODUCT_ID ( i ) IS NULL ) THEN
	         INSERT INTO DW_PRODUCT_DATA (   PRODUCT_ID
                                             ,PRODUCT_NAME
                                             ,COLOR
                                             ,PRICE)
	              VALUES ( SEQ_PRODUCTS.NEXTVAL
	                      ,PRODUCT_NAME_SOURCE( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
	                      , NULL );
	
	         COMMIT;
	      ELSIF ( LINE_ID_SOURCE ( i )<> LINE_ID ( i )) THEN
                 INSERT INTO DW_PRODUCT_DATA (   PRODUCT_ID
                                             ,PRODUCT_NAME
                                             ,COLOR
                                             ,PRICE)
	              VALUES ( SEQ_PRODUCTS.NEXTVAL
	                      ,PRODUCT_NAME_SOURCE( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
	                      , NULL );
                  COMMIT;
           ELSE UPDATE DW_PRODUCT_DATA
                    SET PRODUCT_NAME = PRODUCT_NAME_SOURCE( i )
                          ,COLOR = COLOR ( i )
                          ,PRICE = PRICE ( i )                    
	          WHERE DW_product_DATA.product_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_productS_DW;
END pkg_etl_products_dw_stage;

------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_etl_store_dw_stage
AS  
   PROCEDURE load_STORES_DW;
END pkg_etl_store_dw_stage;




CREATE OR REPLACE PACKAGE BODY pkg_etl_store_dw_stage
AS PROCEDURE load_stores_dw
AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE BIG_CURSOR IS REF CURSOR;
       
       STORE_PHONE CURSOR_VARCHAR;
       STORE_NAME CURSOR_VARCHAR;
       STORE_NAME_STAGE CURSOR_VARCHAR;
       STORE_ID CURSOR_NUMBER;
       ALL_INF BIG_CURSOR;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_CL.STORE_NAME AS STORE_NAME_source_CL
                 , source_CL.STORE_PHONE AS STORE_PHONE_source_CL
                 , source_CL.INSERT_DATE AS INSERT_DATE
	             , stage.STORE_NAME AS STORE_NAME_stage
                 , STAGE.STORE_ID AS STORE_ID
	          FROM (SELECT DISTINCT *
                           FROM ts_dw_CL.DW_CL_STORE_DATA) source_CL
                     LEFT JOIN
                        DW_STORE_DATA stage
                     ON (source_CL.STORE_NAME = stage.STORE_NAME);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO STORE_NAME, STORE_PHONE, STORE_NAME_STAGE, STORE_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN STORE_ID.FIRST .. STORE_ID.LAST LOOP
	      IF ( STORE_ID ( i ) IS NULL ) THEN
	         INSERT INTO DW_STORE_DATA ( STORE_ID
                                         , STORE_PHONE 
                                         , STORE_NAME)
	              VALUES ( SEQ_STORES.NEXTVAL
	                     , STORE_PHONE( i )
                         , STORE_NAME( i )
	                     , NULL );
	
	         COMMIT;
	      ELSE  UPDATE DW_STORE_DATA
	            SET STORE_PHONE = STORE_PHONE( i )
                   ,STORE_NAME = STORE_NAME( i )
	          WHERE DW_STORE_DATA.STORE_ID = STORE_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_STORES_DW;
END pkg_etl_store_dw_stage;




--------------------------------------

BEGIN
   pkg_etl_store_dw_stage.load_stores_dw;
   pkg_etl_customers_dw_stage.load_customers_dw;
   pkg_etl_products_dw_stage.load_products_dw;
END;
