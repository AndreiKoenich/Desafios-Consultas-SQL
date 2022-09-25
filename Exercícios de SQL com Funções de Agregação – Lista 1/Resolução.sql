-- Autor: Andrei Pochmann Koenich

drop table if exists gravacao;
drop table if exists musica;
drop table if exists artista;
drop table if exists genero;

create table genero
(codg char(3) NOT NULL primary key,
nomeg varchar(20) NOT NULL);

insert into genero values ('g1', 'sertanejo');
insert into genero values ('g2', 'funk');
insert into genero values ('g3', 'raggae');
insert into genero values ('g4', 'rock');

create table musica
(codm char(3) NOT NULL primary key,
nomem varchar(30) NOT NULL,
ano smallint not null,
codg char(3),
downloads smallint NOT NULL,
foreign key(codg) references genero
);

insert into musica values ('m1', 'some que ele vem atras', 2019, 'g1', 3000);
insert into musica values ('m2', 'todo mundo vai sofrer', 2019, 'g1', 3000);
insert into musica values ('m3', 'terremoto', 2020, 'g2', 4000);
insert into musica values ('m4', 'o grave bater', 2018, 'g2', 2000);
insert into musica values ('m5', 'nem perco meu tempo', 2018, 'g2', 5000);
insert into musica values ('m6', 'brisa', 2019, 'g3', 10000);
insert into musica values ('m7', 'casa do sol', 2019, 'g3', 4000);

update musica set ano = 2018 where nomem = 'o grave bater';
update musica set downloads = 3000 where nomem = 'some que ele vem atras';

create table artista
(coda char(3) NOT NULL primary key,
nomea varchar(30) NOT NULL,
sexo char(1) NOT NULL 
);

insert into artista values('a1', 'marilia mendonca', 'f');
insert into artista values('a2', 'anitta', 'f');
insert into artista values('a3', 'mc kevinho', 'm');
insert into artista values('a4', 'iza', 'f');
insert into artista values( 'a5', 'Armandinho', 'm');

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
insert into gravacao values ('m3', 'a2');
insert into gravacao values ('m3', 'a3');
insert into gravacao values ('m4', 'a2');
insert into gravacao values ('m4', 'a3');
insert into gravacao values ('m5', 'a2' );
insert into gravacao values ('m6', 'a4' );
insert into gravacao values ('m7', 'a5' );

-- CONSULTAS ---------------------------------------------

-- 1) Compare
-- Para todos os gêneros, o seu nome e nome das músicas do gênero

select distinct nomeg as nome_genero, nomem as nome_musica
from genero natural join musica

-- o número de gêneros musicais e de músicas gravadas

select count(distinct nomeg), count(distinct nomem)
from genero natural join musica

-- 2) Compare
-- para o gênero funk, o nome das músicas e dos artista que gravaram músicas deste gênero

select nomem as nome_musica, nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
where nomeg = 'funk'

-- para o gênero funk, o número de músicas gravadas, e de artistas envolvidos

select count(distinct codm) as total_musicas, count(distinct coda) as total_artistas
from genero natural join musica natural join gravacao
where nomeg = 'funk'

-- 3) Compare
-- o nome de cada gênero, música e número de downloads

select distinct nomeg as nome_genero, nomem as nome_musica, downloads
from genero natural join musica

-- para cada gênero (nome), o número de músicas e de downloads

select distinct nomeg as nome_genero, count(distinct codm) as total_musicas, sum(downloads) as total_downloads
from genero natural left join musica
group by codg, nomeg

-- 4) Compare
-- para cada artista, o nome e ano das musicas que gravou

select distinct nomea as nome_artista, ano
from artista natural join gravacao natural join musica

-- para cada artista (nome), o numero de musicas que gravou por ano

select nomea as nome_artista, ano, count(distinct codm) as total_musicas
from artista natural join gravacao natural join musica
group by coda, nomea, ano

-- 5) Compare
-- o ano, genero, e artistas que gravaram o gênero

select distinct ano, nomeg as nome_genero, nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
order by ano

-- para cada ano, o número de gêneros gravados, e o número de artista envolvidos

