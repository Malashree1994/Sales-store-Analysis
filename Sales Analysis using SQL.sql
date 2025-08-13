select * from sales_store;
-->We can also import dataset using the bulk insert

-->Data cleaning 
select * from sales_store
--> copy data in another table for back up 
select * into sales from sales_store;

select * from sales;
-->Data cleaning 
-- step1  to check  for duplicate 
select transaction_id,count(*) 
from sales
group by transaction_id
having count(transaction_id)>1;

WITH CTE AS(
select *,
row_number() over(partition by transaction_id order by transaction_id) as row_num
from sales
)
--delete from CTE
--where row_num=2

select * from CTE
where transaction_id in('TXN240646','TXN342128','TXN855235','TXN981773');

--Step 2 : Correction of headers 
EXEC sp_rename'sales.quantiy','Quantity','COLUMN'
EXEC sp_rename'sales.prce','Price','COLUMN'
select * from sales

--step 3) check datatype
select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='sales'

--Step 4 to check null count
select * from sales 
where transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
Quantity is null
or
Price is null
or
payment_mode is null
or
purchase_date is null
or 
time_of_purchase is null
or
status is null

delete from sales where transaction_id is null
select * from sales where customer_name='Damini Raju'
update sales
set customer_id='CUST1401'
where customer_name='Damini Raju'
select * from sales

select * from sales
where customer_id='CUST1003'
update sales
set customer_name='Mahika Saini',customer_age=35,gender='Male'
where customer_id='CUST1003'

select * from sales

--step 5. Data cleaning
select distinct gender from sales

update sales
set gender='Male'
Where gender='M'
Update sales 
set gender='Female'
Where gender='F'
_
select distinct payment_mode
from sales
update sales
SET payment_mode='Credit Card'
where payment_mode='CC'

--Data Analysis 
--Q1)What are the top five selling products by quantity.?
select top 5 product_name,sum(Quantity) as total_quantity_sold
from sales
where status='delivered'
group by product_name
order by total_quantity_sold desc
--Business problem : we dont know which products are most in demand.
--Business impact : It helps to priorities stock and boost the sales thorugh promotion.

--Q2)Which products are frequently cancelled ?
select top 5 product_name,count(*) as total_cancelled
from sales
where status='cancelled'
group by product_name
order by total_cancelled desc

--Business problem: Frequent cancelled affect revenue and customer trust.
--Business impact : Identify poor-performing products to improve qulity or remove from catalog.

--3)What time of the day has the highest number of purchase.?
select * from sales 
select 
case 
when DATEPART(HOUR,time_of_purchase)between 0 and 5 then 'NIGHT'
when DATEPART(HOUR,time_of_purchase)between 6 and 11 then 'MORNING'
when DATEPART(HOUR,time_of_purchase)between 12 and 17 then 'AFTERNOON'
when DATEPART(HOUR,time_of_purchase)between 18 and 23 then 'EVENING'
END AS time_of_day,
count(*) as total_orders
from sales
group by 
case 
when DATEPART(HOUR,time_of_purchase)between 0 and 5 then 'NIGHT'
when DATEPART(HOUR,time_of_purchase)between 6 and 11 then 'MORNING'
when DATEPART(HOUR,time_of_purchase)between 12 and 17 then 'AFTERNOON'
when DATEPART(HOUR,time_of_purchase)between 18 and 23 then 'EVENING'
END
order by total_orders desc
--Business problem solved : Find peak sales time
--Business Impact :Optimize staffing, promotion, and server loaads

--Q4)Who are the top 5 highest spending customers
select * from sales
select top 5 customer_name, 
format(sum(Price*Quantity),'c0','en-IN') as total_spent
from sales
group by customer_name
order by sum(Price*Quantity) DESC

--Business problem solved : Identify the VIP customers 
-->Business impact : Personalized categories generate the highest revenue

--Q5) Which product categories generate the highest revenue 
select * from sales;
select product_category,
format(sum(Price*Quantity),'c0','en-IN') as total_spent
from sales 
group by product_category
order by sum(Price*Quantity) desc

--Business problem solved : Top performing product categories.
--Business Impact : Refine product strategy, supply chain, and promotion
--allowing the business to invest more in high -margin or high demand categories

--Q6)What is the return/cancellation rate per product category?
select * from sales 
--cancellation
select product_category,
format(count(case when status='cancelled' then 1 end)*100.0/count(*),'N3')+'%' as cancelled_percent
from sales
group by product_category
order by cancelled_percent desc 
--Return
select product_category,
format(count(case when status='returned' then 1 end)*100.0/count(*),'N3')+'%' as return_percent
from sales
group by product_category
order by return_percent desc 
--Business problem solved : Monitor dissatisfaction trend per category
-- Business Impact: Reduce the return, improve product descriptions/explainations.
--helps identify and fix product or logistics issues 

--Q7)What is the most preferred payment mode?
select * from sales 

select payment_mode ,count(*) as total_count
from sales
group by payment_mode
order by count(*) desc

--Business problem solved : Know which payment options customers prefer.
--Business impact : Streamline payment processing, prioritize popular modes.

--Q8)How does the age group affect the business behavior 
select min(customer_age),max(customer_age) from sales
select 
case
when customer_age between 18 and 25 then '18-25'
when customer_age between 26 and 35 then '26-35'
when customer_age between 36 and 50then '36-50'
else '50+'
end as customer_age, 
format(SUM(Price*Quantity),'c0','en-IN') as total_purchase
from sales 
group by case
when customer_age between 18 and 25 then '18-25'
when customer_age between 26 and 35 then '26-35'
when customer_age between 36 and 50 then '36-50'
else '50+'
end
order by SUM(Price*Quantity) desc

--Business problem solved : Understand customer demographics.
--Business Impact : Targeted marketing and product recommendations by age group.

--Q9) What's the monthly sales trend?
--Method 1 
select 
format(purchase_date,'yyyy-MM') as Month_Year,
format(sum(Price*Quantity),'c0','en-IN') as total_sales,
sum(Quantity) as total_quantity
from sales
group by format(purchase_date,'yyyy-MM')

--Method 2 
select
month(purchase_date) as months,
format(sum(Price*Quantity),'c0','en-IN') as total_sales,
sum(Quantity) as total_quantity
from sales
group by 
month(purchase_date)
order by month(purchase_date)

--Business problem solved :		Sales fluctuations go unnoticed
--Business Impact : Plan inventory and marketing according to seasonal trends 

--Q10) Are certain genders buying more specific product categories?
select gender,product_category,count(product_category) as total_purchase
from sales
group by gender,product_category
order by gender
--Method 2
select *
from
(select gender,product_category from sales) as source_table
pivot(
count(gender)
for gender in ([Male],[Female])
) as pivot_table
order by product_category
--Business problem solved : Gender -based product preferences
--Business Impact : Personalized ads, gender-focused campaigns.








