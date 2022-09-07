CREATE TABLE DM_EMPLOYEES(
EMPLOYEE_ID NUMBER,
FIRST_NAME VARCHAR(20),
LAST_NAME VARCHAR(20),
PHONE VARCHAR(20),
EMAIL VARCHAR(40), 
STORE_ID NUMBER,
NAME_POSITION VARCHAR(30),
START_DATE DATE,
SALARY NUMBER,
position_parent   NUMBER,
position_child    NUMBER
);

INSERT INTO DM_EMPLOYEES VALUES(1, 'IGOR', 'KARPUK', '+375295483190', 'IGOR.KARPUK@MAIL.RU', 4, 'manager', TO_DATE('17/12/2021', 'DD/MM/YYYY') , 750, NULL, 1 );
INSERT INTO DM_EMPLOYEES VALUES(2, 'VLADIMIR', 'PASECHKIN', '+375293383112' , 'VLADIMIR.PASECHKIN@MAIL.RU', 2, 'consultant',TO_DATE('22/01/2022', 'DD/MM/YYYY'), 650, 1, 10 );
INSERT INTO DM_EMPLOYEES VALUES(3, 'EKATERINA', 'VLASOVA', '+375294561234' , 'EKATERINA.VLASOVA@MAIL.RU' , 2, 'cashier',TO_DATE('21/12/2021', 'DD/MM/YYYY'), 650, 10, 100 );
INSERT INTO DM_EMPLOYEES VALUES(4, 'MARIYA', 'EGOROVA', '+375293567321', 'MARIYA.EGOROVA@MAIL.RU', 2, 'cashier', TO_DATE('16/04/2022', 'DD/MM/YYYY'), 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(5, 'DARYA', 'MYS', '+375293384298', 'DARYA.MYS@MAIL.RU', 2, 'cashier', TO_DATE('17/05/2022', 'DD/MM/YYYY'), 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(6, 'ANDREW', 'POLON', '+375294926830' , 'ANDREW.POLON@MAIL.RU', 2, 'cashier', TO_DATE('19/06/2022', 'DD/MM/YYYY'), 650, 10, 100 );
INSERT INTO DM_EMPLOYEES VALUES(7, 'VLADISLAV', 'ULYANOV', '+375291737083', 'VLADISLAV.ULYANOV@MAIL.RU', 2, 'consultant', TO_DATE('31/01/202', 'DD/MM/YYYY'),  650, 1, 10  );
INSERT INTO DM_EMPLOYEES VALUES(8, 'IRINA', 'GORA', '+375295820400', 'IRINA.GORA@MAIL.RU', 2, 'cashier', TO_DATE('10/05/2022', 'DD/MM/YYYY'), 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(9, 'VIKTORIA', 'BOBR', '+375293008992', 'VIKTORIA.BOBR@MAIL.RU', 2, 'cashier', TO_DATE('24/02/2022', 'DD/MM/YYYY'), 650, 10, 100  );
INSERT INTO DM_EMPLOYEES VALUES(10, 'EGOR', 'MIRONOV', '+375293896781', 'EGOR.MIRONOV@MAIL.RU', 2, 'consultant',TO_DATE('28/12/2021', 'DD/MM/YYYY'),  650, 1, 10  );


SELECT * FROM SALES;



CREATE OR REPLACE VIEW shop_profit AS
SELECT          DISTINCT TRUNC(date_sales, 'MM') AS month,
                STORE_ID,
                SUM(PRICE) AS total_profit,
                COUNT(PRODUCT_NAME) AS total_sale
FROM sales
GROUP BY TRUNC(date_sales, 'MM'), store_id;

SELECT * FROM shop_profit;

CREATE OR REPLACE VIEW watchs_stat AS
SELECT          DISTINCT TRUNC(date_sales, 'MM') AS month,
                PRODUCT_NAME,
                SUM(PRICE) AS total_profit,
                COUNT(PRODUCT_NAME) AS total_sale
FROM sales
GROUP BY TRUNC(date_sales, 'MM'), PRODUCT_NAME;

SELECT * FROM watchs_stat;

CREATE TABLE sales_fact(
sale_id NUMBER,
customes_id NUMBER NOT NULL,
employee_id NUMBER NOT NULL,
shop_id NUMBER NOT NULL,
date_sale DATE NOT NULL,
product_id NUMBER NOT NULL,
price INT NOT NULL,
PARTITION BY RANGE (date_sales) 
( 
PARTITION quarter_1 VALUES LESS THAN(to_date('01.04.2021','DD.MM.YYYY')),
PARTITION quarter_2 VALUES LESS THAN(to_date('01.07.2021','DD.MM.YYYY')),
PARTITION quarter_3 VALUES LESS THAN(to_date('01.10.2021','DD.MM.YYYY')),
PARTITION quarter_4 VALUES LESS THAN(to_date('01.01.2022','DD.MM.YYYY'))
);

CREATE OR REPLACE PACKAGE pkg_etl_sal_level
AS  
   PROCEDURE load_sal_sales_fact;
END pkg_etl_sal_level;

CREATE OR REPLACE PACKAGE body pkg_etl_sal_level
AS  
  PROCEDURE load_sal_sales_fact
  AS
  BEGIN
    MERGE INTO sales_fact a
    USING (SELECT * FROM sales) b
    ON (a.sale_id=b.sale_id)
    WHEN MATCHED THEN 
                UPDATE SET a.customer_id = b.customer_id
    WHEN NOT MATCHED THEN 
                INSERT (a.sale_id,
a.customes_id ,
a.employee_id,
a.shop_id ,
a.date_sale ,
a.product_id ,
a.price )
                VALUES (a.sale_id,
b.customes_id ,
b.employee_id,
b.shop_id ,
b.date_sale ,
b.product_id ,
b.price);
COMMIT;
   END load_sal_sales_fact;
END pkg_etl_sal_level;