--Task 3 OLAP reports
-- Question a: Simple reports
--REPORT 1: Top 5 total number of sales of property accrording to property type and state.
select * from
(select a.state_code, b.property_type, sum(d.noofsale) as Total,
dense_rank() over (order by sum(d.noofsale) desc) as sales_rank
from state0DIM a, Property0DIM b, sales0Fact d
where a.state_code = d.state_code
and b.property_id = d.property_id
Group by a.state_code,b.property_type)
where sales_rank <= 5;

--REPORT 2: Top 10% properties visited by property type and visit date

Select * from
(select c.visitdate, a.property_type, sum(c.Total_property_visited) as T_visit,
Percent_Rank() over (order by sum(c.Total_property_visited)) as Top_Percent
from Property0DIM a, Property0Fact c
Where a.property_id = c.property_id
group by c.visitdate, a.property_type
order by Top_Percent desc)
Where Top_Percent >= 0.9;


--REPORT 3: Show all the propertise with descending visits by date and property type

Select * from
(select c.visitdate, a.property_type, sum(c.Total_property_visited) as Total_visit,
dense_Rank() over (order by sum(c.Total_property_visited) desc ) as property_rank
from Property0DIM a, Property0Fact c
Where a.property_id = c.property_id
group by c.visitdate, a.property_type
order by property_rank );


--Question b: reports with proper sub-totals
--What are the sub-total and total rental fees from each suburb, time period, and property type
--REPORT 4: USING CUBE OPERATOR

Select f.suburb, a.rent_date , b.property_type, sum(a.no_of_price) as Total_rental_fees
from Rent0Fact a, property0DIM b, suburb0DIM f
where b.property_id = a.property_id
and f.address_id = a.address_id
group by cube (f.suburb,b.property_type,a.rent_date);



--REPORT 5: USING PARTIAL CUBE OPERATOR
--What are the sub-total and total rental fees from each suburb, time period, and property type

Select f.suburb, a.rent_date , b.property_type, sum(a.no_of_price) as Total_rental_fees
from Rent0Fact a, property0DIM b, suburb0DIM f
where b.property_id = a.property_id
and f.address_id = a.address_id
group by f.suburb ,cube (b.property_type,a.rent_date);



--REPORT 6: what are total and Subtotals of number of employees from each office and each gender using Roll-up
Select a.office_name, b.gender, Sum(c.no_of_employee) as Total_agents
from Office0DIM a, agent0dim b,Agent0Fact c
where a.office_id = c.office_id
and b.agent_id = c.agent_id
group by rollup( a.office_name, b.gender);


--REPORT 7: what are total and Subtotals of number of employees from each office and each gender using partial rollup
Select a.office_name, b.gender, b.salary,Sum(c.no_of_employee) as Total_agents
from Office0DIM a, agent0dim b,Agent0Fact c
where a.office_id = c.office_id
and b.agent_id = c.agent_id
group by a.office_name, rollup(b.gender,b.salary);


--REPORT 8: the total number of clients and cumulative number of clients with a high budget in each year ( by year not done)!!

select a.r_date, 
to_char(sum(total_no_client),'9,999,999,999') as client_total,
to_char(sum(sum(total_no_client)) over
(order by a.r_date rows unbounded preceding),'9,999,999,999') as cumulative_client_total
from client0fact a, client_budgetdim c
where a.client_id = c.client_id
and c.min_budget > 100001 
and  c.max_budget < 10000000
group by a.r_date; 


--REPORT 9: Moving aggregate reports : number of clients in each day for low budget

select a.r_date, 
to_char(sum(total_no_client),'9,999,999,999') as client_total,
to_char(avg(sum(total_no_client)) over
(order by a.r_date rows 2 preceding),'9,999,999,999') as cumulative_client_total
from client0fact a, client_budgetdim c
where a.client_id = c.client_id
and c.min_budget > 0
and  c.max_budget < 1000
group by a.r_date; 

--REPORT 10: Cumulative aggregate reports : Total rent and cumulative rent in each day 

select a.rent_date, 
to_char(SUM(total_no_of_rent),'9,999,999,999') as rent_total,
to_char(sum(sum(total_no_of_rent)) over
(order by a.rent_date rows unbounded preceding),'9,999,999,999') as cumulative_rent_total
from rent0fact a 
group by a.rent_date; 



--report 11: show ranking of each property type based on the yearly total
--number of sales and the ranking of each state based on the yearly total number of
--sales.


SELECT a.property_type, b.state_code,
 SUM(b.noofsale)as Total,
 RANK() OVER (PARTITION BY a.property_type
 ORDER BY SUM(b.noofsale)DESC) AS RANK_of_property,
 RANK() OVER (PARTITION BY b.state_code
 ORDER BY SUM(b.noofsale)DESC) AS RANK_of_state
FROM property0DIM a, sales0Fact b, state0DIM c
WHERE b.state_code = c.state_code
and a.property_id = b.property_id
GROUP BY a.property_type, b.state_code;


--report 12: Ranking of each suburb and feature based on yearly no of rent

SELECT c.feature_description, b.suburb,
 SUM(a.total_no_of_rent)as Total,
 dense_RANK() OVER (PARTITION BY b.suburb
 ORDER BY SUM(a.total_no_of_rent)DESC) AS RANK_of_suburb,
 dense_RANK() OVER (PARTITION BY c.feature_description
 ORDER BY SUM(a.total_no_of_rent)DESC) AS RANK_of_feature
FROM rent0fact a, suburb0DIM b, feature0DIM c
WHERE a.address_id = b.address_id
and a.feature_code = c.feature_code
GROUP BY c.feature_description, b.suburb;

