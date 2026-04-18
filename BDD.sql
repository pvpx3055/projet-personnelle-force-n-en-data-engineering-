IF NOT EXISTS (Select * from sys.database where name = "database_univ")
 CREATE DATABASE database_univ
GO
USE database_univ
IF NOT EXISTS (select * from sys.tables where name = "enseignant")
CREATE TABLE enseignant (
  id_enseignant PRIMARY KEY,
  nom VARCHAR(20)NOT NULL,
  prenom VARCHAR(20)NOT NULL,
  specialité varchar(20) NOT NULL,
  email VARCHAR(30) UNIQUE
  );
GO
IF NOT EXISTS (select * from sys.tables where ="filiere")
CREATE TABLE filiere (
  id_filiere PRIMARY KEY,
  libelle VARCHAR(20) NOT NULL
  );
GO
IF NOT EXISTS (select * from sys.tables where name = "niveau")
CREATE TABLE  niveau (
  id_niveau PRIMARY KEY ,
  libelle VARCHAR(20) NOT NULL
  );
GO
IF NOT EXISTS (select * from sys.table where name = "étudiant"
CREATE TABLE etudiant (
  id_etudiant PRIMARY KEY,
  nom VARCHAR (20) NOT NULL,
  prenom VARCHAR(20) NOT NULL,
  filiere INT,
  niveau INT
  );
GO
IF NOT EXISTS ( select * from sys.tables where name ="cours")
CREATE TABLE cours (
  id_cours PRIMARY KEY ,
  nom_cour VARCHAR(20) NOT NULL,
  professeur INT,
  coefficient INT,
  filiere INT,
  niveau INT 
);
GO
IF NOT EXISTS (select * from sys.tables where name = "note")
CREATE TABLE note (
  id_note PRIMARY KEY,
  id_etudiant INT,
  valeur INT,
  date DATE,
  type_eva 
  );
GO
