-- Q6: Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal.
-- Output: Product name, month, year, cur stock, pre stock, % growth rate

-- Calc stock quantity of each month
WITH stock_quantity AS (
  SELECT 
    Name,
    EXTRACT(MONTH FROM w.ModifiedDate) mth,
    EXTRACT(YEAR FROM w.ModifiedDate) yr,
    SUM(StockedQty) stock_qty
  FROM `adventureworks2019.Production.WorkOrder` w
  INNER JOIN `adventureworks2019.Production.Product` p USING(ProductID)
  WHERE EXTRACT(YEAR FROM w.ModifiedDate) = 2011
  GROUP BY 1, 3, 2
),

-- Get stock quantity of the last month
pre_stock AS (
  SELECT 
    *,
    LAG(stock_qty) OVER(
      PARTITION BY Name, yr
      ORDER BY mth
    ) stock_prv
  FROM stock_quantity
)

SELECT 
  *,
  ROUND(
    CASE
      WHEN stock_prv IS NULL THEN 0
      ELSE 100 * (stock_qty - stock_prv) / stock_prv
    END, 1) diff
FROM pre_stock
ORDER BY Name, mth DESC;


-- Q7: Calc MoM Ratio of Stock / Sales in 2011 by product name. Order results by month desc, ratio desc. Round Ratio to 1 decimal.
-- Output: Month, year, product id, name, stock qty, order qty, ration

-- Calc stock quantity of each product by month
WITH stock_qty AS (
  SELECT 
    EXTRACT(MONTH FROM ModifiedDate) mth,
    EXTRACT(YEAR FROM ModifiedDate) yr,
    ProductId,
    SUM(StockedQty) stock
  FROM `adventureworks2019.Production.WorkOrder`
  WHERE EXTRACT(YEAR FROM ModifiedDate) = 2011
  GROUP BY 2, 1, 3
),

-- Calc order quantity of each product by month
order_count AS (
  SELECT 
    EXTRACT(MONTH FROM ModifiedDate) mth,
    EXTRACT(YEAR FROM ModifiedDate) yr,
    ProductId,
    SUM(OrderQty) sales
  FROM `adventureworks2019.Sales.SalesOrderDetail`
  WHERE EXTRACT(YEAR FROM ModifiedDate) = 2011
  GROUP BY 2, 1, 3
)

SELECT 
  mth,
  yr,
  ProductId,
  Name,
  sales,
  stock,
  ROUND(stock / sales, 2) AS ratio
FROM stock_qty
FULL JOIN order_count
USING(mth, yr, ProductId)
INNER JOIN `adventureworks2019.Production.Product` USING(ProductID)
ORDER BY 
  1 DESC, 
  7 DESC;

  