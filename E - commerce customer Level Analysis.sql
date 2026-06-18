                                                                   -- Customer Level Analysis 

-- objective : finding Our Total_customer  we have
 
SELECT 
    COUNT(DISTINCT (Customer_id)) AS Total_unique_Custome
FROM
    fact_orders_enriched;
    
    
    
--  objective : building a Create Procedure Find    "No_of_New customer"  in the last N Month
    
    
    Delimiter //
     create procedure New_Cust_in_Last_N_Months ( in No_Of_Month int) 
     begin
      with c1 as (
          select customer_id , 
           min(order_Date) as first_purchase_Date
           from fact_orders_enriched
           group by customer_id 
           ),
	c2 AS (
     select customer_id , order_Date
	from fact_orders_enriched
    where order_Date >= 
    date_add(date_sub((select max(order_date) from fact_orders_enriched), interval  No_Of_Month  month) ,
    interval 1 day)    
    ),
    c3 as (
    
    select  count(distinct(CUSTOMER_ID)) as New_Customer from  c1 
    join c2  using(customer_id)
    where order_Date = first_purchase_Date
    )
     select * from c3;
      end
  // 
    delimiter ;
    
 call New_Cust_in_Last_N_Months (2);
	
	
  
  
  
  
  -- objective : Analysing   "AVG Retention_Rate"  Monthly  each Year
  
      with c1 as (
   SELECT 
    customer_id, MIN(order_Date) AS first_purchase_Date
FROM
    fact_orders_enriched
GROUP BY customer_id
		),
 c2 as (
    select 
    customer_id , order_date, first_purchase_Date
	 from fact_orders_enriched 
	join c1  using (customer_id)
    ),
     c3 as (
	 select year(order_Date) as year_, month(order_Date ) as month_  , count(distinct(customer_id)) as Total_Active_customer,
     
     lag(count(distinct(customer_id))) over (partition by year(order_Date) order by month(order_Date ) ) as Last_Month_active_Cust,
     
       count(distinct((case when order_date = first_purchase_Date then customer_id end))) as New_Customer_this_Month,
       
       (count(distinct(customer_id)) -  count(distinct((case when order_date = first_purchase_Date then customer_id end)))) as Last_Months_Repeat_Customer

from c2
        group by year_,month_
       ),
	 c4 as (
      select *, Last_Month_active_Cust -Last_Months_Repeat_Customer as Last_Months_Churned_customer
      from c3
      ),
	c5 as (
    
     SELECT 
    year_,
    month_,
    Total_Active_customer,
    New_Customer_this_Month,
    ROUND((Last_Months_Repeat_Customer * 100) / Last_Month_active_Cust,
            2) AS Retention_Percentage_Last_Months
FROM
    c4
    )
 select  Round(avg(Case when year_ = 2023 then Retention_Percentage_Last_Months end ),2) as AVg_Retention_Percentage_2023,
  Round(avg(Case when year_ = 2024 then Retention_Percentage_Last_Months end ),2) as AVg_Retention_Percentage_2024
 from c5;
       
      
      
      
      
	-- objective  : Analysing AVG_Churn_Percentage Monthly Each year
	


      with c1 as (
   SELECT 
    customer_id, MIN(order_Date) AS first_purchase_Date
FROM
    fact_orders_enriched
GROUP BY customer_id
		),
 c2 as (
    select 
    customer_id , order_date, first_purchase_Date
	 from fact_orders_enriched 
	join c1  using (customer_id)
    ),
     c3 as (
	 select year(order_Date) as year_, month(order_Date ) as month_  , count(distinct(customer_id)) as Total_Active_customer,
     
     lag(count(distinct(customer_id))) over (partition by year(order_Date) order by month(order_Date ) ) as Last_Month_active_Cust,
     
	count(distinct((case when order_date = first_purchase_Date then customer_id end))) as New_Customer_this_Month,
       
	(count(distinct(customer_id)) -  count(distinct((case when order_date = first_purchase_Date then customer_id end)))) as Last_Months_Repeat_Customer
       
from c2
        group by year_,month_
       ),
	 c4 as (
      select *, Last_Month_active_Cust -Last_Months_Repeat_Customer as Last_Months_Churned_customer
      from c3
      ),
	c5 as (
    
     SELECT 
    year_,
    month_,
    Total_Active_customer,
    New_Customer_this_Month,
    ROUND((Last_Months_Churned_customer * 100) / Last_Month_active_Cust,
            2) AS Churned_Percentage_Last_Months
FROM
    c4
    )
 select  Round(avg(Case when year_ = 2023 then Churned_Percentage_Last_Months end ),2) as AVg_Churned_Percentage_2023,
  Round(avg(Case when year_ = 2024 then Churned_Percentage_Last_Months end ),2) as AVg_Churned_Percentage_2024
 from c5;
 
 
 
 
 
  -- objective : Analysing   "AVG_#_New_Customer_joining"   Monthly  each Year
  
  
      with c1 as (
   SELECT 
    customer_id, MIN(order_Date) AS first_purchase_Date
FROM
    fact_orders_enriched
GROUP BY customer_id
		),
 c2 as (
    select 
    customer_id , order_date, first_purchase_Date
	 from fact_orders_enriched 
	join c1  using (customer_id)
    ),
     c3 as (
	 select year(order_Date) as year_, month(order_Date ) as month_  , count(distinct(customer_id)) as Total_Active_customer,
     
     lag(count(distinct(customer_id))) over (partition by year(order_Date) order by month(order_Date ) ) as Last_Month_active_Cust,
     
       count(distinct((case when order_date = first_purchase_Date then customer_id end))) as New_Customer_this_Month,
       
       (count(distinct(customer_id)) -  count(distinct((case when order_date = first_purchase_Date then customer_id end)))) as Last_Months_Repeat_Customer

from c2
        group by year_,month_
       ),
	 c4 as (
      select *, Last_Month_active_Cust -Last_Months_Repeat_Customer as Last_Months_Churned_customer
      from c3
      ),
	c5 as (
    
     SELECT 
    year_,
    month_,
    Total_Active_customer,
    New_Customer_this_Month
   
FROM
    c4
       order by year_, New_Customer_this_Month
    )
     select
       round(avg(case when year_ = 2023 then New_Customer_this_Month end),2) as "AVG_#_New_Customer_2023",
     Round( avg(case when year_ = 2024 then New_Customer_this_Month end),2) as "AVG_#_New_Customer_2024"
      from c5;
    






