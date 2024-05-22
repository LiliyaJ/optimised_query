----------------------------------------------------------------------------------------------
-- Declare a variable 'd' and set it to the current date
-- Check if the consumer table already exists
   -- If yes 
      -- Set the variable 'd' to the next day after the maximum date in the existing table
      -- Check if the difference between the current date and the maximum date in the table is greater than 0
         -- If yes
            -- Insert the data between the variable 'd' and yesterday
         -- If no 
            -- Do nothing
   -- If the table doesn't exist
      -- Create the table with dates between your start date (e.g., '20230101') and yesterday
----------------------------------------------------------------------------------------------

--declare a variable d and set it to the current date
declare d date default current_date();

--check if the table already exists
if (select count(1) as cnt from `YOUR_PROJECT.YOUR_CONSUMER_DATASET.__TABLES_SUMMARY__` where table_id = 'YOUR_CONSUMER_TABLE') > 0
    --if yes 
   then
    --set the variable d to the next day after the maximum date in the existing table
   set d = date_sub((select max(event_date) from `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE`), INTERVAL -1 day);
   --check if the difference between the current date and the maximum date in the table > 0
   if date_diff(current_date(), (select max(event_date) from `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE`), day) > 1 
      --if yes
      then
      --insert the data between the variable d and yesterday
      insert into `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE` (event_date, users, active_users, total_events, sessions)
        parse_date('%Y%m%d', _table_suffix) event_date,
        count(distinct user_pseudo_id) users,
        count(distinct case when (select value.int_value from unnest(event_params) where key = 'engagement_time_msec') > 0 or ( select value.string_value from unnsest(event_params) where key = 'session_engaged') = '1' then user_pseudo_id end) active_users,
        count(case when event_name is not null then concat(user_pseudo_id, ( select value.int_value from UNNEST(event_params) where key='ga_session_id')) else null end) total_events
        
        --more code if needed

        from `YOUR_PROJECT.analytics_000000000.events_*`
        --between the variable d, which is the next day after the maximum date in the existing table, and yesterday
        where _table_suffix between format_date('%Y%m%d', d) and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
    
    --if no 
        --do nothing
   end if;

  --if the table doesn't exists
   else
   --create the table with the date between your start date (e.g. '20230101') and yesetrday
   create or replace table
      `YOUR_PROJECT.YOUR_CONSUMER_DATASET.YOUR_CONSUMER_TABLE` as(
        select
        parse_date('%Y%m%d', _table_suffix) event_date,
        count(distinct user_pseudo_id) users,
        count(distinct case when ( select value.int_value from unnest(event_params) where key = 'engagement_time_msec') > 0 or ( select value.string_value from unnest(event_params) where key = 'session_engaged') = '1' then user_pseudo_id end) active_users,
        count(case when event_name is not null then concat(user_pseudo_id, ( select value.int_value from unnest(event_params) where key='ga_session_id')) else null end) total_events
    
        --more code if needed        

        from `YOUR_PROJECT.analytics_000000000.events_*`
        where _table_suffix between '20230101' and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
   );
end if;