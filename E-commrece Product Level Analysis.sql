                                                           -- Product Level Analysis (Revenue and Profit ) and also product_combinatioin analysis 
 
 
 

 
  -- Obective :Analyzing How many Unique Products we have sold Till Now 
  
  
SELECT 
    COUNT(DISTINCT (product_id)) AS Total_Unique_Products_sold_yet
FROM
    fact_orders_enriched;
    
    
    
    
    -- objective : Analyzing total_Revenue_Generated 
    
    
SELECT 
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) Total_Rev_IN_CR
FROM
    fact_orders_enriched;
      
    
    
    --   -- objective : Analyzing total_Profit__Generated 
    
    SELECT 
    ROUND((SUM(total_amount_to_pay ) -  sum(total_cost_Price))/1000000, 2) Total_Profit_in_Mill
FROM
    fact_orders_enriched;
      
    
    
  
  -- objective :  Analyzing  Categoriacal Level Total  "Revenue & Demand & Profit " 
  
  
  with c1 as (
  SELECT 
    category AS Product_Category,
    ROUND(SUM(quantity) / 1000, 2) AS Total_QTY_sold_in_K,
    ROUND(SUM(total_amount_to_pay) / 10000000, 2) AS Revenue__IN_CR,
    (ROUND(SUM(total_amount_to_pay) / 10000000, 2) - ROUND(SUM(total_cost_price) / 10000000, 2)) AS Total_Profit_In_CR
FROM
    fact_orders_enriched
GROUP BY Product_Category
     ),
	c2 as (
 SELECT 
    *,
    ROUND((Total_Profit_In_CR * 100) / Revenue__IN_CR,
            2) AS Profit_Margin,
            
	ROUND((Revenue__IN_CR * 100) / (select sum(total_Amount_to_pay)/10000000 from fact_orders_enriched),
            2) As "%_contribution_overall_Sales"
            
FROM
    c1
    )
   SELECT  *  FROM c2;
	
	

-- objective : Analyzing Product_Category 's  "Revenue & Demand & Profit"   Performance "YoY"

with c1 as (
SELECT 
    category AS Product_Category,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN quantity
            END) / 1000,
            2) AS QTY_sold_in_K_in_2023,
    ROUND(SUM(CASE
                WHEN year = 2023 THEN total_amount_to_pay
            END) / 10000000,
            2) Revenue_IN_CR_in_2023,
    (ROUND(SUM(CASE
                WHEN year = 2023 THEN total_amount_to_pay
            END) / 10000000,
            2) - ROUND(SUM(CASE
                WHEN year = 2023 THEN total_cost_price
            END) / 10000000,
            2)) AS _Profit_In_CR_in_2023,
            
            
             ROUND(SUM(CASE
                WHEN year = 2024 THEN quantity
            END) / 1000,
            2) AS QTY_sold_in_K_in_2024,
    ROUND(SUM(CASE
                WHEN year = 2024 THEN total_amount_to_pay
            END) / 10000000,
            2) Revenue_IN_CR_in_2024,
    (ROUND(SUM(CASE
                WHEN year = 2024 THEN total_amount_to_pay
            END) / 10000000,
            2) - ROUND(SUM(CASE
                WHEN year = 2024 THEN total_cost_price
            END) / 10000000,
            2)) AS _Profit_In_CR_in_2024
FROM
    fact_orders_enriched
GROUP BY Product_Category
),
 c2 as (
SELECT 
    *,
    ROUND((_Profit_In_CR_in_2023 * 100) / Revenue_IN_CR_in_2023,
            2) AS Profit_Margin_in_2023,
    ROUND((_Profit_In_CR_in_2024 * 100) / Revenue_IN_CR_in_2024,
            2) AS Profit_Margin_in_2024
from c1
),
c3 as (
SELECT 
    *,
    ROUND((QTY_sold_in_K_in_2024 - QTY_sold_in_K_in_2023) * 100 / QTY_sold_in_K_in_2023,
            2) AS vs_Previous_year_Demand,
    ROUND((Revenue_IN_CR_in_2024 - Revenue_IN_CR_in_2023) * 100 / Revenue_IN_CR_in_2023,
            2) AS vs_Previous_year_Revenue,
    ROUND((Profit_Margin_in_2024 - Profit_Margin_in_2023) * 100 / Profit_Margin_in_2023,
            2) AS vs_Previous_year_profit_margin
FROM
    c2
  )
   SELECT 
    Product_Category,
    vs_Previous_year_Demand,
    vs_Previous_year_Revenue,
    vs_Previous_year_profit_margin
FROM
    c3;

 
 
 -- Objective : Analyzing the  product_Category Monthly Trend  To See Seasoanal_pattern if Any 
 
