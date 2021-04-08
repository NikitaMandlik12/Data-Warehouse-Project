--Task 3 OLAP reports
-- Question a: Simple reports
--REPORT 1: Top 5 total number of sales of property accrording to suburb and state.
select * from
(select a.state_code, b.property_type, sum(d.total_sales) as Total,
dense_rank() over (order by sum(d.total_sales) desc) as sales_rank
from state2DIM a, Property2DIM b, sales2Fact d
where a.state_code = d.state_code
and b.property_id = d.property_id
Group by a.state_code,b.property_type)
where sales_rank <= 5;

--REPORT 2: Top 10% properties visited in summer

Select * from
(select a.property_id, b.season_type, sum(c.Total_no_of_visit) as T_visit,
Percent_Rank() over (order by sum(c.Total_no_of_visit)) as Top_Percent
from Property2DIM a, seasonDIM b, Property2Fact c
Where a.property_id = c.property_id
and b.seasonID = c.SeasonID
and b.season_type = 'Summer'
group by a.property_id, b.season_type
order by Top_Percent desc)
Where Top_Percent >= 0.9;

--REPORT 3: Show all the rental properties in descending order based upon number of features type such as basic feature, standard and luxurious and property scale
Select a.property_id, b.scale_desc, c.feature_type, count(a.Total_no_of_rent),
dense_rank() over (order by count(a.Total_no_of_rent) desc ) as rent_rank
from rent2Fact a, property_scale2DIM b, feature2DIM c
where a.scale_id = b.scale_id
and a.feature_id = c.feature_id
group by a.property_id, b.scale_desc, c.feature_type;

--Question b: reports with proper sub-totals
--What are the sub-total and total rental fees from each suburb, time period, and property type
--REPORT 4: USING CUBE OPERATOR

Select f.suburb, a.year, b.property_type, sum(a.no_of_price) as Total_rental_fees
from Rent2Fact a, property2DIM b, suburb2DIM f
where b.property_id = a.property_id
and f.postcode = a.postcode
group by cube (f.suburb,b.property_type,a.year);



--REPORT 5: Show total of Rental price based upon Property type , time and year of different suburbs

Select f.suburb, a.year, b.property_type, sum(a.no_of_price) as Total_rental_fees
from Rent2Fact a, property2DIM b, suburb2DIM f
where b.property_id = a.property_id
and f.postcode = a.postcode
and b.property_type = 'House'
group by f.suburb, cube(a.year, b.property_type);

---awating agent information
--REPORT 6: Subtotals of Agents based upon office type and office name using Roll-up
Select a.office_name, b.office_type, Sum(c.total_no_agents) as Total_agents
from Office2DIM a, Office_type2DIM b, Agent2Fact c
where a.office_id = c.office_id
and b.office_typeid = c.officetype_id
group by rollup( a.office_name, b.office_type);


--REPORT 7: Subtotals of sales price based upon featuretype and suburb using Partial Roll-up
select a.feature_type, c.suburb, sum(no_of_price) as total_rent
from feature2DIM a, rent2Fact b, suburb2DIM c
where a.feature_id = b.feature_id
and b.postcode = c.postcode
group by rollup(a.feature_type, c.suburb);


--REPORT 8: the total number of clients and cumulative number of clients with a high budget in each year

select a.year, 
to_char(sum(total_no_of_clients),'9,999,999,999') as client_total,
to_char(sum(sum(total_no_of_clients)) over
(order by a.year rows unbounded preceding),'9,999,999,999') as cumulative_client_total
from client2fact a, budget2DIM c
where a.budgetID = c.budgetID
and a.budgetid = '3'
group by a.year; 


--REPORT 9: Moving aggregate reports

SELECT a.year,scale_desc,
TO_CHAR (SUM(a.total_no_of_rent), '9,999,999,999') AS R_rent,
TO_CHAR (AVG(SUM(a.total_no_of_rent)) OVER
(ORDER BY a.year
ROWS 2 PRECEDING),'9,999,999,999') AS MOVING_2_MONTH_AVG
FROM rent2fact a, property_scale2DIM b
WHERE a.scale_id = b.scale_id 
and b.scale_desc = 'Small'
GROUP BY a.year,b.scale_desc;


--REPORT 10: Cumulative aggregate reports
select a.year, 
to_char(SUM(total_no_of_rent),'9,999,999,999') as rent_total,
to_char(sum(sum(total_no_of_rent)) over
(order by a.year rows unbounded preceding),'9,999,999,999') as cumulative_rent_total
from rent2fact a,property_scale2DIM b
WHERE a.scale_id = b.scale_id 
and b.scale_desc = 'Large'
group by a.year; 



--report 11: show ranking of each property type based on the yearly total
--number of sales and the ranking of each state based on the yearly total number of
--sales.


SELECT a.property_type, b.state_code,
 SUM(b.total_sales)as Total,
 RANK() OVER (PARTITION BY a.property_type
 ORDER BY SUM(b.total_sales)DESC) AS RANK_of_property,
 RANK() OVER (PARTITION BY b.state_code
 ORDER BY SUM(b.total_sales)DESC) AS RANK_of_state
FROM property2DIM a, sales2Fact b, state2DIM c
WHERE b.state_code = c.state_code
GROUP BY a.property_type, b.state_code;

select * from  VisitTimeDIM;

--report 12: Ranking of each suburb and scale based on no of rent

SELECT a.year, b.suburb,
 SUM(a.total_no_of_rent)as Total,
 dense_RANK() OVER (PARTITION BY b.suburb
 ORDER BY SUM(a.total_no_of_rent)DESC) AS RANK_of_suburb,
 dense_RANK() OVER (PARTITION BY a.year
 ORDER BY SUM(a.total_no_of_rent)DESC) AS RANK_of_year
FROM rent2fact a, suburb2DIM b
where a.postcode = b.postcode
GROUP BY a.year, b.suburb;
