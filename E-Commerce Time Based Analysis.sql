 
                                                                          -- Time based Analysis                                  Note -- If your failed to Run pls check if there is total_price written 
																																		--  change it into Total_amount_to_pay


-- overall KPI 


 -- obejective :  Finding Total_Revenue Generated yet
   
    select round(sum( total_amount_to_pay)/10000000,2) as Revenue_CR from fact_orders_enriched;
    
    
-- obejective :  Finding Total_Profit Generated yet
      
	select Round((sum( total_amount_to_pay) - sum(total_Cost_price))/10000000,2) as Profit_CR from fact_orders_enriched;
    
       
-- obejective :  Finding Profit_Percentage
      
      
	select Round((sum( total_amount_to_pay) - sum(total_Cost_price))/(sum(total_amount_to_Pay)),2)*100 as Profit_PCT from fact_orders_enriched;
      
      
-- objective : finding  Total_Orders Got yet


    select Round(count(distinct(order_id))/1000,2) as Total_Orders_Yet_K 
    from fact_orders_enriched ;
 
 
  
  
  
--  Objective  : Analyzing Yearly Revenue & Profit  Trend
 
with c1 as (
SELECT 
    year,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Total_Revenue_CR,
     Round((sum( total_amount_to_pay) - sum(total_Cost_price))/10000000,2) as Profit_CR,
	Round((sum( total_amount_to_pay) - sum(total_Cost_price))/(sum(total_amount_to_Pay)),2)*100 as profit_PCT
FROM   
    fact_orders_enriched
GROUP BY year
ORDER BY year
),
 c2 as (
  select * ,
  round(((Total_Revenue_CR - lag(Total_Revenue_CR) over( order by year))*100/lag(Total_Revenue_CR) over( order by year)),2) as Vs_Prev_Year_Revenue,
  round(((Profit_CR - lag(Profit_CR) over( order by year))*100/lag(Profit_CR) over( order by year)),2) as Vs_Prev_Year_Profit
  from c1
  )
  select * from c2;





-- Objective : Analyzing Quaterly Rev Trend (combined  2 years)

 with c1 as (
  SELECT 
    quarter_name,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Total_Revenue_CR
FROM
    fact_orders_enriched
GROUP BY quarter_name
),
c2 as (
 select *, round(Total_Revenue_CR*100/(select sum(Total_amount_to_pay)/10000000 from fact_orders_enriched),2) as Contirbution_to_overall_Rev
 from c1 
 )
 select * from c2;
  
  
  
  
  
-- objective : Analzing Querterly Revenue Trend YoY (For any Declination  or Increament change)
 
 
 
with C1 as (
 SELECT 
    quarter_name,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN total_amount_to_pay
            END) / 10000000,
            2) AS _2023_Revenue_in_CR,
    ROUND(SUM(CASE
                WHEN year = 2024 THEN total_amount_to_pay
            END) / 10000000,
            2) AS _2024_Revenue_in_CR
FROM
    fact_orders_enriched
GROUP BY quarter_name
     ),
c2 as  (
SELECT 
    *,
    ROUND((_2024_Revenue_in_CR - _2023_Revenue_in_CR) * 100 / _2023_Revenue_in_CR,
            2) AS vs_Prev_year_change
FROM
    c1
)
select * from c2;





 -- objective : Analyzing Monthly "Revenue & Demand"  Trend (combibed_for 2 years )
 
 
with c1 as (
SELECT 
    month_name,
    ROUND(SUM(total_amount_to_pay) / 10000000,2) AS Total_Revenue_CR,
    	round(sum(quantity)/1000,2) as Demand_In_K,
        round(SUM(total_amount_to_pay)*100/(select sum(Total_amount_to_pay) from fact_orders_enriched),2) as Contirbution_to_overall_Rev
FROM
    fact_orders_enriched
GROUP BY month_name
),
c2 as (
 select month_name,
 Total_Revenue_CR,
 Demand_In_K ,
 Contirbution_to_overall_Rev,
 sum(Contirbution_to_overall_Rev) over( order by Contirbution_to_overall_Rev desc) as Rolling_Rev_contribution_PCT_Wise
 from c1 
 )
 select * from c2;    
  
    
    
    
-- objective : Analzing Monthly  "Revenue & Demand"  Trend YoY  (For any Declination  or Increament change)
        
        

 with C1 as (
SELECT 
    month_name,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN total_amount_to_pay
            END) / 1000000,
            2) AS _2023_Revenue_in_M,
    ROUND(SUM(CASE
                WHEN year = 2024 THEN total_amount_to_pay
            END) / 1000000,
            2) AS _2024_Revenue_in_M,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN quantity
            END) / 1000,
            2) AS _2023_Demand_in_K,
    ROUND(SUM(CASE
                WHEN year = 2024 THEN quantity
            END) / 1000,
            2) AS _2024_Demand_in_K
FROM
    fact_orders_enriched
GROUP BY month_name
     ),
