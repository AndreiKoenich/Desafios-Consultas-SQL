-- Autor: Andrei Pochmann Koenich

drop table if exists gravacao;
drop table if exists musica;
drop table if exists artista;
drop table if exists genero;

create table genero
(codg char(3) NOT NULL primary key,
nomeg varchar(20) NOT NULL);

create table musica
(codm char(3) NOT NULL primary key,
nomem varchar(30) NOT NULL,
ano smallint not null,
codg char(3),
downloads smallint NOT NULL,
foreign key(codg) references genero
);

create table artista
(coda char(3) NOT NULL primary key,
nomea varchar(30) NOT NULL
);

create table gravacao
(codm char(3) NOT NULL,
coda char(3) NOT NULL,
primary key (coda, codm),
foreign key (coda) references artista,
foreign key (codm) references musica
);

insert into genero values ('g1', 'rapp');
insert into genero values ('g2', 'pop');
insert into genero values ('g3', 'funk');
insert into genero values ('g4', 'rock');
insert into genero values ('g5', 'sertanejo');

insert into musica values ('m1', 'pipa voada', 2020, 'g1', 5000);
insert into musica values ('m2', 'amarelo', 2020, 'g1', 15000);
insert into musica values ('m3', 'passarinhos', 2015, 'g2', 5000);
insert into musica values ('m4', 'mae', 2015, 'g2', 5000);
insert into musica values ('m5', 'modo turbo', 2020, 'g3', 4000);
insert into musica values ('m6', 'bandida', 2020, 'g3', 4000);
insert into musica values ('m7', 'boa sorte', 2019, 'g2', 4000);
insert into musica values ('m8', 'fala mal de mim', 2021, 'g5', 5000);

insert into artista  values('a1', 'emicida');
insert into artista  values('a2', 'rashid');
insert into artista  values('a3', 'vanessa da mata');
insert into artista  values('a4', 'pabllo vittar');
insert into artista values('a5', 'luisa sonza');
insert into artista values('a6', 'pedro sampaio');
insert into artista values('a7', 'wesley safadao');
insert into artista values('a8', 'projota');

insert into gravacao values ('m1', 'a1');
insert into gravacao values ('m1', 'a2');
insert into gravacao values ('m2', 'a1');
insert into gravacao values ('m2', 'a4');
insert into gravacao values ('m3', 'a1');
insert into gravacao values ('m3', 'a3');
insert into gravacao values ('m4', 'a1');
insert into gravacao values ('m5', 'a4' );
insert into gravacao values ('m5', 'a5' );
insert into gravacao values ('m6', 'a4' );
insert into gravacao values ('m7', 'a3' );
insert into gravacao values ('m8', 'a6');
insert into gravacao values ('m8', 'a7');

-- CONSULTAS ---------------------------------------------

-- 1) Compare
-- os generos que o Emicida grava

select distinct nomeg as nome_genero
from artista natural join gravacao natural join musica natural join genero
where nomea = 'emicida'
order by nome_genero

-- os generos que o Emicida n??o grava

select distinct nomeg as nome_genero
from genero
where codg not in (select codg
		   from artista natural join gravacao natural join musica natural join genero
		   where nomea = 'emicida')
order by nome_genero

-- os g??neros em comum entre a Pabllo Vittar e o Emicida

select distinct nomeg as nome_genero
from artista natural join gravacao natural join musica natural join genero
where nomea = 'pabllo vittar' and codg in (select codg
					   from artista natural join gravacao natural join musica natural join genero
					   where nomea = 'emicida')
order by nome_genero

-- os g??neros que a Pabllo Vittar grava e o Emicida n??o grava

select distinct nomeg as nome_genero
from artista natural join gravacao natural join musica natural join genero
where nomea = 'pabllo vittar' and codg not in (select codg
					       from artista natural join gravacao natural join musica natural join genero
					       where nomea = 'emicida')
order by nome_genero

-- 2) Compare
-- aumentar em 10.000 os downloads da musica Pipa Voada

update musica
set downloads = downloads + 10000
where nomem = 'pipa voada'

-- aumentar em 10.000 os downlaods das m??sicas do Emicida

update musica
set downloads = downloads + 10000
where codm in (select codm 
	       from musica natural join gravacao natural join artista 
	       where nomea = 'emicida')

-- 3) Compare
-- remover o cantor de nome projota

delete from artista
where nomea = 'projota'

-- remover as musicas do genero rock

delete from musica
where codm in (select codm 
	       from musica natural join genero 
	       where nomeg = 'rock')

-- 4) Compare
-- o nome das musicas que o Emicida gravou com o Rashid

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista 
where nomea = 'emicida' and codm in (select codm 
                                     from gravacao natural join artista 
				     where nomea = 'rashid')
order by nome_musica									 

-- o nome das musicas que o Emicida n??o gravou com o Rashid

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista 
where nomea = 'emicida' and codm not in (select codm 
                                         from gravacao natural join artista 
					 where nomea = 'rashid')
order by nome_musica	

