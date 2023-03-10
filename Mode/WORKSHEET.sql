/*
Write a query that shows 3 columns. The first indicates which dataset
(part 1 or 2) the data comes from, the second shows company status, and the
third is a count of the number of investors.

Group by status and dataset

Desired output columns:
- which dataset
- tutorial.crunchbase_companies.status
- count, # investors
*/

with t1 AS (

  SELECT
        company_permalink,
        'part_1'AS dataset,
        COUNT(DISTINCT investor_name) AS total_investors
  FROM tutorial.crunchbase_investments_part1
  GROUP BY 1,2

  UNION ALL

  SELECT
        company_permalink,
        'part_2'AS dataset,
        COUNT(DISTINCT investor_name) AS total_investors
  FROM tutorial.crunchbase_investments_part2
  GROUP BY 1,2

)

SELECT t.dataset,
       c.status,
       SUM(t.total_investors)
FROM t1 t
JOIN tutorial.crunchbase_companies c
ON t.company_permalink = c.permalink
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
Convert the funding_total_usd and founded_at_clean columns in the
tutorial.crunchbase_companies_clean_date table to strings (varchar)
using a different formatting function for each one
*/

SELECT funding_total_usd :: VARCHAR,
       CAST(founded_at_clean AS VARCHAR)
FROM tutorial.crunchbase_companies_clean_date;

/*
Write a query that counts the number of companies acquired within
3 years, 5 years, and 10 years of being founded (in 3 separate
columns). Include a column for total companies acquired as well.
Group by category and limit to only rows with a founding date.
*/

SELECT c.category_code,
       COUNT(CASE WHEN a.acquired_at_cleaned <= c.founded_at_clean::timestamp +
             INTERVAL '3 years' THEN 1 ELSE NULL END) AS aqcuired_3_yrs,
       COUNT(CASE WHEN a.acquired_at_cleaned <= c.founded_at_clean::timestamp +
             INTERVAL '5 years' THEN 1 ELSE NULL END) AS acquired_5_yrs,
       COUNT(CASE WHEN a.acquired_at_cleaned <= c.founded_at_clean::timestamp +
             INTERVAL '10 years' THEN 1 ELSE NULL END) AS acquired_10_yrs,
       COUNT(1) AS total
FROM tutorial.crunchbase_companies_clean_date c
JOIN tutorial.crunchbase_acquisitions_clean_date a
ON a.company_permalink = c.permalink
WHERE c.founded_at_clean IS NOT NULL
GROUP BY 1
ORDER BY 5 DESC;

/*
Write a query that separates the `location` field into separate fields for
latitude and longitude. You can compare your results against the actual
`lat` and `lon` fields in the table.
*/

SELECT location,
       TRIM(leading '(' FROM LEFT(location, POSITION(',' IN location) - 1))
       AS lattitude,
       TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) -
       POSITION(',' IN location) ) ) AS longitude
  FROM tutorial.sf_crime_incidents_2014_01;

/*
Concatenate the lat and lon fields to form a field that is equivalent
to the location field.
*/

SELECT
      lat,
      lon,
      '(' || lat || ', ' || lon || ')' AS coords
FROM tutorial.sf_crime_incidents_2014_01
LIMIT 1;

/*
Write a query that creates a date column formatted YYYY-MM-DD
*/

SELECT
      SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)
      AS cleaned_date
FROM tutorial.sf_crime_incidents_2014_01
LIMIT 1;


/*
Write a query that returns the category field with the first letter capitalized
and the rest in lower case
*/
SELECT
      UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category)-1)) AS
      category
FROM tutorial.sf_crime_incidents_2014_01
LIMIT 1;

/*
Write a query that creates an accurate timestamp using the date and time columns
in tutorial.sf_crime_incidents_2014_01. Include a field that is exactly 1 week
later as well.
*/
SELECT
      (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp AS datetime,
      (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp +
      INTERVAL '1 week' AS datetime_plus_interval
FROM tutorial.sf_crime_incidents_2014_01
LIMIT 1;

/*
Extract pieces of the date one by one
*/

SELECT
       cleaned_date,
       EXTRACT('year'   FROM cleaned_date) AS year,
       EXTRACT('month'  FROM cleaned_date) AS month,
       EXTRACT('day'    FROM cleaned_date) AS day,
       EXTRACT('hour'   FROM cleaned_date) AS hour,
       EXTRACT('minute' FROM cleaned_date) AS minute,
       EXTRACT('second' FROM cleaned_date) AS second,
       EXTRACT('decade' FROM cleaned_date) AS decade,
       EXTRACT('dow'    FROM cleaned_date) AS day_of_week
FROM tutorial.sf_crime_incidents_cleandate
LIMIT 1;

/*
Round dates to nearest unit of measurement
*/

SELECT
       cleaned_date,
       DATE_TRUNC('year'   , cleaned_date) AS year,
       DATE_TRUNC('month'  , cleaned_date) AS month,
       DATE_TRUNC('week'   , cleaned_date) AS week,
       DATE_TRUNC('day'    , cleaned_date) AS day,
       DATE_TRUNC('hour'   , cleaned_date) AS hour,
       DATE_TRUNC('minute' , cleaned_date) AS minute,
       DATE_TRUNC('second' , cleaned_date) AS second,
       DATE_TRUNC('decade' , cleaned_date) AS decade
FROM tutorial.sf_crime_incidents_cleandate
LIMIT 1;

/*
Write a query that casts the number of incidents per week
*/

with sub AS (
  SELECT
      incidnt_num AS incident,
      (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp AS datetime
  FROM tutorial.sf_crime_incidents_2014_01
)

SELECT
      DATE_TRUNC('week', datetime)::date AS week,
      COUNT(*)
FROM sub
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
Write a query that counts the number of companies founded and acquired by
quarter starting in Q1 2012. Create the aggregations in two separate queries,
then join them.
*/

SELECT
      COALESCE(c.quarter, a.quarter) AS quarter,
      c.companies_founded,
      a.companies_acquired
FROM (
      SELECT
            founded_quarter AS quarter,
            COUNT(permalink) AS companies_founded
      FROM tutorial.crunchbase_companies
      WHERE founded_year >= 2012
      GROUP BY 1
    ) c
LEFT JOIN (
          SELECT
                acquired_quarter AS quarter,
                COUNT(DISTINCT company_permalink) AS companies_acquired
          FROM tutorial.crunchbase_acquisitions
          WHERE acquired_year >= 2012
          GROUP BY 1
    ) a
ON c.quarter = a.quarter
ORDER BY 1
