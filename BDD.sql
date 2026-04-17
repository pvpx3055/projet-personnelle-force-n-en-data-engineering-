CREATE DATABASE gestion_université 

CREATE enseignant (
  id_enseignant PRIMARY KEY,
  nom VARCHAR(20),
  prenom VARCHAR(20),
  specialité varchar(20)
  );
CREATE filiere (
  id_filiere PRIMARY KEY,
  libelle VARCHAR(20)
  );
CREATE niveau (
  id_niveau PRIMARY KEY ,
  libelle VARCHAR(20)
  );
CREATE etudiant (
  id_etudiant PRIMARY KEY,
  nom VARCHAR (20),
  prenom VARCHAR(20),
  filiere INT,
  niveau INT
  );
CREATE TABLE cours (
  id_cours PRIMARY KEY ,
  nom_cour VARCHAR(20),
  type_eva VARCHAR(20),
  professeur INT,
  coefficient INT,
  filiere INT,
  niveau INT 
);
CREATE TABLE note (
  id_note PRIMARY KEY,
  id_etudiant INT,
  valeur INT,
  date DATE,
  type_eva 
  );
