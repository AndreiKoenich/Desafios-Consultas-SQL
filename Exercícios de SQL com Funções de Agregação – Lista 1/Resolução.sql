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
-- Para todos os g??neros, o seu nome e nome das m??sicas do g??nero

select distinct nomeg as nome_genero, nomem as nome_musica
from genero natural join musica
order by nome_genero, nome_musica

-- o n??mero de g??neros musicais e de m??sicas gravadas

select count(distinct nomeg), count(distinct nomem)
from genero natural join musica

-- 2) Compare
-- para o g??nero funk, o nome das m??sicas e dos artista que gravaram m??sicas deste g??nero

select nomem as nome_musica, nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
where nomeg = 'funk'
order by nome_musica, nome_artista

-- para o g??nero funk, o n??mero de m??sicas gravadas, e de artistas envolvidos

select count(distinct codm) as total_musicas, count(distinct coda) as total_artistas
from genero natural join musica natural join gravacao
where nomeg = 'funk'

-- 3) Compare
-- o nome de cada g??nero, m??sica e n??mero de downloads

select distinct nomeg as nome_genero, nomem as nome_musica, downloads
from genero natural join musica
order by nome_genero, nome_musica, downloads

-- para cada g??nero (nome), o n??mero de m??sicas e de downloads

select distinct nomeg as nome_genero, count(distinct codm) as total_musicas, sum(downloads) as total_downloads
from genero natural left join musica
group by codg, nomeg
order by nome_genero, total_musicas, total_downloads

-- 4) Compare
-- para cada artista, o nome e ano das musicas que gravou

select distinct nomea as nome_artista, ano
from artista natural join gravacao natural join musica
order by nome_artista, ano

-- para cada artista (nome), o numero de musicas que gravou por ano

select nomea as nome_artista, ano, count(distinct codm) as total_musicas
from artista natural join gravacao natural join musica
group by coda, nomea, ano
order by nome_artista, ano, total_musicas

-- 5) Compare
-- o ano, genero, e artistas que gravaram o g??nero

select distinct ano, nomeg as nome_genero, nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
order by ano

-- para cada ano, o n??mero de g??neros gravados, e o n??mero de artista envolvidos

select ano, count(distinct codg) as total_generos, count(distinct coda) as total_artistas
from artista natural join gravacao natural join musica natural join genero
group by ano
order by ano

-- 6) Compare
-- o nome dos g??neros e n??mero de downloads

select nomeg as nome_generos, sum(downloads) as total_downloads
from genero natural join musica
group by codg, nomeg
order by nome_generos, total_downloads

-- o nome dos g??neros que t??m mais de 10.000 downloads

select nomeg as nome_generos, sum(downloads) as total_downloads
from genero natural join musica
group by codg, nomeg
having sum(downloads) > 10000
order by nome_generos, total_downloads

-- 7) Compare
-- o nome dos artistas, de suas m??sicas e n??mero de downloads

select nomea as nome_artista, nomem as nome_musica, downloads
from artista natural join gravacao natural join musica
order by nome_artista
order by nome_artista, nome_musica, downloads

-- o nome dos artistas cujas m??sicas t??m sempre o mesmo n??mero de downloads

select nomea as nome_artista
from artista natural join gravacao natural join musica
group by coda, nomea
having count(distinct downloads) = 1
order by nome_artista

-- o nome dos artista cujas m??sicas jamais tiveram o mesmo n??mero de downloads

select nomea as nome_artista
from artista natural join gravacao natural join musica
group by coda, nomea
having count(distinct downloads) = count(downloads)
order by nome_artista

-- 8) Compare
-- o nome das m??sicas que a anitta gravou, o nome do g??nero e downloads

select nomem as nome_musica, nomeg as nome_genero, downloads
from artista natural join gravacao natural join musica natural join genero
where nomea = 'anitta'
order by nome_musica, nome_genero, downloads

-- o n??mero de m??sicas que a anita gravou, o total de g??neros envolvidos e de downloads

select count(distinct codm) as total_musicas, count(distinct codg) as total_generos, sum(downloads) as total_downloads
from artista natural join gravacao natural join musica
where nomea = 'anitta'
order by total_musicas, total_generos, total_downloads

-- 9) Compare
-- o nome do artista, da m??sica que gravou, e respectivo numero de downloads

select nomea as nome_artista, nomem as nome_musica, sum(downloads) as total_downloads
from artista natural join gravacao natural join musica
group by coda, nomea, codm, nomem
order by nome_artista, nome_musica, total_downloads

-- para cada artista, o n??mero de m??sicas gravadas, o menor e maior n??mero de downloads

select nomea as nome_artista, count(distinct codm) as total_musicas, min(downloads) as menor_downloads, max(downloads) as maior_downloads
from artista natural join gravacao natural join musica
group by coda, nomea
order by nome_artista

-- 10) Compare
-- para cada g??nero musical, o nome das m??sicas gravadas por artistas do sexo feminino

select distinct nomeg as nome_genero, nomem as nome_musicas
from genero natural join musica natural join gravacao natural join artista
where sexo = 'f'
order by nome_genero, nome_musicas

-- para cada g??nero musical, o n??mero de m??sicas gravadas por artistas do sexo feminino

select distinct nomeg as nome_genero, count(distinct coda) as total_musicas
from genero natural join musica natural join gravacao natural join artista
where sexo = 'f'
group by codg, nomeg
order by nome_genero, total_musicas

-- 11) Compare
-- os anos nos quais a anitta gravou m??sicas com mais de 2000 downloads

select distinct ano
from artista natural join gravacao natural join musica
where nomea = 'anitta' and downloads > 2000
order by ano

-- o n??mero de anos nos quais a anitta conseguiu gravar pelo menos uma m??sica com mais de 2000 downloads

select count(distinct ano) as total_anos
from artista natural join gravacao natural join musica
where nomea = 'anitta' and downloads > 2000
order by total_anos

-- 12) Compare
-- o nome das m??sicas e o n??mero de artista que gravaram a m??sica

select distinct nomem as nome_musica, count(distinct coda) as numero_artistas
from musica natural join artista
group by codm, nomem
order by nome_musica, numero_artistas

-- o nome das m??sicas gravadas por mais de um artista

select distinct nomem as nome_musica
from musica natural join artista
group by codm, nomem
having count(distinct coda) > 1
order by nome_musica

-- 13) Compare
-- o nome dos g??neros e dos artistas que gravaram m??sicas

select distinct nomeg as nome_genero, nomea as nome_artista
from genero natural join musica natural join gravacao natural join artista
order by nome_genero, nome_artista

-- o nome dos g??neros e de m??sicas gravadas, para g??neros cujas m??sicas foram gravadas

select distinct nomeg as nome_genero, nomem as nome_musica
from genero natural join musica
order by nome_genero, nome_musica
