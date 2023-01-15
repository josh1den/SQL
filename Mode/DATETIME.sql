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
