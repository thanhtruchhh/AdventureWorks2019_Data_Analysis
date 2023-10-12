-- Q1: Calc Quantity of items, Sales value & Order quantity by each Subcategory in L12M.
-- Output: Period, subcat name, qty, line total, order

-- Find last 12 months
WITH l12m AS (
  SELECT DATE_TRUNC(
    DATE_SUB(
      CAST(MAX(ModifiedDate) AS DATETIME), 
      INTERVAL 12 MONTH
    ), 
    MONTH)
  FROM `adventureworks2019.Sales.SalesOrderDetail` 
)

SELECT 
  FORMAT_DATE('%h %Y', d.ModifiedDate) AS period,
  s.Name,
  SUM(OrderQty) AS qty_item,
  SUM(LineTotal) AS total_sales,
  COUNT(DISTINCT SalesOrderID) AS order_cnt,
FROM `adventureworks2019.Sales.SalesOrderDetail` AS d
INNER JOIN `adventureworks2019.Production.Product` AS p USING (ProductID)
INNER JOIN `adventureworks2019.Production.ProductSubcategory` AS s ON CAST(p.ProductSubcategoryID AS INT) = s.ProductSubcategoryID
WHERE CAST(d.ModifiedDate AS DATETIME) >= (
  SELECT *
  FROM l12m
)
GROUP BY 1, 2
ORDER BY 1 DESC, 2;


-- Q2: Calc % YoY growth rate by SubCategory & release top 3 cat with highest grow rate. Round results to 2 decimal.
-- Output: Subcat name, cur quantity item, pre quantity item, growth rate

-- Calc item quantity of each subcat by year
WITH item_quantity AS (
  SELECT
    EXTRACT(YEAR FROM d.ModifiedDate) yr, 
    ProductSubcategoryID,
    SUM(OrderQty) qty_item
  FROM `adventureworks2019.Sales.SalesOrderDetail` d
  INNER JOIN `adventureworks2019.Production.Product` p USING(ProductID)
  GROUP BY 1, 2
),

-- Get previous item quantity of each subcat
pre_item_quantity AS (
  SELECT
    *,
    LAG(qty_item) OVER(
      PARTITION BY ProductSubcategoryID
      ORDER BY yr
    ) AS prv_qty
  FROM item_quantity
)

SELECT 
  s.Name,
  qty_item,
  prv_qty,
  ROUND((qty_item - prv_qty) / prv_qty, 2) qty_diff
FROM pre_item_quantity q
INNER JOIN `adventureworks2019.Production.ProductSubcategory` s ON CAST(q.ProductSubcategoryID AS INT) = s.ProductSubcategoryID
ORDER BY 2 DESC
LIMIT 3;


-- Q3: Rank top 3 TeritoryID with biggest order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number.
-- Output: Year, teritory id, order qty, rank

-- Calc orderd items of each territory every year 
WITH total_items AS (
  SELECT 
    EXTRACT(YEAR FROM d.ModifiedDate) AS yr,
    TerritoryID,
    SUM(OrderQty) AS order_cnt
  FROM `adventureworks2019.Sales.SalesOrderDetail` d
  INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` h USING(SalesOrderID)
  GROUP BY 1, 2
),

-- Rank territory with biggest Order quantity of every year
rank_territory AS (
  SELECT 
    *,
    DENSE_RANK() OVER(
      PARTITION BY yr
      ORDER BY order_cnt DESC
    ) AS rk
  FROM total_items
)

SELECT * 
FROM rank_territory
WHERE rk <= 3
ORDER BY 
  MOD(yr, 2), -- Categorize years as even or odd 
  yr DESC, 
  rk;

-- Q4: Calc Total Discount Cost belongs to Seasonal Discount for each SubCategory.
-- Output: Year, subcat name, total cost for discount.

SELECT 
  FORMAT_DATE('%Y', d.ModifiedDate) AS yr,
  s.Name,
  SUM(DiscountPct * UnitPrice * OrderQty) AS total_cost
FROM `adventureworks2019.Sales.SalesOrderDetail` d
INNER JOIN `adventureworks2019.Sales.SpecialOffer` o USING (SpecialOfferID)
INNER JOIN `adventureworks2019.Production.Product` p ON d.ProductID = p.ProductID
INNER JOIN `adventureworks2019.Production.ProductSubcategory` s ON CAST(p.ProductSubcategoryID AS INT) = s.ProductSubcategoryID
WHERE o.Type = 'Seasonal Discount'
GROUP BY 1, 2
ORDER BY 1;

-- Q5: Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis).
-- Output: month join, month diff, customer count

-- Get customer whose orders with status = shipped and year = 2014
WITH shipped_2014 AS (
  SELECT 
    CustomerID,
    ModifiedDate
  FROM `adventureworks2019.Sales.SalesOrderHeader`
  WHERE 
    EXTRACT(YEAR FROM ModifiedDate) = 2014
    AND Status = 5 -- 5 = shipped
),

-- Get 1st month 
first_months AS (
  SELECT 
    CustomerID,
    EXTRACT(MONTH FROM MIN(ModifiedDate)) AS first_mth
  FROM shipped_2014
  GROUP BY CustomerID
),

-- Get retention month
retention_months AS (
  SELECT 
    CustomerID,
    EXTRACT(MONTH FROM ModifiedDate) AS retention_mth
  FROM shipped_2014
)

SELECT 
  first_mth month_join,
  CONCAT('M-', retention_mth - first_mth) month_diff,
  COUNT(DISTINCT CustomerID) customer_cnt
FROM first_months
INNER JOIN retention_months USING(CustomerID)
GROUP BY 1, 2
ORDER BY 1, 2;