SELECT 
    category AS Product_Category,
    month_,
    ROUND(SUM(quantity) / 1000, 2) AS Total_Demand_in_K,
    ROUND(SUM(total_amount_to_pay) / 1000000, 2) AS Revenue__in_M
FROM
    fact_orders_enriched
GROUP BY Product_Category , month_
ORDER BY Product_Category , month_;



--



                                                              --  NOw  Product_Level  analysis   ( Demand , Revenue , Profit_margin)
    


-- ojective : indentifying Full overview first 


with c1 as (
  SELECT 
    Product_name,
    category AS product_Category,
	ROUND(SUM(quantity) / 1000, 2) AS Total_Units_sold,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue__in_Lakhs,
     ROUND(SUM(total_amount_to_pay - total_cost_price ) / 100000, 2) AS Profit_in_Lakhs,
	Round((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY Product_name , product_Category
ORDER BY Revenue__in_Lakhs DESC
)
   select * from c1;





 -- OBjective : finding Top  20 Performing Products in terms of  "Revenue"  with their contribution to overll Revenue
 
 
  with c1 as (
  SELECT 
    Product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue__in_Lakhs
FROM
    fact_orders_enriched
GROUP BY Product_name , product_Category
ORDER BY Revenue__in_Lakhs DESC
LIMIT 20
),
c2 as (
select *, 
round((Revenue__in_Lakhs*100)/(select sum(total_amount_to_pay)/100000 from fact_orders_enriched),2) as Contribution_to__overall
from c1
),
c3 as (
   select product_name
   ,product_Category,
   Revenue__in_Lakhs ,
   sum(Contribution_to__overall) over (order by Contribution_to__overall desc) as Rolling_contribution_to_overall_Rev
   from c2
   )
   select * from c3 ;
   
   
   
   

 -- OBjective : finding Top  20  Products in terms of  "Profit"  with theirs contiribution to overll Profit
 
 
 
  with c1 as (
  SELECT 
    Product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay - total_cost_price ) / 100000, 2) AS Profit_in_Lakhs
FROM
    fact_orders_enriched
GROUP BY Product_name , product_Category
ORDER BY Profit_in_Lakhs DESC
LIMIT 20
),
c2 as (
select *, 
round((Profit_in_Lakhs*100)/(select sum(total_amount_to_pay - total_cost_price)/100000 from fact_orders_enriched),2) 
as Contribution_to__overall
from c1
),
c3 as (
   select product_name,
   product_Category,
   Profit_in_Lakhs ,
   sum(Contribution_to__overall) over (order by Contribution_to__overall desc) as Rolling_contribution_to_overall_Profit
   from c2
   )
   select product_Category , count(*) as no_of_Products
   from c3  group by product_Category order by no_of_Products desc;
   
   
   
   
    -- OBjective : finding Top  20  Products in terms of  " high Profit_margin" 
    
    
    
SELECT 
    product_name,
    category AS Prod_Category,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),
            2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY product_name , Prod_Category
ORDER BY profit_margin DESC
LIMIT 20;
   
   
   
   
   
   
   
   -- OBjective : finding Top  20  highest selling products (QTY sold wise)
   
   with c1 as (
   SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(quantity) / 1000, 2) AS Total_Units_sold
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
ORDER BY Total_Units_sold DESC limit 20
)
select * from c1;
   
   
   
   
   
   
-- objective : Doing Pareto  Analysis to know How much percentage of Products covering 80 % of "Revenue"
    
    
   
  with c1 as (
  SELECT 
    Product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue__in_Lakhs
FROM
    fact_orders_enriched
GROUP BY Product_name , product_Category
ORDER BY Revenue__in_Lakhs DESC
),
c2 as (
select *, 
round((Revenue__in_Lakhs*100)/(select sum(total_amount_to_pay)/100000 from fact_orders_enriched),2) as Contribution_to__overall
from c1
),
c3 as (
   select product_name
   ,product_Category,
   Revenue__in_Lakhs ,
   sum(Contribution_to__overall) over (order by Contribution_to__overall desc) 
   as Rolling_contribution_to_overall_Rev
   from c2
   )
   select * from c3 where Rolling_contribution_to_overall_Rev <=80;
   
   -- to check the  percentage of Product 
   select round(137*100/237,2); 
   
   



  -- objective  : Finding  the Products with    "High sales" ⬆️   with    "High_Profit_Margin" ⬇️            NOTE : ->  (As per our data Our AVG profit Margin is 28% we analyzed as per the threshold)
                                                                                                          
		
    with c1 as (
    SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue_in_lakhs,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),
            2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
HAVING Revenue_in_lakhs >= 8
    AND profit_margin >= 25
