-- Autor: Andrei Pochmann Koenich

drop table if exists escalacoes ; 
drop table if exists voos ;
drop table if exists aeroportos ;
drop table if exists pilotos ;

create table aeroportos
(CODA	char(3) not null,
NOMEA 	varchar(20) not null,	
CIDADE 	varchar(20) not null,	
PAIS 	char(2) not null,
primary key(CODA));

create table voos
(CODV	char(5)	 not null,	
ORIGEM 	char(3)	 not null,	
DEST	char(3)	 not null,
HORA	numeric not null,
primary key(codv),
foreign key (origem) references aeroportos,
foreign key (dest) references aeroportos);

create table pilotos
(CODP		char(3) not null,
NOMEP		varchar(10) not null,	
SALARIO		numeric not null,	
GRATIFICACOES	numeric not null,		
TEMPO		numeric not null,	
PAIS		char(2) not null,
COMPANHIA	varchar(10) not null,
primary key(codp));

create table escalacoes
(CODV	char(5) not null,	
DATA	char(5)	not null,
CODP	char(3),
AVIAO	varchar(10) not null,
primary key(codv, data),
foreign key (codp) references pilotos,
foreign key (codv) references voos);

insert into aeroportos values ('poa','santos dumont','porto alegre','BR');
insert into aeroportos values ('gru','guarulhos','sao paulo','BR');
insert into aeroportos values ('gal','galeao','rio de janeiro','BR');
insert into aeroportos values ('rom','int de rome','roma','IT');
insert into aeroportos values ('stu','int de stutgart','stutgart','AL');
insert into aeroportos values ('gau','charles de gaulle','paris','FR');
insert into aeroportos values ('mun','int de munique','munique','AL');

insert into voos values ('GL230','gru','poa','7');
insert into voos values ('GL330','gru','rom','11');
insert into voos values ('GL430','poa','gru','14');
insert into voos values ('GL530','gru','gau','17');
insert into voos values ('GL531','gau','gru','11');
insert into voos values ('TM100','gru','rom','14');
insert into voos values ('TM150','rom','gru','7');
insert into voos values ('LF200','gru','stu','8');
insert into voos values ('LF210','stu','mun','17');
insert into voos values ('KL400','gal','stu','14');

insert into pilotos values ('p11','joao', 3000, 200, 5,'BR','gol');
insert into pilotos values ('p13','pedro', 2000, 100, 5,'BR','gol');
insert into pilotos values ('p12','paulo', 3000, 200, 3,'BR','gol');
insert into pilotos values ('p21','antonio', 1500, 300, 7,'BR','tam');
insert into pilotos values ('p22','carlos', 5000, 200, 10,'BR','tam');
insert into pilotos values ('p31','hanz', 5000, 1000, 6,'AL','lufthansa');
insert into pilotos values ('p41','roel', 5000, 2000, 5,'NL','klm');

insert into escalacoes values('GL230','01/05','p11','737'); 
insert into escalacoes values('GL230','01/06','p11','737');
insert into escalacoes values('TM100','01/05','p21','777');
insert into escalacoes values('LF200','01/05','p31','A320');
insert into escalacoes values('GL330','01/06','p12','737');
insert into escalacoes values('GL330','01/07','p12','777');
insert into escalacoes values('GL530','01/05','p12','777');
insert into escalacoes values('GL530','01/07',NULL,'777');
insert into escalacoes values('LF200','01/06','p31','777');
insert into escalacoes values('KL400','01/05','p41','A320');
insert into escalacoes values('LF210','01/05','p31','777');
insert into escalacoes values('TM150','01/06','p21','777');

-- CONSULTAS ---------------------------------------------

-- a) Liste por ordem alfabética o nome da companhia, e dos pilotos brasileiros.

select distinct NOMEP, COMPANHIA
from pilotos
where PAIS = 'BR'
order by NOMEP, COMPANHIA

-- b) O nome dos pilotos da gol escalados de 737

select distinct NOMEP
from pilotos natural join escalacoes
where AVIAO = '737'

-- c) A companhia dos vôos escalados para 1/05. 

select distinct COMPANHIA
from pilotos natural join escalacoes
where DATA = '01/05'

-- d) O código de todos os vôos que foram escalados para o primeiro dia de um mes qualquer, junto com a
-- respectiva companhia.

select distinct CODV
from voos natural join escalacoes
where DATA like '01%'

-- e) O nome dos pilotos da gol e os aviões que usam em suas escalas (listar somente pilotos escalados).

select distinct NOMEP, AVIAO
from pilotos natural join escalacoes
where COMPANHIA = 'gol'

-- f) O nome dos pilotos da gol e os aviões que usam em suas escalas (listar todos os pilotos, mesmo os sem
-- escalações).

select distinct NOMEP, AVIAO
from pilotos natural left join escalacoes
where COMPANHIA = 'gol'

