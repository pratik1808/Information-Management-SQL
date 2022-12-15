
--Creating base tables with relational integrity

create table Physicians(
    PhysicianID number(6,0) NOT NULL PRIMARY KEY,
    PhysicianType varchar2(255),
    PhysicianFirstName varchar2(255),
    PhysicianLastName varchar2(255)
);

create table Patients(
    PatientID number(6,0) NOT NULL PRIMARY KEY,
    PatientAge varchar2(255)
);

create table Drugs(
    DrugID number(6,0) NOT NULL PRIMARY KEY,
    DrugName varchar2(255),
    DrugPrice number(5,0),
    DiseaseArea varchar2(255)
);

create table Pharmacy_list(
    PharmacyId number(6,0) not null Primary Key,
    PharmacyName Varchar2(255),
    PharmacyAddress Varchar2(255)
);

--Transactional datasets

create table Transactions(
    TransactionID number(6,0) NOT NULL PRIMARY KEY,
    PatientID number(6,0) NOT NULL,
    PhysicianID number(6,0),
    PharmacyId number(6,0) NOT NULL,
    DrugID number(6,0) NOT NULL,
    TransactionDate date NOT NULL,
    Quantity number(4,0) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (PhysicianID) REFERENCES Physicians(PhysicianID),
    FOREIGN KEY (PharmacyId) REFERENCES Pharmacy_list(PharmacyId),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

create table Promotions(
    CallID number(6,0) NOT NULL PRIMARY KEY,
    PhysicianID number(6,0),
    DrugID number(6,0) NOT NULL,
    CallDate date NOT NULL,
    FOREIGN KEY (PhysicianID) REFERENCES Physicians(PhysicianID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

create table InventoryOut(
    DrugID number(6,0) NOT NULL,
    DeliveryDate date NOT NULL,
    Units number (6,0) NOT NULL,
    PharmacyId number(6,0),
    FOREIGN KEY (PharmacyId) REFERENCES Pharmacy_list(PharmacyId),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

create table InventoryIn(
    DrugID number(6,0) NOT NULL,
    ReceivedDate date NOT NULL,
    Units number (6,0) NOT NULL,
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

--Creating Warehouse datasets to be used as SSOT for our application

--Promotion warehouse

create table promotion_warehouse as
with 
CTE as(select c.callid,c.Calldate, p.PHYSICIANFIRSTNAME, p.PHYSICIANLASTNAME, p.PHYSICiANTYPE,c.DRUGID, c.PHYSICIANID FROM physicians p join promotions c on p.physicianid=c.physicianid)
select r.callid,r.calldate, r.PHYSICIANFIRSTNAME, r.PHYSICIANLASTNAME, r.PHYSICIANTYPE, r.PHYSICIANID, d.DRUGID, d.DRUGNAME, d.Drugprice, d.diseasearea from cte r join DRUGS d on d.DRUGID=r.DRUGID

--TRANSACTIONAL WAREHOUSE

create table TRANSACTIONS_WAREHOUSE AS

WITH 

CTE1 AS (select a.transactionid, a.PatientID,a.PhysicianID,a.PharmacyID,a.DrugID,a.TransactionDate,a.Quantity, b.patientage FROM transactions a join patients b on a.patientid=b.patientid),
CTE2 AS (select c.transactionid, c.PatientID,c.PhysicianID, c.PharmacyID,c.DrugID,c.TransactionDate,c.Quantity, c.patientage,d.pharmacyname, d.pharmacyaddress from CTE1 c join pharmacy_list d on c.pharmacyid=d.pharmacyid),
CTE3 AS (select e.transactionid, e.PatientID,e.PhysicianID,e.PharmacyID,e.DrugID,e.TransactionDate,e.Quantity, e.patientage,e.pharmacyname, e.pharmacyaddress,f.physiciantype,f.physicianfirstname, f.physicianlastname from CTE2 e join physicians f on e.physicianid= f.physicianid)
select g.transactionid, g.PatientID,g.PhysicianID,g.PharmacyID,g.DrugID,g.TransactionDate,g.Quantity, g.patientage,g.pharmacyname, g.pharmacyaddress,g.physiciantype,g.physicianfirstname, g.physicianlastname, h.DRUGNAME, h.Drugprice, h.diseasearea from CTE3 g join DRUGS h on g.drugid=h.drugid

--Inventory Warehouse

create table INVENTORY_WAREHOUSE AS

select c.DrugID, c.DrugName, c.DDate, c.Units, d.PharmacyId, d.PharmacyName, d.PharmacyAddress from
(select a. DrugID, a.DrugName, b.DDate, b.Units, b.PharmacyId from Drugs a
join (select DrugID,DeliveryDate as DDate, -1*Units as Units,PharmacyID from InventoryOut
union
select DrugID,ReceivedDate as DDate, Units, Null as PharmacyID from InventoryIn) b
on a.DrugID = b.DrugID) c left join
Pharmacy_list d on
c.PharmacyId = d.PharmacyId
order by DDate















