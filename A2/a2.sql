create or replace view Q1(Name) as
select p.name
from person p,proceeding pr
where pr.editorid=p.personid
group by p.personid;

create or replace view Q2(Name) as
select p.name
from person p,proceeding pr,RelationPersonInProceeding re,InProceeding inp
where pr.editorid=p.personid and re.personid=p.personid and re.inproceedingid=inp.inproceedingid
group by p.personid;

create or replace view Q3(Name) as
select p.name
from person p,proceeding pr,RelationPersonInProceeding re,InProceeding inp
where pr.editorid=p.personid and re.personid=p.personid and re.inproceedingid=inp.inproceedingid and inp.proceedingid=pr.proceedingid
group by p.personid;

create or replace view Q4(Title) as
select inp.title
from person p,proceeding pr,RelationPersonInProceeding re,InProceeding inp
where pr.editorid=p.personid and  re.personid=p.personid and re.inproceedingid=inp.inproceedingid and inp.proceedingid=pr.proceedingid
group by inp.title;

create or replace view Q5(Title) as
select distinct(inp.title)
from person p,RelationPersonInProceeding re,InProceeding inp
where p.name like '%Clark' and inp.inproceedingid=re.inproceedingid and re.personid=p.personid;

create or replace view Q6(Year, Total) as
select pr.year,count(distinct(inp.inproceedingid))
from proceeding pr,inproceeding inp
where inp.proceedingid=pr.proceedingid and pr.year not in (select year from proceeding where year='unknown') 
group by pr.year
having count(*)<>0
order by pr.year asc;

create or replace view npublisher as
select pu.name as pname,count(distinct(inp.inproceedingid)) as t
from publisher pu,inproceeding inp,proceeding pr
where pr.publisherid=pu.publisherid and inp.proceedingid=pr.proceedingid
group by pu.name;

create or replace view Q7(Name) as
select pname
from npublisher
where t=(select max(t) from npublisher);

create or replace view coporation as
select re.inproceedingid as inp,count(distinct(re.personid)) as t
from person p,relationpersoninproceeding re,inproceeding inp
where p.personid=re.personid and inp.inproceedingid=re.inproceedingid
group by re.inproceedingid
having count(re.personid)>1
order by t desc;

create or replace view nau as
select re.personid as pid,count(distinct(re.inproceedingid)) as t
from coporation,relationpersoninproceeding re
where re.inproceedingid=inp
group by re.personid
order by t desc;

create or replace view Q8(Name) as
select p.name
from nau,person p
where p.personid=pid and t=(select max(t) from nau);


create or replace view ninp as
select re.inproceedingid as reinp,count(distinct(re.personid)) as t
from relationpersoninproceeding re
group by re.inproceedingid;

create or replace view ncoauthor as
select p.personid as pid
from person p,ninp,relationpersoninproceeding re
where p.personid=re.personid and re.inproceedingid=reinp and t=1
group by p.personid;

create or replace view ncoauthor2 as
select p.personid as pid2
from person p,ninp,relationpersoninproceeding re
where p.personid=re.personid and re.inproceedingid=reinp and t>1
group by p.personid;

create or replace view Q9(Name) as
select p.name
from person p
where p.personid in (select pid from ncoauthor) and p.personid not in (select pid2 from ncoauthor2);

create or replace view countauthor(a,c) as
select distinct re1.personid as a,re2.personid as c
from relationpersoninproceeding re1 left join relationpersoninproceeding re2 on (re1.inproceedingid=re2.inproceedingid)
order by a asc;

create or replace view Q10(Name, Total) as
select p.name,count(c)-1 as t
from countauthor,person p
where p.personid=a 
group by p.personid
order by t desc,p.name asc;


create or replace view cowithrichard as
select p1.personid as pid
from countauthor,person p1,person p2
where p1.name not like 'Richard%' and a=p1.personid and p2.name like 'Richard%' and c=p2.personid
group by p1.personid;

create or replace view cocowithrichard as 
select distinct(re2.personid) as pid
from person p,relationpersoninproceeding re1,relationpersoninproceeding re2
where re1.inproceedingid=re2.inproceedingid and re1.personid=p.personid and re1.personid in (select pid from cowithrichard);

create or replace view richard as 
select personid
from person
where name like 'Richard%';

create or replace view Q11(Name) as
select p.name
from person p,relationpersoninproceeding re
where p.personid=re.personid and p.personid not in (select distinct(pid) from cowithrichard) and p.personid not in (select distinct(personid) from richard) and p.personid not in (select pid from cocowithrichard)
group by p.personid;

