use mkd;
-- ���������� �������������, ��� ������� �������� ����� ������� �������� � �� ��� ������������ ������ ����������� ����������� ����� (���)
drop view if exists houses_oud ;
create view houses_oud as
	select 
		h.id as '��� ����', 
		h.mo as '������������� �����������', 
		h.address as '�����',
		c.id as '��� ���',
		c.name as '�������� ���',
		c.inn as '��� ���',
		c.ogrn as '���� ���',
		c.type_org as '��� ���',
		h.used 
	from houses h
	left join companies c on h.company_id  = c.id 
	where h.used = 1;
-- ��� ���������� ������� ������������� ������� ������� � ������� ��, � ������� ����� �������� ����� ����� ������� ��������� � ���������� ������ �����������
alter table companies add column (
	qty_mkd int unsigned not null default 0);

-- ��������� ������� �������� ������ �� ���������� ����� � ���������� ���
DELIMITER -
DROP PROCEDURE IF EXISTS update_count_houses -
CREATE PROCEDURE update_count_houses ()
BEGIN
  DECLARE cid INT;
  DECLARE is_end INT DEFAULT 0;
  DECLARE qty INT; 
  DECLARE curcat CURSOR FOR SELECT id, qty_mkd FROM companies;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;
  OPEN curcat;
  cycle : LOOP
	  FETCH curcat INTO cid, qty;
		  IF is_end THEN LEAVE cycle;
		  END IF;
	  set qty = (select count(h.id) from houses h where h.company_id = cid );
	  update companies c set c.qty_mkd = qty where c.id = cid;
  END LOOP cycle;
  CLOSE curcat;
end -
DELIMITER ;

call update_count_houses();
-- ������������� � ������� ��������� �������� ��� ������ �� �� � ����� ���������� ����� � ���������� (��� ���)
drop view if exists oud ;
create view oud as
select 
		c.id as '��� ��',
		c.type_org as '��� ��', 
		c.name as '�������� ��',
		c.inn as '��� ��',
		c.ogrn as '���� ��',
		c.qty_mkd as '���������� ����� � ����������',
		cd.address as '����� ��',
		cd.site,
		cd.phone,
		cd.email 
from companies c 
left join comp_details cd on cd.company_id = c.id 
where c.type_org  in ('���' , '���� �����������' ,'���' , '���' , '��' ) and c.used = 1;

-- ������ ������� ������� ����� ��� �� ��������, �� ���� �� ��� ��, ������� �� ������ ������ �� ������������� �� ����� ������ �� ���, � ����� �� ��������� � ������� ��������
update companies c
set c.used = 0 
where c.id not in (select distinct(company_id) from (
(select distinct(company_id) 
	from services where company_id is not null)
union 
(select company_id from licenses l where l.used = 1)
) as ii);

-- ���������, ������� ����������� ����� ���������� �� ���� ��, � ����������� �� ���� ������������� �� ��� ������ � ���� �� � ������� ��������
DELIMITER -
CREATE procedure used_companies ()
BEGIN
	update companies set used = 0;
	update companies c
		set c.used = 1 
		where c.id in 
			(select distinct(company_id) 
				from (
					(select distinct(company_id) 
						from services where company_id is not null)
					union 
					(select company_id from licenses l where l.used = 1)
					) as cid);

END -
DELIMITER ;

select * from companies c where used = 1;
call used_companies() ;

-- �������� ������� ������������� ����������� ��� � ������� 
DELIMITER -
drop trigger if exists servisec_oud_insert -
create trigger servisec_oud_insert after insert on services
for each row 
BEGIN
 	update houses h set h.company_id = new.company_id where h.id = new.house_id and new.service_type_id = 1;
END - 
drop trigger if exists servisec_oud_update -
create trigger servisec_oud_update after update on services
for each row 
BEGIN
 	update houses h set h.company_id = new.company_id where h.id = new.house_id and new.service_type_id = 1;
END - 
DELIMITER ;


update services s set s.company_id = 9469 where s.house_id = 114691;

-- ������ ������� ���������� �� ���� �� �� ������� ����� ������������� ������ ��� ��� � ��� ����������������� ����������� (���)
select 
	c.name, 
	c.type_org, 
	count(distinct(s1.house_id)) as '���', 
	count(distinct(s2.house_id)) as '���',
	count(distinct(s1.house_id))  + count(distinct(s2.house_id)) as total
from companies c  
left join services s1 on c.id = s1.company_id and s1.service_type_id = 1
left join services s2 on c.id = s2.company_id and s2.service_type_id > 1
group by c.id 
having total > 0;

-- ������ ������� ������� �������� �������������� ����� �� ������� ������
select 
	h.id, 
	h.mo , 
	h.address ,
	hd1.value as '����� ������� ����',
	hd2.value as '����� ������� ����� ���������',
	hd3.value as '��� ���������',
	hd4.value as '���������� ������'
from houses h
left join hdata hd1 on hd1.house_id = h.id and hd1.indicator_id = 50038
left join hdata hd2 on hd2.house_id = h.id and hd2.indicator_id = 64924
left join hdata hd3 on hd3.house_id = h.id and hd3.indicator_id = 56527
left join hdata hd4 on hd4.house_id = h.id and hd4.indicator_id = 65683
;

-- ������ ������� ���������� ������ �� ����� �������������� ���� (����� ������� ����� ���������) � ������ �������� ������� �� ����������� �������  � ������� ����� � ��� ��� �������� ����� ��� �� 1 ��.�.
select 
	h.mo ,
	h.address, 
	count(q.num ) as '���������� ������� � ����',
	sum(q.area_total ) as '����� �������� �������', 
	hd.value as '����� ������� ����� ���������', 
	if(ABS(sum(q.area_total) - hd.value) < 1, 'Ok', 'No Ok') as 'Is Ok'
from houses h
left join quarters q on q.house_id = h.id 
left join hdata hd on hd.house_id = h.id and hd.indicator_id = 64924
group by q.house_id 
;


