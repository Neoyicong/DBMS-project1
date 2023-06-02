create table city
(CID varchar(10),
CName varchar(25) not null,
Country varchar(25) not null,
Latitude number,
Longitude number,
primary key (CID));

select * from City;

create table Climate_Records
    (ClimateID varchar(10),
    CID varchar(10),
    WID varchar(10),
    datetime date, 
    Humidity number, 
    Pressure number, 
    Temperature number,
    WindSpeed number,
    WindDirection number,
    primary key (ClimateID),
    CONSTRAINT FK_CID FOREIGN KEY (CID)
    REFERENCES City(CID),
    CONSTRAINT FK_WID FOREIGN KEY (WID)
    REFERENCES Weather_Description(WID)   
);
select * from Climate_Records;

create table Weather_Description
    (WID varchar(10),
    WEATHER_TYPE varchar(25) not null, 
    primary key (WID));
    
select * from Weather_Description;
