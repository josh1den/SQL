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