-- objective  : finding Average Customer_Growth_Rate_Monthly each Year 
    
    
 with c1 as (
  select year as year_, month_,
   Count(distinct(customer_id)) as Active_Customersin_Month,
   lag(Count(distinct(customer_id))) over(partition by  year  order by month_) as Active_Cust_Prev_Month 
   from fact_orders_enriched
   group by year_, month_
   ),
c2 as (
   SELECT 
    *,
    ROUND((Active_Customersin_Month - Active_Cust_Prev_Month) * 100 / Active_Cust_Prev_Month,
            2) AS Cust_Growth_percentage
FROM
    c1
    )
    select 
    ROUND(avg(case when year_ =2023 then Active_Cust_Prev_Month end ),2) as AVg_ACtive_Customer_Monthly_2023,
    
            ROUND(avg(case when year_ = 2023 then Cust_Growth_percentage end),2) as AVg_Cust_Growth_rate_monthly_2023, 
            
            ROUND(avg(case when year_ =2024 then Active_Cust_Prev_Month end ),2) as AVg_ACtive_Customer_Monthly_2024,
            
            ROUND(avg(case when year_ = 2024 then Cust_Growth_percentage end),2) as AVg_Cust_Growth_rate_monthly_2023
     from c2;
     
     
     
     
      
     -- objective : Full oveview of   "Retention and Churn Rate with No_Of_new_Customer"    / Month Each year
	
      with c1 as (
   SELECT 
    customer_id, MIN(order_Date) AS first_purchase_Date
FROM
    fact_orders_enriched
GROUP BY customer_id
		),
 c2 as (
    select 
    customer_id , order_date, first_purchase_Date
	 from fact_orders_enriched 
	join c1  using (customer_id)
    ),
     c3 as (
	 select year(order_Date) as year_, month(order_Date ) as month_  , count(distinct(customer_id)) as Total_Active_customer,
     
     lag(count(distinct(customer_id))) over (partition by year(order_Date) order by month(order_Date ) ) as Last_Month_active_Cust,
     
       count(distinct((case when order_date = first_purchase_Date then customer_id end))) as New_Customer_this_Month,
       
       (count(distinct(customer_id)) -  count(distinct((case when order_date = first_purchase_Date then customer_id end)))) as Last_Months_Repeat_Customer

from c2
        group by year_,month_
       ),
	 c4 as (
      select *, Last_Month_active_Cust -Last_Months_Repeat_Customer as Last_Months_Churned_customer
      from c3
      ),
	c5 as (
    
     SELECT 
    year_,
    month_,
    Total_Active_customer,
    New_Customer_this_Month,
    ROUND((Last_Months_Repeat_Customer * 100) / Last_Month_active_Cust,
            2) AS Retention_Percentage_Last_Months,    
ROUND((Last_Months_Churned_customer * 100) / Last_Month_active_Cust,
            2) AS Churned_Percentage_Last_Months
            
FROM
    c4
    )
     select * from c5;
     
     
     
     -- objective  : Analyzing 	which one drives the more revenue "Repeat Customer or  New_Customer " in Each Month for Each Year
     
      with c1 as (
SELECT 
    customer_id, month(MIN(order_Date))  AS first_purchase_month , 
    year ( MIN(order_Date) ) as first_purchase_Year
FROM
    fact_orders_enriched 
GROUP BY customer_id
		),
 c2 as (
   SELECT      
    year,
    customer_id,
    order_date,
    total_Amount_to_Pay,
    first_purchase_month,
    first_purchase_Year
FROM
    fact_orders_enriched
        JOIN
    c1 USING (customer_id)
    ), 
