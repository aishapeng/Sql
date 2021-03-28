/* drop tables in case exist already */
drop table author cascade constraints purge;
drop table publication cascade constraints purge;
drop table wrote cascade constraints purge;
drop table proceedings cascade constraints purge;
drop table journal cascade constraints purge;
drop table book cascade constraints purge;
drop table article cascade constraints purge;


/* create the base tables */
create table author ( 
    aid         integer not null, 
    name        varchar2(22) not null, 
    url         char(42), 
    primary key (aid) );

create table publication ( 
    pubid       char(10) not null, 
    title       char(70) not null, 
    primary key (pubid) );

create table wrote ( 
    aid         integer not null, 
    pubid       char(10) not null, 
    aorder      integer not null, 
    primary key (aid, pubid), 
    foreign key (aid) references author (aid), 
    foreign key (pubid) references publication (pubid) );

create table proceedings ( 
    pubid       char(10) not null, 
    year        integer not null, 
    primary key (pubid), 
    foreign key (pubid) references publication (pubid) );

create table journal ( 
    pubid       char(10) not null, 
    volume      integer not null, 
    num         integer not null, 
    year        integer not null, 
    primary key (pubid), 
    foreign key (pubid) references publication (pubid) );

create table book ( 
    pubid       char(10) not null, 
    publisher   char(50) not null, 
    year        integer not null, 
    primary key (pubid), 
    foreign key (pubid) references publication (pubid) );

create table article ( 
    pubid       char(10) not null, 
    appearsin   char(10) not null, 
    startpage   integer not null, 
    endpage     integer not null, 
    primary key (pubid), 
    foreign key (pubid) references publication (pubid), 
    foreign key (appearsin) references publication (pubid) );


/* Load sample data*/

INSERT INTO  author (aid, name) VALUES (1, 	'Ajit_A._Diwan');
INSERT INTO  author (aid, name) VALUES (2, 	'Ch._Sobhan Babu');
INSERT INTO  author (aid, name) VALUES (34,	'Ben_Chin_Ooi');
INSERT INTO  author (aid, name) VALUES (3, 	'Daniel_Deutch');
INSERT INTO  author (aid, name) VALUES (4, 	'David_DeHaan');
INSERT INTO  author (aid, name) VALUES (5, 	'Dongyan_Zhao');
INSERT INTO  author (aid, name) VALUES (31, 	'Gang_Chen');
INSERT INTO  author (aid, name) VALUES (6, 	'Goetz_Graefe');
INSERT INTO  author (aid, name) VALUES (7, 	'Gunes_Aluc');
INSERT INTO  author (aid, name) VALUES (8, 	'Gustavo_Alonso');
INSERT INTO  author (aid, name) VALUES (9, 	'Harumi_A._Kuno');
INSERT INTO  author (aid, name) VALUES (32,	'Hoang_Tam_Vo');
INSERT INTO  author (aid, name) VALUES (10, 'Ivan_T._Bowman');
INSERT INTO  author (aid, name) VALUES (11, 'Jens_Teubner');
INSERT INTO  author (aid, name) VALUES (12, 'Jinghui_Mo');
INSERT INTO  author (aid, name) VALUES (13, 'K._Georgoulas');
INSERT INTO  author (aid, name) VALUES (14, 'Lei_Chen');
INSERT INTO  author (aid, name) VALUES (15, 'Lei_Zou');
INSERT INTO  author (aid, name) VALUES (16, 'M._Tamer_Ozsu');
INSERT INTO  author (aid, name) VALUES (17, 'Markus_Kirchberg');
INSERT INTO  author (aid, name) VALUES (18, 'Muhammad_A._Cheema');
INSERT INTO  author (aid, name) VALUES (19, 'Patrick_Valduriez');
INSERT INTO  author (aid, name) VALUES (20, 'R._Guravannavar');
INSERT INTO  author (aid, name) VALUES (21, 'Rene_Muller');
INSERT INTO  author (aid, name) VALUES (33,	'Sai_Wu');
INSERT INTO  author (aid, name) VALUES (22, 'S._Sudarshan');
INSERT INTO  author (aid, name) VALUES (23, 'Sebastian_Link');
INSERT INTO  author (aid, name) VALUES (24, 'Sven_Hartmann');
INSERT INTO  author (aid, name) VALUES (25, 'Tova_Milo');
INSERT INTO  author (aid, name) VALUES (26, 'Wenjie_Zhang');
INSERT INTO  author (aid, name) VALUES (27, 'Xuefei_Li');
INSERT INTO  author (aid, name) VALUES (28, 'Xuemin_Lin');
INSERT INTO  author (aid, name) VALUES (29, 'Yannis_Kotidis');
INSERT INTO  author (aid, name) VALUES (30, 'Ying_Zhang');
INSERT INTO  author (aid, name) VALUES (35,	'Yingying_Tao');


INSERT INTO  publication (pubid, title) VALUES 
	  ('MullerTA12', 'Sorting networks on FPGAs');
	  
INSERT INTO  publication (pubid, title) VALUES 
	  ('GeorgouK12', 	'Distributed similarity estimation using derived dimensions');

INSERT INTO  publication (pubid, title) VALUES 	
	  ('DeutchM12',	'Type inference and type checking for queries over execution traces');
	  
INSERT INTO  publication (pubid, title) VALUES 
	  ('CheeZLZL12',	'Continuous reverse k nearest neighbors queries in Euclidean space...');
	  
