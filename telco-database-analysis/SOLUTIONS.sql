-- ==============================================================================
-- PROJECT: i2i Systems Telecom Data Analysis
-- DEVELOPER: Samet Bekir Yuksel
-- ROLE: Database Developer
-- DESCRIPTION: SQL Solutions for business scenarios and data insights.
-- ==============================================================================

-- 1. TARIFF-BASED CUSTOMER QUERIES

-- 1.1 List customers subscribed to the 'Kobiye Destek' tariff.
/* 
To list the customers using the 'Kobiye Destek' plan, I joined the CUSTOMERS and TARIFFS tables on their common column, TARIFF_ID. 
I then used a WHERE clause to filter the results specifically for this tariff name. 
Finally, I added an ORDER BY clause to sort the output alphabetically by customer name, making the final list organized and easy to read.
*/

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, t.NAME AS TARIFF_NAME
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.NAME;


-- 1.2 Find the newest customer subscribed to this tariff.

/* 
I needed to find the most recent signup for this specific tariff. 
Since the SIGNUP_DATE is stored as a string in the database, I used the TO_DATE function to convert it into a proper date format so the database can sort it chronologically. 
I ordered the dates in descending order and used FETCH FIRST 1 ROW ONLY to retrieve just the absolute newest record.
*/

SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE, t.NAME AS TARIFF_NAME
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY TO_DATE(c.SIGNUP_DATE, 'DD/MM/YYYY') DESC
FETCH FIRST 1 ROW ONLY;


-- 2. TARIFF DISTRIBUTION

-- 2.1 Find the distribution of tariffs among customers (including market share percentage).

/* 
To see how customers are distributed across different plans, I grouped the data by tariff name and counted the CUSTOMER_IDs for each group. 
To make the report more detailed, I also calculated the percentage share of each tariff within the total user base. 
I achieved this by using the SUM OVER() analytical function to get the total count, and I used the ROUND function to keep the result clean with two decimal places before appending the percentage sign.
*/


SELECT 
    t.NAME AS TARIFF_NAME, 
    COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS,
    ROUND(COUNT(c.CUSTOMER_ID) / SUM(COUNT(c.CUSTOMER_ID)) OVER() * 100, 2) || '%' AS MARKET_SHARE
FROM SYSTEM.TARIFFS t
LEFT JOIN SYSTEM.CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.NAME
ORDER BY TOTAL_CUSTOMERS DESC;



-- 3. CUSTOMER REGISTRATION ANALYSIS

-- 3.1 Identify the oldest customers (Dual-Perspective Analysis)
/* 
I approached finding the oldest customers in two ways to provide a better technical view. 
In Solution A, I used a direct WHERE clause to filter specifically for the absolute first day of service ('07/04/2025'). 
In Solution B, I used the LIKE operator to capture all signups within the entire launch month (April 2025). I ordered the second list using TO_DATE to ensure the chronological sequence is correct regardless of string formats.*/

-- Solution A: Identity list of absolute "Day One" Pioneers (April 7th, 2025)
SELECT CUSTOMER_ID, NAME, SIGNUP_DATE
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE = '07/04/2025'
ORDER BY NAME;

-- Solution B: Identity list of the entire "Launch Month" Cohort (April 2025)
SELECT CUSTOMER_ID, NAME, SIGNUP_DATE
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE LIKE '%/04/2025'
ORDER BY TO_DATE(SIGNUP_DATE, 'DD/MM/YYYY') ASC;


-- 3.2 Find the geographical distribution of these earliest subscribers.
/* 
To analyze the geographical distribution of the first  customers, I grouped the dataset by the CITY column and provided two separate views. 
In Solution A, I filtered the data specifically for the first day of service ('07/04/2025') to see the immediate impact. 
In Solution B, I expanded the scope to include all registrations within the first month (April 2025) using the LIKE operator. 
For both solutions, I used the SUM OVER() function to calculate each city's percentage share. 
I also applied the 'FM990.00' format mask so that values under 1% retain their leading zero (e.g., %0.94) for a consistent layout.*/

-- Solution A: City Distribution for "Day One" Pioneers (April 7th, 2025)

SELECT 
    CITY, 
    COUNT(*) AS PIONEER_COUNT,
    '%' || TO_CHAR(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 'FM990.00') AS REGIONAL_SHARE
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE = '07/04/2025'
GROUP BY CITY
ORDER BY PIONEER_COUNT DESC;


-- Solution B: City Distribution for the entire "Launch Month" (April 2025)

SELECT 
    CITY, 
    COUNT(*) AS APRIL_CUSTOMER_COUNT,
    '%' || TO_CHAR(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 'FM990.00') AS REGIONAL_SHARE
FROM SYSTEM.CUSTOMERS
WHERE SIGNUP_DATE LIKE '%/04/2025'
GROUP BY CITY
ORDER BY APRIL_CUSTOMER_COUNT DESC;




-- 4. MISSING MONTHLY RECORDS


-- 4.1 Determine the IDs of customers with missing monthly records.
/* 
To find customers who are registered in the system but have no monthly usage records, I used the MINUS operator. 
This command takes all CUSTOMER_IDs from the main CUSTOMERS table and subtracts the ones found in the MONTHLY_STATS table. 
The remaining IDs are the missing records, which helps us quickly spot data insertion or synchronization issues.*/


SELECT CUSTOMER_ID FROM SYSTEM.CUSTOMERS
MINUS
SELECT CUSTOMER_ID FROM SYSTEM.MONTHLY_STATS;


-- 4.2 Find the distribution of missing customers across different cities.