c3 as (
SELECT 
    *,
    CASE
        WHEN month(order_Date) = first_purchase_month and year(order_Date ) = first_purchase_Year THEN 'New_Customer'
        ELSE 'Repeat_Customer'
    END AS R_N_Customer
FROM
    c2
 )
SELECT 
    year,
    ROUND(SUM(CASE
                WHEN R_N_Customer = 'Repeat_Customer' THEN total_Amount_to_Pay
            END) / 1000000,
            2) AS Rev_Generated_with_RpT_Cust_Mill,
    ROUND(SUM(CASE
                WHEN R_N_Customer = 'New_Customer' THEN total_Amount_to_Pay
            END) / 1000000,
            2) AS Rev_Generated_with_New_Cust_Mill
FROM
    c3
GROUP BY year;



    -- objective : Analyzing Each Customer's Total    "Revenue , no_of_orders, AOV(Average order Value"  ( as OverView overall)
          
	    
	SELECT 
    customer_id,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending DESC;
    



-- objective :  Doing the Pareto Analysis(80/20) with customers  to see the Contribution Spread 

   
    with c1 as (
    SELECT 
    customer_id,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_k
FROM
    fact_orders_enriched 		
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  SELECT 
    *,
    ROUND((Total_spending_k * 100) / (SELECT 
                    ROUND(SUM(total_Amount_to_pay) / 1000, 2)
                FROM
                    fact_orders_enriched),
            3) AS contribution_to_Overall_sales
FROM
    c1
   )
,
c3 as (
 select *, 
 sum(contribution_to_Overall_sales) over(order by Total_spending_k desc) as rolling__sum_of_contribution 
 from c2 
   )
   select * from c3 where rolling__sum_of_contribution<=80;

  select round(9950*100/18414,2) as "%_of_customer_covering_80%_of_REv";   -- to check the percentage of Customoers
  
  
  
  
  


-- objective : Doing  "R F M" ( R - Recency , F- Frequency  , M-Monetary )  and Adding  " Customer Segements "  to Analyse


with c1 as (
SELECT 
    customer_id,
      datediff((select max(order_Date)  from fact_orders_enriched),max(order_date)) as Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender" 
       else "Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status
       from c2
       )
SELECT 
  *
FROM
    c3
    ;
    
			
    
-- objective  : Analysing Customer Distribution into "Repeat and One time Buyers " Customers 

    with c1 as (
SELECT 
    customer_id,
      datediff((select max(order_Date)  from fact_orders_enriched),max(order_date)) 
      as Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC

),
c2 as (
 select * , case when Total_orderd_yet >1 
 then "Repeat_Customer" else "One_Time_Buyer" end as Purchase_group
 from c1 
 )
 select Purchase_group, count(*) as No_Of_Customer, 
 Round((count(*) *100/(select Count(distinct(Customer_id)) from fact_orders_enriched)),2)
 as PCT_of_Overall_Customer
 from c2
 group by Purchase_group;


    -- Objective -  Anlyzing  ( spend_Group )   & ( Customer_Status ) wise Customer_Distribution
    
    
with c1 as (
SELECT 
    customer_id,
      datediff((select max(order_Date)  from fact_orders_enriched),max(order_date)) as Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender" 
       else "Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status
       from c2
       )
