-- Autor: Andrei Pochmann Koenich

drop table if exists matricula;
drop table if exists aluno;
drop table if exists professor;

create table aluno
(coda char(3) not null primary key,
nomea varchar(30) not null);

create table professor
(codp char(3) not null primary key,
nomep varchar(20) not null);

create table matricula
(coda char(3) not null,
codd char(3) not null,
codp char(3) not null,
nota int,
primary key (coda,codd),
foreign key(coda) references aluno,
foreign key (codp) references professor);

insert into aluno
values ('a1', 'joao');
insert into aluno
values ('a2', 'maria');
insert into aluno
values ('a3', 'aline');
insert into aluno
values ('a4', 'pedro');
insert into aluno 
values ('a5', 'xico');

insert into professor
values ('p1', 'jose');
insert into professor
values ('p2', 'marta');
insert into professor
values ('p3', 'paulo');
insert into professor
values ('p4', 'zeca');
insert into professor
values ('p5', 'carlos');

insert into matricula values
('a1', 'd1', 'p1', 7);
insert into matricula values
('a1', 'd2', 'p1', 8);
insert into matricula values
('a2', 'd1', 'p2', 10);
insert into matricula values
('a2', 'd2', 'p2', 10);
insert into matricula values
('a3', 'd1', 'p3', 8);
insert into matricula values
('a3', 'd3', 'p3', 8);
insert into matricula values
('a4', 'd3', 'p4', 8);
insert into matricula values
('a4', 'd4', 'p4', 8);
insert into matricula values
('a5', 'd1', 'p5', 7);
insert into matricula values
('a5', 'd2', 'p5', 8);
insert into matricula values
('a5', 'd3', 'p5', 10);

-- CONSULTAS ---------------------------------------------

-- O código das disciplinas que jose ministrou;

select distinct codd as codigo_disciplina
from professor natural join matricula
where nomep = 'jose'
order by codigo_disciplina

-- O código das disciplinas com os respectivos professores, para disciplinas que jose também ministra.

select distinct codd as codigo_disciplina, nomep as nome_professor
from professor natural join matricula
where nomep != 'jose' and codd in (select codd
								   from professor natural join matricula
								   where nomep = 'jose')
order by codigo_disciplina, nome_professor

-- O código das disciplinas com os respectivos professores, para disciplinas que jose não ministra.

select distinct codd as codigo_disciplina, nomep as nome_professor
from professor natural join matricula
where nomep != 'jose' and codd not in (select codd
									   from professor natural join matricula
									   where nomep = 'jose')
order by codigo_disciplina, nome_professor

-- O nome dos professores que não ministram nenhuma das disciplinas que jose ministra.

select distinct nomep as nome_professor
from professor
where nomep != 'jose' and nomep not in (select nomep
                                        from professor natural join matricula
										where codd in (select codd
													   from professor natural join matricula
													   where nomep = 'jose'))
order by nome_professor													   
													   
-- O nome dos professores que ministram todas as disciplinas que jose ministra (e possivelmente outras)

select distinct nomep as nome_professor
from professor PROF
where nomep != 'jose' and not exists (select *
									  from professor natural join matricula
									  where nomep = 'jose' and codd not in (select codd
									                                        from professor natural join matricula
																			where codp = PROF.codp))
order by nome_professor

-- O nome dos professores que ministram exatamente as mesmas disciplinas que jose ministra;

select distinct nomep as nome_professor
from professor PROF natural join matricula
where nomep != 'jose' and not exists (select *
									  from professor natural join matricula
									  where nomep = 'jose' and codd not in (select codd
									                                        from professor natural join matricula
																			where codp = PROF.codp))
group by codp, nomep
having count(distinct codd) = (select count(distinct codd)
							   from professor natural join matricula
							   where nomep = 'jose')
order by nome_professor