IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DW_Univ')
    CREATE DATABASE DW_Univ
GO
USE DW_Univ
GO
CREATE TABLE dim_etudiant (
    id_etudiant_dim INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20),
    prenom VARCHAR(20));
CREATE TABLE dim_filiere (
    id_filiere_dim INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20)
);

CREATE TABLE dim_niveau (
    id_niveau_dim INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20)
);
CREATE TABLE dim_cours (
    id_cours_dim INT IDENTITY(1,1) PRIMARY KEY,
    nom_cour VARCHAR(20),
    coefficient INT
);
CREATE TABLE dim_enseignant (
    id_enseignant_dim INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20),
    prenom VARCHAR(20)
);
CREATE TABLE dim_temps (
    id_temps_dim INT PRIMARY KEY,
    annee INT,
    mois INT,
    semestre INT
);
CREATE TABLE fait_note (
    id_note_fait INT IDENTITY(1,1) PRIMARY KEY,
    id_etudiant_dim INT,
    id_cours_dim INT,
    id_filiere_dim INT,
    id_niveau_dim INT,
    id_enseignant_dim INT,
    id_temps_dim INT,
    valeur_note DECIMAL(4,2),
    type_evaluation VARCHAR(15)
);