-- o nome das musicas que o Emicida gravou sozinho

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista 
where nomea = 'emicida' and codm in (select codm
				     from musica natural join gravacao
				     group by codm, nomem
				     having count(distinct coda) = 1)
order by nome_musica

-- o nome das musicas que o emicida gravou em parceria com outro artista

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista 
where nomea = 'emicida' and codm in (select codm
				     from musica natural join gravacao
				     group by codm, nomem
				     having count(distinct coda) > 1)
order by nome_musica

-- 5) Compare
-- para as m??sicas gravadas em parceria com o emicida, o numero de downloads

select distinct nomem as nome_musica, downloads
from musica natural join gravacao natural join artista 
where nomea = 'emicida' and codm in (select codm
				     from musica natural join gravacao
				     group by codm, nomem
				     having count(distinct coda) > 1)
order by nome_musica, downloads								 

-- para artistas que gravaram m??sicas em parceria com o emicida, o nome de suas m??sicas e o
-- n??mero de downloads

select distinct nomem as nome_musica, downloads
from musica natural join gravacao natural join artista 
where nomea != 'emicida' and coda in (select coda 
                                      from artista natural join gravacao 
				      where codm in (select codm 
				      from artista natural join gravacao
				      where nomea = 'emicida'))
order by nome_musica, downloads		

-- 6) Compare
-- o n??mero de downloads por m??sica (ordenado de forma decrescente)

select distinct nomem as nome_musica, downloads
from musica
order by downloads desc

-- a m??sica com maior n??mero de downloads

select distinct nomem as nome_musica, downloads
from musica
where downloads = (select max(downloads) 
		   from musica)

-- 7) Compare
-- o nome dos artistas que gravaram em parceria com o Emicida

select distinct nomea as nome_artista
from artista natural join gravacao
where nomea != 'emicida' and codm in (select codm 
				      from artista natural join gravacao
			              where nomea = 'emicida')
order by nome_artista										  

-- o nome dos artistas que n??o gravaram m??sicas com o Emicida

select distinct nomea as nome_artista
from artista
where nomea != 'emicida' and coda not in (select coda
					  from gravacao
			                  where codm in (select codm
							 from artista natural join gravacao
							 where nomea = 'emicida'))
order by nome_artista
														 
-- 8) Compare
-- O nome dos artistas que gravam funk

select distinct nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
where nomeg = 'funk'
order by nome_artista

-- O nome dos artistas que n??o gravam funk

select distinct nomea as nome_artista
from artista
where coda not in (select coda
		   from genero natural join musica natural join gravacao
		   where nomeg = 'funk')
order by nome_artista

-- O nome dos artistas que gravam rapp e pop

select distinct nomea as nome_artista
from artista natural join gravacao natural join musica natural join genero
where nomeg = 'rapp' and coda in (select coda
			          from gravacao natural join musica natural join genero
			          where nomeg = 'pop')
order by nome_artista								  

-- O nome das m??sicas de artistas que gravaram mais de um g??nero

select distinct nomem as nome_musica
from musica natural join gravacao natural join artista
where coda in (select coda
	       from artista natural join gravacao natural join musica
	       group by coda
	       having count(distinct codg) > 1)
order by nome_musica

-- 9) Execute
-- crie o g??nero Forro

insert into genero values ('g6','forro')

-- trocar o g??nero das m??sicas do Wesley Safadao classificadas como sertanejo para o c??digo do
-- g??nero que voc?? criou representando forro

update musica
set codg = 'g6'	
where codm in (select codm
	       from artista natural join gravacao natural join genero
	       where nomea = 'wesley safadao' and nomeg = 'sertanejo')		   

-- 10) Execute
-- remover as grava????es do Wesley Safadao

delete from gravacao
where coda in (select coda
	       from artista
	       where nomea = 'wesley safadao')

-- 11) Compare
-- o n??mero de musicas que cada artista gravou com a Pablo Vittar

select distinct nomea as nome_artista, count(distinct codm) as total_musicas
from artista natural join gravacao
where nomea != 'pabllo vittar' and codm in (select codm
					    from artista natural join gravacao
					    where nomea = 'pabllo vittar')
group by coda, nomea
order by nome_artista 

-- o n??mero de m??sicas gravadas por artistas que gravaram com a Pablo Vittar (qualquer musica)

select distinct nomea as nome_artista, count(distinct codm) as total_musicas
from artista natural join gravacao
where nomea != 'pabllo vittar' and coda in (select coda
					    from gravacao
					    where codm in (select codm
							   from artista natural join gravacao
							   where nomea = 'pabllo vittar'))
group by coda, nomea
order by nome_artista 														   

-- 12) Compare
-- Para m??sicas gravadas com a Pabllo Vittar, o nome da m??sica, do artista parceiro, e o g??nero da m??sica

select distinct nomem as nome_musica, nomea as nome_artista, nomeg as nome_genero
from artista natural join gravacao natural join musica natural join genero
where nomea != 'pabllo vittar' and codm in (select codm
					    from gravacao natural join artista
					    where nomea = 'pabllo vittar')
order by nome_musica, nome_artista, nome_genero
