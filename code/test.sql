--1
-- time difference



select SUBSTR(t1.d1,0,10) datetime, avg(a2-a1) tem_difference
from
(with city1 as(
select cid 
from city 
where latitude > (select avg(latitude) from city)
and latitude <> (select max(latitude) from city))
select c1.datetime d1,avg(c1.temperature) a1 from climate_records c1,city1
where city1.cid=c1.cid 
group by c1.datetime
order by c1.datetime asc) t1,
(with city2 as(
select cid 
from city 
where latitude <= (select avg(latitude) from city)
and latitude <> (select min(latitude) from city))
select c2.datetime d2,avg(c2.temperature) a2 from climate_records c2,city2
where city2.cid=c2.cid 
group by c2.datetime
order by c2.datetime asc)t2
where t1.d1=t2.d2
group by SUBSTR(t1.d1,0,10)
order by datetime;


--2

-- hour count where temp > 285

select cname,ym,hours from
(select distinct(t1.cid) cid,t1.ym ym,nvl(hours,0) hours from
(
(select cid, SUBSTR(datetime,0,7) ym 
from climate_records) t1
left outer join
(select cid, count(datetime) hours,SUBSTR(datetime,0,7) ym 
from climate_records
where  temperature > 285 
group by cid,SUBSTR(datetime,0,7)
order by cid,ym) t2 
on t1.ym = t2.ym and t1.cid = t2.cid
) 
order by cid) f,city
where f.cid = city.cid
order by cname,ym;



--3QL(1)
with gale as
(select windspeed ws
 from (select distinct windspeed  
       from climate_records 
       order by windspeed desc)
 where windspeed is not NULL and
       ROWNUM < (select (ceil(count(*)/10))*7 n 
                 from (select distinct windspeed  
                       from climate_records)))
select t1.cname ,t1.ym,nvl(t2.hours,0) s_hours,nvl(t3.hours,0) n_hours
from
(select distinct cname, SUBSTR(datetime,0,7) ym 
from climate_records c,city  
where c.cid = city.cid
order by ym)t1
left outer join
(select cname,ym,nvl(hours,0) hours 
from (select cname,SUBSTR(datetime,0,7) ym,count(SUBSTR(datetime,0,13)) hours
      from climate_records c,gale,city
      where c.windspeed in gale.ws and winddirection between 90 and 270 and city.cid = c.cid
      group by cname,SUBSTR(datetime,0,7)
      order by cname,SUBSTR(datetime,0,7)))t2
on t1.cname = t2.cname and t1.ym=t2.ym
left outer join
(select cname,ym,nvl(hours,0) hours 
from (select cname,SUBSTR(datetime,0,7) ym,count(SUBSTR(datetime,0,13)) hours
      from climate_records c,gale,city
      where c.windspeed in gale.ws and winddirection not between 90 and 270 and city.cid = c.cid
      group by cname,SUBSTR(datetime,0,7)
      order by cname,SUBSTR(datetime,0,7)))t3
on t1.cname = t3.cname and t1.ym=t3.ym
order by cname,ym;

--3QL(2)
-- 一天内，所有城市刮了n1小时的北大风，刮了n2小时的南大风， 大风等级自定义
with gale as
(select windspeed ws
 from (select distinct windspeed  
       from climate_records 
       order by windspeed desc)
 where windspeed is not NULL and
       ROWNUM < (select (ceil(count(*)/5))*4 n 
                 from (select distinct windspeed  
                       from climate_records)))
select t1.ym,sum(nvl(t2.hours,0)) s_hours,sum(nvl(t3.hours,0)) n_hours
from
(select distinct cname, SUBSTR(datetime,0,7) ym 
from climate_records c,city  
where c.cid = city.cid
order by ym)t1
left outer join
(select cname,ym,nvl(hours,0) hours 
from (select cname,SUBSTR(datetime,0,7) ym,count(SUBSTR(datetime,0,13)) hours
      from climate_records c,gale,city
      where c.windspeed in gale.ws and winddirection between 90 and 270 and city.cid = c.cid
      group by cname,SUBSTR(datetime,0,7)
      order by cname,SUBSTR(datetime,0,7)))t2
on t1.cname = t2.cname and t1.ym=t2.ym
left outer join
(select cname,ym,nvl(hours,0) hours 
from (select cname,SUBSTR(datetime,0,7) ym,count(SUBSTR(datetime,0,13)) hours
      from climate_records c,gale,city
      where c.windspeed in gale.ws and winddirection not between 90 and 270 and city.cid = c.cid
      group by cname,SUBSTR(datetime,0,7)
      order by cname,SUBSTR(datetime,0,7)))t3
