----------------------------------------------------------------------------------------------
--declare a variable d and set it to the current date
--check if the table already exists
   --if yes 
      --set the variable d to the next day after the maximum date in the existing table
      --check if the difference between the current date and the maximum date in the table > 0
         --if yes
            --insert the data between the variable d and yesterday
         --if no 
            --do nothing
   --if if the table doesn't exists
      --create the table with the date between your start date (e.g. '20230101') and yesetrday
----------------------------------------------------------------------------------------------

--declare a variable d and set it to the current date
DECLARE d DATE DEFAULT CURRENT_DATE();

--check if the table already exists
IF (SELECT COUNT(1) AS cnt FROM `YOUR_PROJECT.YOUR_CONSUMER_DATASET.__TABLES_SUMMARY__` WHERE table_id = 'YOUR_CONSUMER_TABLE') > 0
    --if yes 
   THEN
    --set the variable d to the next day after the maximum date in the existing table
   SET d = DATE_SUB((SELECT MAX(event_date) FROM `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE`), INTERVAL -1 DAY);
   --check if the difference between the current date and the maximum date in the table > 0
   IF DATE_DIFF(CURRENT_DATE(), (SELECT MAX(event_date) FROM `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE`), DAY) > 1 
      --if yes
      THEN
      --insert the data between the variable d and yesterday
      INSERT INTO `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE` (event_date, users, active_users, total_events, sessions)
        PARSE_DATE('%Y%m%d', _table_suffix) event_date,
        COUNT(DISTINCT user_pseudo_id) users,
        COUNT(DISTINCT CASE WHEN ( SELECT value.int_value FROM UNNEST(event_params) WHERE KEY = 'engagement_time_msec') > 0 OR ( SELECT value.string_value FROM UNNEST(event_params) WHERE KEY = 'session_engaged') = '1' THEN user_pseudo_id END) active_users,
        COUNT(CASE WHEN event_name IS NOT NULL THEN CONCAT(user_pseudo_id, ( SELECT value.int_value FROM UNNEST(event_params) WHERE KEY='ga_session_id')) ELSE NULL END) total_events
        
        --more code if needed

        FROM `YOUR_PROJECT.analytics_000000000.events_*`
        --between the variable d, which is the next day after the maximum date in the existing table, and yesterday
        WHERE _table_suffix BETWEEN FORMAT_DATE('%Y%m%d', d) AND FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), interval 1 DAY))
    
    --if no 
        --do nothing
   END IF;

  --if the table doesn't exists
   ELSE
   --create the table with the date between your start date (e.g. '20230101') and yesetrday
   CREATE OR REPLACE TABLE
      `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE` AS(
        SELECT
        PARSE_DATE('%Y%m%d', _table_suffix) event_date,
        COUNT(DISTINCT user_pseudo_id) users,
        COUNT(DISTINCT CASE WHEN ( SELECT value.int_value FROM UNNEST(event_params) WHERE KEY = 'engagement_time_msec') > 0 OR ( SELECT value.string_value FROM UNNEST(event_params) WHERE KEY = 'session_engaged') = '1' THEN user_pseudo_id END) active_users,
        COUNT(CASE WHEN event_name IS NOT NULL THEN CONCAT(user_pseudo_id, ( SELECT value.int_value FROM UNNEST(event_params) WHERE KEY='ga_session_id')) ELSE NULL END) total_events
    
        --more code if needed        

        FROM `YOUR_PROJECT.analytics_000000000.events_*`
        WHERE _table_suffix BETWEEN '20230101' AND FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), interval 1 DAY))
   );
END IF;