
DROP MATERIALIZED VIEW MVIEW_PRODUCTS
CREATE MATERIALIZED VIEW MVIEW_PRODUCTS
BUILD DEFERRED
REFRESH COMPLETE ON DEMAND
AS
SELECT /*+ parallel(ff 8 prg 8)*/
        TRUNC ( DATE_SALES, 'mm' ) AS month_dt
       , DECODE ( GROUPING ( PRODUCT_NAME ), 1, 'All products', PRODUCT_NAME ) AS PRODUCT
       , SUM ( price ) AS sum
    FROM SALES
    GROUP BY  TRUNC ( DATE_SALES, 'mm' ) , CUBE ( PRODUCT_NAME, price)
    HAVING GROUPING_ID ( PRODUCT_NAME ) < 1
    ORDER BY 1,2,3;
    
select * from  MVIEW_PRODUCTS;

EXECUTE DBMS_MVIEW.REFRESH('MVIEW_PRODUCTS');


--ÇÀÄÀÍÈÅ 2

CREATE MATERIALIZED VIEW LOG ON SALES
WITH rowid, SEQUENCE (PRODUCT_NAME, PRICE,
DATE_SALES, CITY)
INCLUDING NEW VALUES;

DROP MATERIALIZED VIEW MVIEW_SALES_CITY
CREATE MATERIALIZED VIEW MVIEW_SALES_CITY
 BUILD IMMEDIATE
 REFRESH FAST ON COMMIT
 ENABLE QUERY REWRITE
 AS
 SELECT DATE_SALES AS event_dt
       , city
       , product_name
       , SUM ( price ) AS sum
    FROM sales
    WHERE TRUNC ( DATE_SALES
                       , 'DD' ) = TO_DATE ( '06.06.2021'
                                          , 'DD.MM.YYYY' )
    GROUP BY  DATE_SALES ,city, PRODUCT_NAME
    order by city, sum;
    
SELECT * FROM MVIEW_SALES_CITY;

UPDATE SALES
    SET PRICE = PRICE*0.5
    WHERE TRUNC ( DATE_SALES
                       , 'DD' ) = TO_DATE ( '06.06.2021'
                                          , 'DD.MM.YYYY' );
                                          
--ÇÀÄÀÍÈÅ 3

DROP MATERIALIZED VIEW MVIEW_SALES
CREATE MATERIALIZED VIEW MVIEW_SALES
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND  START WITH SYSDATE NEXT (SYSDATE + 1/1440)
 AS
select distinct
  nvl(CITY , 'all city' ) as city
, nvl(PRODUCT_name, 'all product') as Product_name
, price
from SALES
group by cube(city, PRODUCT_name) 
having city is not null 
model dimension by (city, PRODUCT_name)
measures (sum(price) price)
rules(price[null, for PRODUCT_name in (select PRODUCT_name from sales group by PRODUCT_name)] = sum (price)[any, cv(PRODUCT_name)])
order by city, Product_name, price desc;


UPDATE SALES
    SET PRICE = PRICE*2
    WHERE PRODUCT_NAME = 'Watch Finift' AND CITY = 'Minsk';

SELECT * FROM MVIEW_SALES
