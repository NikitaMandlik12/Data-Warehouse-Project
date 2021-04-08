---Creating star schema for property with Aggregation level 2

--Creating VisitTime2DIM dimension
Drop table visitTime2DIM;
Create table VisitTime2DIM as 
select Distinct
    to_char(VISIT_DATE, 'DD-MM-YYYY') as VisitDate
from visit;

select * from visitTime2DIM;

--Creating property2DIM dimension
Drop table Property2DIM;
Create table Property2DIM as
select 
    PROPERTY_ID,
    to_char(PROPERTY_DATE_ADDED, 'MM') as Month,
    to_char(PROPERTY_DATE_ADDED, 'YYYY') as Year,
    PROPERTY_TYPE
from property;

select * from Property2DIM;

--Creating Advert2DIM dimension
Drop table Advert2DIM;

Create table Advert2DIM as
select * from advertisement;

select * from Advert2DIM;

--Creating Advertise_property2DIM
Drop table Advertise_property2DIM;

Create table Advertise_property2DIM as
select
    ADVERT_ID,
    PROPERTY_ID
From Property_Advert;

select * from advertise_property2dim;

--Create TempSeasonDIM dimension
Drop table TempSeason2DIM;

Create table TempSeason2DIM as
select 
    to_char(VISIT_DATE, 'MM') as Visit_Month
from Visit;

Alter table TempSeason2DIM add SeasonID number(2);
Alter table TempSeason2DIM add Season_type varchar(20);
    
update TempSeason2DIM set SeasonID = 1, season_type = 'Summer' where visit_month >'01' and visit_month <= '03';
update TempSeason2DIM set SeasonID = 2, season_type = 'Autumn' where visit_month >'03' and visit_month <= '06';
update TempSeason2DIM set SeasonID = 3, season_type = 'Winter' where visit_month > '06' and visit_month <= '09';
update TempSeason2DIM set SeasonID = 4, season_type = 'Spring' where visit_month > '09' and visit_month <= '12';

---Creating SeasonDIM dimension
Drop table SeasonDIM;
Create table SeasonDIM as Select Distinct SeasonID, Season_type from TempSeason2DIM;
select * from SeasonDIM;

---Create TempPropertyFact fact dimension
drop table TempProperty2Fact;
Create table TempProperty2Fact as
select 
to_char(a.VISIT_DATE, 'MMDDYYYY') || client_person_id as VisitID,
to_char(a.VISIT_DATE, 'MM-DD-YYYY') as VisitDate,
to_char(a.VISIT_DATE, 'MM') as Visit_Month,
b.property_type,
b.property_date_added,
c.advert_name,
d.advert_id,
d.property_id
from Visit a, Property b, Advertisement c, Property_advert d
where a.property_id = b.property_id
and d.property_id = b.property_id
and d.advert_id = c.advert_id;

Alter table TempProperty2Fact add SeasonID number(2);
Alter table TempProperty2Fact add Season_type Varchar(20);

update TempProperty2Fact set SeasonID = 1, season_type = 'Summer' where visit_month >'01' and visit_month <= '03';
update TempProperty2Fact set SeasonID = 2, season_type = 'Autumn' where visit_month >'03' and visit_month <= '06';
update TempProperty2Fact set SeasonID = 3, season_type = 'Winter' where visit_month > '06' and visit_month <= '09';
update TempProperty2Fact set SeasonID = 4, season_type = 'Spring' where visit_month > '09' and visit_month <= '12';


--Creating propertyFact fact dimension
Drop table Property2Fact;

Create table Property2Fact as
Select 
visitdate,
seasonID,
Property_id,
count(property_id) as Total_no_of_property,
Sum(visitid) as Total_no_of_visit,
Count(Visitid) as No_of_visit
from tempproperty2fact
group by Visitdate, seasonID, property_id;

select * from Property2Fact;
--------------------------------------------------------------------------------
--Creating State2DIM dimension
Drop table State2DIM;
 