/* 
To analyze the distribution of missing customers across cities, I used a subquery with the NOT IN operator in the WHERE clause. 
This effectively filters out the customers who do not exist in the MONTHLY_STATS table. 
I then grouped the remaining records by the CITY column. 
I also included a percentage calculation using the SUM OVER() function, formatted with 'FM990.00', to clearly show the regional share of these missing data points.
*/


SELECT 
    CITY, 
    COUNT(*) AS MISSING_RECORD_COUNT,
    '%' || TO_CHAR(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 'FM990.00') AS GAP_SHARE
FROM SYSTEM.CUSTOMERS
WHERE CUSTOMER_ID NOT IN (SELECT CUSTOMER_ID FROM SYSTEM.MONTHLY_STATS)
GROUP BY CITY
ORDER BY MISSING_RECORD_COUNT DESC;


-- 5. USAGE ANALYSIS

-- 5.1 Find customers who have used at least 75% of their data limit.
/* 
To identify customers approaching their data limit, I calculated the ratio of DATA_USAGE to DATA_LIMIT. 
I used a WHERE clause to filter for users who have reached 0.75 (75%) or more of their quota. 
I formatted this ratio into a readable percentage using the TO_CHAR function. 
I also included the CUSTOMER_ID in the SELECT statement to ensure we can uniquely identify each user, since filtering by name alone could lead to confusion.
*/

SELECT 
    c.CUSTOMER_ID,
    c.NAME, 
    ms.DATA_USAGE, 
    t.DATA_LIMIT, 
    '%' || TO_CHAR((ms.DATA_USAGE / t.DATA_LIMIT) * 100, 'FM999.00') AS USAGE_RATIO
FROM SYSTEM.MONTHLY_STATS ms
JOIN SYSTEM.CUSTOMERS c ON ms.CUSTOMER_ID = c.CUSTOMER_ID
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.DATA_LIMIT > 0 
  AND (ms.DATA_USAGE / t.DATA_LIMIT) >= 0.75
ORDER BY (ms.DATA_USAGE / t.DATA_LIMIT) DESC;



-- 5.2 Identify customers who have consumed all of their package limits (Data, Minutes, and SMS).
/* 
To identify subscribers who have completely exhausted all their package allocations, I used the AND operator to strictly filter for records where data, voice, and SMS usage meet or exceed their respective limits simultaneously. 
I also concatenated the usage and limit values within the SELECT statement to create a clear, consolidated view of quota exhaustion. 
However, upon executing this query, the result set returned empty. 
This operational execution confirms that there are currently no users in the dataset who have maxed out all three service dimensions at the same time.
*/

SELECT 
    c.CUSTOMER_ID,
    c.NAME, 
    t.NAME AS CURRENT_TARIFF,
    ms.DATA_USAGE || ' / ' || t.DATA_LIMIT AS DATA_STATUS,
    ms.MINUTE_USAGE || ' / ' || t.MINUTE_LIMIT AS VOICE_STATUS,
    ms.SMS_USAGE || ' / ' || t.SMS_LIMIT AS SMS_STATUS
FROM SYSTEM.MONTHLY_STATS ms
JOIN SYSTEM.CUSTOMERS c ON ms.CUSTOMER_ID = c.CUSTOMER_ID
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE ms.DATA_USAGE >= t.DATA_LIMIT 
  AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND ms.SMS_USAGE >= t.SMS_LIMIT;

-- 6. PAYMENT ANALYSIS

-- 6.1 Find customers with unpaid fees.

/* 
To identify subscribers with outstanding balances, I generated a list of all accounts currently marked as unpaid. 
I utilized the UPPER function in the WHERE clause to make the query case-insensitive, ensuring I capture all relevant records regardless of how the data was entered. 
I joined the customer data with the tariffs table to accurately display the specific monetary value and plan name associated with each debt. 
Finally, I ordered the results by the monthly fee in descending order so that the highest outstanding balances appear at the top of the report.
*/

SELECT 
    c.CUSTOMER_ID,
    c.NAME, 
    t.NAME AS TARIFF_NAME, 
    ms.PAYMENT_STATUS, 
    t.MONTHLY_FEE
FROM SYSTEM.MONTHLY_STATS ms
JOIN SYSTEM.CUSTOMERS c ON ms.CUSTOMER_ID = c.CUSTOMER_ID
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE UPPER(ms.PAYMENT_STATUS) = 'UNPAID'
ORDER BY t.MONTHLY_FEE DESC;


-- 6.2 Find the distribution of payment statuses across different tariffs.
/* 
To analyze the distribution of payment statuses across different plans, I grouped the records by both tariff name and payment status. 
I utilized the PARTITION BY clause within the SUM OVER() analytical function to calculate the specific percentage share of paid versus unpaid accounts for each individual tariff. 
This technical approach allowed me to generate a statistical breakdown of billing health without losing the context of individual plan sizes. 
I applied the 'FM990.00' format mask using TO_CHAR to ensure the resulting percentages maintain a consistent and readable presentation.
*/

SELECT 
    t.NAME AS TARIFF_NAME, 
    ms.PAYMENT_STATUS, 
    COUNT(*) AS TRANSACTION_COUNT,
    '%' || TO_CHAR(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY t.NAME) * 100, 'FM990.00') AS STATUS_SHARE
FROM SYSTEM.MONTHLY_STATS ms
JOIN SYSTEM.CUSTOMERS c ON ms.CUSTOMER_ID = c.CUSTOMER_ID
JOIN SYSTEM.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, ms.PAYMENT_STATUS
ORDER BY t.NAME, ms.PAYMENT_STATUS;