SELECT 
     Spend_Group, customer_Status, Round(count(*)*100/( select Count(distinct(customer_id)) from fact_orders_enriched) ,2)as PCT_Of_Total_Customer
     from  c3 
     group by Spend_Group, customer_Status ;
     
     
    
    
    
    
-- objective :  Analysing ( "Churned"  and "At Risk" )  Customer's Revenue Contribution  OR   _At Risk Amount_ 
    
    
        with c1 as (
SELECT 
    customer_id,
    DATEDIFF((SELECT 
                    MAX(order_Date)
                FROM
                    fact_orders_enriched),
            MAX(order_date)) AS Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender " 
       else " Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status
       from c2
       ),
	 c4 as (
      select count(distinct(customer_id)) from c3 where Spend_Group ="High spender" 
      )
   select 
   customer_Status,  
   count(distinct(customer_id)) as Total_Customers_Are,
   round((sum(Total_spending_k)*1000)/10000000,2)  as Total_Amount_At_Risk_CR,
   
   round(((sum(Total_spending_k)*1000)/10000000)*100/(select sum(total_amount_to_pay)/10000000 from fact_orders_enriched) ,2) as percentage_of_Overall_Sales,
   
   count(distinct(( case when Spend_Group = "High spender"  then customer_id end ))) as No_of_high_spend_Customer,
   
   round(count(distinct(( case when Spend_Group = "High spender"  then customer_id end )))*100/(select * from c4 ),2) as  percentage_of_total_high_spender
    from c3 
    where customer_Status = "Churned" or customer_Status = "At Risk"
    group by customer_Status ;  	
   
    
    
      
      
      
-- objective : Showing Top 20 customers in terms of Total_spending 
    
    
       with c1 as (
SELECT 
    customer_id,
    DATEDIFF((SELECT 
                    MAX(order_Date)
                FROM
                    fact_orders_enriched),
            MAX(order_date)) AS Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender " 
       else " Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status
       from c2
       )
	   select count(*) from c3  where Spend_Group = "High spender";			
       
       
    
       -- objective : showing Bottom 20 customers in terms of total_spending 
       
    
       with c1 as (
SELECT 
    customer_id,
    DATEDIFF((SELECT 
                    MAX(order_Date)
                FROM
                    fact_orders_enriched),
            MAX(order_date)) AS Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender " 
       else " Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status
       from c2
       )
	   select * from c3 order by Total_spending_k  limit 20;
       
       
       
       
       
       
       
       -- objective  : Analyzing Customer purchasing Behaviour
       
       
	 with  c1 as (
       select customer_id , order_Date ,datediff(order_Date, lag(order_Date) over(partition by customer_id order by order_date )) as purchase_Gap
       from  order_table   
	),
   APG as (
     select customer_id , round(avg(purchase_Gap),0) as Avg_Purchase_gap
     from c1
     group by customer_id
     ),
 c3 as (
  select customer_id , order_id , count(distinct(product_id)) as no_of_items
  from fact_orders_enriched
  group by  customer_id , order_id 
  ),
ABS as (
 select customer_id , round(avg(no_of_items),0) as AVG_basket_Size                                                                                      -- NOTE :  Basket size means AVg no of distinct items per order 
	 from c3 
     group by customer_id
),
c4 as (
 select customer_id , category ,
 sum(quantity) as Most_purchased_Category,
 dense_rank() OVER(partition by customer_id  order by  sum(quantity) desc) as Purhcased_rank
 from fact_orders_enriched
 group by customer_id , category 
 order by customer_id , Most_purchased_Category desc
),
MPC as (                                                                                                                                                                             -- note ABS -> Average  Basket Siz
 select customer_id , group_concat(concat(category," - ", cast(Most_purchased_Category as char)) separator " | ") as Top_3_category_with_NoOFitems_bought                             --  MPS -> Most Purchased Category
 from c4                                                                                                                                                                              --  MAD -. days with most ORders
 where Purhcased_rank <=3
 group by customer_id
 ),
 c6 as (
  select customer_id , day_name , count(distinct(order_id)) as No_of_orders,
  dense_rank() over(partition by customer_id order by count(distinct(order_id))  desc) as Active_ranks
  from fact_orders_enriched
  group by  customer_id , day_name
  ),
  MAD as (
   select customer_id , group_concat(concat(day_name," - ",cast(No_of_orders as char)) separator" | " ) as Top_3_Days_with_NoOforders
   from c6
   where Active_ranks <=3
   group by customer_id
   )
 select * from 
 APG  join 
 ABS using (customer_id)
 join MPC using (customer_id)
 join MAD using(customer_id);





                                                                  -- Doing Profitablity Analaysis Customer Level  
 
 --  overall  profitablityl Overview 
 
   with c1 as (
    select customer_id , round(sum(total_Amount_to_pay)/1000,2) as Total_spending_K,
	round((sum(total_Amount_to_pay)/1000 - sum(total_Cost_price)/1000),2) as Total_profit_K,
    	Round((round((sum(total_Amount_to_pay)/1000 - sum(total_Cost_price)/1000),2)*100)/round(sum(total_Amount_to_pay)/1000,2),2)  as Profit_Margin 
	from fact_orders_enriched
    group by customer_id 
    )
    select * from c1;
    
    
    
    -- objective : Segmenting Customers into " Higly profitable customer , Moderate_Profit_Customer,  Basic_Profitable_Customer,  Very_Low_Profitable_Customers"

	     
  
		   with c1 as (
    SELECT 
    customer_id,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_K,
    ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
            2) AS Total_profit_K,
    ROUND((ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
                    2) * 100) / ROUND(SUM(total_Amount_to_pay) / 1000, 2),
            2) AS Profit_Margin
