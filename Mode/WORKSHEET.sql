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
