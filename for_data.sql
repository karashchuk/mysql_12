INSERT INTO mkd.houses (houses.id, houses.address, houses.mo, houses.company_id, houses.gorod, houses.street, houses.num, houses.korp, houses.building, houses.frac_num)
SELECT h.id, h.address, h.mr, o.id, h.gorod, h.street, h.nomer, h.korp, h.stroen, h.nomer_drob  
FROM gzhi.hobject h 
LEFT JOIN gzhi.org o ON o.inn = h.inn
WHERE mr IN ('Бронницы г о', 'Дзержинский г о', 'Дубна г о', 'Котельники г о', 'Красноармейск г о', 'Рошаль г о', 'Электрогорск г о');

INSERT INTO mkd.companies (mkd.companies.id, mkd.companies.name, mkd.companies.full_name, mkd.companies.inn, mkd.companies.ogrn, mkd.companies.type_org) 
SELECT o.id, o.name, o.fulname, o.inn, o.ogrn, o.`type`  
FROM gzhi.org o;

insert into mkd.comp_details 
(mkd.comp_details.company_id, mkd.comp_details.address,mkd.comp_details.address_fact, 
mkd.comp_details.phone, mkd.comp_details.site, mkd.comp_details.email )
SELECT o.id, o.address, o.fact_address, 
o.phone, o.site, o.email  
FROM gzhi.org o ;

insert into licenses (licenses.num, licenses.company_id, licenses.startday )
SELECT ol.nom_lic, o.id, ol.date  
FROM gzhi.orglic ol 
LEFT JOIN gzhi.org o ON o.inn = ol.inn; 

insert into mkd.services (mkd.services.house_id , mkd.services.service_type_id , 
mkd.services.company_id , mkd.services.startday , 
mkd.services.contract_number , mkd.services.contract_date )
SELECT 
	hol.id_house, 
	case usluga
		when  'Управление' then 1
		when  'Отопление' then 2
		when  'Горячее водоснабжение' then 3
		when  'Холодное водоснабжение' then 4
		when  'Водоотведение' then 5
		when  'Электроснабжение' then 6
		when  'Газоснабжение' then 7
		when  'Лифт'then 8
		ELSE 9
	END service_type_id,
	o.id,
	if(year(hol.start_day) > '2000',hol.start_day,null),
	hol.N_dogovor,
	if(year(hol.Data_dogovor) > '2000',hol.Data_dogovor,NULL)
FROM gzhi.house_org_list hol
LEFT JOIN gzhi.hobject h ON h.id = hol.id_house
LEFT JOIN gzhi.org o ON o.inn = hol.INN
WHERE  h.mr IN ('Бронницы г о', 'Дзержинский г о', 'Дубна г о', 'Котельники г о', 'Красноармейск г о', 'Рошаль г о', 'Электрогорск г о'); 

insert into mkd.elevators (mkd.elevators.id , mkd.elevators.house_id , 
mkd.elevators.entrance_num , mkd.elevators.serialnum , mkd.elevators.carrying , 
mkd.elevators.elevator_type_id , mkd.elevators.start_year )
SELECT  hl.id, hl.id_house, 
if (hl.podjezd BETWEEN 1 AND 20, hl.podjezd, 1),
hl.z_nomer, 
if(hl.gruz BETWEEN 1 AND 10000, hl.gruz, NULL), 
if (hl.`type` BETWEEN 1 AND 4, hl.`type`, 1),
if (hl.year BETWEEN 1970 AND 2021, hl.year, NULL)
FROM gzhi.hlift hl
LEFT JOIN gzhi.hobject h ON h.id = hl.id_house
WHERE h.mr IN ('Бронницы г о', 'Дзержинский г о', 'Дубна г о', 'Котельники г о', 'Красноармейск г о', 'Рошаль г о', 'Электрогорск г о');

insert into mkd.entrances (mkd.entrances.house_id, mkd.entrances.num , mkd.entrances.entrance_floor )
SELECT 
	e.id_house,
	if(e.nomer BETWEEN 1 AND 20, e.nomer, 1) as num,
	if(e.etazh BETWEEN 1 AND 50, e.etazh, 1) as efloor
 FROM gzhi.entrance e
LEFT JOIN gzhi.hobject h ON h.id = e.id_house
WHERE  h.mr IN ('Бронницы г о', 'Дзержинский г о', 'Дубна г о', 'Котельники г о', 'Красноармейск г о', 'Рошаль г о', 'Электрогорск г о'); 

insert into mkd.quarters (mkd.quarters.id , mkd.quarters.house_id , 
mkd.quarters.entrance_num , mkd.quarters.num , mkd.quarters.area_total , 
mkd.quarters.area_living , mkd.quarters.rooms )
SELECT 
	hf.id,
	hf.id_house,
	hf.n_pod,
	hf.nomer,
	hf.g_s,
	hf.z_s,
	hf.q_room
FROM gzhi.hflat hf
LEFT JOIN gzhi.hobject h ON h.id = hf.id_house
WHERE  h.mr IN ('Бронницы г о', 'Дзержинский г о', 'Дубна г о', 'Котельники г о', 'Красноармейск г о', 'Рошаль г о', 'Электрогорск г о') 
AND hf.`type` = 1;

insert into mkd.indicators 
SELECT distinct(f1.id), f1.name FROM gzhi.forma1 f1 WHERE id IN (SELECT i.id FROM gzhi.indikator i);

insert into mkd.hdata 
SELECT h.id, hd.id_forma1, hd.`value` 
FROM mkd.houses h 
LEFT JOIN gzhi.hdata hd ON hd.id_house = h.id
WHERE hd.id_forma1 IN (SELECT id FROM gzhi.indikator) and hd.id_forma1 <> 55245;

insert into mkd.hdata 
SELECT Distinct(h.id), hd.id_forma1, hd.`value` 
FROM mkd.houses h 
LEFT JOIN gzhi.hdata hd ON hd.id_house = h.id
WHERE hd.id_forma1 = 55245;