FROM
    fact_orders_enriched
GROUP BY customer_id
    ),
c2 as (
 select *, ntile(10) over(order by Total_profit_K desc) as Profit_Level_Distributer  
 from c1 
 ),
 c3 as (
  select *, case when Total_profit_K >0 and Profit_Level_Distributer in (1,2) then "High_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (3,4,5) then "Moderate_Profit_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (6,7,8) then "Basic_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (9,10) then "Very_Low_Profitable_Customers"
    else "Loss_Making_Customer" end as Profit_Group
    from c2
    )
 SELECT 
    customer_id,
    Total_spending_K,
    Total_profit_K,
    Profit_Margin,
    Profit_Group
FROM
    c3;
    
    


-- Objective : Idenitifying   "Top 20 Highly Profitable customers"  and its rolling Contribution to  overall "Profit"



		   with c1 as (
    SELECT 
    customer_id,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_K,
    ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
            2) AS Total_profit_K,
    ROUND((ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
                    2) * 100) / ROUND(SUM(total_Amount_to_pay) / 1000, 2),
            2) AS Profit_Margin
FROM
    fact_orders_enriched
GROUP BY customer_id
    ),
c2 as (
 select *, ntile(10) over(order by Total_profit_K desc) as Profit_Level_Distributer  
 from c1 
 ),
 c3 as (
  select *, case when Total_profit_K >0 and Profit_Level_Distributer in (1,2) then "High_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (3,4,5) then "Moderate_Profit_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (6,7,8) then "Basic_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (9,10) then "Very_Low_Profitable_Customers"
    else "Loss_Making_Customer" end as Profit_Group
    from c2
    ),
    c4 as (
  SELECT 
    *,Round((Total_profit_K)*100/
    (select (sum(total_amount_to_pay) - sum(total_cost_price))/1000 from fact_orders_enriched ),2)
    as contribution_to_Overall_Profit
FROM
    c3
WHERE
    Profit_Group = 'High_Profitable_Customer'
ORDER BY Total_profit_K DESC
LIMIT 20
)
select *  from c4;
    
    

      
 -- objective : Doing  " Peroto Analysis "  on the basis of Profit  Generated  to know How Much percentage of Customer covering 80% of Profit
 
   with c1 as (
   select 
    customer_id ,
    round((sum(total_Amount_to_pay) - sum(total_Cost_price))/1000,2) as Total_Profit_Acheived_,
	round( ( round((sum(total_Amount_to_pay) - sum(total_Cost_price))/1000,2))*100/
    (select  round((sum(total_Amount_to_pay) - sum(total_Cost_price))/1000,2) from fact_orders_enriched),3) 
    as contribution_to_overall_Profit
      from fact_orders_enriched
      group by customer_id
      ),
	C2 AS (
     select *, sum(contribution_to_overall_Profit) over (order by Total_Profit_Acheived_  desc)
     as rolling_contribution_till_80
     from c1
     )
     select * from C2 where rolling_contribution_till_80 <=80;
    
     select round(7887*100/18414 ,2) as PCT_Of_Customer_coveering_80_PCT ; -- To see the Customer_Percentage_covering 80% of profit
     
     
     
     
     
     
     -- objective : Idenitfying Customers who are high_Spenders and Also Highly_Profitable
     
     
        with c1 as (
SELECT 
    customer_id,
      datediff((select max(order_Date)  from fact_orders_enriched),max(order_date)) as Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
        ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
            2) AS Total_profit_K,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider,
  ntile(10) over(order by Total_profit_K desc) as Profit_Level_Distributer  
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender " 
       else " Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status,
       
        case when Total_profit_K >0 and Profit_Level_Distributer in (1,2) then "High_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (3,4,5) then "Moderate_Profit_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (6,7,8) then "Basic_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (9,10) then "Very_Low_Profitable_Customers"
    else "Loss_Making_Customer" end as Profit_Group
       from c2
       )
