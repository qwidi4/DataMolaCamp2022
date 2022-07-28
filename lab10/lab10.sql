DROP TABLE CALENDAR;
PURGE RECYCLEBIN;

CREATE TABLE CALENDAR 
AS SELECT * FROM 
    (SELECT 
        TRUNC( sd + rn ) time_id,
        TO_CHAR( sd + rn, 'fmDay' ) day_name,
        TO_CHAR( sd + rn, 'D' ) day_number_in_week,
        TO_CHAR( sd + rn, 'DD' ) day_number_in_month,
        TO_CHAR( sd + rn, 'DDD' ) day_number_in_year,
        TO_CHAR( sd + rn, 'W' ) calendar_week_number,
        ( CASE
            WHEN TO_CHAR( sd + rn, 'D' ) IN ( 1, 2, 3, 4, 5, 7 ) THEN
             NEXT_DAY( sd + rn, 'СУББОТА' )
              ELSE
               ( sd + rn )
         END ) week_ending_date,
         TO_CHAR( sd + rn, 'MM' ) calendar_month_number,
         TO_CHAR( LAST_DAY( sd + rn ), 'DD' ) days_in_cal_month,
         LAST_DAY( sd + rn ) end_of_cal_month,
         TO_CHAR( sd + rn, 'FMMonth' ) calendar_month_name,
        ( ( CASE
            WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
              TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
            WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
              TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
            WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
             TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
           WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
              TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
         END ) - TRUNC( sd + rn, 'Q' ) + 1 ) days_in_cal_quarter,
         TRUNC( sd + rn, 'Q' ) beg_of_cal_quarter,
         ( CASE
            WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
               TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
            WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
              TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
           WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
              TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
            WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
             TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          END ) end_of_cal_quarter,
         TO_CHAR( sd + rn, 'Q' ) calendar_quarter_number,
         TO_CHAR( sd + rn, 'YYYY' ) calendar_year,
         ( TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          - TRUNC( sd + rn, 'YEAR' ) ) days_in_cal_year,
         TRUNC( sd + rn, 'YEAR' ) beg_of_cal_year,
         TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' ) end_of_cal_year
        FROM
         ( 
          SELECT 
            TO_DATE( '12/31/2002', 'MM/DD/YYYY' ) sd,
            rownum rn
          FROM dual
            CONNECT BY level <= 200000
         )
    );
    commit;
    
    SELECT * FROM calendar
    
    SELECT * FROM calendar 
    WHERE DAY_NAME = 'Понедельник' AND 
          CALENDAR_WEEK_NUMBER > 3 AND
          CALENDAR_MONTH_NAME = 'Август';
          
     SELECT /*+ parallel(CALENDAR, 4) */* FROM calendar 
    WHERE DAY_NAME = 'Понедельник' AND 
          CALENDAR_WEEK_NUMBER > 3 AND
          CALENDAR_MONTH_NAME = 'Август';
          
       DELETE FROM CALENDAR 
     WHERE DAY_NAME = 'Понедельник';

     DELETE /*+ parallel enable_parallel_dml */ FROM CALENDAR 
     WHERE DAY_NAME = 'Понедельник';
     
     
    
    
    