# AdventureWorks2019 Data Analysis

This project uses SQL on the Google BigQuery to analyze the AdventureWorks2019 database, which contains a vast array of information related to a fictional company's operations in the Sales, Production, and Purchasing departments. 

## Data dictionary
The AdventureWorks database supports standard online transaction processing scenarios for a fictitious bicycle
manufacturer (Adventure Works Cycles). Scenarios include Manufacturing, Sales, Purchasing, Product Management,
Contact Management, and Human Resources.

You can refer to the [AdventureWorks Data Dictionary](https://drive.google.com/file/d/1bwwsS3cRJYOg1cvNppc1K_8dQLELN16T/view) for detailed information on the dataset.

## Questions

### Sales Department
- **Query 1:** Calculate the quantity of items sold, total sales value, and order quantity for each product subcategory over the last 12 months.
- **Query 2:** Calculate the Year-over-Year (YoY) growth rate for each subcategory and identifies the top three categories with the highest growth rates. Round result to 2 decimal.
- **Query 3:** Rank the top 3 TerritoryIDs with the highest order quantity for each year. In case of tie, the rank is not skipped.
- **Query 4:** Determine the total discount cost related to seasonal discounts for each subcategory.
- **Query 5:** Determine retention rate of customers in the year 2014 who had orders with a "Successfully Shipped" status (Cohort Analysis).

### Production Department
- **Query 6:** Analyze the trend of stock levels and calculates the Month-over-Month (MoM) difference percentage for all products in the year 2011. In cases where the growth rate is null, it is considered as 0%. Round result to 1 decimal.
- **Query 7:** Compute the MoM ratio of stock to sales for each product (product name) in the year 2011. Sort the result by desc order and round ratio to 1 decimal.

### Purchasing Department
- **Query 8:** Identify the number of orders and their total due to vendor with a "Pending" status in the year 2014.

