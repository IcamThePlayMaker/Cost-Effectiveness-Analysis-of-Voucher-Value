#Understand data
WITH DL AS 
(
SELECT transaction_date,voucher_name,transaction_time,customer_id 
FROM `bitlabs-dab.I_CID_03.order`   
WHERE voucher_name = "mass_voucher_25%" order by 1 asc),

 LP AS
(
SELECT transaction_date,voucher_name,transaction_time,customer_id 
FROM `bitlabs-dab.I_CID_03.order`   
WHERE voucher_name = "mass_voucher_50%" order by 1 asc)

SELECT 
LP.voucher_name,
LP.Customer_id,
DL.voucher_name
FROM 
LP
JOIN DL
ON LP.customer_ID = DL.customer_ID ;

SELECT  count(customer_id),customer_id,voucher_name
FROM `bitlabs-dab.I_CID_03.order`  
GROUP BY 2,3
HAVING COUNT(customer_id)>1
order by 1 desc ;

SELECT  customer_id,voucher_name
FROM `bitlabs-dab.I_CID_03.order`  
where customer_id = '7a6ee9-0542-4498-a5fa-29fd16c3bf' ; 
# jadi ini customernya beda beda antara mass_voucher 50 dan 25 kemungkinan  mereka sedang melakukan A/B testing untuk customer yang berbeda
#agar dapat mengetahui behavior purchase ketika mendapat trigger welcome discount 50 atau 25 



--------------------------------------------------------------------------------------------------------------------------------------------------

WITH Step1 as 
(
-- show retention order from first purchase of each customer in a month of 50% voucher program (Maret)
SELECT
    D.id,
    first_date_purchase,
    (retention_purchase-First_day_purchase) AS day_range_from_first
FROM 
      (SELECT         
          min(extract(day from transaction_date)) AS First_day_purchase,
          min(transaction_date) First_date_purchase,
          customer_id  AS ID
      FROM `bitlabs-dab.I_CID_03.order` 
      WHERE 
          voucher_name = "mass_voucher_50%" AND voucher_value !=0
      GROUP BY 3
      order by 1 asc) F,

      (SELECT
          customer_id ID,
          extract(day FROM transaction_date) AS retention_purchase
      FROM `bitlabs-dab.I_CID_03.order` 
      WHERE
          voucher_name = 'mass_voucher_50%' AND  voucher_value !=0
            ) D

WHERE F.ID=D.ID
ORDER BY 2 asc
),

 step2 AS (
-- counting the number of unique customer for each day and range_day_order
SELECT
    first_date_purchase,
    step1.day_range_from_first AS range_order_retention_from_startdate,
    count(distinct step1.ID)  AS Number_Retention_buyers
FROM 
    step1
GROUP BY 1,2
order by 1 asc,2 asc
),

step3 AS 
(
-- window total unique buyers into column based on each first day purchase (this step must done so that the percentage can be calculated in the end of query )
SELECT
    first_date_purchase,
    step2.range_order_retention_from_startdate,
    Number_Retention_buyers,
    FIRST_VALUE(step2.Number_Retention_buyers) OVER (PARTITION BY first_date_purchase ORDER BY step2.range_order_retention_from_startdate) AS total_buyer_in_start_date
FROM step2
)
SELECT
--- SHOWING PERCENTAGE of cohort retention
    first_date_purchase,
    step3.range_order_retention_from_startdate,
    Number_Retention_buyers, 
    total_buyer_in_start_date,
    SAFE_DIVIDE(Number_Retention_buyers, total_buyer_in_start_date) AS in_percentage
FROM
step3  ;

----------------------------------------------------------------------------------------------------

WITH C25 as 
(
-- show retention order from first purchase of each customer in a month of 25% voucher program (June)
SELECT
    D.id,
    first_date_purchase,
    (retention_purchase-First_day_purchase) AS day_range_from_first
FROM 
      (SELECT         
          min(extract(day from transaction_date)) AS First_day_purchase,
          min(transaction_date) First_date_purchase,
          customer_id  AS ID
      FROM `bitlabs-dab.I_CID_03.order` 
      WHERE 
          voucher_name = "mass_voucher_25%" AND voucher_value !=0
      GROUP BY 3
      order by 1 asc) F,

      (SELECT
          customer_id ID,
          extract(day FROM transaction_date) AS retention_purchase
      FROM `bitlabs-dab.I_CID_03.order` 
      WHERE
          voucher_name = 'mass_voucher_25%' AND  voucher_value !=0
            ) D

WHERE F.ID=D.ID
ORDER BY 2 asc
),

 C251 AS 
 (
-- counting the number of unique customer for each day and range_day_order
SELECT
    first_date_purchase, 
    day_range_from_first AS range_order_retention_from_startdate,
    count(distinct ID)  AS Number_Retention_buyers
FROM 
    C25
GROUP BY 1,2
order by 1 asc,2 asc
),

C252 AS 
(
--- window total unique buyers into column based on each first day purchase (this step must done so that the percentage can be calculated in the end of query )
SELECT
    first_date_purchase,
    range_order_retention_from_startdate,
    Number_Retention_buyers,
    FIRST_VALUE(Number_Retention_buyers) OVER (PARTITION BY first_date_purchase ORDER BY range_order_retention_from_startdate) AS  total_buyer_in_start_date
FROM C251
)
SELECT
--- SHOWING PERCENTAGE of cohort retention
    first_date_purchase,
    range_order_retention_from_startdate,
    Number_Retention_buyers, 
     total_buyer_in_start_date,
    SAFE_DIVIDE(Number_Retention_buyers,  total_buyer_in_start_date) AS in_percentage
FROM
C252

 
