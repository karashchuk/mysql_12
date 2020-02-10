use mkd;
DROP TABLE IF EXISTS houses;
CREATE TABLE houses (
	id SERIAL PRIMARY KEY,
	address VARCHAR(255) not null COMMENT '�����',
	mo VARCHAR(64) null COMMENT '������������� �����������',
	company_id INT null COMMENT '����������� ����������� ����� ',
	gorod VARCHAR(127) null COMMENT '���������� �����',
	street VARCHAR(127) null COMMENT '�����',
	num VARCHAR(31) null COMMENT '����� ����',
	korp VARCHAR(7) null COMMENT '������',
	building VARCHAR(15) null COMMENT '��������',
	frac_num VARCHAR(7) null COMMENT '������� �����',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL DEFAULT true) COMMENT = '��������������� ����';

drop table if exists companies;
create table companies (
	id SERIAL PRIMARY KEY,
	name varchar(127) not null COMMENT '�������� �����������',
	full_name varchar(255) null COMMENT '������ �������� �����������',
	inn varchar(31) not null COMMENT '���',
	ogrn varchar(31) null COMMENT '����',
	type_org ENUM ('���������' , '���' , '���� �����������' , '���������������� ����������' , '����' , '���' , '���' , '���' , '��' ),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL default true
) COMMENT = '�����������';

drop table if exists comp_details;
create table comp_details (
	company_id int unsigned primary key,
	address varchar(255) null COMMENT '����� (�����������)',
	address_fact varchar(255) null COMMENT '����� (�����������)',	
	phone varchar(127) null COMMENT '�������', 
	site varchar(127) null COMMENT '����������� ����',
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	email varchar(127) null
) COMMENT = '�������� �����������';

DROP TABLE IF EXISTS entrances;
CREATE TABLE entrances (
	house_id INT not NULL,
	num int(2) not null default 1,
	entrance_floor int(3) null,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (house_id,num)
) COMMENT = '��������';


DROP TABLE IF exists quarters;
CREATE TABLE quarters (
	id SERIAL PRIMARY key,
	house_id INT not NULL,
	entrance_num int COMMENT '����� ��������',
	num varchar(31) not null COMMENT '����� ��������',
	area_total float(10,4) null COMMENT '����� �������',
	area_living float(10,4) null COMMENT '����� �������',
	rooms int(2) null COMMENT '���-�� ������',
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '��������';


DROP TABLE IF EXISTS elevators;
CREATE TABLE elevators (
	id SERIAL PRIMARY key,
	house_id INT not NULL,
	entrance_num int not null COMMENT '����� ��������',
	serialnum varchar(127) null COMMENT '��������� �����',
	carrying int(5) NULL Comment '����������������',
	elevator_type_id int(1) not null default 1 COMMENT '��� �����',
	start_year int(4) COMMENT '��� �������',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '�����';	

DROP TABLE IF EXISTS elevator_types;
CREATE TABLE elevator_types (
	id SERIAL PRIMARY key,
	name VARCHAR(20) not null) COMMENT = '���� ������';

insert into elevator_types (name) values 
('������������'),
('�����������������'),
('��������');

DROP TABLE IF EXISTS indicators;
CREATE TABLE indicators (
	id SERIAL PRIMARY key,
	name VARCHAR(127) not null) COMMENT = '�������� �����������';

DROP TABLE IF EXISTS hdata;
CREATE TABLE hdata (
	house_id INT not NULL,
	indicator_id int not null,
	`value` VARCHAR(255) null,
	PRIMARY KEY (house_id, indicator_id));

DROP TABLE IF EXISTS service_types;
CREATE TABLE service_types (
	id SERIAL PRIMARY key,
	name VARCHAR(63) not null) COMMENT = '�������� �����';

insert into service_types (name) values
('����������'),
('���������'),
('������� �������������'),
('�������� �������������'),
('�������������'),
('����������������'),
('�������������'),
('����');



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
) COMMENT = '�������� �� �������';


DROP TABLE IF EXISTS licenses;
CREATE TABLE licenses (
	num INT not null primary key,
	company_id int null,
	startday date not null,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	used BOOL default true
	) COMMENT = '�������� �� ���������� ���';

