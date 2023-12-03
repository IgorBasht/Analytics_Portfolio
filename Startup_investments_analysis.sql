-- Исследование данных об инвестициях венчурных фондов в компании-стартапы

 -- ==========================================================================
 
SELECT count(status) 
FROM company
WHERE status = 'closed' 
 
 -- ==========================================================================
 
SELECT funding_total 
FROM company
WHERE category_code = 'news'  AND country_code = 'USA'
ORDER BY funding_total DESC;
 
 -- ==========================================================================
 
SELECT SUM(price_amount)
FROM acquisition
WHERE (EXTRACT(YEAR FROM CAST(acquired_at AS date)) >= 2011 
      AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) <= 2013) 
      AND term_code = 'cash';
              
 -- ==========================================================================
 
SELECT first_name, 
       last_name, 
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%'

 -- ==========================================================================
 
SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%'
 
 -- ==========================================================================
 
SELECT country_code AS country,
       SUM(funding_total) AS raised_sum
FROM company 
GROUP BY country_code
ORDER BY raised_sum DESC

 -- ==========================================================================
 
SELECT funded_at, 
       MIN(raised_amount) min,
       MAX(raised_amount) max
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount)!= 0 
       AND MIN(raised_amount) != MAX(raised_amount)
   
 -- ==========================================================================
 
SELECT *, 
      CASE
          WHEN invested_companies >= 100 THEN 'high_activity'
          WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
          ELSE 'low_activity'
      END     
FROM fund

 -- ==========================================================================
 
SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds )) AS mean
FROM fund
GROUP BY activity
ORDER BY mean;

 -- ==========================================================================
 
SELECT country_code,
      MIN(invested_companies),     
      MAX(invested_companies), 
      AVG(invested_companies ) as mean
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) >= 2010 
      AND EXTRACT(YEAR FROM CAST(founded_at AS date)) <= 2012 
GROUP BY country_code 
HAVING MIN(invested_companies) != 0
ORDER BY mean DESC, country_code
LIMIT 10;

 -- ==========================================================================
 
SELECT first_name,
       last_name,
       instituition 
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id

 -- ==========================================================================
 
SELECT c.name, 
       COUNT(DISTINCT instituition) AS inst_count
FROM company AS c
JOIN people AS p ON c.id = p.company_id
JOIN education AS e ON p.id = e.person_id
GROUP BY c.name
ORDER BY inst_count DESC
LIMIT 5;

 -- ==========================================================================
 
SELECT DISTINCT c.name
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE  c.status = 'closed' AND fr.is_first_round = 1 AND fr.is_last_round  = 1
  
 -- ==========================================================================
 
SELECT DISTINCT p.id
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
JOIN people as p ON p.company_id = c.id
WHERE c.status = 'closed' AND fr.is_first_round = 1 AND fr.is_last_round  = 1

 -- ==========================================================================
 
SELECT DISTINCT p.id AS pid, e.instituition 
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
JOIN people as p ON p.company_id = c.id
JOIN education AS e  ON p.id = e.person_id 
WHERE c.status = 'closed' AND fr.is_first_round = 1 AND fr.is_last_round  = 1

 -- ==========================================================================
 
SELECT DISTINCT p.id AS pid, COUNT(DISTINCT e.id)
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
JOIN people as p ON p.company_id = c.id
JOIN education AS e  ON p.id = e.person_id 
WHERE c.status = 'closed' AND fr.is_first_round = 1 AND fr.is_last_round  = 1
GROUP BY pid

 -- ==========================================================================
 
SELECT AVG(i.e_count_id)
FROM (SELECT DISTINCT p.id AS pid, COUNT(DISTINCT e.id) AS e_count_id
             FROM company AS c
             JOIN funding_round AS fr ON c.id = fr.company_id
             JOIN people as p ON p.company_id = c.id
             JOIN education AS e  ON p.id = e.person_id 
             WHERE c.status = 'closed' AND fr.is_first_round = 1 AND fr.is_last_round  = 1
             GROUP BY pid) AS i

 -- ==========================================================================
 
SELECT AVG(i.e_count_id)
FROM (SELECT DISTINCT p.id AS pid, COUNT(DISTINCT e.id) AS e_count_id
             FROM company AS c
             JOIN funding_round AS fr ON c.id = fr.company_id
             JOIN people as p ON p.company_id = c.id
             JOIN education AS e  ON p.id = e.person_id 
             WHERE c.name = 'Facebook'
             GROUP BY pid) AS i

 -- ==========================================================================
 
SELECT f.name AS name_of_fund, 
       c.name AS name_of_company,
       fr.raised_amount  AS amount 
FROM investment AS i
JOIN company AS c ON i.company_id = c.id
JOIN fund AS f ON i.fund_id = f.id
JOIN funding_round AS fr ON i.funding_round_id = fr.id
WHERE c.milestones > 6 AND (EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) >= 2012 
      AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) <= 2013) 

 -- ==========================================================================
 
SELECT p.name, 
       price_amount, 
       k.name, 
      k.funding_total,
       ROUND(price_amount/k.funding_total) AS sum_total
FROM acquisition AS a 
JOIN company AS p ON  a.acquiring_company_id = p.id
JOIN company AS k ON  a.acquired_company_id = k.id
WHERE  k.funding_total != 0 AND price_amount != 0
ORDER BY price_amount DESC,  k.name
LIMIT 10;

 -- ==========================================================================
 
SELECT c.name, 
       -- c.category_code, 
        EXTRACT(MONTH FROM CAST(fr.funded_at AS date))--, 
       -- raised_amount 
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
WHERE (EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) >= 2010 
      AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) <= 2013) AND c.category_code ='social' 
      AND raised_amount != 0
 
 -- ==========================================================================
 
WITH
name_f AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at  AS date)) AS month_x,
                  COUNT(DISTINCT f.name) AS name_fund
       FROM funding_round AS fr    
       JOIN investment AS i ON fr.id = i.funding_round_id
       JOIN fund AS f ON i.fund_id = f.id
       WHERE (EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) >= 2010 
              AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) <= 2013) 
              AND f.country_code = 'USA'
       GROUP BY month_x),
count_c AS (SELECT EXTRACT(MONTH FROM CAST(acquired_at  AS date)) AS month_x,
                   COUNT(a.acquired_company_id) AS count_company,
                    SUM(a.price_amount)
            FROM acquisition AS a
            WHERE (EXTRACT(YEAR FROM CAST(acquired_at AS date)) >= 2010 
                   AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) <= 2013) 
            GROUP BY month_x)       


SELECT nf.month_x, name_fund, count_company, sum
FROM name_f AS nf JOIN count_c AS cc ON nf.month_x = cc.month_x
 
 -- ==========================================================================
 
WITH
y_11 AS (SELECT country_code, 
               AVG(funding_total) AS avg_2011
        FROM company
        WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2011
        GROUP BY country_code),
y_12 AS (SELECT country_code, 
               AVG(funding_total) AS avg_2012
        FROM company
        WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2012
        GROUP BY country_code),
y_13 AS (SELECT country_code, 
               AVG(funding_total) AS avg_2013
        FROM company
        WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2013
        GROUP BY country_code)        

SELECT y_11.country_code, 
       avg_2011, 
       avg_2012, 
       avg_2013
FROM y_11 
JOIN y_12 ON y_11.country_code = y_12.country_code
JOIN y_13 ON y_11.country_code = y_13.country_code
ORDER BY avg_2011 desc

