--отчёт по магазинам
SELECT DATE_SALES, store_id, SUM(price) AS profit, COUNT(*) AS sales FROM SALES
GROUP BY CUBE (DATE_SALES, store_id)
HAVING store_id is not null AND date_sales IS NOT NULL
ORDER BY DATE_SALES, store_id; 

--отчёт по странам
SELECT trunc(DATE_SALES, 'MM'), country, SUM(price) AS profit, COUNT(*) AS sales FROM SALES
GROUP BY CUBE (trunc(DATE_SALES, 'MM'), country)
HAVING country is not null AND trunc(DATE_SALES, 'MM') IS NOT NULL
ORDER BY trunc(DATE_SALES, 'MM'), country; 

--отчёт по магазинам
SELECT trunc(DATE_SALES, 'MM'), store_id, SUM(price) AS profit, COUNT(*) AS sales FROM SALES
GROUP BY CUBE (trunc(DATE_SALES, 'MM'), store_id)
HAVING store_id is not null AND trunc(DATE_SALES, 'MM') IS NOT NULL
ORDER BY trunc(DATE_SALES, 'MM'), store_id; 

--генерация новой таблицы
DROP table SALES;
CREATE TABLE SALES
 AS(
select a.DATE_Sales, dm_product.product_id, dm_product.product_name,
dm_product.price, dm_stores.store_id, 
dm_stores.city, dm_stores.country
FROM (select b.* ,TRUNC(DBMS_RANDOM.VALUE( 1,22)) as PRODUCT, TRUNC(DBMS_RANDOM.VALUE( 1,13)) as STORES
FROM
(SELECT TRUNC (TO_DATE( '01/01/2021', 'DD/MM/YYYY')+
TRUNC(DBMS_RANDOM.VALUE( 1, (to_date('01/01/2022', 'DD/MM/YYYY') 
-to_date('01/01/2021', 'DD/MM/YYYY')+1)))) DATE_Sales, 
rownum as rn FROM dual CONNECT BY level <= 30000 )b 
)a 
LEFT JOIN DM_PRODUCT on PRODUCT = DM_PRODUCT.PRODUCT_ID
LEFT JOIN DM_STORES on STORES = DM_STORES.STORE_ID);

SELECT * FROM SALES
ORDER BY 1, 5

SELECT DECODE (GROUPING_ID(TRUNC(DATE_SALES, 'YYYY'),
TRUNC(DATE_SALES, 'Q'),
TRUNC(DATE_SALES, 'MM'),
TRUNC(DATE_SALES, 'DD')), 15, 'GRAND TOTAL',
TRUNC(DATE_SALES, 'YYYY') ) AS year,
DECODE (GROUPING_ID(TRUNC(DATE_SALES, 'YYYY'),
TRUNC(DATE_SALES, 'Q'),
TRUNC(DATE_SALES, 'MM'), 
TRUNC(DATE_SALES, 'DD')), 7, 'TOTAL BY YEAR', 
TRUNC(DATE_SALES, 'Q') ) AS quarter, 
DECODE (GROUPING_ID(TRUNC(DATE_SALES, 'YYYY'),
TRUNC(DATE_SALES, 'Q'),
TRUNC(DATE_SALES, 'MM'), 
TRUNC(DATE_SALES, 'DD')), 3, 'TOTAL BY QUARTER', 
TRUNC(DATE_SALES, 'MM') ) AS month, 
DECODE (GROUPING_ID(TRUNC(DATE_SALES, 'YYYY'),
TRUNC(DATE_SALES, 'Q'), 
TRUNC(DATE_SALES, 'MM'), 
TRUNC(DATE_SALES, 'DD')), 1, 'TOTAL BY MONTH', 
TRUNC(DATE_SALES, 'DD') ) AS day, 
SUM(PRICE) AS profit FROM sales GROUP BY ROLLUP( TRUNC ( DATE_SALES, 'YYYY'), 
                                                TRUNC ( DATE_SALES, 'Q'),
                                                TRUNC ( DATE_SALES, 'MM'), 
                                                TRUNC ( DATE_SALES, 'DD') )
ORDER BY year, quarter, month, day;

select * from sales