-- Autor: Andrei Pochmann Koenich

drop table if exists Matriculas;
drop table if exists Alunos;
drop table if exists Disciplinas;
drop table if exists Cursos;

create table Cursos
(codc serial not null primary key,
nomec varchar(20) not null);

insert into Cursos(nomec) values ('cic');
insert into Cursos(nomec) values ('ecp');
insert into Cursos(nomec) values ('med');

create table Disciplinas
(codd serial not null primary key,
nomed varchar(20) not null unique,
 creditos INT not null,
 professor varchar(20) not null);

insert into Disciplinas(nomed, creditos, professor) values ('calculo I',6,'paulo'); 
insert into Disciplinas(nomed, creditos, professor) values ('calculo II',6,'paulo');
insert into Disciplinas(nomed, creditos, professor) values ('geometria', 2, 'tereza');
insert into Disciplinas(nomed, creditos, professor) values ('algebra', 4, 'tereza');
insert into Disciplinas(nomed, creditos, professor) values ('anatomia', 4, 'paula');
insert into Disciplinas(nomed, creditos, professor) values ('etica', 4, 'raquel');

create table Alunos
(coda serial not null primary key,
nomea varchar(20) not null,
idade int not null,
codc int,
foreign key(codc) references Cursos(codc));

insert into Alunos(nomea, idade, codc) values ('maria', 20, 1);
insert into Alunos(nomea, idade, codc) values ('joao', 18, 1);
insert into Alunos(nomea, idade, codc) values ('jose', 18, 1);
insert into Alunos(nomea, idade, codc) values ('raoni', 18, 3);
insert into Alunos(nomea, idade, codc) values ('anahi', 18, 3);
insert into Alunos(nomea, idade, codc) values ('raquel', 21, 2);
insert into Alunos(nomea, idade, codc) values ('augusto', 24, 2);

create table Matriculas
(coda int not null,
codd int not null,
nota int not null,
primary key (coda, codd),
foreign key (coda) references Alunos(coda),
foreign key (codd) references Disciplinas(codd));

insert into Matriculas(coda, codd, nota) values (1,1,10);
insert into Matriculas(coda, codd, nota) values (1,2,8);
insert into Matriculas(coda, codd, nota) values (1,3,7);
insert into Matriculas(coda, codd, nota) values (2,1,7);
insert into Matriculas(coda, codd, nota) values (2,2,5);
insert into Matriculas(coda, codd, nota) values (2,3,7);
insert into Matriculas(coda, codd, nota) values (3,1,8);
insert into Matriculas(coda, codd, nota) values (3,2,8);
insert into Matriculas(coda, codd, nota) values (4,5,7);
insert into Matriculas(coda, codd, nota) values (4,6,10);
insert into Matriculas(coda, codd, nota) values (5,5,10);
insert into Matriculas(coda, codd, nota) values (5,6,10);

-- CONSULTAS ---------------------------------------------

-- 1) Considerando a professora tereza, o n??mero de suas disciplinas (i.e. disciplinas sob sua
-- responsabilidade), o total de cr??ditos de suas disciplinas, e a m??dia de cr??ditos de suas
-- disciplinas.

select distinct count(distinct codd) as total_disciplinas, sum(creditos) as total_creditos, avg(creditos) as media_creditos
from Disciplinas
where professor = 'tereza'

-- 2) Para cada professor, o nome do professor, o n??mero de disciplinas que ministra, o total de
-- cr??ditos de suas disciplinas, e a m??dia de cr??ditos de suas disciplinas. Ordenar professores
-- alfabeticamente.

select distinct professor, count(distinct codd) as total_disciplinas, sum(creditos) as total_creditos, avg(creditos) as media_creditos
from Disciplinas
group by professor
order by professor

-- 3) Para o conjunto das disciplinas de c??lculo (ex: calculo I, calculo I, calculo numerico, etc), o
-- n??mero de disciplinas e de professores.

select distinct count(distinct codd) as total_disciplinas, count(distinct professor) as total_professores
from Disciplinas
where nomed like 'calculo%'

-- 4) Para cada professor, mostrar seu nome, o n??mero de disciplinas sob sua responsabilidade
-- (mesmo que n??o existam alunos matriculados nelas), n??mero total de matriculas nestas
-- disciplinas, e n??mero total alunos (distintos) envolvidos (ordenar por nome de professor).

select distinct professor, count(distinct codd) as total_disciplinas, count(coda) as total_matriculas, count(distinct coda) as total_alunos 
from Matriculas right join Disciplinas using (codd)
group by professor
order by professor

-- 5) Para a aluna de nome maria, o numero de matriculas, notas m??nima/m??xima/m??dia, e
-- n??mero de distintos professores que tem.

select count(distinct codd) as total_matriculas, min(nota) as nota_minima, max(nota) as nota_maxima, avg(nota) as nota_media, count(distinct professor) as total_professores
from Alunos natural join Matriculas natural join Disciplinas
where nomea = 'maria'

-- 6) Para cada aluno do curso cic, seu nome, o n??mero de disciplinas na qual se matriculou, sua
-- nota m??dia, e o n??mero de professores que teve.

select nomea as nome_aluno, count(distinct codd) as total_disciplinas, avg(nota) as nota_media, count(distinct professor) as total_professores
from Alunos natural join Cursos natural join Matriculas natural join Disciplinas
where nomec = 'cic'
group by coda, nomea
order by nome_aluno

-- 7) O nome dos alunos que sempre tiveram no m??nimo nota 8 nas disciplinas nas quais se matricularam

select nomea as nome_aluno
from Alunos natural join Matriculas
group by coda, nomea
having min(nota) >= 8
order by nome_aluno

-- 8) Considerando apenas disciplinas de 4 cr??ditos ou mais, o nome do professor e da disciplina,
-- desde que a nota m??nima dos alunos matriculados tenha 7 ou superior, e a m??dia, 8,5 ou superior.

select professor, nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where creditos >= 4
group by codd, nomed
having min(nota) >= 7 and avg(nota) >= 8.5
order by professor, nome_disciplina

-- 9) O nome das disciplinas com pelo menos 3 alunos matriculados.

select nomed as nome_disciplina
from Disciplinas natural join Matriculas
group by codd, nomed
having count(distinct coda) >= 3
order by nome_disciplina

-- 10) O nome dos alunos que nunca tiraram notas iguais nas disciplinas nas quais se matricularam;

select nomea as nome_aluno
from Alunos natural join Matriculas
group by coda, nomea
having count(distinct nota) = count(nota)
order by nome_aluno

-- 11) O nome dos alunos que sempre tiram a mesma nota;

select nomea as nome_aluno
from Alunos natural join Matriculas
group by coda, nomea
having count(distinct nota) = 1
order by nome_aluno
