use mkd;
DROP TABLE IF EXISTS houses;
CREATE TABLE houses (
	id SERIAL PRIMARY KEY,
	address VARCHAR(255) not null COMMENT 'Адрес',
	mo VARCHAR(64) null COMMENT 'Муниципальное образование',
	company_id INT null COMMENT 'Организация управляющая домом ',
	gorod VARCHAR(127) null COMMENT 'населенный пункт',
	street VARCHAR(127) null COMMENT 'улица',
	num VARCHAR(31) null COMMENT 'номер дома',
	korp VARCHAR(7) null COMMENT 'корпус',
	building VARCHAR(15) null COMMENT 'строение',
	frac_num VARCHAR(7) null COMMENT 'дробный номер',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL DEFAULT true) COMMENT = 'Многоквартирные дома';

drop table if exists companies;
create table companies (
	id SERIAL PRIMARY KEY,
	name varchar(127) not null COMMENT 'Название организации',
	full_name varchar(255) null COMMENT 'Полное название организации',
	inn varchar(31) not null COMMENT 'ИНН',
	ogrn varchar(31) null COMMENT 'ОГРН',
	type_org ENUM ('Ведомства' , 'ЖСК' , 'Иные кооперативы' , 'Непосредственное управление' , 'ОМСУ' , 'РСО' , 'ТСЖ' , 'ТСН' , 'УК' ),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL default true
) COMMENT = 'Организации';

drop table if exists comp_details;
create table comp_details (
	company_id int unsigned primary key,
	address varchar(255) null COMMENT 'Адрес (юридический)',
	address_fact varchar(255) null COMMENT 'Адрес (фактический)',	
	phone varchar(127) null COMMENT 'Телефон', 
	site varchar(127) null COMMENT 'Официальный сайт',
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	email varchar(127) null
) COMMENT = 'Карточка организации';

DROP TABLE IF EXISTS entrances;
CREATE TABLE entrances (
	house_id INT not NULL,
	num int(2) not null default 1,
	entrance_floor int(3) null,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (house_id,num)
) COMMENT = 'Подъезды';


DROP TABLE IF exists quarters;
CREATE TABLE quarters (
	id SERIAL PRIMARY key,
	house_id INT not NULL,
	entrance_num int COMMENT 'Номер подъезда',
	num varchar(31) not null COMMENT 'Номер квартиры',
	area_total float(10,4) null COMMENT 'Общая площадь',
	area_living float(10,4) null COMMENT 'Жилая площадь',
	rooms int(2) null COMMENT 'Кол-во комнат',
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Квартиры';


DROP TABLE IF EXISTS elevators;
CREATE TABLE elevators (
	id SERIAL PRIMARY key,
	house_id INT not NULL,
	entrance_num int not null COMMENT 'Номер подъезда',
	serialnum varchar(127) null COMMENT 'Заводской номер',
	carrying int(5) NULL Comment 'Грузоподъемность',
	elevator_type_id int(1) not null default 1 COMMENT 'Тип лифта',
	start_year int(4) COMMENT 'Год запуска',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Лифты';	

DROP TABLE IF EXISTS elevator_types;
CREATE TABLE elevator_types (
	id SERIAL PRIMARY key,
	name VARCHAR(20) not null) COMMENT = 'Типы лифтов';

insert into elevator_types (name) values 
('Пассажирский'),
('Грузопассажирский'),
('Грузовой');

DROP TABLE IF EXISTS indicators;
CREATE TABLE indicators (
	id SERIAL PRIMARY key,
	name VARCHAR(127) not null) COMMENT = 'Название показателей';

DROP TABLE IF EXISTS hdata;
CREATE TABLE hdata (
	house_id INT not NULL,
	indicator_id int not null,
	`value` VARCHAR(255) null,
	PRIMARY KEY (house_id, indicator_id));

DROP TABLE IF EXISTS service_types;
CREATE TABLE service_types (
	id SERIAL PRIMARY key,
	name VARCHAR(63) not null) COMMENT = 'Название услуг';

insert into service_types (name) values
('Управление'),
('Отопление'),
('Горячее водоснабжение'),
('Холодное водоснабжение'),
('Водоотведение'),
('Электроснабжение'),
('Газоснабжение'),
('Лифт');



DROP TABLE IF EXISTS services;
CREATE TABLE services (
	house_id INT not NULL,
	service_type_id int not null,
	company_id int null,
	startday date null default null,
	contract_number varchar(127) null,
	contract_date date null default null,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	primary key (house_id, service_type_id)
) COMMENT = 'договоры по услугам';


DROP TABLE IF EXISTS licenses;
CREATE TABLE licenses (
	num INT not null primary key,
	company_id int null,
	startday date not null,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL default true
	) COMMENT = 'Лицензии на управление МКД';