select ano, count(distinct codg) as total_generos, count(distinct coda) as total_artistas
from artista natural join gravacao natural join musica natural join genero
group by ano
order by ano

-- 6) Compare
-- o nome dos gêneros e número de downloads

select nomeg as nome_generos, sum(downloads) as total_downloads
from genero natural join musica
group by codg, nomeg

-- o nome dos gêneros que têm mais de 10.000 downloads

select nomeg as nome_generos, sum(downloads) as total_downloads
from genero natural join musica
group by codg, nomeg
having sum(downloads) > 10000

-- 7) Compare
-- o nome dos artistas, de suas músicas e número de downloads

select nomea as nome_artista, nomem as nome_musica, downloads
from artista natural join gravacao natural join musica
order by nome_artista

-- o nome dos artistas cujas músicas têm sempre o mesmo número de downloads

select nomea as nome_artista
from artista natural join gravacao natural join musica
group by coda, nomea
having count(distinct downloads) = 1
order by nome_artista

-- o nome dos artista cujas músicas jamais tiveram o mesmo número de downloads

select nomea as nome_artista
from artista natural join gravacao natural join musica
group by coda, nomea
having count(distinct downloads) = count(downloads)
order by nome_artista

-- 8) Compare
-- o nome das músicas que a anitta gravou, o nome do gênero e downloads

select nomem as nome_musica, nomeg as nome_genero, downloads
from artista natural join gravacao natural join musica natural join genero
where nomea = 'anitta'

-- o número de músicas que a anita gravou, o total de gêneros envolvidos e de downloads

select count(distinct codm) as total_musicas, count(distinct codg) as total_generos, sum(downloads) as total_downloads
from artista natural join gravacao natural join musica
where nomea = 'anitta'

-- 9) Compare
-- o nome do artista, da música que gravou, e respectivo numero de downloads

select nomea as nome_artista, nomem as nome_musica, sum(downloads) as total_downloads
from artista natural join gravacao natural join musica
group by coda, nomea, codm, nomem

-- para cada artista, o número de músicas gravadas, o menor e maior número de downloads

select nomea as nome_artista, count(distinct codm) as total_musicas, min(downloads) as menor_downloads, max(downloads) as maior_downloads
from artista natural join gravacao natural join musica
group by coda, nomea
order by nome_artista

-- 10) Compare
-- para cada gênero musical, o nome das músicas gravadas por artistas do sexo feminino

select distinct nomeg as nome_genero, nomem as nome_musicas
from genero natural join musica natural join gravacao natural join artista
where sexo = 'f'

-- para cada gênero musical, o número de músicas gravadas por artistas do sexo feminino

select distinct nomeg as nome_genero, count(distinct coda)
from genero natural join musica natural join gravacao natural join artista
where sexo = 'f'
group by codg, nomeg

-- 11) Compare
-- os anos nos quais a anitta gravou músicas com mais de 2000 downloads

select distinct ano
from artista natural join gravacao natural join musica
where nomea = 'anitta' and downloads > 2000
order by ano

-- o número de anos nos quais a anitta conseguiu gravar pelo menos uma música com mais de 2000 downloads

select count(distinct ano) as total_anos
from artista natural join gravacao natural join musica
where nomea = 'anitta' and downloads > 2000
order by total_anos

-- 12) Compare
-- o nome das músicas e o número de artista que gravaram a música

select distinct nomem as nome_musica, count(distinct coda)
from musica natural join artista
group by codm, nomem
order by nome_musica

-- o nome das músicas gravadas por mais de um artista

select distinct nomem as nome_musica
from musica natural join artista
group by codm, nomem
having count(distinct coda) > 1
order by nome_musica

-- 13) Compare
-- o nome dos gêneros e dos artistas que gravaram músicas

select distinct nomeg as nome_genero, nomea as nome_artista
from genero natural join musica natural join gravacao natural join artista
order by nome_genero, nome_artista

-- o nome dos gêneros e de músicas gravadas, para gêneros cujas músicas foram gravadas

select distinct nomeg as nome_genero, nomem as nome_musica
from genero natural join musica
order by nome_genero, nome_musica