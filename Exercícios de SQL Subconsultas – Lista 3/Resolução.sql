-- Autor: Andrei Pochmann Koenich

drop table if exists consultas;
drop table if exists medicos ;
drop table if exists especialidades;
drop table if exists pacientes;

create table especialidades
(code char(3)  not null primary key,
nomee varchar(100) not null unique);

insert into especialidades(code, nomee) values ('e1','cardio');
insert into especialidades(code, nomee) values ('e2','oftalmo');
insert into especialidades(code, nomee) values ('e3','neuro');
insert into especialidades(code, nomee) values ('e4','pediatra');
insert into especialidades(code, nomee) values ('e5','obstetra');
insert into especialidades(code, nomee) values ('e6','hebiatra');

create table medicos
(codm char(3) not null primary key,
nomem varchar(100) not null unique,
salario int not null,
UF char(2) not null,
code char(3),
foreign key (code) references especialidades
);

insert into medicos values ('m1', 'maria', 25000, 'sp', 'e1');
insert into medicos values ('m2', 'pedro', 4000, 'sp', 'e1');
insert into medicos values ('m3', 'isaura', 5000, 'rs', 'e1');
insert into medicos values ('m4', 'paula', 3000, 'rs', 'e2');
insert into medicos values ('m5', 'tereza', 14000, 'rs', 'e2');
insert into medicos values ('m6', 'jose', 14000, 'rs', 'e1');
insert into medicos values ('m7', 'mauro', 14000, 'rs', 'e4');
insert into medicos values ('m10', 'nome1', 14000, 'rs', 'e5');
insert into medicos values ('m11', 'nome2', 14000, 'rs', 'e5');

create table pacientes
(codp char(3) not null primary key,
nomep varchar(100) not null unique,
UF char(2) not null
);

insert into pacientes values ('p1', 'paulo', 'sp');
insert into pacientes values ('p2', 'roberto', 'rs');
insert into pacientes values ('p3', 'mariana', 'sp');
insert into pacientes values ('p4', 'xico', 'sp');

create table consultas
(codp char(3) not null,
codm char(3) not null,
data date not null,
 foreign key(codp) references pacientes,
 foreign key(codm) references medicos,
primary key (codp, codm, data));

insert into consultas values ('p1', 'm1', '2021-01-02');
insert into consultas values ('p1', 'm1', '2021-02-02');
insert into consultas values ('p1', 'm3', '2021-03-02');
insert into consultas values ('p2', 'm1', '2021-01-02');
insert into consultas values ('p2', 'm4', '2021-02-02');
insert into consultas values ('p3', 'm4', '2021-02-03');
insert into consultas values ('p3', 'm4', '2021-02-02');
insert into consultas values ('p4', 'm4', '2021-02-02');

-- CONSULTAS ---------------------------------------------

-- 1) O nome das especialidades para as quais n??o existem m??dicos cadastrados;

select nomee as nome_especialidade
from especialidades
where code not in (select code 
		   from especialidades natural join medicos)
order by nome_especialidade

-- 2) remover todos os m??dicos obstetras;

delete from medicos
where codm in (select codm 
	       from medicos natural join especialidades 
	       where nomee = 'obstetra')

-- 3) alterar o c??digo de todos os m??dicos pediatras para e6

update medicos
set code = 'e6'
where crm in (select codm 
	      from medicos natural join especialidades 
	      where nomee = 'pediatra')

-- 4) o nome de todos os pacientes que consultaram o m??dico que recebe o maior salario
-- dentre os m??dicos

select distinct nomep as nome_paciente
from pacientes natural join consultas natural join medicos
where salario = (select max(salario) 
	         from medicos)
order by nome_paciente

-- 5) o nome e a especialidade dos m??dicos que ganham acima da m??dia salarial dos m??dicos

select distinct nomem as nome_medico, nomee as nome_especialidade
from medicos natural join especialidades
group by codm, nomem, nomee
having salario > (select avg(salario) 
		  from medicos)
order by nome_medico, nome_especialidade

-- 6) O nome das especialidades cuja m??dia salarial dos m??dicos daquela especialidade ??
-- superior ?? m??dia salarial dos m??dicos em geral

select distinct nomee as nome_especialidade
from especialidades natural join medicos
group by code, nomee
having avg(salario) > (select avg(salario) 
		       from medicos)
order by nome_especialidade

-- 7) O nome dos m??dicos que paulo consultou e que roberto tab??m consultou
 
select distinct nomem as nome_medico
from medicos natural join consultas natural join pacientes
where nomep = 'paulo' and codm in (select codm 
				   from pacientes natural join consultas 
				   where nomep = 'roberto')
order by nome_medico
