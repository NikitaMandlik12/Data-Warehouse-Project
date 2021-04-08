---Creating star schema for property with Aggregation level 0

--Creating VisitDate0DIM dimension
Drop table VisitDate0DIM;

Create table VisitDate0DIM as 
select Distinct
    to_char(VISIT_DATE, 'MM-DD-YYYY') as VisitDate
from visit;

Select * from VisitDate0DIM;

----Creating property0DIM dimension
Drop table Property0DIM;

Create table Property0DIM as
select 
    PROPERTY_ID,
    to_char(PROPERTY_DATE_ADDED, 'MM-DD-YYYY') as Property_date_added,
    PROPERTY_TYPE,
    property_no_of_bedrooms
from property;

Select * from Property0DIM;

--Creating Advert0DIM dimension
Drop table Advert0DIM;

Create table Advert0DIM as
select * 
    from advertisement;

Select * from Advert0DIM;

--Creating Advertise_property0DIM
Drop table Advertise_property0DIM;

Create table Advertise_property0DIM as
select
    ADVERT_ID,
    PROPERTY_ID
From Property_Advert;

Select * from Advertise_property0DIM;

--Creating TempProperty0Fact 
Drop table TempProperty0Fact;

Create table TempProperty0Fact as
select distinct
a.client_person_id,
a.agent_person_id,
to_char(a.VISIT_DATE, 'MM-DD-YYYY') as VisitDate,
a.property_id,
count(a.property_id) as Total_property_visited
from Visit a, Property b
where a.property_id = b.property_id
group by a.VISIT_DATE,a.property_id,a.client_person_id,a.agent_person_id;

--Creating Property0Fact 
Drop table Property0Fact;

Create table Property0Fact as
select 
Visitdate,
property_id,
Total_property_visited
from TempProperty0Fact; 

select * from Property0Fact;
-----------------------------------------------------------------------------------------------------
--Creating State0DIM dimension

Drop table State0DIM;
 
create table state0DIM as
select state_code, state_name
from state;

Select * from State0DIM;

--Creating feature0DIM dimension
Drop table Feature0DIM;

Create table Feature0DIM as
Select  
feature_code,
feature_description
from Feature;

Select * from Feature0DIM;

--Creating Property0DIM dimension
Drop Table Property0DIM;

create table property0DIM as 
select 
property_id,
to_char(property_date_added, 'mm-dd-yyyy') as Property_date_added,
property_type,
Property_no_of_bedrooms
from property;

Select * from Property0DIM;

--Creating Sales0DIM Dimension
Drop table Sales0DIM;

Create table Sales0DIM as
Select 
sale_id,
price
from Sale;

Select * from Sales0DIM;

--Creating TempSales0Fact
Drop table TempSales0Fact;

Create table TempSales0fact as
select 
a.Property_id,
b.State_code,
e.Feature_code,
d.Sale_id,
sum(d.price) as total_sale,
count(d.sale_id) as noOfSale
from Property a, state b, sale d, property_feature e, Address f, Postcode g
where a.property_id = d.property_id
and a.property_id = e.property_id
and a.property_id = d.property_id
and a.Address_id = f.Address_id
and f.postcode = g.postcode
group by a.Property_id,
b.State_code,
e.Feature_code,
d.Sale_id ;

--Creating Fact table for Sales0Fact
drop table sales0fact;

Create table Sales0Fact as
select *
from TempSales0Fact;

select * from sales0Fact;

--Create Postcode0DIM dimension
Drop table Postcode0DIM;

create table postcode0DIM as select
postcode,
state_code from 
postcode;

Select * from Postcode0DIM;

----Create Suburb0DIM dimension
Drop table Suburb0DIM;

create table suburb0DIM as select
a.Address_id,
p.postcode,
a.suburb 
from postcode p , 
address a
where a.postcode= p.postcode;

Select * from Suburb0DIM;

----Create RentHis0Dim Dimension
Drop table RentHis0DIM;

create table rentHis0DIM as select
property_id,
rent_id,
RENT_START_DATE ,
RENT_END_DATE ,
price
from rent;

Select * from RentHis0DIM;

--Creating Date0DIM dimension
Drop table Date0DIM;

create table Date0DIM as (
select distinct
to_char(rent_start_date,'DD-MM-YYYY') as R_Date
from rent 
Union
Select Distinct
to_char(sale_date, 'DD-MM-YYYY') as R_Date from sale) ;

Select *  from Date0DIM;

--Creating TempRent0Fact table
Drop table TempRent0Fact;

select * from rent;
Create table TempRent0Fact as 
select
a.Property_id,
b.Address_id,
c.Feature_code,
d.rent_start_date as rent_date,
d.price
from property a, Address b, property_Feature c, Rent d
where a.address_id = b.Address_id
and a.property_id = c.property_id
and a.property_id = d.property_id
group by a.Property_id,
b.Address_id,
c.Feature_code,
d.rent_start_date,
d.price;


Select * from TempRent0Fact;
--Creating Rent0Fact table
Drop table Rent0Fact;

Create table Rent0fact as
select 
t.Property_id,
t.Address_id,
t.Feature_code,
t.rent_date ,
count(t.price) as total_no_of_rent,
sum(t.price) as no_of_price
from TempRent0Fact t
group by t.Property_id,
t.Address_id,
t.Feature_code,
t.rent_date;

select * from rent0fact;

------------------------------------------------------------------------------------------------------------------------

--Creating Agent0DIM dimension
Drop table Agent0DIM;

Create table Agent0DIM as
select
c.person_id as agent_id,
c.salary,
b.Gender
--Count(c.person_id) as number_of_employee
from Agent_office a, person b, agent c
where a.person_id = c.person_id
and b.person_id = c.person_id
group by c.person_id,
c.salary,
b.Gender;

select * from agent0dim;

--Creating Office0DIM dimension
Drop table Office0DIM;

Create table Office0DIM as
select 
office_id,
office_name
from Office;

Select * from Office0DIM;

--creating temp fact
drop table tagent0fact;
Create table TAgent0Fact as
select
a.office_id,
c.person_id as Agent_id
from Agent_office a, agent c
where a.person_id = c.person_id
group by a.office_id,
c.person_id ;


--Creating Agent0Fact 
Drop table Agent0Fact;


Create table Agent0Fact as
select
t.office_id,
t.agent_id,
count(t.agent_id) no_of_employee
from TAgent0Fact t
group by t.office_id,
t.agent_id;

select * from agent0fact;
----------------------------------------------------------------------------------------------
--Creating Client_budgetDIM dimension
Drop table Client_budgetDIM;

Create table Client_budgetDIM as
Select 
person_id as Client_id,
Min_Budget,
Max_Budget
from Client;

Select * from Client_budgetDIM;

--Creating ClientFact table
Drop table TClientFact;

Create table TClientFact as
select
c.Person_id as Client_id,
r_Date
from
(select distinct
to_char(rent_start_date,'DD-MM-YYYY') as r_Date, Client_person_ID as Client
from rent
Union
Select Distinct
to_char(sale_date, 'DD-MM-YYYY') as r_Date, Client_person_id as Client
from sale) a
inner join Client  C
On A.Client = C.person_id;

Select * from TClientFact;

create table client0fact as select
client_id,
R_date,
count(client_id) as total_no_client
from TClientFact t
group by client_id,
R_date;

select * from client0fact;









 