c2 as  (
SELECT 
    *,
    ROUND((_2024_Revenue_in_M - _2023_Revenue_in_M) * 100 / _2023_Revenue_in_M,
            2) AS vs_Prev_yr_Rev_PCT_Wise,
	ROUND((_2024_Demand_in_K - _2023_Demand_in_K) * 100 / _2023_Demand_in_K,
            2) AS vs_Prev_year_Demand_PCT_Wise
FROM
    c1
)
select * from c2;





 -- objective : Analyzing   Weekly Trend  ( combined for 2 years) (Customer_prefrence)
  
 With C1 as (
 SELECT 
    week_of_month,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Total_Revenue_CR,
    round(SUM(total_amount_to_pay)*100 /( select sum(total_amount_to_pay) from  fact_orders_enriched),2) as PCT_contribution_overall_Sales
FROM
    fact_orders_enriched
GROUP BY week_of_month
),
c2 as (
select week_of_month,
Total_Revenue_CR,
sum(PCT_contribution_overall_Sales) over(order by PCT_contribution_overall_Sales desc ) as Rolling_Rev_contribution_PCT_wise
from c1
)
select * from c2;





-- Objective : Analyzing the Weekly Trend YoY (For any Declination  or Increament change)

 with C1 as (
 SELECT 
    week_of_month ,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN total_amount_to_pay
            END) / 1000000,
            2) AS _2022_Revenue_in_M,
    ROUND(SUM(CASE
                WHEN year = 2024 THEN total_amount_to_pay
            END) / 1000000,
            2) AS _2023_Revenue_in_M
FROM
    fact_orders_enriched
GROUP BY week_of_month
     ),
c2 as  (
SELECT 
    *,
    ROUND((_2023_Revenue_in_M - _2022_Revenue_in_M) * 100 / _2022_Revenue_in_M,
            2) AS vs_Prev_year_change
FROM
    c1
)
select * from c2;





 -- objective : Analyzing WeekDay's "Reveune & Demand"  Trend ( Customer_Prefrence) combine 2 years for overall View
 
 
with c1 as(
SELECT 
    Day_name,
    Day_of_week,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Total_Revenue_CR,
    ROUND(SUM(quantity) / 1000, 2) AS Demand_In_K,
    round(SUM(total_amount_to_pay)*100 /( select sum(total_amount_to_pay) from  fact_orders_enriched),2) as PCT_contribution_overall_Sales
    
FROM
    fact_orders_enriched
GROUP BY Day_name , Day_of_week
ORDER BY Day_of_week
),
 c2 as (
     select 
     Day_name,
     Day_of_week,
     Total_Revenue_CR,
     Demand_In_K,
     sum(PCT_contribution_overall_Sales) over(order by PCT_contribution_overall_Sales desc ) as Rolling_Rev_contribution_PCT_wise
     from c1 
     )
select * from c2;
     
     





   
    -- Objective :  Analyzing   WeekEnd vs WeekDay   "Revenue  & Demand  & AOV(Average order Value)" Trend 
 
 
  with c1 as (
SELECT 
    Week_End_or_day,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Total_Revenue_CR,
    ROUND(SUM(quantity) / 1000, 2) AS Demand_In_K,
    ROUND(COUNT(DISTINCT (order_id)) / 1000, 2) AS Total_Uniq_Ordr_in_K
FROM
    fact_orders_enriched
GROUP BY Week_End_or_day
),
c2 as (
SELECT 
    order_id,
    Week_End_or_day,
    SUM(total_amount_to_pay) AS total_Amount_to_Pay
FROM
    fact_orders_enriched
GROUP BY order_id , Week_End_or_day
  ),
c3 as (
    SELECT 
    Week_End_or_day,
    ROUND(AVG(total_Amount_to_Pay) / 1000, 2) AS AOV
FROM c2
GROUP BY Week_End_or_day
      )
	SELECT * FROM c1
        JOIN
    c3 USING (Week_End_or_day);
     
      
         
-- Objective : Analyzing Hourly-Demand Trend ( Customer_Prefrence)
        
	SELECT 
    HOUR(order_time) AS hours,
    ROUND(SUM(quantity) / 1000, 2) AS Demand_In_K,
    COUNT(DISTINCT (order_id)) AS Total_unique_Orders
FROM
    fact_orders_enriched
GROUP BY hours
ORDER BY Demand_In_K DESC;
        
        
        
        
  -- objectice : Analyzing  "Demand"  Trend using  Hourly_Buckets
        
        
     with c1 as (
           SELECT 
    HOUR(order_time),
    CASE
        WHEN HOUR(order_time) BETWEEN 1 AND 3 THEN '1 - 3'
        WHEN HOUR(order_time) BETWEEN 4 AND 6 THEN '4 -6'
        WHEN HOUR(order_time) BETWEEN 7 AND 9 THEN '7 to 9'
        WHEN HOUR(order_time) BETWEEN 10 AND 12 THEN '10 - 12'
        WHEN HOUR(order_time) BETWEEN 13 AND 15 THEN '13 - 15'
        WHEN HOUR(order_time) BETWEEN 16 AND 18 THEN '16- 18'
        WHEN HOUR(order_time) BETWEEN 19 AND 21 THEN '17 - 21'
        ELSE '22 -24'
    END AS Hourly_Bucket,
    quantity
FROM
    fact_orders_enriched
)
SELECT 
    Hourly_Bucket, ROUND(SUM(quantity) / 1000, 2) AS Demand_In_K
FROM
    c1
GROUP BY Hourly_Bucket
ORDER BY Demand_In_K DESC; 
    
    
 -- Objective : Analyzing Top 10 calender dates in terms of Revenue Generation
               
               
	SELECT 
    order_Date,month_name,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Total_Revenue_Lakhs
FROM
    fact_orders_enriched
GROUP BY order_Date,month_name
ORDER BY Total_Revenue_Lakhs DESC
LIMIT 20;
     
     
     
     



 


     
     