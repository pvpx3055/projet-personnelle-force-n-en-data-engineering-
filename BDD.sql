IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'database_univ')
    CREATE DATABASE database_univ
GO
USE database_univ
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'enseignant')
CREATE TABLE enseignant (
  id_enseignant INT IDENTITY(1,1) PRIMARY KEY,
  nom VARCHAR(20) NOT NULL,
  prenom VARCHAR(20) NOT NULL,
  specialite VARCHAR(20) NOT NULL,
  email VARCHAR(30) UNIQUE
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'filiere')
CREATE TABLE filiere (
  id_filiere INT IDENTITY(1,1) PRIMARY KEY,
  libelle VARCHAR(20) NOT NULL
);
GO
-- Ajout de la table inscription
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inscription')
CREATE TABLE inscription (
    id_inscription INT IDENTITY(1,1) PRIMARY KEY,
    id_etudiant INT,
    id_niveau INT,
    annee_scolaire VARCHAR(9),
    date_debut DATE,
    date_fin DATE,
    CONSTRAINT fk_inscription_etudiant FOREIGN KEY (id_etudiant) REFERENCES etudiant(id_etudiant) ON DELETE CASCADE,
    CONSTRAINT fk_inscription_niveau FOREIGN KEY (id_niveau) REFERENCES niveau(id_niveau)
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'niveau')
CREATE TABLE niveau (
  id_niveau INT IDENTITY(1,1) PRIMARY KEY,
  libelle VARCHAR(20) NOT NULL
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'etudiant')
CREATE TABLE etudiant (
  id_etudiant INT IDENTITY(1,1) PRIMARY KEY,
  nom VARCHAR(20) NOT NULL,
  prenom VARCHAR(20) NOT NULL,
  filiere INT,
  niveau INT,
  CONSTRAINT fk_etudiant_filiere FOREIGN KEY (filiere) REFERENCES filiere(id_filiere) ON DELETE CASCADE,
  CONSTRAINT fk_etudiant_niveau FOREIGN KEY (niveau) REFERENCES niveau(id_niveau) ON DELETE CASCADE
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cours')
CREATE TABLE cours (
  id_cours INT IDENTITY(1,1) PRIMARY KEY,
  nom_cour VARCHAR(20) NOT NULL,
  professeur INT,
  coefficient INT,
  filiere INT,
  niveau INT,
  CONSTRAINT fk_cours_filiere FOREIGN KEY (filiere) REFERENCES filiere(id_filiere) ON DELETE CASCADE,
  CONSTRAINT fk_cours_niveau FOREIGN KEY (niveau) REFERENCES niveau(id_niveau) ON DELETE CASCADE,
  CONSTRAINT fk_cours_enseignant FOREIGN KEY (professeur) REFERENCES enseignant(id_enseignant) ON DELETE SET NULL
);
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'note')
CREATE TABLE note (
  id_note INT IDENTITY(1,1) PRIMARY KEY,
  id_etudiant INT,
  id_cours INT,
  valeur DECIMAL(4,2),
  date DATE,
  type_evaluation VARCHAR(15),
  CONSTRAINT fk_note_etudiant FOREIGN KEY (id_etudiant) REFERENCES etudiant(id_etudiant) ON DELETE CASCADE,
  CONSTRAINT fk_note_cours FOREIGN KEY (id_cours) REFERENCES cours(id_cours) ON DELETE CASCADE,
  CONSTRAINT chk_note CHECK (valeur BETWEEN 0 AND 20),
  CONSTRAINT chk_evaluation CHECK (type_evaluation IN ('Devoir', 'Exam'))
);
GO
