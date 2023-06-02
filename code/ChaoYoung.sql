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