-- g) O nome dos pilotos e dos aviões usados (listar todos os pilotos, e todos aviões ainda que a escala não
-- esteja definida (i.e. sem piloto)

select distinct NOMEP, AVIAO
from pilotos full join escalacoes using (codp)

-- h) O nome dos pilotos escalados de 777 que voam para (destino) o aeroporto de código gru

select distinct NOMEP
from pilotos natural join escalacoes natural join voos
where AVIAO = '777' and DEST = 'gru'

-- i) O código dos pilotos escalados de 777 que voam para (destino) o aeroporto de nome guarulhos

select distinct CODP
from escalacoes natural join voos join aeroportos on (aeroportos.CODA = voos.DEST)
where AVIAO = '777' and NOMEA = 'guarulhos'

-- j) O código dos pilotos que voaram de (origem) gru para (destino) para poa

select distinct CODP
from escalacoes natural join voos
where ORIGEM = 'gru' and DEST = 'poa'

-- k) O código dos pilotos que voaram de (origem) sao paulo para (destino) porto alegre

select distinct CODP
from escalacoes natural join voos join aeroportos aero_origem on (voos.ORIGEM = aero_origem.CODA) join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where aero_origem.CIDADE = 'sao paulo' and aero_destino.CIDADE = 'porto alegre'

-- l) O nome dos pilotos que voam de 777 para o seu próprio país

select distinct NOMEP
from pilotos natural join escalacoes natural join voos join aeroportos on (aeroportos.CODA = voos.DEST)
where AVIAO = '777' and pilotos.PAIS = aeroportos.PAIS

-- m) O nome de todos os aeroportos onde a Gol opera (indistintamente se é origem/destino).

select distinct NOMEA
from pilotos natural join escalacoes natural join voos join aeroportos on (voos.ORIGEM = aeroportos.CODA or voos.DEST = aeroportos.CODA)
where COMPANHIA = 'gol'

-- n) O código de todos os vôos internacionais que as companhias fazem a partir de aeroportos em seus
-- próprios países. (dica: uma companhia não pode operar internamente em outro pais) 

select distinct CODV
from pilotos natural join escalacoes natural join voos join aeroportos aero_origem on (voos.ORIGEM = aero_origem.CODA) join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where (aero_origem.PAIS != aero_destino.PAIS) and (pilotos.PAIS = aero_origem.PAIS) 

-- 1. O código de voo, e os dados do destino (nome do aeroporto, cidade e país) de todos os vôos
-- escalados em 737. Ordene por pais e nome de aeroporto.

select distinct CODV, NOMEA, CIDADE, PAIS
FROM escalacoes natural join voos join aeroportos on (voos.DEST = aeroportos.CODA)
where AVIAO = '737'
ORDER BY PAIS, NOMEA

-- 2. Os dados do destino (nome do aeroporto, cidade e país) de todos os vôos da Gol. Ordene por pais e
-- cidade.

select distinct NOMEA, CIDADE, aeroportos.PAIS
FROM pilotos natural join voos join aeroportos on (voos.DEST = aeroportos.CODA)
where COMPANHIA = 'gol'
ORDER BY PAIS, CIDADE

-- 3. Os dados da origem e do destino (para cada um, nome do aeroporto, cidade e pais), de todos os vôos
-- escalados no aviao 777.

select distinct aero_origem.NOMEA, aero_origem.CIDADE, aero_origem.PAIS, aero_destino.NOMEA, aero_destino.CIDADE, aero_destino.PAIS
from escalacoes natural join voos join aeroportos aero_origem on (voos.ORIGEM = aero_origem.CODA) join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where AVIAO = '777'

-- 4. O código de todos os vôos e hora de saída, junto com o nome dos pilotos escalados para os mesmos,
-- e respectivos tipos de avião e companhia, para todos os vôos de companhias estrangeiras.

select distinct CODV, HORA, NOMEP, AVIAO, COMPANHIA
from pilotos natural join escalacoes natural join voos
where COMPANHIA != 'BR'

-- 5. O código de todos os vôos para a Alemanha ou Itália, com as respectivas data e hora de saída.

select distinct CODV, DATA, HORA
from escalacoes natural join voos join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where aero_destino.PAIS = 'BR' OR aero_destino.PAIS = 'IT'

-- 6. A companhia dos pilotos que voam para a Italia.

select distinct COMPANHIA
from pilotos natural join escalacoes natural join voos join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where aero_destino.PAIS = 'IT'

-- 7. O nome dos aeroportos de origem e de destino de todos os vôos marcados para o dia 1/05.

select distinct aero_origem.NOMEA, aero_destino.NOMEA
from escalacoes natural join voos join aeroportos aero_origem on (voos.ORIGEM = aero_origem.CODA) join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where DATA = '01/05'

-- 8. O código e horario dos vôos internos de todos os países.

select distinct CODV, HORA
from voos join aeroportos aero_origem on (voos.ORIGEM = aero_origem.CODA) join aeroportos aero_destino on (voos.DEST = aero_destino.CODA)
where aero_origem.PAIS = aero_destino.PAIS 
