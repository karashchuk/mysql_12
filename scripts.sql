use mkd;
-- реализация представления, где показан перечень домов которые активные и по ним показываются данные организации управляющей домом (ОУД)
drop view if exists houses_oud ;
create view houses_oud as
	select 
		h.id as 'код дома', 
		h.mo as 'Муниципальное образование', 
		h.address as 'Адрес',
		c.id as 'код ОУД',
		c.name as 'Название ОУД',
		c.inn as 'ИНН ОУД',
		c.ogrn as 'ОГРН ОУД',
		c.type_org as 'Тип ОУД',
		h.used 
	from houses h
	left join companies c on h.company_id  = c.id 
	where h.used = 1;
-- для реализации второго представления добавим колонку в таблицу ЮЛ, в которой будем заносить число домов которые находятся в управлении данной организации
alter table companies add column (
	qty_mkd int unsigned not null default 0);

-- процедура которая заполнит данные по количеству домов в управлении ОУД
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
-- представление в которой выводятся полность все данные по ЮЛ и также количество домов в управлении (для ОУД)
drop view if exists oud ;
create view oud as
select 
		c.id as 'код ЮЛ',
		c.type_org as 'Тип ЮЛ', 
		c.name as 'Название ЮЛ',
		c.inn as 'ИНН ЮЛ',
		c.ogrn as 'ОГРН ЮЛ',
		c.qty_mkd as 'Количество домов в управлении',
		cd.address as 'Адрес ЮЛ',
		cd.site,
		cd.phone,
		cd.email 
from companies c 
left join comp_details cd on cd.company_id = c.id 
where c.type_org  in ('ЖСК' , 'Иные кооперативы' ,'ТСЖ' , 'ТСН' , 'УК' ) and c.used = 1;

-- запрос который удаляет метку что ЮЛ активная, то есть по тем ЮЛ, которые на данный момент не предоставляют ни одной услуги по МКД, а также не находятся в реестре лицензий
update companies c
set c.used = 0 
where c.id not in (select distinct(company_id) from (
(select distinct(company_id) 
	from services where company_id is not null)
union 
(select company_id from licenses l where l.used = 1)
) as ii);

-- процедура, которая проставляет метки активности по всем ЮЛ, в зависимости от того предоставляет ли она услугу и есть ли в реестре лицензий
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

-- триггеры которые автоматически проставляют ОУД в таблице 
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

-- запрос который показывает по всем ЮЛ по скольки домам предоставляют услуги как ОУД и как Ресурсоснабжающая организация (РСО)
select 
	c.name, 
	c.type_org, 
	count(distinct(s1.house_id)) as 'ОУД', 
	count(distinct(s2.house_id)) as 'РСО',
	count(distinct(s1.house_id))  + count(distinct(s2.house_id)) as total
from companies c  
left join services s1 on c.id = s1.company_id and s1.service_type_id = 1
left join services s2 on c.id = s2.company_id and s2.service_type_id > 1
group by c.id 
having total > 0;

-- запрос который выводит некторые характеристики домов по каждому адресу
select 
	h.id, 
	h.mo , 
	h.address ,
	hd1.value as 'Общая площадь дома',
	hd2.value as 'Общая площадь жилых помещений',
	hd3.value as 'Год постройки',
	hd4.value as 'Количество этажей'
from houses h
left join hdata hd1 on hd1.house_id = h.id and hd1.indicator_id = 50038
left join hdata hd2 on hd2.house_id = h.id and hd2.indicator_id = 64924
left join hdata hd3 on hd3.house_id = h.id and hd3.indicator_id = 56527
left join hdata hd4 on hd4.house_id = h.id and hd4.indicator_id = 65683
;

-- запрос который сравнивает данные по общей характеристике дома (Общая площадь жилых помещений) с суммой площадей квартир из подчиненной таблицы  и выводит метку о том где различие более чем на 1 кв.м.
select 
	h.mo ,
	h.address, 
	count(q.num ) as 'Количество квартир в доме',
	sum(q.area_total ) as 'Сумма площадей квартир', 
	hd.value as 'Общая площадь жилых помещений', 
	if(ABS(sum(q.area_total) - hd.value) < 1, 'Ok', 'No Ok') as 'Is Ok'
from houses h
left join quarters q on q.house_id = h.id 
left join hdata hd on hd.house_id = h.id and hd.indicator_id = 64924
group by q.house_id 
;


