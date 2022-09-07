
SET autotrace STATISTICS
SELECT TRUNC(DATE_SALES, 'MM') AS month, 
       DECODE(GROUPING(fct.PRODUCT_NAME), 1, 'All product', fct.PRODUCT_NAME) AS PRODUCT_NAME,  
       SUM(fct.PRICE) AS price 
FROM (SELECT DISTINCT * FROM SALES) fct
LEFT JOIN DM_PRODUCT prod ON(fct.PRODUCT_NAME = prod.PRODUCT_NAME)
WHERE TRUNC ( DATE_SALES, 'mm') = TO_DATE ( '02.01.21', 'MM.DD.YY') 
GROUP BY GROUPING SETS((TRUNC(DATE_SALES, 'MM'), fct.PRODUCT_NAME),(TRUNC(DATE_SALES, 'MM')))
ORDER BY SUM(fct.PRICE) DESC;


SET autotrace STATISTICS
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

SET autotrace STATISTICS
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