-- Autor: Andrei Pochmann Koenich

drop table if exists alocacoes;
drop table if exists projetos;
drop table if exists funcionarios;

create table projetos
(codp char(2) not null primary key,
nomep varchar(50) not null,
linguagem varchar(20),
custo numeric not null,
cliente varchar(30));

insert into projetos values ('p1', 'projeto1', 'python', 300000, 'cli1');
insert into projetos values ('p2', 'projeto2', 'python', 400000, 'cli1');
insert into projetos values ('p3', 'projeto3', 'cobol', 400000, 'cli1');
insert into projetos values ('p4', 'projeto4', 'java', 200000, 'cli2');
insert into projetos values ('p5', 'projeto5', 'java', 50000, 'cli2');
insert into projetos values ('p6', 'projeto6', 'java', 200000, 'cli3');
insert into projetos values ('p7', 'projeto7', NULL, 50000, 'cli3');

create table funcionarios
(codf char(2) not null primary key,
nomef varchar(10) not null,
salario numeric not null);

insert into funcionarios values ('f1', 'maria', 10000);
insert into funcionarios values ('f2', 'pedro', 5000);
insert into funcionarios values ('f3', 'carlos', 7000);
insert into funcionarios values ('f4', 'pedro', 15000);


create table alocacoes
(codp char(2) not null references projetos,
codf char(2) not null references funcionarios,
horas numeric not null,
funcao varchar(15),
primary key (codp, codf));

insert into alocacoes values ('p1', 'f1', 10, 'programador');
insert into alocacoes values ('p1', 'f2', 20, 'analista');
insert into alocacoes values ('p2', 'f1', 15, 'programador');
insert into alocacoes values ('p2', 'f2', 20, 'analista');
insert into alocacoes values ('p4', 'f1', 5, 'analista');
insert into alocacoes values ('p5', 'f3', 10, 'programador');
insert into alocacoes values ('p4', 'f4', 10, 'programador');
insert into alocacoes values ('p3', 'f2', 10, 'programador');
insert into alocacoes values ('p3', 'f4', 5, 'programador');

-- CONSULTAS ---------------------------------------------

-- a) Considerando os projetos do cliente cli1, o custo do projeto mais barato, mais caro, a médio do custo dos
-- projetos, e o custo total de todos seus projetos.

select distinct min(custo) as mais_barato, max(custo) mais_caro, avg(custo) as media_custo, sum(custo) custo_total
from projetos
where cliente = 'cli1'

-- b) Considerando os projetos do cliente cli3, o número de projetos e de linguagens usadas.

select distinct count(distinct codp) as total_projetos, count(distinct linguagem) as total_linguagens
from projetos
where cliente = 'cli3'

-- c) Considerando os projetos em java, o número de projetos e o número de clientes envolvidos.

select distinct count(distinct codp) as total_projetos, count(distinct cliente) as total_clientes
from projetos
where linguagem = 'java'

-- d) Para cada linguagem, o número de projetos, o custo do projeto mais barato e mais caro. 

select distinct linguagem, count(distinct codp) as projetos, min(custo) as mais_barato, max(custo) as mais_caro
from projetos
where linguagem is not null
group by linguagem

-- e) Para cada cliente, o custo total de seus projetos em java

select distinct cliente, sum(custo) as custo_total
from projetos
where linguagem = 'java'
group by cliente

-- f) Considerando apenas projetos de no mínimo 100000, para cada cliente que tem projetos em mais de
-- uma linguagem, o nome do cliente, e o número de projetos. 

select distinct cliente, count(distinct codp) as total_projetos
from projetos
where custo >= 100000
group by cliente
having count(distinct linguagem) > 1

-- g) Considerando apenas projetos em java, o nome do cliente e custo total de seus projetos, desde que o
-- cliente só tenha projetos com custo acima de 100000.

select distinct cliente, sum(custo) as custo_total
from projetos
where linguagem = 'java'
group by cliente
having min(custo) > 100000

-- h) Para cada projeto em python, o nome do projeto, o número de pessoas trabalhando e o total de horas
-- alocadas.

select distinct nomep, count(distinct codf) as total_funcionarios, sum(horas) as total_horas
from projetos natural join alocacoes
where linguagem = 'python'
group by codp, nomep

-- i) Para cada funcionário, seu nome, e o número de projetos e de horas que trabalha.

select distinct nomef, count(distinct codp) as total_projetos, sum(horas) as total_horas
from projetos natural join alocacoes natural join funcionarios
group by codf, nomef

-- j) Para cada projeto, o número de pessoas alocadas (listar todos os projetos).

select distinct codp, count(distinct codf) as total_funcionarios
from projetos natural left join alocacoes
group by codp
order by codp

-- k) Considerando apenas os programadores, listar o nome do funcionário, número de projetos nos quais
-- trabalha nesta função, e número de clientes.

select distinct nomef, count(distinct codp) as total_projetos, count(distinct cliente) as total_clientes
from projetos natural join alocacoes natural join funcionarios
where funcao = 'programador'
group by codf, nomef

-- l) Listar o nome dos funcionários que exercem diferentes funções, e o número de projetos onde trabalham.

select distinct nomef, count(distinct codp) as total_projetos
from alocacoes natural join funcionarios
group by codf, nomef
having count(distinct funcao) > 1

-- m) Listar o nome dos funcionários que exercem diferentes funções, o número de projetos onde trabalham e
-- o número de clientes para os quais trabalham.

select distinct nomef, count(distinct codp) as total_projetos, count(distinct cliente) as total_clientes
from projetos natural join alocacoes natural join funcionarios
group by codf, nomef
having count(distinct funcao) > 1

-- n) Listar o nome dos funcionários cujos projetos envolvem todos a mesma linguagem.

select distinct nomef
from projetos natural join alocacoes natural join funcionarios
group by codf, nomef
having count(distinct linguagem) = 1

-- o) Listar o nome dos funcionários que trabalham para um único cliente.

select distinct nomef
from projetos natural join alocacoes natural join funcionarios
group by codf, nomef
having count(distinct cliente) = 1

-- p) Listar o nome dos funcionários cujos projetos são todos para clientes distintos.

select distinct nomef
from projetos natural join alocacoes natural join funcionarios
group by codf, nomef
having count(distinct cliente) = count(cliente)