ORDER BY Revenue_in_lakhs DESC limit 20
)
select product_Category , count(*) as No_of_Product  from c1
group by product_Category order by No_of_Product desc;  s    


  
  
  -- objective : Finding the products with the    "High Sales"    but    "Low Profit_Margin "
  
  
  
   SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue_in_lakhs,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),
            2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
HAVING Revenue_in_lakhs >= 8
    AND profit_margin <=15
ORDER BY Revenue_in_lakhs DESC;


	
     
  -- objective : Finding the products with the     "Low Sales"     but     "High Profit_Margin "
   
   
   with c1 as (
   SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue_in_lakhs,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),
            2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
HAVING Revenue_in_lakhs <=7
    AND profit_margin >=25
ORDER BY Revenue_in_lakhs Asc limit 20
)
 select * from c1;



  
    -- objective : Finding the products with the    "Low Sales"  and    "Low Profit_Margin "   
    
    
    
        SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue_in_lakhs,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price)) * 100 / SUM(total_amount_to_pay),
            2) AS profit_margin
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
HAVING Revenue_in_lakhs <=7
    AND profit_margin <=15
ORDER BY Revenue_in_lakhs asc;


  


                                                        -- Now uunder_Performing Products int terms of Revenue and Demand (TOP N Analysis)
  

	
-- Objective : finding Bottom 20 Products in tersm of  "Revenue Generating"


   SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(total_Amount_to_pay) / 100000, 2) AS Revenue_in_lakhs
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
ORDER BY Revenue_in_lakhs asc limit 20;



-- Objective:  finding Bottom 20 Products  in terms of Demand / Qty sold

   with c1 as (
   SELECT 
    product_name,
    category AS product_Category,
    ROUND(SUM(quantity) / 1000, 2) AS Total_Units_sold_k
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
ORDER BY Total_Units_sold_k asc limit 20
)
select * from c1;



-- objective : Idenitfying the bottom 20 products in terms of Profit making  (amount Wise)
 
 
  with c1 as (
  SELECT 
    product_name,
    category AS product_Category,
    ROUND((SUM(total_amount_to_pay) - SUM(total_cost_price))/100000,
            2) AS profit_in_Lakhs 
FROM
    fact_orders_enriched
GROUP BY product_name , product_Category
ORDER BY  profit_in_Lakhs  asc limit 20
)
select product_Category , count(*) as No_of_Products 
from c1 group by product_Category  order by No_of_Products  desc;      

 
 
  
   -- Objective : Analyzing Each   Product's performence in each Category in Terms of Revenue, demand, profit_Margin as Combined View 
   
   
       with c1 as (
  SELECT 
    category AS Product_Category,
    product_name,
    ROUND(SUM(quantity) / 1000, 2) AS Total_QTY_sold_in_K,
    ROUND(SUM(total_amount_to_pay) / 100000, 2) AS Revenue__in_Lakhs,
    (ROUND(SUM(total_amount_to_pay) / 100000, 2) - ROUND(SUM(total_cost_price) / 100000, 2)) AS Total_Profit_in_Lakhs
FROM
    fact_orders_enriched
GROUP BY Product_Category,  product_name
     ),
	c2 as (
 SELECT 
    *,
    ROUND((Total_Profit_in_Lakhs * 100) / Revenue__in_Lakhs,
            2) AS Profit_Margin
FROM
    c1
    )
   SELECT 
    *
FROM
    c2 order by product_Category , Revenue__in_Lakhs desc;
 



   -- objective : Doing  " Market Basket Analysis " (Finding Product Combinaitons which frequently bought Together )
   
   
     with c1 as (
     SELECT 
    a.product_name AS Product_A,
    b.product_name AS Product_B,
    COUNT(*) AS Frequency
FROM
    fact_orders_enriched AS a
        JOIN
    fact_orders_enriched AS b ON a.order_id = b.order_id
        AND a.product_id < b.product_id
GROUP BY a.product_name , b.product_name
      ),
      c2 as (
       SELECT 
    product_name, COUNT(*) AS times_orderes
FROM
    fact_orders_enriched
GROUP BY product_name
       ),
	c3 as (
     select *, 
     Round(Frequency*100/(select count(distinct(order_id)) from fact_orders_enriched),2) as  support                                  -- Support Means -> Percentage_of_Odrs_contains_thisComboo
     from c1
     )
     select * 
     , Round(Frequency *100/(select times_orderes from c2 where product_name = c3.Product_A ),2) confidence from c3 ;         -- CONFIDENCE -> If someone buys product_A → confidence% chance they also buy product_B
      

 


 















































































































































































































































































 



 
 
 
 
 
 
 
 