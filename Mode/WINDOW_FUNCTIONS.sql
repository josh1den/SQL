### Running Total

SELECT
      duration_seconds,
      SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
FROM tutorial.dc_bikeshare_q1_2012;

### Running Total by starting terminal

SELECT
      start_terminal,
      duration_seconds,
      SUM(duration_seconds) OVER (PARTITION BY start_terminal
        ORDER BY start_time) AS running_total
FROM tutorial.dc_bikeshare_q1_2012;

### Show the duration of each ride as a percentage of the total time accrued
### by riders from each start_terminal

SELECT
      start_terminal,
      duration_seconds,
      SUM(duration_seconds) OVER (PARTITION BY start_terminal)
      AS start_terminal_sum,
      (duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal))
      * 100 AS pct_of_total_time
FROM tutorial.dc_bikeshare_q1_2012
ORDER BY 1, 4 DESC;
