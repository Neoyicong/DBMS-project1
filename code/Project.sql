select c2.winddirection wd,round(avg(c1.temperature-c2.temperature),3) td
from climate_records c1,climate_records c2 
where c1.climateid = c2.climateid+1 and c2.winddirection is not null
group by c2.winddirection
order by wd;