create table state2DIM as
select state_code, state_name
from state;

select * from state2DIM;

--Creating Feature2DIM dimension
DROP table TempFeature2DIM;
DROP table Feature2DIM;

create table tempfeature2DIM
as select  a.property_id, count(a.Feature_code) as count
from property_feature a, property b
where a.property_id = b.property_id
Group by a.property_id;

Alter table tempfeature2DIM add feature_id number(3);
Alter table tempfeature2DIM add feature_type varchar(20);

update tempfeature2DIM set feature_id = 1, feature_type = 'Very Basic' where count < 10;
update tempfeature2DIM set feature_id = 2, feature_type = 'Standard' where count >= 10 and count <= 20;
update tempfeature2DIM set feature_id = 3, feature_type = 'Luxurious' where count > 20;

Create table feature2DIM as 
select distinct feature_id, 
feature_type 
from tempfeature2DIM;

select * from Feature2DIM;

--Creating Property2DIM dimension
Drop Table Property2DIM;

create table property2DIM as 
select property_id,to_char(property_date_added,'mm') as month,to_char(property_date_added,'yyyy')as year,property_type
from property;

select * from property2DIM;

--Creating TempSales2Fact
drop table Tempsales2Fact;

create table Tempsales2Fact as
select p.property_id , 
st.state_code, 
count(f.feature_code) as count,
to_char(s.sale_date, 'YYYY') as Year,
s.price,
s.sale_id
from property p, state st, property_feature f, sale s, address a, postcode p
where p.property_id = f.property_id
and f.property_id = s.property_id
and p.address_id = a.address_id
and a.postcode = p.postcode
and p.state_code = st.state_code
group by p.property_id , st.state_code,to_char(s.sale_date, 'YYYY'), s.price, s.sale_id;

Alter table Tempsales2Fact add feature_id number(3);
Alter table Tempsales2Fact add feature_type varchar(20);

update Tempsales2Fact set feature_id = 1, feature_type = 'Very Basic' where count < 10;
update Tempsales2Fact set feature_id = 2, feature_type = 'Standard' where count >= 10 and count <= 20;
update Tempsales2Fact set feature_id = 3, feature_type = 'Luxurious' where count > 20;

--Creating Sales2Fact table
Drop table Sales2Fact;

Create table sales2Fact as select 
t.property_id,
t.state_code,
t.feature_id, 
t.year,
count(sale_id) as total_sales_count,
sum(price) as total_sales
from Tempsales2Fact t
group by t.property_id,t.state_code,t.feature_id, t.year; 

select * from Sales2Fact;

--Create Postcode2DIM dimension
Drop table Postcode2DIM;

create table postcode2DIM as select
postcode,state_code from 
postcode;

select * from postcode2dim;

--Create Suburb2DIM dimension
Drop table Suburb2DIM;

create table suburb2DIM as select
p.postcode,
a.suburb 
from postcode p , address a
where a.postcode= p.postcode;

select * from Suburb2DIM;

--Create RentHis2Dim Dimension
Drop table RentHis2DIM;

create table rentHis2DIM as select
property_id,
rent_id,
RENT_START_DATE ,
RENT_END_DATE ,
price
from rent;

select * from RentHis2DIM;

--Create Property_scale2DIM dimension;
Drop table Property_Scale2DIM;

create table property_scale2DIM(
scale_id number,
scale_desc varchar(20));

insert into  property_scale2DIM values
('1','Extra Small');
insert into  property_scale2DIM values
('2','Small');
insert into  property_scale2DIM values
('3','Medium');
insert into  property_scale2DIM values
('4','Large');
insert into  property_scale2DIM values
('5','Extra Large');

select * from Property_Scale2DIM;

--Creating Rent_year2DIM dimension
Drop table Year2DIM;

create table Year2DIM as (select 
distinct 
to_char(rent_start_date,'yyyy') as year
from rent 
Union
select 
distinct 
to_char(Sale_date, 'YYYY') as year
from sale) ;