select  * from c3;
     
	
    
    
    
    
    
-- Objective :  Analyzing  Customer's  "Spending and Profitability  " Together with  "Churn" 
     
     

      with c1 as (
SELECT 
    customer_id,
      datediff((select max(order_Date)  from fact_orders_enriched),max(order_date)) as Days_since_Last_Purchase,
    ROUND(SUM(total_Amount_to_pay) / 1000, 2) AS Total_spending_k,
        ROUND((SUM(total_Amount_to_pay) / 1000 - SUM(total_Cost_price) / 1000),
            2) AS Total_profit_K,
    COUNT(DISTINCT (order_id)) AS Total_orderd_yet,
    ROUND((SUM(total_Amount_to_pay) / COUNT(DISTINCT (order_id))) / 1000,
            2) AS AOV_K
FROM
    fact_orders_enriched
GROUP BY customer_id
ORDER BY Total_spending_k DESC
),
c2 as (
  select *, 
  ntile(5) over ( order by Total_spending_k desc ) as Table_divider,
  ntile(10) over(order by Total_profit_K desc) as Profit_Level_Distributer  
  from c1
  ),
  c3 as (
select *,
 case when Table_divider = 1 then "High spender" 
	   WHEN Table_divider IN (2,3,4) THEN "Mid level Spender " 
       else " Low spnder" end as Spend_Group ,
       
       case when Days_since_Last_Purchase <=30 then  "Active" 
	   WHEN Days_since_Last_Purchase >=31 and  Days_since_Last_Purchase <=60  THEN "At Risk" 
       else "Churned" end as customer_Status,
       
        case when Total_profit_K >0 and Profit_Level_Distributer in (1,2) then "High_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (3,4,5) then "Moderate_Profit_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (6,7,8) then "Basic_Profitable_Customer"
    when Total_profit_K > 0 and Profit_Level_Distributer in (9,10) then "Very_Low_Profitable_Customers"
    else "Loss_Making_Customer" end as Profit_Group
       from c2
       )
select count(*) as Total_Customer ,
 count( case when Spend_Group ="High spender"  then 1 end ) as Total_high_spenders,
 count( case when Spend_Group ="High spender" and Profit_Group = "High_Profitable_Customer" then 1 end ) as Custome_high_spender_with_highly_profitable,
  count( case when Spend_Group ="High spender" and Profit_Group = "High_Profitable_Customer" and customer_Status = "Churned"   then 1 end ) as  Cust_high_spender_with_highly_profitable_and_churned,
 count( case when Spend_Group ="High spender" and Profit_Group = "High_Profitable_Customer" and customer_Status = "At Risk"   then 1 end ) as Cust_high_spender_with_highly_profitable_and_AtRisk,
 
(sum( case when Spend_Group ="High spender" and Profit_Group = "High_Profitable_Customer" and customer_Status = "Churned"    then Total_spending_k  end ) + 
 sum( case when Spend_Group ="High spender" and Profit_Group = "High_Profitable_Customer" and customer_Status = "At Risk"   then Total_spending_k end )) as Total_amount_At_Risk_to_loose
 from c3;
 
 
 
 
 
--- objective : Acquition Cohort  analysis 

 with c1 as (
  select customer_id , date_format(min(order_Date),"%Y-%m-01")  as cohort_month
  from fact_orders_enriched  
   GROUP BY customer_id
     ),
	c2 as (
	  select cohort_month ,date_format(order_date,"%Y-%m-01") as Activity_Month, count(distinct(customer_id)) as Acitve_customers
      from fact_orders_enriched
join  c1 
using (Customer_id)
  group by cohort_month,Activity_Month
)
select * from c2;
  
    
     



      
		