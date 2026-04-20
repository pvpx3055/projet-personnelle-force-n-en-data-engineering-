-- =============================================
-- BASE TRANSACTIONNELLE : database_univ
-- Projet : Système de Gestion des Notes
-- =============================================

-- Création de la base
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'database_univ')
    CREATE DATABASE database_univ;
GO

USE database_univ;
GO

-- =============================================
-- TABLES
-- =============================================

-- Niveaux (L1, L2, L3)
CREATE TABLE niveau (
    id_niveau INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL
);

-- Filières
CREATE TABLE filiere (
    id_filiere INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL
);

-- Enseignants
CREATE TABLE enseignant (
    id_enseignant INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE
);

-- Étudiants
CREATE TABLE etudiant (
    id_etudiant INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    filiere INT,
    CONSTRAINT fk_etudiant_filiere FOREIGN KEY (filiere) REFERENCES filiere(id_filiere) ON DELETE SET NULL
);

-- Inscriptions (historique des niveaux par année)
CREATE TABLE inscription (
    id_inscription INT IDENTITY(1,1) PRIMARY KEY,
    id_etudiant INT NOT NULL,
    id_niveau INT NOT NULL,
    annee_scolaire VARCHAR(9),
    date_debut DATE,
    date_fin DATE,
    CONSTRAINT fk_inscription_etudiant FOREIGN KEY (id_etudiant) REFERENCES etudiant(id_etudiant) ON DELETE CASCADE,
    CONSTRAINT fk_inscription_niveau FOREIGN KEY (id_niveau) REFERENCES niveau(id_niveau)
);

-- Cours
CREATE TABLE cours (
    id_cours INT IDENTITY(1,1) PRIMARY KEY,
    nom_cour VARCHAR(50) NOT NULL,
    professeur INT,
    coefficient INT,
    filiere INT,
    niveau INT,
    CONSTRAINT fk_cours_filiere FOREIGN KEY (filiere) REFERENCES filiere(id_filiere) ON DELETE CASCADE,
    CONSTRAINT fk_cours_niveau FOREIGN KEY (niveau) REFERENCES niveau(id_niveau) ON DELETE CASCADE,
    CONSTRAINT fk_cours_enseignant FOREIGN KEY (professeur) REFERENCES enseignant(id_enseignant) ON DELETE SET NULL
);

-- Notes
CREATE TABLE note (
    id_note INT IDENTITY(1,1) PRIMARY KEY,
    id_etudiant INT NOT NULL,
    id_cours INT NOT NULL,
    valeur DECIMAL(4,2),
    date DATE,
    type_evaluation VARCHAR(15),
    CONSTRAINT fk_note_etudiant FOREIGN KEY (id_etudiant) REFERENCES etudiant(id_etudiant) ON DELETE CASCADE,
    CONSTRAINT fk_note_cours FOREIGN KEY (id_cours) REFERENCES cours(id_cours) ON DELETE CASCADE,
    CONSTRAINT chk_note CHECK (valeur BETWEEN 0 AND 20),
    CONSTRAINT chk_evaluation CHECK (type_evaluation IN ('Devoir', 'Exam'))
);

-- =============================================
-- INSERTIONS DES DONNEES DE BASE
-- =============================================

-- Niveaux
INSERT INTO niveau (libelle) VALUES ('L1'), ('L2'), ('L3');

-- Filières
INSERT INTO filiere (libelle) VALUES ('Informatique'), ('Gestion'), ('Anglais');

-- Enseignants
INSERT INTO enseignant (nom, prenom, specialite, email) VALUES
('MARTIN', 'Jean', 'BDD', 'jean.martin@univ.fr'),
('DUPONT', 'Sophie', 'Algorithmique', 'sophie.dupont@univ.fr'),
('BERNARD', 'Pierre', 'Reseaux', 'pierre.bernard@univ.fr'),
('PETIT', 'Marie', 'Comptabilite', 'marie.petit@univ.fr'),
('DURAND', 'Philippe', 'Finance', 'philippe.durand@univ.fr'),
('ROBERT', 'Claire', 'Marketing', 'claire.robert@univ.fr'),
('MOREAU', 'Thomas', 'Linguistique', 'thomas.moreau@univ.fr'),
('SIMON', 'Laura', 'Litterature', 'laura.simon@univ.fr'),
('LAURENT', 'Nicolas', 'Civilisation', 'nicolas.laurent@univ.fr'),
('MICHEL', 'Julie', 'Anglais affaires', 'julie.michel@univ.fr');

-- Cours (45 cours : 5 par filiere × 3 niveaux)
INSERT INTO cours (nom_cour, professeur, coefficient, filiere, niveau) VALUES
-- Informatique (filiere=1)
('Algorithmique', 2, 5, 1, 1),
('Base de donnees', 1, 4, 1, 1),
('Programmation', 2, 3, 1, 1),
('Systemes', 3, 4, 1, 1),
('Mathematiques', 1, 3, 1, 1),
('Algorithmique avancee', 2, 5, 1, 2),
('BDD avancee', 1, 4, 1, 2),
('Programmation Web', 2, 3, 1, 2),
('Reseaux', 3, 4, 1, 2),
('Genie logiciel', 1, 4, 1, 2),
('Algorithmique L3', 2, 5, 1, 3),
('NoSQL', 1, 4, 1, 3),
('Architecture', 3, 3, 1, 3),
('Projet', 2, 5, 1, 3),
('Securite', 3, 4, 1, 3),
-- Gestion (filiere=2)
('Comptabilite generale', 4, 5, 2, 1),
('Finance', 5, 4, 2, 1),
('Economie', 4, 3, 2, 1),
('Droit', 6, 3, 2, 1),
('Management', 6, 4, 2, 1),
('Comptabilite analytique', 4, 5, 2, 2),
('Finance d entreprise', 5, 4, 2, 2),
('Marketing', 6, 3, 2, 2),
('RH', 4, 3, 2, 2),
('Controle gestion', 5, 4, 2, 2),
('Comptabilite L3', 4, 5, 2, 3),
('Finance L3', 5, 4, 2, 3),
('Audit', 5, 4, 2, 3),
('Strategie', 6, 4, 2, 3),
('Cas pratique', 4, 5, 2, 3),
-- Anglais (filiere=3)
('Grammaire', 7, 4, 3, 1),
('Litterature', 8, 3, 3, 1),
('Civilisation', 9, 3, 3, 1),
('Expression ecrite', 7, 3, 3, 1),
('Phonetique', 8, 3, 3, 1),
('Grammaire avancee', 7, 4, 3, 2),
('Litterature moderne', 8, 3, 3, 2),
('Civilisation GB', 9, 3, 3, 2),
('Anglais affaires', 10, 4, 3, 2),
('Traduction', 7, 4, 3, 2),
('Grammaire L3', 7, 4, 3, 3),
('Litterature L3', 8, 3, 3, 3),
('Civilisation L3', 9, 3, 3, 3),
('Anglais juridique', 10, 4, 3, 3),
('Memoire', 7, 5, 3, 3);