create or replace view recursive(personid) as 
with recursive recoauthor(personid,pcoauthor)as(
	select re1.personid,re2.personid
	from relationpersoninproceeding re1
	join person p on (re1.personid=p.personid)
	join relationpersoninproceeding re2 on(re2.inproceedingid=re1.inproceedingid)
where p.name like'Richard%'
union
	select re1.personid,re2.personid
	from relationpersoninproceeding re1
	join recoauthor rc on (re1.personid=rc.pcoauthor)
	join relationpersoninproceeding re2 on (re1.inproceedingid=re2.inproceedingid))
select distinct p.personid
from person p join recoauthor rc on (p.personid=rc.personid)
;

create or replace view q12(name) as
select p.name
from person p join recursive re on (p.personid=re.personid)
where p.name !~ '^Richard';


create or replace view Q13(Author, Total, FirstYear, LastYear) as
select p.name,count(inp.inproceedingid) as t,coalesce(min(pr.year),'unknown') as c1,coalesce(max(pr.year),'unknown') as c2
from person p, relationpersoninproceeding re,proceeding pr right join inproceeding inp on (pr.proceedingid=inp.proceedingid)
where re.personid=p.personid and re.inproceedingid=inp.inproceedingid
group by p.personid
order by t desc,p.name asc;

create or replace view Q14(Total) as
select count(distinct(re.personid)) as total
from proceeding pr right join inproceeding inp on(inp.proceedingid=pr.proceedingid),
relationpersoninproceeding re
where (pr.title ilike '%data%' or inp.title ilike '%data%')  and re.inproceedingid=inp.inproceedingid;


create or replace view Q15(EditorName, Title, PublisherName, Year, Total) as
select p.name,pr.title,pu.name,pr.year,count(inp.inproceedingid) as t
from proceeding pr,inproceeding inp,publisher pu,person p
where pr.editorid=p.personid and pr.publisherid=pu.publisherid and inp.proceedingid=pr.proceedingid
group by p.name,pr.title,pu.name,pr.year
order by t desc,pr.year asc,pr.title asc;


create or replace view Q16(Name) as
select p.name
from person p
where p.personid in (select pid from ncoauthor) and p.personid not in (select pid2 from ncoauthor2) and p.personid not in (select pr.editorid from proceeding pr,person p where p.personid=pr.editorid);


create or replace view Q17(Name, Total) as
select p.name,count(distinct(pr.proceedingid)) as t
from proceeding pr,inproceeding inp,relationpersoninproceeding re,person p
where p.personid=re.personid and pr.proceedingid=inp.proceedingid and re.inproceedingid=inp.inproceedingid 
group by p.personid
order by t desc,p.name asc;


create or replace view npublications as 
select p.name as pname,count(distinct(inp.inproceedingid)) as t
from person p,relationpersoninproceeding re,inproceeding inp,proceeding pr
where inp.inproceedingid=re.inproceedingid and pr.proceedingid=inp.proceedingid and p.personid=re.personid
group by p.personid;


create or replace view Q18(MinPub, AvgPub, MaxPub) as
select min(t),avg(t)::int,max(t)
from npublications;


create or replace view npublications2 as 
select pr.proceedingid,count(distinct(inp.inproceedingid)) as t
from proceeding pr left join inproceeding inp on
 (pr.proceedingid=inp.proceedingid)
group by pr.proceedingid;


create or replace view Q19(MinPub, AvgPub, MaxPub) as
select min(t),avg(t)::int,max(t)
from npublications2;




create or replace function checkauthor() returns trigger as $$
begin
if new.personid in (select pr.editorid from proceeding pr right join inproceeding inp on (pr.proceedingid=inp.proceedingid) where inp.inproceedingid=new.inproceedingid) 
	then raise exception 'author can not be editor';
end if;
return new;
end;
$$ language plpgsql;

create trigger checkeditorauthor 
before insert or update
on RelationPersoninproceeding
for each row execute procedure checkauthor();




create or replace function checkeditor() returns trigger as $$
begin
if new.editorid in (select re.personid from proceeding pr left join inproceeding inp on (pr.proceedingid=inp.proceedingid) left join relationpersoninproceeding re on (inp.inproceedingid=re.inproceedingid)
where new.proceedingid=inp.proceedingid and inp.inproceedingid=re.inproceedingid
)
	then raise exception 'editor can not be author';
end if;
return new;
end;
$$ language plpgsql;

create trigger checkeditor
before insert or update
on Proceeding
for each row execute procedure checkeditor();


create or replace function checkproceedingeditor() returns trigger as $$
begin
if new.proceedingid in (select new.proceedingid 
from proceeding pr,relationpersoninproceeding re,inproceeding inp
where pr.proceedingid=inp.proceedingid and new.inproceedingid=re.inproceedingid
and re.personid=pr.editorid
)
	then raise exception 'editor can not be author';
end if;
return new;
end;
$$ language plpgsql;


create trigger checproceedingkeditor
before insert or update
on InProceeding
for each row execute procedure checkproceedingeditor();








