use mkd;
alter table companies modify column id int(10) unsigned;
alter table mkd.comp_details 
	add constraint comp_details_company_id_fk
		foreign key (company_id) references mkd.companies(id)
			on delete cascade;
			
alter table services modify column company_id int(10) unsigned;
alter table licenses modify column company_id int(10) unsigned;
alter table houses modify column company_id int(10) unsigned;
alter table services 
	add constraint services_company_id_fk
		foreign key (company_id) references mkd.companies(id)
			on delete set NULL;
		
alter table licenses 
	add constraint licenses_company_id_fk
		foreign key (company_id) references mkd.companies(id)
			on delete set NULL;

alter table houses 
	add constraint houses_company_id_fk
		foreign key (company_id) references mkd.companies(id)
			on delete set NULL;

alter table service_types modify column id int(11);
alter table services 
	add constraint services_service_type_id_fk
		foreign key (service_type_id) references mkd.service_types(id);
	
alter table elevator_types modify column id int(1);

alter table indicators modify column id int(11);
alter table houses modify column id int(11);
	
alter table elevators 
	add constraint elevators_elevator_type_id_fk
		foreign key (elevator_type_id) references mkd.elevator_types(id),
	add constraint elevators_house_id_fk
		foreign key (house_id) references mkd.houses(id);
alter table services 
	add constraint services_house_id_fk
		foreign key (house_id) references mkd.houses(id);	

alter table hdata 
	add constraint hdata_indicator_id_fk
		foreign key (indicator_id) references mkd.indicators(id),
	add constraint hdata_house_id_fk
		foreign key (house_id) references mkd.houses(id);
alter table entrances 
	add constraint entrances_house_id_fk
		foreign key (house_id) references mkd.houses(id);
	
alter table quarters 
	add constraint quarters_house_id_fk
		foreign key (house_id) references mkd.houses(id);
		
	
create index company_id_idx on services(company_id);
create index house_id_idx on quarters(house_id);
create index house_id_idx on elevators(house_id);
create index company_id_idx on licenses(company_id);
create index name_idx on companies(name);
create index inn_idx on companies(inn);
create index name_idx on companies(name);
create index company_id_idx on houses(company_id);
create index address_idx on houses(address);