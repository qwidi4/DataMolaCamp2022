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

CREATE OR REPLACE PACKAGE body pkg_etl_product_dim
AS  
   PROCEDURE load_product_dim
   AS
   BEGIN
      DECLARE
	   TYPE CURSOR_VARCHAR IS TABLE OF varchar2(50);
	   TYPE CURSOR_NUMBER IS TABLE OF number(10);  
       TYPE CURSOR_DATE IS TABLE OF DATE;
       TYPE CURSOR_FLOAT IS TABLE OF FLOAT;
	   TYPE BIG_CURSOR IS REF CURSOR ;
	
	   ALL_INF BIG_CURSOR;
	   
        PRODUCT_NAME      CURSOR_VARCHAR;
        COLOR             CURSOR_VARCHAR;
        PRICE             CURSOR_FLOAT;
        PRODUCT_ID_SOURCE        CURSOR_NUMBER;
        PRODUCT_ID        CURSOR_NUMBER;
	BEGIN
	   OPEN ALL_INF FOR
	       SELECT source_DW.PRODUCT_NAME AS PRODUCT_NAME_source
	             , source_DW.COLOR AS COLOR_SOURCE
                 , source_DW.PRICE AS PRICE_SOURCE
                 , source_DW.PRODUCT_ID AS PRODUCT_ID_SOURCE
                 , STAGE.PRODUCT_ID AS PRODUCT_ID
	          FROM (SELECT DISTINCT *
                           FROM ts_dw_DATA.DW_PRODUCT_DATA) source_DW
                     LEFT JOIN
                        DIM_PRODUCT stage
                     ON (source_DW.PRODUCT_ID = stage.PRODUCT_ID);

	
	   FETCH ALL_INF
	   BULK COLLECT INTO PRODUCT_NAME, LINE_ID, LINE_NAME,COLLECTION_ID
                         ,COLLECTION_NAME, SEASON_ID, SEASON, SIZE_CLOTHES
                         ,COLOR, PRICE , INSERT_DATE, PRODUCT_ID_SOURCE, PRODUCT_ID;
	
	   CLOSE ALL_INF;
	
	   FOR i IN PRODUCT_ID.FIRST .. PRODUCT_ID.LAST LOOP
	      IF ( PRODUCT_ID ( i ) IS NULL AND PRODUCT_ID_SOURCE ( i )IS NOT NULL) THEN
	         INSERT INTO DIM_PRODUCT (   PRODUCT_ID
                                        ,PRODUCT_NAME
                                        ,COLOR
                                        ,PRICE)
	              VALUES ( PRODUCT_ID_SOURCE ( i )
	                      ,PRODUCT_NAME( i )
                          ,COLOR ( i )
                          ,PRICE ( i )
	                      , NULL );
	         COMMIT;
	      ELSE UPDATE DIM_PRODUCT
                    SET PRODUCT_NAME = PRODUCT_NAME( i )
                          ,COLOR = COLOR ( i )
                          ,PRICE = PRICE ( i )
	                      ,UPDATE_DATE = SYSDATE
	          WHERE DIM_PRODUCT.PRODUCT_ID = product_ID ( i );
	
	         COMMIT;
	      END IF;
	   END LOOP;
	END;
   END load_product_DIM;
END pkg_etl_product_dim;



begin
    pkg_etl_product_dim.load_product_dim;
end;

SELECT COUNT(*) FROM DM_PRODUCT

EXECUTE load_product_DIM;

SELECT COUNT(*) FROM DM_PRODUCT


--TASK 2--

SELECT * FROM SALES

