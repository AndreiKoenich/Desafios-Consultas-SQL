-- Autor: Andrei Pochmann Koenich

drop table if exists escalacao;
drop table if exists voo;
drop table if exists aeroporto;
drop table if exists piloto;

create table aeroporto
(CODA	char(3) not null,
NOMEA 	varchar(20) not null,	
CIDADE 	varchar(20) not null,	
PAIS 	char(2) not null,
primary key(CODA));

create table voo
(CODV	char(5)	 not null,	
ORIGEM 	char(3)	 not null,	
DEST	char(3)	 not null,
HORA	numeric not null,
primary key(codv),
foreign key (origem) references aeroporto,
foreign key (dest) references aeroporto);

create table piloto
(CODP		char(3) not null,
NOMEP		varchar(10) not null,	
SALARIO		numeric not null,	
GRATIFICACOES	numeric not null,		
TEMPO		numeric not null,	
PAIS		char(2) not null,
COMPANHIA	varchar(10) not null,
primary key(codp));

create table escalacao
(CODV	char(5) not null,	
DATA	char(5)	not null,
CODP	char(3),
AVIAO	varchar(20) not null,
primary key(codv, data),
foreign key (codp) references piloto,
foreign key (codv) references voo);

insert into aeroporto values ('poa','salgado filho','porto alegre','BR');
insert into aeroporto values ('gru','guarulhos','sao paulo','BR');
insert into aeroporto values ('rom','int de rome','roma','IT');

insert into voo values ('GL230','gru','poa','7');
insert into voo values ('GL330','gru','rom','11');
insert into voo values ('GL430','poa','gru','14');

insert into piloto values ('p11','Paulo', 3000, 200, 5,'BR','Gol');
insert into piloto values ('p12','Pedro', 2000, 100, 5,'BR','Gol');
insert into piloto values ('p13','Carlos', 3000, 200, 3,'BR','Gol');
insert into piloto values ('p14','Antonio', 1500, 300, 7,'BR','Tam');
insert into piloto values ('p15','Maria', 5000, 200, 10,'BR','Tam');

insert into escalacao values('GL230','01/01','p11','737'); 
insert into escalacao values('GL330','01/02','p11','A320');
insert into escalacao values('GL230','01/03','p12','737'); 
insert into escalacao values('GL430','01/04','p12','BANDEIRANTE');
insert into escalacao values('GL330','01/05','p13','A320'); 
insert into escalacao values('GL430','01/06','p13','BANDEIRANTE');
insert into escalacao values('GL230','01/07','p13','737');
insert into escalacao values('GL430','01/08','p14','BANDEIRANTE'); 
insert into escalacao values('GL230','01/09','p15','737'); 
insert into escalacao values('GL330','01/10','p15','A320');

-- CONSULTAS ---------------------------------------------

--1) COMPARE
-- a) Os aviões usados por Paulo (pelo menos uma vez);

select distinct aviao
from piloto natural join escalacao
where nomep = 'Paulo'
order by aviao

-- b) O nome de pilotos com a aeronave usada, para qualquer aeronave usada por Paulo.

select distinct nomep as nome_piloto
from piloto natural join escalacao
where nomep != 'Paulo' and aviao in (select aviao
									 from piloto natural join escalacao
									 where nomep = 'Paulo')
order by nome_piloto			

-- c) O nome de pilotos com a aeronave usada, para qualquer aeronave que Paulo não tenha usado.

select distinct nomep as nome_piloto
from piloto natural join escalacao
where aviao in (select aviao
				from escalacao
				where aviao not in (select aviao
									from piloto natural join escalacao
									where nomep = 'Paulo'))
order by nome_piloto	

-- d) O nome dos pilotos que jamais usaram aeronaves usadas por Paulo.

select distinct nomep as nome_piloto
from piloto
where nomep not in (select nomep
				    from piloto natural join escalacao
					where aviao in (select aviao
									from piloto natural join escalacao
									where nomep = 'Paulo'))
order by nome_piloto	

-- e) O nome dos pilotos que usaram todas aeronaves usadas por Paulo (e possivelmente outras);

select distinct nomep as nome_piloto
from piloto PILOT
where nomep != 'Paulo' and not exists (select * 
									   from piloto natural join escalacao
									   where nomep = 'Paulo' and aviao not in (select aviao
																			   from piloto natural join escalacao
																			   where nomep = PILOT.nomep))
order by nome_piloto	

-- f) O nome dos pilotos que usaram exatamente as mesmas aeronaves que Paulo usou;

select distinct nomep as nome_piloto
from piloto PILOT natural join escalacao
where nomep != 'Paulo' and not exists (select * 
									   from piloto natural join escalacao
									   where nomep = 'Paulo' and aviao not in (select aviao
																			   from piloto natural join escalacao
																			   where nomep = PILOT.nomep))
group by codp, nomep
having count(distinct aviao) = (select count(distinct aviao)
								from piloto natural join escalacao
								where nomep = 'Paulo')
order by nome_piloto

-- 2) COMPARE
-- a) O código dos voos para os quais Paulo foi escalado;

select distinct codv as codigo_voo
from piloto natural join escalacao
where nomep = 'Paulo'
order by codigo_voo

-- b) O código dos voos com os respectivos pilotos escalados, para voos nos quais Paulo também foi escalado.

select distinct codv as codigo_voo, nomep as nome_piloto
from piloto natural join escalacao
where codv in (select codv
			   from piloto natural join escalacao
			   where nomep = 'Paulo')
order by codigo_voo, nome_piloto

-- c) O código dos voos com os respectivos pilotos escalados, para voos que Paulo não fez.

select distinct codv as codigo_voo, nomep as nome_piloto
from piloto natural join escalacao
where codv not in (select codv
			       from piloto natural join escalacao
			       where nomep = 'Paulo')
order by codigo_voo, nome_piloto

-- d) O nome dos pilotos que fizeram todos os voos para os quais Paulo foi escalado (e possivelmente outros)

select distinct nomep as nome_piloto
from piloto PILOT
where nomep != 'Paulo' and not exists (select *
									   from piloto natural join escalacao
									   where nomep = 'Paulo' and codv not in (select codv
																			  from piloto natural join escalacao
																			  where codp = PILOT.codp))
									   
order by nome_piloto

-- e) O nome dos pilotos que não fizeram nenhum dos voos para os quais Paulo foi escalado;

select distinct nomep as nome_piloto
from piloto PILOT natural join escalacao
where nomep != 'Paulo' and not exists (select *
									   from piloto natural join escalacao
									   where nomep = 'Paulo' and codv in (select codv
																		  from piloto natural join escalacao
																		  where codp = PILOT.codp))
order by nome_piloto

-- f) O nome dos pilotos que fizeram exatamente os mesmos voos para os quais Paulo foi escalado;

select distinct nomep as nome_piloto
from piloto PILOT natural join escalacao
where nomep != 'Paulo' and not exists (select *
									   from piloto natural join escalacao
									   where nomep = 'Paulo' and codv not in (select codv
																			  from piloto natural join escalacao
																			  where codp = PILOT.codp))
group by codp, nomep
having count(distinct codv) = (select count(distinct codv)
							  from piloto natural join escalacao
							  where nomep = 'Paulo')
									   
order by nome_piloto