INSERT INTO  publication (pubid, title) VALUES 	
	  ('ZouCOZ12', 	'Answering pattern match queries in large graph databases via graph...');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('HartmaKL12', 	'Design by example for SQL table definitions with functional...');

INSERT INTO  publication (pubid, title) VALUES 
	  ('GuravSDB12', 	'Which sort orders are interesting');
	  
INSERT INTO  publication (pubid, title) VALUES 
  	  ('AlucDB12', 	'Parametric plan caching using density-based clustering');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('Graefe11',	'Robust query processing');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('GraefeK11',	'Modern B-tree techniques');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('ZouMCOZ11',	'gStore: Answering SPARQL Queries via Subgraph Matching');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('CheVWOO11',	'A Framework for Supporting DBMS-like Indexes in the Cloud');
	  
INSERT INTO  publication (pubid, title) VALUES 	  
	  ('TaoO09a', 	'Mining frequent itemsets in time-varying data streams');
	  
INSERT INTO  publication (pubid, title) VALUES ('VLDBJ21_1', 	'VLDB Journal');

INSERT INTO  publication (pubid, title) VALUES ('PVLDB4_8', 	'Proceedings of the VLDB Endowment');

INSERT INTO  publication (pubid, title) VALUES ('PVLDB4_11',	'Proceedings of the VLDB Endowment');

INSERT INTO  publication (pubid, title) VALUES ('ICDE2011', 	'Proc. IEEE 28th International Conference on Data Engineering');
	  
INSERT INTO  publication (pubid, title) VALUES ('ICDE2012', 	'Proc. IEEE 29th International Conference on Data Engineering');

INSERT INTO  publication (pubid, title) VALUES ('CIKM2009', 	'Proc. 18th ACM Conference on Information and Knowledge Management');

INSERT INTO  publication (pubid, title) VALUES ('0029498', 	'Principles of Distributed Database Systems, Third Edition');

  
INSERT INTO  wrote (aid, pubid, aorder) VALUES (7, 'AlucDB12', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (4, 'AlucDB12', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (10, 'AlucDB12', 3);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (6, 'Graefe11', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (6, 'GraefeK11', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (9, 'GraefeK11', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (15, 'ZouMCOZ11', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (12, 'ZouMCOZ11', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES  (14, 'ZouMCOZ11', 3);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (16, 'ZouMCOZ11', 4); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (5, 'ZouMCOZ11', 5);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (21, 'MullerTA12', 1); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (11, 'MullerTA12', 2); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (8, 'MullerTA12', 3);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (13, 'GeorgouK12', 1); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (29, 'GeorgouK12', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (3, 'DeutchM12', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (25, 'DeutchM12', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (18, 'CheeZLZL12', 1); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (26, 'CheeZLZL12', 2); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (28, 'CheeZLZL12', 3); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (30, 'CheeZLZL12', 4); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (27, 'CheeZLZL12', 5);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (15, 'ZouCOZ12', 1); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (14, 'ZouCOZ12', 2); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (16, 'ZouCOZ12', 3); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (5, 'ZouCOZ12', 4);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (24, 'HartmaKL12', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (17, 'HartmaKL12', 2); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (23, 'HartmaKL12', 3);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (20, 'GuravSDB12', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (22, 'GuravSDB12', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (1, 'GuravSDB12', 3); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (2, 'GuravSDB12', 4);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (31, 'CheVWOO11', 1); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (32, 'CheVWOO11', 2); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (33, 'CheVWOO11', 3);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (34, 'CheVWOO11', 4); 
INSERT INTO  wrote (aid, pubid, aorder) VALUES (16, 'CheVWOO11', 5);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (35, 'TaoO09a', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (16, 'TaoO09a', 2);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (16, '0029498', 1);
INSERT INTO  wrote (aid, pubid, aorder) VALUES (19, '0029498', 2);


INSERT INTO  journal (pubid, volume, num, year) VALUES ('VLDBJ21_1', 21, 1, 2012); 
INSERT INTO  journal (pubid, volume, num, year) VALUES ('PVLDB4_8', 4, 8, 2011);
INSERT INTO  journal (pubid, volume, num, year) VALUES('PVLDB4_11', 4, 11, 2011);

INSERT INTO  proceedings (pubid, year) VALUES ('ICDE2011', 2011); 
INSERT INTO  proceedings (pubid, year) VALUES ('ICDE2012', 2012);
INSERT INTO  proceedings (pubid, year) VALUES('CIKM2009', 2009);

INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES  
('MullerTA12', 'VLDBJ21_1', 1, 23) ;
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES
('GeorgouK12', 'VLDBJ21_1', 25, 50);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('DeutchM12', 'VLDBJ21_1', 51, 68);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('CheeZLZL12', 'VLDBJ21_1', 69, 95);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('ZouCOZ12', 'VLDBJ21_1', 97, 120);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('HartmaKL12', 'VLDBJ21_1', 121, 144);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('GuravSDB12', 'VLDBJ21_1', 145, 165);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('AlucDB12', 'ICDE2012', 402, 413);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('Graefe11', 'ICDE2011', 1361, 1361);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('GraefeK11', 'ICDE2011', 1370, 1373);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('ZouMCOZ11', 'PVLDB4_8', 482, 493);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('CheVWOO11', 'PVLDB4_11', 702, 713);
INSERT INTO  article (pubid, appearsin, startpage, endpage) VALUES	
('TaoO09a', 'CIKM2009', 1521, 1524);


INSERT INTO  book (pubid, publisher, year) VALUES  ('0029498', 'Springer', 2011);

COMMIT;
