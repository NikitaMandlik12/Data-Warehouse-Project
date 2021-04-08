---Data Cleaning of MonRE database

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Address table
-------------------------------------------------------------------------------------
-- For Checking number of rows 
Select Count(*) from MonRE.Address;

Drop table Address;

Create table Address as 
Select distinct Address_id, Street, Suburb, postcode
from MonRE.Address
order by Address_id;

--To check duplicate values in address table
select Address_Id, 
count(*)
from Address
group by Address_Id
having count(*) > 1;

--Checking for null values in all the columns in the  Address table 
select Address_id
from address 
where Address_id = null;

select Street
from address 
where Street = null;

select Suburb
from address 
where Suburb = null;

select postcode
from address 
where postcode = null or postcode = 0;

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Advertisement table
-------------------------------------------------------------------------------------
-- For Checking number of rows 
Select Count(*) from MonRE.Advertisement;

Drop table Advertisement;

Create table Advertisement as 
select *
from MonRE.Advertisement;

--To check duplicate values in advertisement table
select ADVERT_ID, 
count(*)
from Advertisement
group by ADVERT_ID
having count(*) > 1;

--Checking for null values in all the columns in the  advertisement table 
select ADVERT_ID
from Advertisement 
where ADVERT_ID = null or ADVERT_ID = 0;

select ADVERT_NAME
from Advertisement 
where ADVERT_NAME = null;

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Agent table
-------------------------------------------------------------------------------------
-- For Checking number of rows 
Select Count(*) from MonRE.Agent;

Drop table Agent;

Create table Agent 
as select *
from MonRE.Agent;

--To check duplicate values in agent table
select PERSON_ID, 
count(*)
from Agent
group by PERSON_ID
having count(*) > 1;

--Checking for null and negative values in all the columns in the  Agent table 
select PERSON_ID
from Agent
where PERSON_ID = null or PERSON_ID = 0;

select SALARY
from Agent
where SALARY= null or SALARY<= 0;

--Checking if Person_id from perosn table mattches with Person_id from Agent table
select * from Agent
where PERSON_ID not in
 (select PERSON_ID from MonRE.Person);

Select Count(*) from Agent;

--Deleting negative values of salary from the Agent table to clean the data
Delete from Agent where Salary <= 0;

Select Count(*) from Agent;

--Deleting row with person_id from agent table does not present in MonRE.Person table
Delete from Agent
where PERSON_ID not in
 (select PERSON_ID from MonRE.Person);

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Agent_Office table
-------------------------------------------------------------------------------------
-- For Checking number of rows 
Select Count(*) from MonRE.Agent_Office;

Drop table Agent_office;

Create table Agent_office
as select *
from MonRE.Agent_office;

--To check duplicate values in agent table
select PERSON_ID, 
count(*)
from Agent_Office
group by PERSON_ID
having count(*) > 1;

--As agent are allowed to work in different offices, duplicate values present here are acceptable.

--Checking for null values in all the columns in the  Agent_Office table 
select PERSON_ID
from Agent_Office
where PERSON_ID = null or PERSON_ID = 0;

select OFFICE_ID 
from Agent_office
where OFFICE_ID = null or OFFICE_ID = 0;

--Checking if PERSON_ID from MonRE.perosn table mattches with PERSON_ID from Agent_Office table
select * from Agent_Office
where PERSON_ID not in
(select PERSON_ID 
from MonRE.person);  

--Deleting row with PERSON_ID from Agent_Office table does not present in MonRE.Person table
Delete from Agent_Office
where PERSON_ID not in
(select PERSON_ID 
from MonRE.person);  

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Client table
-------------------------------------------------------------------------------------
-- For Checking number of rows 
Select Count(*) from MonRE.Client;

Drop table Client;

Create table Client
as select *
from MonRE.Client;

--To check duplicate values in Client table
select PERSON_ID, 
count(*)
from Client
group by PERSON_ID
having count(*) > 1;

--Checking negative and null values of budget in Client table
Select * from Client
where Min_Budget < 0 or Min_Budget = null;

Select * from Client
where Max_Budget <= 0 or Max_Budget > 10000000 or Max_Budget = null;

--Deleting row with Max_Budget is negative
Delete from Client
where Max_Budget <= 0 or Max_Budget > 10000000 or Max_Budget = null;

--Checking if PERSON_ID from Monre.person table mattches with PERSON_ID from Client table
select * from Client
where PERSON_ID not in
(select PERSON_ID 
from MonRE.person);  

--Deleting row with PERSON_ID from Agent_Office table does not present in MonRE.person table
Delete from Client
where PERSON_ID not in
(select PERSON_ID 
from MonRE.person);  

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Client_Wish table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Client_Wish;

Drop table Client_Wish;

Create table Client_Wish
as select *
from MonRE.Client_Wish;

--Checking negative and null values of budget in Client_Wish table
Select * from Client_Wish
where feature_code <= 0 or feature_code = null;
--No null values

Select * from Client_Wish
where Person_id <= 0 or Person_id = null;
--No null values

