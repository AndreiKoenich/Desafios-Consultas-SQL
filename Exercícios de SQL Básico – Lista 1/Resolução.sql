-- Autor: Andrei Pochmann Koenich

drop table if exists gravacao;
drop table if exists musica;
drop table if exists artista;
drop table if exists genero;

create table genero
(codg char(3) NOT NULL primary key,
nomeg varchar(20) NOT NULL);

insert into genero values ('g1', 'rapp');
insert into genero values ('g2', 'pop');
insert into genero values ('g3', 'funk');
insert into genero values ('g4', 'rock');

create table musica
(codm char(3) NOT NULL primary key,
nomem varchar(50) NOT NULL,
ano smallint not null,
codg char(3),
downloads smallint NOT NULL,
foreign key(codg) references genero
);

insert into musica values ('m1', 'pipa voada', 2020, 'g1', 1000);
insert into musica values ('m2', 'amarelo', 2020, 'g1', 3000);
insert into musica values ('m3', 'passarinhos', 2015, 'g2', 5000);
insert into musica values ('m4', 'bum bum tam tam: remix vacina butantan', 2020, 'g3', 2000);
insert into musica values ('m5', 'bum bum tam tam', 2017, 'g3', 20000);
insert into musica values ('m6', 'boa sorte', 2019, 'g2', 4000);

create table artista
(coda char(3) NOT NULL primary key,
nomea varchar(30) NOT NULL,
sexo char(1) NOT NULL 
);

insert into artista values('a1', 'emicida', 'm');
insert into artista values('a2', 'rashid', 'm');
insert into artista values('a3', 'vanessa da mata', 'f');
insert into artista values('a4', 'mc fioti', 'm');
insert into artista values( 'a5', 'projota', 'm');

create table gravacao
(codm char(3) NOT NULL,
coda char(3) NOT NULL,
primary key (coda, codm),
foreign key (coda) references artista,
foreign key (codm) references musica
);

insert into gravacao values ('m1', 'a1');
insert into gravacao values ('m1', 'a2');
insert into gravacao values ('m2', 'a1');
insert into gravacao values ('m3', 'a1');
insert into gravacao values ('m3', 'a3');
insert into gravacao values ('m4', 'a4');
insert into gravacao values ('m5', 'a4' );
insert into gravacao values ('m6', 'a3' );

-- CONSULTAS ---------------------------------------------

-- 1) -- o nome do gênero de todas as música feitas em 2020

select distinct nomeg as nome_genero
from musica natural join genero
where ano = '2020'
order by nome_genero

-- 2) -- o nome de todas as músicas que o emicida gravou

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista
where nomea = 'emicida'
order by nome_musica

-- 3) -- o nome das músicas no gênero rapp

select distinct nomem as nome_musica
from musica natural join genero
where nomeg = 'rapp'
order by nome_musica

-- 4) -- o nome das musicas que comecam com "bum bum"

select distinct nomem as nome_musica
from musica
where nomem like 'bum bum%'
order by nome_musica

-- 5) -- o ano que emicida gravou musicas

select distinct ano
from artista natural join gravacao natural join musica
where nomea = 'emicida'
order by ano

-- 6) -- o nome de todos os artistas, e das músicas que gravaram (artistas sem gravações
-- devem aparecer no resultado). Ordene por ordem alfabetica de artista

select distinct nomea as nome_artista, nomem as nome_musica
from artista natural left join gravacao natural left join musica
order by nome_artista, nome_musica

-- 7) -- o nome das artistas de sexo masculino que gravaram músicas pop

select distinct nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
where sexo = 'm' and nomeg = 'pop'
order by nome_artista

-- 8) -- o gênero que das musicas que o mc fioti grava

select distinct nomeg as nome_genero
from artista natural join gravacao natural join musica natural join genero
where nomea = 'mc fioti'
order by nome_genero

-- 9) -- o nome das músicas que o rashid e emicida gravaram

select distinct nomem as nome_musica
from artista natural join gravacao natural join musica
where nomea = 'emicida' or nomea = 'rashid'
order by nome_musica

-- 10) -- O nome dos artistas que não gravaram musicas

select distinct nomea as nome_artista
from artista natural left join gravacao
group by coda, nomea
having count(distinct codm) = 0
order by nome_artista

-- 11) -- o nome do gênero de todas as músicas com pelo menos 3000 downloads

select distinct nomeg as nome_genero
from genero natural join musica
where downloads >= 3000
order by nome_genero

-- 12) -- o nome dos artistas que gravaram a música 'passarinhos'

select distinct nomea as nome_artista
from artista natural join gravacao natural join musica
where nomem = 'passarinhos'
order by nome_artista

-- 13) -- o nome das músicas cantadas por artistas mc

select distinct nomem as nome_musica
from artista natural join gravacao natural join musica
where nomea like 'mc%'
order by nome_musica

-- 14) -- o nome dos gêneros e das respectivas musicas, ordenadas por gênero (generos não gravados aparecem no resultado)

select distinct nomeg as nome_genero, nomem as nome_musica
from genero natural left join musica
order by nome_genero, nome_musica

-- 15) –- o numero de downloads de músicas pop cantadas por artistas de sexo feminino

select distinct downloads
from genero natural join musica natural join gravacao natural join artista
where sexo = 'f' and nomeg = 'pop'
order by downloads

-- 16) -- o nome dos artistas que gravaram músicas com o emicida

select distinct nomea as nome_artista
from artista natural join gravacao
where nomea != 'emicida' and codm in (select codm
                                      from artista natural join gravacao
                                      where nomea = 'emicida')
order by nome_artista               

-- 17) –- o nome dos gêneros que o emicida nao gravou

select distinct nomeg as nome_genero
from genero
where codg not in (select codg
                   from genero natural join musica natural join gravacao natural join artista
                   where nomea = 'emicida')
order by nome_genero
