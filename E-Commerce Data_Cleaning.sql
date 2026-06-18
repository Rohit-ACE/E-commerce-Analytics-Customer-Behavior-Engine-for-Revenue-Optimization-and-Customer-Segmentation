
-- Creating Table strunture 


 CREATE TABLE order_table (
    order_id INT,
    customer_id INT,
    order_date VARCHAR(50),
    promised_delivery_time VARCHAR(50),
    actual_delivery_time VARCHAR(50),
    delivery_status VARCHAR(30),
    order_total DECIMAL(10 , 2 ),
    payment_method VARCHAR(30),
    delivery_partner_id INT,
    store_id INT
);
   
   CREATE TABLE order_item_table (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10 , 2 )
);
   
 CREATE TABLE dim_Customers (
    customer_id INT,
    customer_name VARCHAR(40),
    email VARCHAR(100),
    phone INT,
    area VARCHAR(40),
    pincode INT,
    registration_date VARCHAR(50)
);
 
CREATE TABLE dim_Products (
    product_id INT,
    product_name VARCHAR(20),
    category VARCHAR(30),
    brand VARCHAR(40),
    price DECIMAL(10 , 5 ),
    margin_percentage INT,
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT
);

CREATE TABLE dim_Date (
    Dates DATE,
    Year INT,
    Month_Name VARCHAR(30),
    Month_ INT,
    Quarter_ INT,
    Week_of_Month INT,
    Week_of_Year INT,
    Day_Name VARCHAR(20),
    Day_of_Week INT,
    Y_M VARCHAR(20),
    Y_Q VARCHAR(20),
    Week_End_or_day VARCHAR(20),
    Quarter_Name VARCHAR(15)
);





SHOW VARIABLES LIKE 'secure_file_priv';
 
  -- Data importing  into the Tables ( large_CSV files that is why this method is choosed)
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/blinkit_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/blinkit_orders.csv'
INTO TABLE order_table
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/blinkit_order_items.csv'
INTO TABLE order_item_table
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Blinkit dim_Date.csv'
INTO TABLE dim_Date
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Some modifications


  -- columns transformation/formating
  
  update order_table set order_date = str_to_date(order_date ,"%d-%m-%Y %H:%i:%s");
  update order_table set promised_delivery_time = str_to_date(promised_delivery_time ,"%d-%m-%Y %H:%i:%s");
  update order_table set actual_delivery_time = str_to_date(actual_delivery_time ,"%d-%m-%Y %H:%i:%s");
  update order_table set order_time = time(order_date);
  update order_table set order_date = date(order_date);
  update fact_orders_enriched set Total_Amount_to_Pay = (coalesce(mrp,0)*coalesce(quantity,0));
  
  
  -- Datatype Modifactions
  
  alter table order_table modify order_id double;
  alter table order_table modify customer_id double;
  alter table order_table modify store_id double;
  alter table order_table modify order_date date;
  alter table order_table modify promised_delivery_time datetime;
  alter table order_table modify actual_delivery_time datetime;
  alter table dim_customers modify registration_date date;
  alter table dim_customers modify customer_id double;
  alter table order_item_table modify order_id double;
  alter table dim_products modify product_name varchar(100);
  alter table dim_products modify margin_percentage decimal(5,2);
 alter table order_item_table rename column total_price to Total_cost_price;
 alter table fact_orders_enriched rename column total_price to Total_cost_price;
  
 
 
 
 
 -- Adding_new Helper Columns
 
 
  alter table order_table add column Order_time time;
alter table fact_orders_enriched add column Total_Amount_to_Pay decimal(10,2);




-- Createing Keys and Indexes for "Better performances" ;

-- 1 for customer_Table
 
  alter table dim_customers add primary key	(customer_id);
  create index idx_custname on dim_customers(customer_name);
  create index idx_area on dim_customers(area);
  
  
  -- 2 for Product table 
  
   alter table dim_products add primary key (product_id);
 create index idx_prodname on dim_products(product_name);
 
 
 
-- 3 For order_Table 

 alter table order_table add primary key (order_id);
 
 alter table order_table add constraint fk_Custid foreign key (customer_id)
 references dim_customers(customer_id) 
 on delete cascade
 on update cascade;
 create  index idx_odrdate  on order_table(order_date);

alter table order_table add constraint fk_dates foreign key (order_date)
references dim_date(dates)
  on delete cascade
 on update cascade;
 
 
 -- 4 Order_item_table 
 
  alter table order_item_table add constraint fk_order_id foreign key (order_id) 
  references order_table(order_id)
  on delete cascade
  on update cascade;
  
 
 
 -- for Dim_Date
 alter table dim_date add primary key (dates);
 

 
 
 
  -- Created a Fact_order_enriched  Table 
  
   create table Fact_Orders_enriched as 
   select * from dim_date as  dt
   left join order_table as ord
    on dt.dates = ord.order_Date
    left join order_item_table as it
    using(order_id)
    left join dim_customers as cust
     using(customer_id)
    left join dim_products as prod
     using(product_id);

 
  
  
  
  








 
    



