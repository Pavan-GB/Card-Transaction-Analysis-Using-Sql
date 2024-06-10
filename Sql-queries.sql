  a) write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
     with cte as (
     select city,sum(amount) as total_spend
     from credit_card_transcations$
     group by city)
    ,total_spent as (
    select cast(sum(amount) as bigint) as t_amt from credit_card_transcations$)
    select top 5 c.*,round(total_spend*1.0/t_amt*100.0,2) as percent_contrib from cte c inner join total_spent on 1=1
    order by percent_contrib desc
    
