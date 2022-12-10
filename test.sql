---Bagaimana dampak terhadap transaksi dalam satu bulanya?
WITH V50 AS (

SELECT 
  count(transaction_id) Total_Transaction_50_voucher     
FROM `bitlabs-dab.I_CID_03.order` 
WHERE voucher_name = "mass_voucher_50%" and  voucher_value !=0),

comparedata as (
SELECT 
  count(transaction_id) Total_Transaction_25_voucher,
  Total_Transaction_50_voucher   
FROM 
  `bitlabs-dab.I_CID_03.order`,V50 
WHERE 
    voucher_name = "mass_voucher_25%" and  voucher_value !=0
GROUP by 2)

SELECT 
    100*ROUND((Total_Transaction_25_voucher-Total_Transaction_50_voucher)/Total_Transaction_50_voucher,3) AS Percent_decrease
FROM comparedata; 
# in june, when customer got 25% welcome voucher, transaction drop 86.8%  compared to transaction with 50% welcome voucher in march