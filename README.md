# optimised_query

=================

I will collect marketing analytics queries here, that are crafted with optimisation in mind.

[every_day_schedule](#every_day_schedule)

## every_day_schedule

====================

Running once per day in a BigQuery environment, this query transforms GA4 raw data into a table ready for data visualization. Querying GA4 row data daily can be resource-intensive if you simply rewrite it each time. Since GA4 data never alters existing rows, appending new data becomes possible, allowing for optimization of costs and resources. Even though this example made with GA4 data it can be applied to any data ingested incrementally (next extraction adds new rows and do not altered the old ones).

### Algorithm flowchart

====================

![algorithm flowchart every_day_schedule](images/every_day_schedule.png)

-- Declare a variable 'd' and set it to the current date

-- Check if the table already exists

-- If yes: Set the variable 'd' to the next day after the maximum date in the existing table

-- Check if the difference between the current date and the maximum date in the table is greater than 0

-- If yes: Insert the data between the variable 'd' and yesterday

-- If no: Do nothing

-- If the table doesn't exist: Create the table with dates between your start date (e.g., '20230101') and yesterday
