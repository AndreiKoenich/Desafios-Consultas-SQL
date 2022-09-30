-- Autor: Andrei Pochmann Koenich

drop Table if exists  consulta;
drop Table if exists  paciente;
drop Table if exists  medico;

create table paciente
(pront	char(2) not null,
nomep 	varchar(20) not null,	
idadep 	smallint not null,
primary key(pront));

create table medico
(crm		char(2) not null,
nomem		varchar(20) not null,	
especialidade varchar(15) not null,
idadem 	smallint not null,	
primary key(crm));

create table consulta
(pront	char(5)	 not null,	
crm 	char(3)	 not null,	
data	char(5)	 not null,
primary key(pront,crm,data),
foreign key (pront) references paciente,
foreign key (crm) references medico);

insert into paciente values ('p1','joao',7);
insert into paciente values ('p2','pedro',10);
insert into paciente values ('p3','maria',14);
insert into paciente values ('p4','jose',30);
insert into paciente values ('p5','marta',60);
insert into paciente values ('p6','paulo',65);

insert into medico values ('m1','ricardo','oftalmologia', 29);
insert into medico values ('m2','romualdo','pediatria', 24);
insert into medico values ('m3','roberto','pediatria', 35);
insert into medico values ('m4','sheila','endocrinologia', 22);
insert into medico values ('m5', 'paula', 'oftalmologia', 60);
insert into medico values ('m6', 'tereza', 'geriatria', 34);
insert into medico values ('m7', 'carla', 'pediatria', 45);

insert into consulta values ('p1','m2','01/01');
insert into consulta values ('p1','m2','01/02');
insert into consulta values ('p1','m3','01/02');
insert into consulta values ('p2','m2','01/01');
insert into consulta values ('p2','m3','01/02');
insert into consulta values ('p2','m1','01/02');
insert into consulta values ('p5','m4','01/02');
insert into consulta values ('p3', 'm2', '01/01');
insert into consulta values ('p4', 'm4', '01/01');
insert into consulta values ('p4', 'm1', '01/01');
insert into consulta values ('p4', 'm3', '01/01');
insert into consulta values ('p1', 'm5', '01/01');
insert into consulta values ('p1', 'm5', '01/02');
insert into consulta values ('p6', 'm5', '01/02');
insert into consulta values ('p6', 'm6', '01/02');
insert into consulta values ('p6', 'm6', '03/03');
insert into consulta values ('p1', 'm7', '04/04');
insert into consulta values ('p2', 'm7', '05/05');

-- CONSULTAS ---------------------------------------------

-- 1 Compare

-- a) Some 1 à idade dos pacientes que têm mais de 60 anos

update paciente
set idadep = idadep+1
where idadep > 60

-- b) Some 1 à idade dos pacientes que foram atendidos na data 03/03

update paciente
set idadep = idadep+1
where pront in (select pront
                from consulta
                where data = '03/03')
				
-- 2 Compare
-- a) Remova as consultas que ocorreram na data 03/03

delete from consulta
where data = '03/03'

-- b) Remova as consultas que foram atendidas por médicos geriatras

delete from consulta
where crm in (select crm
              from medico
			  where especialidade = 'geriatria')

-- 3. O nome dos médicos que
-- a. atenderam crianças (criança <= 12 anos)

select distinct nomem as nome_medico
from medico
where crm in (select crm
              from paciente natural join consulta
			  where idadep <= 12)
order by nome_medico			  

-- b. não atenderam crianças

select distinct nomem as nome_medico
from medico
where crm not in (select crm
				  from paciente natural join consulta
			      where idadep <= 12)
order by nome_medico				  

-- c. só atenderam crianças

select distinct nomem as nome_medico
from medico natural join consulta
where crm not in (select crm
				  from paciente natural join consulta
			      where idadep > 12)
order by nome_medico

-- d. atenderam crianças e adultos (adulto >=21)

select distinct nomem as nome_medico
from medico
where crm in (select crm from paciente natural join consulta where idadep <= 12)
      and crm in (select crm from paciente natural join consulta where idadep >= 21)
order by nome_medico	  

-- 4. Compare
-- a. O nome dos pacientes que consultaram a endocrinologia

select distinct nomep as nome_paciente
from paciente natural join consulta natural join medico
where especialidade = 'endocrinologia'
order by nome_paciente	  

-- b. O nome dos pacientes e das especialidades consultadas, para todos pacientes que foram
-- atendidos pelo menos uma vez por um endocrinologista

select distinct nomep as nome_paciente, especialidade
from paciente natural join consulta natural join medico
where pront in (select pront 
                from medico natural join consulta 
				where especialidade = 'endocrinologia')
order by nome_paciente, especialidade

-- 5. O nome dos pacientes que foram atendidos por
-- a) no mínimo 3 médicos distintos

select distinct nomep as nome_paciente
from paciente natural join consulta
group by pront, nomep
having count(distinct crm) >= 3
order by nome_paciente

-- b) por médicos que atenderam pelo menos 3 pessoas distintas

select distinct nomep as nome_paciente
from paciente natural join consulta
where crm in (select crm 
              from consulta 
			  group by crm 
			  having count(distinct pront) >= 3)
order by nome_paciente

-- 6. O nome e idade dos médicos que são mais velhos que todos pacientes que atenderam

select distinct nomem as nome_medico, idadem as idade_medico
from medico
where idadem > (select max(idadep) 
                from paciente natural join consulta 
				where crm = medico.crm)
order by nome_medico, idade_medico

-- 7.
-- a) Para cada especialidade, a idade do paciente mais velho

select especialidade, max(idadep) as maior_idade
from medico natural join consulta natural join paciente
group by especialidade
order by especialidade, maior_idade

-- b) Para cada especialidade, a média da idade dos médicos

select especialidade, avg(idadem) as media_idade
from medico natural join consulta
group by especialidade
order by especialidade, media_idade

-- c) O nome das especialidades cuja idade média dos médicos é menor que a idade do paciente
-- mais velho que atenderam

select especialidade
from medico MED
group by especialidade
having avg(idadem) < (select max(idadep)
					  from medico natural join consulta natural join paciente
					  where especialidade = MED.especialidade)
order by especialidade

-- 8. Compare
-- a. O nome dos médicos pediatras e o número de consultas que atendeu

select distinct nomem as nome_medico, count(distinct pront) as total_consultas
from medico natural join consulta
where especialidade = 'pediatria'
group by crm, nomem
order by nome_medico, total_consultas

-- b. O nome dos médicos e número total de consultas que atenderam, para todo o médico
-- pediatra que atendeu pelo menos um paciente que consultou também outra especialidade

select distinct nomem as nome_medico, count(distinct pront) as total_consultas
from medico natural join consulta
where especialidade = 'pediatria' and pront in (select pront 
                                                from consulta natural join medico 
												where especialidade != 'pediatria')
group by crm, nomem
order by nome_medico, total_consultas

-- 9. o nome dos médicos que atenderam pacientes mais velhos que a idade média dos pacientes
-- que consultaram pediatras

select distinct nomem as nome_medico
from medico natural join consulta natural join paciente
where idadep > (select avg(idadep) 
                from medico natural join consulta natural join paciente 
				where especialidade = 'pediatria')
order by nome_medico				