--Checking if PERSON_ID from Monre.person table mattches with PERSON_ID from Client_Wish table
select * from Client_Wish
where PERSON_ID not in
(select PERSON_ID 
from MonRE.person);  
--No invalid input found

--Checking if Feature_code from Monre.Feature table mattches with Feature_code from Client_Wish table
select * from Client_Wish
where Feature_code not in
(select Feature_code
from MonRE.Feature);  
--No invalid input found

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Feature table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Feature; 

Drop table Feature;

Create table Feature
as select *
from MonRE.Feature; 

---For Checking for duplicates values in Feature table
Select feature_code ,count(*) 
from feature 
group by feature_code 
Having Count(*) > 1;
--No duplicate values found

--Checking negative and null values in Feature table
Select * from Feature
where feature_code <= 0;
--No null values

Select * from Feature
where FEATURE_DESCRIPTION = null;
--No null values

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Office table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Office; 

Drop table Office;

Create table Office
as select *
from MonRE.Office; 

--Checking negative and null values in Office table
Select * from office
where Office_id <= 0 or Office_id = null;
--No null values

--Checking null values of column office_name in Office table
Select * from office
where Office_name = null;
--No null values

--Checking if Office_id from Monre.Agent_Office table mattches with Office_id from Office table
select * from Office
where Office_id not in
(select Office_id
from MonRE.Agent_Office);  
-- There are 3 agent offices in office table which are not allocated to any agent yet that's why it is not pressent in Agent_office table

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Person table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Person; 

Drop table Person;

Create table Person
as select *
from MonRE.Person; 

--For checking duplicates values
Select Person_id,
count(*) 
from person
group by Person_id
Having Count(*) > 1;

--To include only distinct rows and removing duplicte rows
Drop table Person;

Create table Person
as select distinct *
from MonRE.Person; 

--For checking duplicates values after creating table by using Distinct
Select Person_id,
count(*) 
from person
group by Person_id
Having Count(*) > 1;

--Checking Null and negative values in the Person table
Select * from Person
where Person_id <= 0 or Person_id = null;

Select * from Person
where Title = null or Title = 'Unknown';

Select * from Person
where First_name = null or First_name  = 'Unknown';

Select * from Person
where Last_name = null or Last_name  = 'Unknown';

Select * from Person
where Gender = null or Gender = 'Unknown';

Select * from Person
where Address_id = null or Address_id <= 0;

Select * from Person
where Phone_no = null or Phone_no <= 0;

Select * from Person
where Email = null or Email = 'Unknown';

--For checking duplicates values
Select PHONE_NO,
count(*) 
from person 
group by PHONE_NO
Having Count(*) > 1;

Select EMAIL,
count(*) 
from person 
group by EMAIL
Having Count(*) > 1;

--Checking if address_id from Monre.Address table mattches with address_id from MonRE.Address table
select * from person
where address_id not in
(select address_id 
from MonRE.address); 

--Deleting the row with address_id from person table which does not match address_id from Monre.Address table
Delete from person
where address_id not in
(select address_id 
from MonRE.address); 
--One row gets deleted

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Postcode table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Postcode; 

Drop table Postcode;

Create table Postcode
as select *
from MonRE.Postcode;

--To check duplicate values in postcode table
select Postcode, 
count(*)
from Postcode
group by Postcode
having count(*) > 1;

--Checking Null and negative values in the postcode table
Select * from Postcode
where Postcode <= 0 or Postcode = null;

Select * from Postcode
where State_code = null;

--Checking if State_code from Monre.State table mattches with State_code from MonRE.State table
select * from Postcode
where State_code NOT IN
 (select State_code from MonRE.State);

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Property table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Property; 

Drop table Property;

Create table Property
as select *
from MonRE.Property;

--To check duplicate values in Property table
select Property_id, 
count(*)
from Property
group by Property_id
having count(*) > 1;

--To select only distinct values into Property table
Drop table Property;

Create table Property
as select distinct *
from MonRE.Property;

--To check duplicate values in Property table after using distinct
select Property_id, 
count(*)
from Property
group by Property_id
having count(*) > 1;

select Address_id, 
count(*)
from Property
group by Address_id
having count(*) > 1;

--Checking Null and negative values in the Property table
Select * from Property
where Property_id <= 0 or Property_id = null;

Select * from Property
where Property_date_added = null;

Select * from Property
where Address_id <= 0 or Address_id = null;

Select * from Property
where Property_type = null;

Select * from Property
where Property_type = null;

Select * from Property
where PROPERTY_NO_OF_BEDROOMS <= 0 or PROPERTY_NO_OF_BEDROOMS = null;

Select * from Property
where PROPERTY_NO_OF_BATHROOMS < 0 or PROPERTY_NO_OF_BATHROOMS = null;

Select * from Property
where PROPERTY_NO_OF_GARAGES < 0 or PROPERTY_NO_OF_GARAGES = null;

Select * from Property
where PROPERTY_SIZE < 0;