on t1.cname = t3.cname and t1.ym=t3.ym
group by t1.ym
order by t1.ym;


--4 
-- 确定了画图，stack bar chart      
-- hour count in different weather type
select t1.cname, t1.dt dateimte,nvl(t5.sunnyHours,0)sunny,nvl(t2.windyHours,0)windy,nvl(t3.cloudyHours,0)cloudy,nvl(t4.rainyHours,0)precipitation,greatest(nvl(t5.sunnyHours,0),nvl(t2.windyHours,0),nvl(t3.cloudyHours,0),nvl(t4.rainyHours,0)) most from
((((select distinct cname,SUBSTR(datetime,0,7)dt from climate_records c,city where c.cid=city.cid order by cname,dt)t1
left outer join
(select cname,SUBSTR(datetime,0,7) dt,count(weather_type) windyHours from weather_description w,climate_records c,city
where c.cid=city.cid and w.wid=c.wid and w.weather_type in (select weather_type from weather_description
                                                            where weather_type like '%thunderstorm%' or weather_type like '%tornado%' or weather_type like '%whirls%')

group by cname,SUBSTR(datetime,0,7)
order by cname)t2
on t1.cname=t2.cname and t1.dt=t2.dt)
left outer join
(select cname,SUBSTR(datetime,0,7) dt,count(weather_type) cloudyHours from weather_description w,climate_records c,city
where c.cid=city.cid and w.wid=c.wid and w.weather_type in (select weather_type from weather_description
                                                            where weather_type like '%clouds%' or weather_type like '%fog%' or weather_type like '%smoke%'or weather_type like '%haze%'or weather_type like '%mist%')

group by cname,SUBSTR(datetime,0,7)
order by cname)t3
on t1.cname=t3.cname and t1.dt=t3.dt)
left outer join
(select cname,SUBSTR(datetime,0,7) dt,count(weather_type) rainyHours from weather_description w,climate_records c,city
where c.cid=city.cid and w.wid=c.wid and w.weather_type in (select weather_type from weather_description
                                                            where weather_type like '%rain%' or weather_type like '%drizzle%' or weather_type like '%snow%'or weather_type like '%sleet')

group by cname,SUBSTR(datetime,0,7)
order by cname)t4
on t1.cname=t4.cname and t1.dt=t4.dt)
left outer join
(select cname,SUBSTR(datetime,0,7) dt,count(weather_type) sunnyHours from weather_description w,climate_records c,city
where c.cid=city.cid and w.wid=c.wid and w.weather_type in (select weather_type from weather_description
                                                            where weather_type like '%clear%' )

group by cname,SUBSTR(datetime,0,7)
order by cname)t5
on t1.cname=t5.cname and t1.dt=t5.dt
;


--5
--temp
-- top 5 city of temp
select * from
(select cname,year, mt,rank()over(partition by year order by mt desc) rank from
(select cname,SUBSTR(datetime,0,4)year,avg(temperature-273.15) mt
from climate_records c,city 
where c.cid = city.cid 
group by cname,SUBSTR(datetime,0,4)
order by year,mt desc))
where rank<6 ;
--pressure
select * from
(select cname,year, round(mt,2),rank()over(partition by year order by mt desc) rank from
(select cname,SUBSTR(datetime,0,4)year,avg(pressure) mt
from climate_records c,city 
where c.cid = city.cid 
group by cname,SUBSTR(datetime,0,4)
order by year,mt desc))
where rank<6 ;
--
--5QL
select year,round(avg(at),2),round(avg(ah),2) from
(select cname,year, at,ah,rank()over(partition by year order by at desc) rank from
(select cname,SUBSTR(datetime,0,4)year,avg(temperature-273.15) at,avg(humidity) ah
from climate_records c,city 
where c.cid = city.cid 
group by cname,SUBSTR(datetime,0,4)
order by year,at desc))
where rank<6 
group by year;

--6
select cname,longitude,round(avg(humidity),2),round(max(temperature)-min(temperature),2),round(avg(nvl(pressure,1010)),2) from city,climate_records c
where city.cid=c.cid
group by cname,longitude
order by longitude;

--7
select c2.winddirection wd,round(avg(c1.temperature-c2.temperature),3) td
from climate_records c1,climate_records c2 
where c1.climateid = c2.climateid+1 and c2.winddirection is not null
group by c2.winddirection
order by wd;

--8