Select * from Year2DIM;

--Creating tempRent2Fact table
drop table tempRent2Fact;

create table tempRent2Fact as select
p.property_id, 
po.postcode, 
to_char(rn.rent_start_date,'yyyy') as year,
p.property_no_of_bedrooms as rooms, 
rn.rent_id, 
rn.price,
count(f.feature_code) as count
from property p, postcode po, property_feature f, address a, rent rn
where p.property_id = f.property_id
and f.property_id = rn.property_id
and p.address_id = a.address_id
and a.postcode = po.postcode
group by 
p.property_id, 
po.postcode, 
to_char(rn.rent_start_date,'yyyy'),
p.property_no_of_bedrooms,
rn.rent_id, 
rn.price;

-----
alter table temprent2Fact add (scale_id  numeric);
alter table temprent2Fact add (scale_desc varchar(20));

update temprent2Fact
set scale_id = '1',scale_desc = 'Extra Small'where rooms <= '1';
update temprent2Fact
set scale_id = '2',scale_desc = 'Small' where rooms <= '03' and rooms >= '02';
update temprent2Fact
set scale_id = '3',scale_desc = 'Medium' where rooms <= '06' and rooms >= '04';
update temprent2Fact
set scale_id = '4',scale_desc = 'Large' where rooms <= '10' and rooms >= '07';
update temprent2Fact
set scale_id = '5',scale_desc = 'Extra Large' where rooms > '10';

Alter table temprent2Fact add feature_id number(3);
Alter table temprent2Fact add feature_type varchar(20);

update temprent2Fact set feature_id = 1, feature_type = 'Very Basic' where count < 10;
update temprent2Fact set feature_id = 2, feature_type = 'Standard' where count >= 10 and count <= 20;
update temprent2Fact set feature_id = 3, feature_type = 'Luxurious' where count > 20;

---Creating Rent2Fact table
Drop table Rent2Fact;

create table Rent2Fact as select
t.property_id,
t.postcode,
t.feature_id,
t.year,
t.scale_id,
count(t.rent_id) as total_no_of_rent,
sum(t.price) as no_of_price
from temprent2Fact t
group by t.property_id, t.postcode, t.feature_id, t.year, t.scale_id;

select * from Rent2Fact;
-----------------------------------------------------------------------------------------

--Creating office2DIM Dimension
drop table Office2DIM;

create table Office2DIM as 
select distinct 
office_id, 
office_name 
from office;

select * from Office2DIM;

--- Creating Agentgender2DIM dimension
drop table Agentgender2DIM;

create table Agentgender2DIM 
as select distinct Gender as gender_type 
from person;

alter table Agentgender2DIM add gender_id number(2);

update Agentgender2DIM set gender_id = 1  Where gender_type = 'Male' ;
update Agentgender2DIM set gender_id = 2 Where gender_type = 'Female' ;

select * from agentgender2dim;

--- Creating TempOfficeType2DIM

drop table TempOfficetype2DIM;

create table TempOfficetype2DIM 
as select Count(person_id) as number_of_employee, office_id from agent_office group by office_id ;

alter table TempOfficetype2DIM add office_type varchar(20);
alter table TempOfficetype2DIM add office_typeid number(2);

update TempOfficetype2DIM set office_typeid = 1 , office_type = 'Small'  Where number_of_employee  <  4;
update TempOfficetype2DIM set office_typeid = 2 , office_type = 'Medium' Where number_of_employee >= 4  and  number_of_employee < 12 ;
update TempOfficetype2DIM set office_typeid = 3 , office_type = 'Big' Where number_of_employee > 12 ;

--Creating office_type2DIM dimension
drop table Office_type2DIM;

Create Table Office_type2DIM as 
Select Distinct 
office_typeid , 
office_type
from TempOfficetype2DIM;

select * from Office_type2DIM;


--Create TempAgent2fact
Drop table TempAgent2fact;