Select * from Property
where PROPERTY_DESCRIPTION = null;

--- Checking if address_id from Address table matches with address_id from property table
select * 
from property
where address_id not in
(select address_id 
from address); 

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Property_Advert table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Property_Advert; 

Drop table Property_Advert;

Create table Property_Advert
as select *
from MonRE.Property_Advert;

--Checking Null and negative values in the property_advert table
Select * from Property_Advert
where Property_id <= 0 or Property_id = null;

Select * from Property_Advert
where ADVERT_ID <= 0 or ADVERT_ID = null;

Select * from Property_Advert
where AGENT_PERSON_ID <= 0 or AGENT_PERSON_ID = null;

Select * from Property_Advert
where COST<= 0 or COST = null;

--Cheking entries for Advert_id, Property_id and Agent_person_id
select * from Property_Advert
where property_id 
not in (select property_id 
from property);    

select * from Property_Advert
where agent_person_id 
not in (select person_id 
from person);     

select * from Property_Advert
where advert_id 
not in (select advert_id 
from Advertisement);   

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Property_Feature table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Property_Feature; 

Drop table Property_Feature;

Create table Property_Feature
as select *
from MonRE.Property_Feature;

--Checking Null and negative values in the property_advert table
Select * from Property_Feature
where Property_id <= 0 or Property_id = null;

Select * from Property_Feature
where FEATURE_CODE <= 0 or FEATURE_CODE = null;

--- Checking for the featurecode and property id 
select * from Property_Feature
where FEATURE_CODE not in
(select FEATURE_CODE 
from feature);

select * from Property_Feature
where property_id not in
(select property_id 
from property);  

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Rent table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Rent; 

Drop table Rent;

Create table Rent
as select *
from MonRE.Rent;

--To check duplicate values in Rent table
select rent_id, 
count(*)
from Rent
group by rent_id
having count(*) > 1;

--Checking Null and negative values in the Rent table
Select * from Rent
where Rent_id <= 0 or Rent_id = null;

Select * from Rent
where AGENT_PERSON_ID <= 0 or AGENT_PERSON_ID = null;

Select * from Rent
where CLIENT_PERSON_ID<= 0 or CLIENT_PERSON_ID= null;

Select * from Rent
where PROPERTY_ID <= 0 or PROPERTY_ID = null;

Select * from Rent
where Price <= 0 or Price = null;

--Checking for property_id or Client_person_id
select * from Rent
where Property_id not in
(select Property_id 
from Property); 

select * from Rent
where AGENT_PERSON_ID not in
(select person_id 
from Agent);

select * from Rent
where Client_person_id not in
(select person_id 
from Client);

--Deleting rows from Rent which values does not match with Person_id from Client table
Delete from Rent
where Client_person_id not in
(select person_id 
from Client);
-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Sale table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Sale; 

Drop table Sale;

Create table Sale
as select *
from MonRE.Sale;

--To check duplicate values in Sale table
select Sale_id, 
count(*)
from Sale
group by Sale_id
having count(*) > 1;

--Checking Null or negative values in the Sale table
Select * from Sale
where Sale_id <= 0 or Sale_id = null;

Select * from Sale
where AGENT_PERSON_ID <= 0 or AGENT_PERSON_ID = null;

Select * from Sale
where Client_person_id <= 0 or Client_person_id = null;

Select * from Sale
where PRICE <= 0 or PRICE = null;

Select * from Sale
where PROPERTY_ID <= 0 or PROPERTY_ID = null;

select * from Sale
where AGENT_PERSON_ID not in
(select person_id 
from Agent);
--All entries are correct

select * from Sale
where Client_person_id not in
(select person_id 
from Client);
--All entries are correct

select * from Sale
where property_id not in
(select property_id 
from property);
--All entries are correct	
-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.State table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.State; 

Drop table State;

Create table State
as select *
from MonRE.State;

--Checking Null and negative values in the State table
Select * from State
where State_Code = null;

select *
from State 
where State_name = null or State_name = 'Unknown'; 
--Null and unknown value is present

--Deleting rows with null values
Delete from State 
where State_name = null or State_name = 'Unknown';

-------------------------------------------------------------------------------------
--Data Cleaning of MonRE.Visit table
-------------------------------------------------------------------------------------
Select Count(*) from MonRE.Visit; 

Drop table Visit;

Create table Visit
as select *
from MonRE.Visit;

select * from Visit 
where agent_person_id = null  or agent_person_id <= 0;

select * from Visit 
where property_id = null  or property_id <= 0 ;

select * from Visit 
where duration = null  or duration <= 0 ;

select * from Visit 
where client_person_id = null  or client_person_id <= 0 ;

--Checking for property_id , Client_person_id , agent_person_id  
select * from Visit
where property_id not in
(select property_id 
from property);

select * from Visit
where agent_person_id  
not in (select person_id 
from agent); 

select * from Visit
where Client_person_id not in
(select person_id 
from Client);

--Deleting rows with unwanted values
Delete from Visit
where Client_person_id not in
(select person_id 
from Client); 
