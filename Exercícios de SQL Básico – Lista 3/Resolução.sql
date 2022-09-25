-- Autor: Andrei Pochmann Koenich

drop table if exists Matriculas;
drop table if exists Alunos;
drop table if exists Disciplinas;
drop table if exists Cursos;

create table Cursos
(codc serial not null primary key,
nome varchar(20) not null);

insert into Cursos(nome) values ('cic');
insert into Cursos(nome) values ('ecp');
insert into Cursos(nome) values ('med');

create table Disciplinas
(codd serial not null primary key,
nomed varchar(20) not null,
 creditos INT not null,
 professor varchar(20) not null);

insert into Disciplinas(nomed, creditos, professor) values ('calculo I',6,'paulo'); 
insert into Disciplinas(nomed, creditos, professor) values ('calculo II',6,'tereza');
insert into Disciplinas(nomed, creditos, professor) values ('geometria', 2, 'paulo');
insert into Disciplinas(nomed, creditos, professor) values ('algebra', 4, 'tereza');

create table Alunos
(coda serial not null primary key,
nome varchar(20) not null,
idade int not null,
codc int,
foreign key(codc) references Cursos(codc));

insert into Alunos(nome, idade, codc) values ('maria', 20, 1);
insert into Alunos(nome, idade, codc) values ('joao', 18, 1);
insert into Alunos(nome, idade, codc) values ('jose', 18, 1);
insert into Alunos(nome, idade, codc) values ('raquel', 21, 2);
insert into Alunos(nome, idade, codc) values ('augusto', 24, 2);

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
insert into Matriculas(coda, codd, nota) values (3,3,6);

-- CONSULTAS ---------------------------------------------

-- 1a) O nome dos alunos que tiveram reprovação

select nome as nome_aluno
from Alunos natural join Matriculas
where nota < 6

-- 1b) A idade dos alunos que cursam CIC

select idade
from Alunos join Cursos using (codc)
where Cursos.nome = 'cic'

-- 2a) O nome de todos os alunos, dos respectivos cursos e o código das disciplinas nas quais se matricularam

select distinct Alunos.nome as nome_aluno, Cursos.nome as nome_curso, codd as codigo_disciplina
from Alunos natural join Matriculas join Cursos using (codc)

-- 2b ) O nome de todos os alunos e dos respectivos cursos (incluir no resultado cursos sem alunos)

select distinct Alunos.nome as nome_aluno, Cursos.nome as nome_curso
from Cursos left join Alunos using (codc)

-- 2c) O nome de todos os cursos, dos respectivos alunos e das disciplinas nas quais se
-- matricularam (incluir no resultado cursos mesmo que não tenham alunos, e alunos mesmo que
-- não tenham se matriculado em nenhuma disciplina).

select distinct Alunos.nome as nome_aluno, Cursos.nome as nome_curso, nomed as nome_disciplina
from Cursos left join Alunos using (codc) natural left join Matriculas natural left join Disciplinas

-- 2d) O nome de todas as disciplinas de 4 créditos e código dos alunos matriculados (incluir no
-- resultado disciplinas sem matrículas).

select distinct nomed as nome_disciplina, coda as codigo_aluno
from Disciplinas natural left join Matriculas
where creditos = 4

-- 3) O nome dos alunos que fizeram alguma disciplina de Calculo (ex: calculo I, calculo II, calculo
-- espacial, cálculo avançado, etc). Ordenar alfabeticamente.

select Alunos.nome as nome_aluno
from Alunos natural join Matriculas natural join Disciplinas
where nomed like 'calculo%'
order by nome_aluno

-- 4) O nome dos alunos, e a nota que tiraram, em disciplinas ministradas por paulo. Ordenar por
-- disciplina, seguido de ordem crescente de nota

select Alunos.nome as nome_aluno, nota
from Alunos natural join Matriculas natural join Disciplinas
where professor = 'paulo'
order by nomed, nota

-- 5) O nome dos alunos que não são da CIC que fizeram a disciplina de Calculo I

select Alunos.nome as nome_aluno
from Alunos join Cursos using (codc) natural join Matriculas natural join Disciplinas
where Cursos.nome != 'cic' and nomed = 'calculo I'

-- 6) O nome dos professores e dos alunos aprovados nas disciplinas que ministram, considerando
-- disciplinas de no mínimo 6 créditos 

select distinct professor as nome_professor, Alunos.nome as nome_aluno
from Disciplinas natural join Matriculas natural join Alunos
where nota >= 6 and creditos >= 6

-- 7) O nome das disciplinas nas quais tanto joao quanto maria se matricularam. 

select distinct nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where Alunos.nome = 'joao'

intersect

select distinct nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where Alunos.nome = 'maria'

-- 8) O nome das disciplinas nas quais maria se matriculou, e jose não.

select distinct nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where Alunos.nome = 'maria'

except

select distinct nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where Alunos.nome = 'joao'

-- 9) O nome das disciplinas nas quais o aluno jose não se matriculou.

select distinct nomed as nome_disciplina
from Disciplinas natural join Matriculas natural join Alunos
where Alunos.nome != 'jose'