Create table TempAgent2fact as
select distinct 
b.person_id as Agent_Id,
b.Salary,
o.office_id, 
o.office_name,
Count(a.person_id) as number_of_employee,
p.Gender as gender_type
from office o, person p, agent_office a, agent b
where o.office_id = a.office_id
and a.person_id = b.person_id
and p.person_id = b.person_id
group by b.person_id,
b.Salary,
o.office_id, 
o.office_name,
p.Gender ;

alter table TempAgent2fact add gender_id number(2);

update TempAgent2fact set gender_id = 1  Where gender_type = 'Male' ;
update TempAgent2fact set gender_id = 2 Where gender_type = 'Female' ;
--
alter table TempAgent2fact add officetype varchar(20);
alter table TempAgent2Fact add officetype_id number(2);

update TempAgent2Fact set officetype_id = 1 , officetype = 'Small'  Where number_of_employee  <  4;
update TempAgent2Fact set officetype_id = 2 , officetype = 'Medium' Where number_of_employee >= 4  and  number_of_employee < 12 ;
update TempAgent2Fact set officetype_id = 3 , officetype = 'Big' Where number_of_employee > 12 ;

---Create final Agent2Fact table
Drop table Agent2Fact; 

Create table Agent2Fact as
Select
officetype_id,
Gender_ID,
office_id,
Count(Agent_id) as Total_no_Agents,
Count(Salary) as Total_salary
from TempAgent2Fact
group by officetype_id,
Gender_ID,
office_id;

select * from Agent2Fact;
---------------------------------------------------------------------------------------------------------
--Creating TempBudget2DIM dimension
Drop table TempBudget2DIM;

Create table TempBudget2DIM as
select
min_budget,
max_budget
from Client;

Alter table TempBudget2DIM add  BudgetID number (2);
Alter table TempBudget2DIM add BudgetType Varchar(20);

update TempBudget2DIM set BudgetID = 1 , BudgetType= 'Low'  Where Min_budget > 0 and Max_budget <= 1000 ;
update TempBudget2DIM set BudgetID = 2 , BudgetType= 'Medium'  Where Min_budget >= 1001 and Max_budget <= 100000 ;
update TempBudget2DIM set BudgetID = 3 , BudgetType= 'High'  Where Min_budget >= 100001 and Max_budget <= 10000000;

--Creating Budget2DIM dimension
Drop table Budget2DIM;

Create table Budget2DIM as
Select Distinct
BudgetID,
BudgetType
from TempBudget2DIM;

select * from Budget2DIM;

Delete from Budget2DIm
where BudgetId is null;

--Creating TempClientFact table
Drop table TempClient2Fact;

Create table TempClient2Fact as
select
C.min_budget,
C.max_budget,
C.Person_id,
A.Year ,
A.Client
From 
(select distinct
to_char(rent_start_date,'YYYY') as Year, Client_person_ID as Client
from rent
Union
Select Distinct
to_char(sale_date, 'YYYY') as Year , Client_person_id as Client
from sale)  A
inner join Client  C
On A.Client = C.person_id;

Alter table TempClient2Fact add  BudgetID number (2);
Alter table TempClient2Fact add BudgetType Varchar(20);

update TempClient2Fact set BudgetID = 1 , BudgetType= 'Low'  Where Min_budget > 0 and Max_budget <= 1000 ;
update TempClient2Fact set BudgetID = 2 , BudgetType= 'Medium'  Where Min_budget >= 1001 and Max_budget <= 100000 ;
update TempClient2Fact set BudgetID = 3 , BudgetType= 'High'  Where Min_budget >= 100001 and Max_budget <= 10000000;

select * from TempClient2Fact;
--Creating Client2Fact table
Drop table Client2Fact;

create table Client2fact as 
select 
BudgetID,
Year,
count(client) as Total_no_of_clients
from tempclient2fact
group by 
BudgetID,
Year;

select * from Client2Fact;







