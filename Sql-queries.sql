a) write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
  with cte as (
  select city,sum(amount) as total_spend
  from credit_card_transcations$
  group by city)
  ,total_spent as (
  select cast(sum(amount) as bigint) as t_amt from credit_card_transcations$)
  select top 5 c.*,round(total_spend*1.0/t_amt*100.0,2) as percent_contrib from cte c inner join total_spent on 1=1
  order by percent_contrib desc
  
b) write a query to print highest spend month and amount spent in that month for each card type
with cte as (
select datepart(year,transaction_date) as yr,datepart(month,transaction_date) as mn,
card_type,sum(amount) as total
from credit_card_transcations$
group by datepart(year,transaction_date),datepart(month,transaction_date),card_type)
,rn as (
select *,ROW_NUMBER() over (partition by card_type order by total desc) as rn
from cte)
select * from rn where rn=1

c) write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as (
select *,
sum(amount) over (partition by card_type order by transaction_date,transaction_id ) as r_s
from credit_card_transcations$)
,rnk as (
select *,ROW_NUMBER() over (partition by card_type order by r_s) as d_r
from cte where r_s>=1000000)
select * from rnk where d_r=1

d) write a query to find city which had lowest percentage spend for gold card type
with cte as (
select city,card_type,sum(amount) as total,
sum(case when card_type='gold' then amount end) as gold_amt
from credit_card_transcations$
group by city,card_type)
,cte1 as (
select city,sum(gold_amt)*1.0/sum(total)*100.0 as gold_ratio
from cte
group by city
having count(gold_amt)>0 and sum(gold_amt)>0)
select * from cte1 order by gold_ratio

e) write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as (
select city,exp_type,sum(amount) as total from credit_card_transcations$
group by city,exp_type)
,rnk as (
select *,row_number() over (partition by city order by total desc) as topp,
row_number() over (partition by city order by total asc) as btm
from cte)
select city,
max(case when topp =1 then exp_type end) as high_exp_type,
max(case when btm =1 then exp_type end) as low_exp_type
from rnk
group by city

f) write a query to find percentage contribution of spends by females for each expense type
with cte as (
select exp_type,cast(sum(amount) as bigint) as total,
cast(sum(case when gender='F' then amount end ) as bigint) as fem_amount
from credit_card_transcations$
group by exp_type)
select exp_type,round(fem_amount*1.0/total*100.0 ,5)as fem_contrib from cte
order by fem_contrib desc

g) which card and expense type combination saw highest month over month growth in Jan-2014
with cte as (
select datepart(year,transaction_date) as yr,
datepart(month,transaction_date) as mn,
card_type,exp_type,sum(amount) as total
from credit_card_transcations$
group by datepart(year,transaction_date),datepart(month,transaction_date),card_type,exp_type)
,p_yr_sales  as (
select *,lag(total,1) over (partition by card_type,exp_type order by yr,mn) as l_yr_sales
from cte)
,diff as (
select *,1.0*(total-l_yr_sales)/l_yr_sales*100.0  as growth from p_yr_sales
where yr='2014' and mn='1'
)
select * from diff order by growth desc

h) during weekends which city has highest total spend to total no of transcations ratio 
with cte as (
select city,sum(amount) as total ,
count(*) as cnt
from credit_card_transcations$
where datename(weekday,transaction_date) in ('Saturday','Sunday')
group by city)
select city,total*1.0/cnt  as ratio from cte
order by ratio desc

i) which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as (
select *,ROW_NUMBER() over (partition by city order by transaction_date,transaction_id) as rn
from credit_card_transcations$)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as df
from cte where rn=1 or rn=500
group by city
having count(*)=2
order by df asc



    
