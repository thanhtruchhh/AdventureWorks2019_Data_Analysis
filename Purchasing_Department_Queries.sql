-- Q8: No of order and value at Pending status in 2014.
-- Output: Yearm status, order count, value.

SELECT 
  EXTRACT(YEAR FROM ModifiedDate) AS yr,
  Status, 
  COUNT(DISTINCT PurchaseOrderID) AS order_Cnt,
  SUM(TotalDue) value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader` o
WHERE 
  Status = 1 
  AND EXTRACT(YEAR FROM ModifiedDate) = 2014
GROUP BY 1, 2;

