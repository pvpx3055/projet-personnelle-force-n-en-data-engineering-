# DOCUMENTATION COMPLÈTE DU PROJET

## Système de Gestion des Notes des Étudiants

---

# PARTIE 1 : BASE TRANSACTIONNELLE (database_univ)

## Script : `01_create_database_univ.sql`

### Objectif général
Créer une base de données transactionnelle (OLTP) pour gérer les opérations quotidiennes : inscription des étudiants, saisie des notes, gestion des cours.

### Pourquoi une base transactionnelle ?
- Permet les opérations CRUD quotidiennes (CREATE, READ, UPDATE, DELETE)
- Garantit l'intégrité des données via des clés étrangères
- Optimisée pour les écritures fréquentes

---

## Détail des tables

### 1. Table `niveau`

```sql
CREATE TABLE niveau (
    id_niveau INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL
);
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_niveau | INT IDENTITY | Clé primaire, auto-incrémentée |
| libelle | VARCHAR(20) | Nom du niveau (L1, L2, L3) |

**Pourquoi ?** Un étudiant progresse du L1 au L3. Cette table permet de suivre son niveau.

**Contraintes :**
- `PRIMARY KEY` : identifiant unique
- `IDENTITY` : auto-incrémentation (1,2,3...)

---

### 2. Table `filiere`

```sql
CREATE TABLE filiere (
    id_filiere INT IDENTITY(1,1) PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL
);
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_filiere | INT IDENTITY | Clé primaire |
| libelle | VARCHAR(20) | Nom de la filière |

**Pourquoi ?** Les étudiants appartiennent à des filières différentes (Informatique, Gestion, Anglais). Chaque filière a ses propres cours.

---

### 3. Table `enseignant`

```sql
CREATE TABLE enseignant (
    id_enseignant INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE
);
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_enseignant | INT IDENTITY | Clé primaire |
| nom | VARCHAR(20) | Nom de famille |
| prenom | VARCHAR(20) | Prénom |
| specialite | VARCHAR(20) | Domaine d'expertise |
| email | VARCHAR(30) | Email professionnel, unique |

**Pourquoi ?** Chaque cours est enseigné par un professeur. La contrainte `UNIQUE` sur l'email évite les doublons.

---

### 4. Table `etudiant`

```sql
CREATE TABLE etudiant (
    id_etudiant INT IDENTITY(1,1) PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    filiere INT,
    CONSTRAINT fk_etudiant_filiere FOREIGN KEY (filiere) REFERENCES filiere(id_filiere) ON DELETE SET NULL
);
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_etudiant | INT IDENTITY | Clé primaire |
| nom | VARCHAR(20) | Nom de famille |
| prenom | VARCHAR(20) | Prénom |
| filiere | INT | Clé étrangère vers filiere |

**Pourquoi `ON DELETE SET NULL` ?** Si une filière est supprimée, l'étudiant reste mais sa filière devient NULL (on ne perd pas l'étudiant).

---

### 5. Table `inscription`

```sql
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
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_inscription | INT IDENTITY | Clé primaire |
| id_etudiant | INT | Référence vers l'étudiant |
| id_niveau | INT | Niveau suivi cette année |
| annee_scolaire | VARCHAR(9) | Ex: '2021-2022' |
| date_debut | DATE | Début de l'année (1er septembre) |
| date_fin | DATE | Fin de l'année (30 juin) |

**Pourquoi cette table ?** Un étudiant change de niveau chaque année. Cette table garde l'historique :
- L'étudiant 1 était en L1 en 2021-2022
- Puis en L2 en 2022-2023
- Puis en L3 en 2023-2024

**Pourquoi `ON DELETE CASCADE` ?** Si on supprime un étudiant, ses inscriptions sont automatiquement supprimées.

---

### 6. Table `cours`

```sql
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
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_cours | INT IDENTITY | Clé primaire |
| nom_cour | VARCHAR(50) | Nom du cours |
| professeur | INT | Référence vers enseignant |
| coefficient | INT | Poids du cours dans la moyenne |
| filiere | INT | Filière concernée |
| niveau | INT | Niveau concerné |

**Pourquoi `ON DELETE SET NULL` sur professeur ?** Si un enseignant quitte l'université, ses cours restent mais sans professeur assigné.

**Pourquoi un cours a une filière ET un niveau ?** Un cours de "Algorithmique" n'est pas le même en L1 et en L3. Cette combinaison (filière, niveau) identifie un cours unique.

---

### 7. Table `note`

```sql
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
```

| Colonne | Type | Rôle |
|---------|------|------|
| id_note | INT IDENTITY | Clé primaire |
| id_etudiant | INT | Qui a eu la note |
| id_cours | INT | Dans quel cours |
| valeur | DECIMAL(4,2) | Note sur 20 |
| date | DATE | Date de l'évaluation |
| type_evaluation | VARCHAR(15) | 'Devoir' ou 'Exam' |

**Pourquoi les contraintes CHECK ?**
- `valeur BETWEEN 0 AND 20` : une note ne peut pas dépasser 20
- `type_evaluation IN ('Devoir','Exam')` : seulement ces deux types

---

# PARTIE 2 : DATA WAREHOUSE (DW_Univ)

## Script : `02_create_dw_univ.sql`

### Objectif général
Créer un Data Warehouse en schéma étoile pour l'analyse des données.

### Pourquoi un schéma étoile ?
- Optimisé pour les lectures (SELECT)
- Requêtes plus simples et plus rapides
- Idéal pour Power BI / Tableau

### Différence avec la base transactionnelle

| Critère | Transactionnelle (OLTP) | Data Warehouse (OLAP) |
|---------|-------------------------|----------------------|
| Objectif | Écrire (INSERT/UPDATE) | Lire (SELECT/analyse) |
| Structure | Normalisée (3NF) | Schéma étoile |
| Clés étrangères | Beaucoup | Aucune (sauf PK) |
| Historique | Non conservé | Conservé |

---

## Détail des tables

### 1. `dim_etudiant` (Dimension)

```sql
CREATE TABLE dim_etudiant (
    id_etudiant_dim INT PRIMARY KEY,
    nom VARCHAR(20),
    prenom VARCHAR(20)
);
```

**Rôle :** Décrire les étudiants. Contient les attributs qui ne changent pas (ou rarement).

**Pourquoi pas de clé étrangère ?** En DW, les dimensions sont indépendantes. Les jointures se font par les valeurs, pas par des contraintes.

---

### 2. `dim_filiere` (Dimension)

```sql
CREATE TABLE dim_filiere (
    id_filiere_dim INT PRIMARY KEY,
    libelle VARCHAR(20)
);
```

**Rôle :** Décrire les filières.

---

### 3. `dim_niveau` (Dimension)

```sql
CREATE TABLE dim_niveau (
    id_niveau_dim INT PRIMARY KEY,
    libelle VARCHAR(20)
);
```

**Rôle :** Décrire les niveaux (L1, L2, L3).

---

### 4. `dim_cours` (Dimension)

```sql
CREATE TABLE dim_cours (
    id_cours_dim INT PRIMARY KEY,
    nom_cour VARCHAR(50),
    coefficient INT
);
```

**Rôle :** Décrire les cours et leur coefficient pour calculer les moyennes pondérées.

---

### 5. `dim_enseignant` (Dimension)

```sql
CREATE TABLE dim_enseignant (
    id_enseignant_dim INT PRIMARY KEY,
    nom VARCHAR(20),
    prenom VARCHAR(20)
);
```

**Rôle :** Décrire les enseignants.

---

### 6. `dim_temps` (Dimension)

```sql
CREATE TABLE dim_temps (
    id_temps INT PRIMARY KEY,
    annee INT,
    mois INT,
    semestre INT
);
```

**Rôle :** Décrire le temps. Permet les analyses temporelles :
- "Moyenne par année"
- "Moyenne par semestre"

**Pourquoi `id_temps` format AAAAMM ?** Exemple : 202109 = septembre 2021. Facile à calculer et à trier.

---

### 7. `fait_note` (Table de faits)

```sql
CREATE TABLE fait_note (
    id_fait_note INT IDENTITY(1,1) PRIMARY KEY,
    id_etudiant_dim INT,
    id_cours_dim INT,
    id_filiere_dim INT,
    id_niveau_dim INT,
    id_enseignant_dim INT,
    id_temps_dim INT,
    valeur_note DECIMAL(4,2),
    type_evaluation VARCHAR(15)
);
```

**Rôle :** Contient les mesures (les notes) et les clés vers les dimensions.

**Pourquoi pas de clés étrangères ?**
- Les DW sont optimisés pour les lectures rapides
- Les contraintes FK ralentissent les INSERT en masse
- L'ETL garantit l'intégrité

**Pourquoi `IDENTITY` sur id_fait_note ?** Chaque note a un identifiant unique.

---

# PARTIE 3 : ETL (Chargement du DW)

## Script : `03_etl_load_dw.sql`

### Objectif général
Transférer les données de la base transactionnelle vers le Data Warehouse.

### Processus ETL (Extract, Transform, Load)

```
Extract (Extraire)    →   Transform (Transformer)   →   Load (Charger)
─────────────────         ────────────────────         ─────────────
Lire les données          Calculer id_temps            Écrire dans
dans database_univ        à partir de date             DW_Univ
```

---

### Étape 1 : Chargement des dimensions

```sql
TRUNCATE TABLE dim_etudiant;
INSERT INTO dim_etudiant (id_etudiant_dim, nom, prenom)
SELECT id_etudiant, nom, prenom FROM database_univ.dbo.etudiant;
```

**Pourquoi `TRUNCATE` ?** Vide la table avant de la remplir (plus rapide que DELETE).

**Pourquoi copie directe ?** Les ID sont identiques entre source et destination.

---

### Étape 2 : Génération de dim_temps

```sql
INSERT INTO dim_temps (id_temps, annee, mois, semestre) VALUES
(202109, 2021, 9, 1),
...
```

**Pourquoi générer et ne pas importer ?** La dimension temps n'existe pas dans la source. On la crée manuellement car elle est universelle (tous les projets DW utilisent un calendrier).

**Règle des semestres :**
- Semestre 1 = septembre à décembre (mois 9-12)
- Semestre 2 = janvier à juin (mois 1-6)

---

### Étape 3 : Chargement de fait_note (la plus complexe)

```sql
INSERT INTO fait_note (...)
SELECT 
    n.id_etudiant,                                    -- Direct
    n.id_cours,                                       -- Direct
    e.filiere,                                        -- Direct
    i.id_niveau,                                      -- Via jointure avec inscription
    c.professeur,                                     -- Direct
    YEAR(n.date) * 100 + MONTH(n.date),              -- Transformé !
    n.valeur,                                         -- Direct
    n.type_evaluation                                 -- Direct
FROM database_univ.dbo.note n
JOIN database_univ.dbo.etudiant e ON n.id_etudiant = e.id_etudiant
JOIN database_univ.dbo.inscription i ON i.id_etudiant = e.id_etudiant 
    AND n.date BETWEEN i.date_debut AND i.date_fin    -- Jointure sur intervalle
JOIN database_univ.dbo.cours c ON n.id_cours = c.id_cours;
```

**Pourquoi 3 jointures ?**

| Jointure | Rôle |
|----------|------|
| `note JOIN etudiant` | Récupérer la filière de l'étudiant |
| `note JOIN inscription` | Trouver le niveau au moment de la note |
| `note JOIN cours` | Récupérer le professeur du cours |

**Pourquoi la jointure sur inscription avec `BETWEEN` ?**
Une note du 15/01/2022 doit trouver l'inscription où cette date est entre date_debut et date_fin. Cela donne le bon niveau (L2).

**Pourquoi `YEAR(date) * 100 + MONTH(date)` ?**
Transforme '2022-01-15' en 202201 (id_temps). Simple, rapide, et correspond à dim_temps.id_temps.

---

# PARTIE 4 : ANALYSES

## Script : `04_queries_analysis.sql`

### Objectif
Répondre aux questions du cahier des charges.

---

### Analyse 1 : Moyenne par étudiant

```sql
SELECT e.nom, e.prenom, AVG(f.valeur_note) as moyenne
FROM fait_note f
JOIN dim_etudiant e ON f.id_etudiant_dim = e.id_etudiant_dim
GROUP BY e.nom, e.prenom;
```

**Pourquoi cette jointure ?** La table fait contient des ID, pas les noms. Il faut aller chercher le nom dans la dimension.

---

### Analyse 2 : Moyenne par filière

```sql
SELECT fi.libelle, AVG(f.valeur_note) as moyenne
FROM fait_note f
JOIN dim_filiere fi ON f.id_filiere_dim = fi.id_filiere_dim
GROUP BY fi.libelle;
```

**Utilité :** Comparer les performances entre Informatique, Gestion et Anglais.

---

### Analyse 3 : Évolution par semestre

```sql
SELECT t.annee, t.semestre, AVG(f.valeur_note) as moyenne
FROM fait_note f
JOIN dim_temps t ON f.id_temps_dim = t.id_temps
GROUP BY t.annee, t.semestre
ORDER BY t.annee, t.semestre;
```

**Utilité :** Voir si les notes s'améliorent au fil du temps.

---

### Analyse 4 : Meilleurs et pires cours

```sql
SELECT c.nom_cour, AVG(f.valeur_note) as moyenne
FROM fait_note f
JOIN dim_cours c ON f.id_cours_dim = c.id_cours_dim
GROUP BY c.nom_cour
ORDER BY moyenne DESC;
```

**Utilité :** Identifier les cours où les étudiants réussissent le mieux.

---

### Analyse 5 : Comparaison Devoir vs Examen

```sql
SELECT type_evaluation, AVG(valeur_note) as moyenne
FROM fait_note
GROUP BY type_evaluation;
```

**Utilité :** Vérifier si les examens sont plus difficiles que les devoirs.

---

# SCHÉMA GLOBAL

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BASE TRANSACTIONNELLE                              │
│                              (database_univ)                                 │
│                                                                              │
│  ┌──────────┐    ┌──────────┐    ┌────────────┐    ┌──────────┐            │
│  │ niveau   │    │ filiere  │    │ enseignant │    │ etudiant │            │
│  └────┬─────┘    └────┬─────┘    └─────┬──────┘    └────┬─────┘            │
│       │               │                │                │                   │
│       ▼               ▼                ▼                ▼                   │
│  ┌────────────────────────────────────────────────────────────────┐         │
│  │                         inscription                              │         │
│  └────────────────────────────────────────────────────────────────┘         │
│       │                                                                    │
│       ▼                                                                    │
│  ┌──────────┐    ┌──────────────────────────────────────────────────┐     │
│  │  cours   │────│                       note                        │     │
│  └──────────┘    └──────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ ETL (SSIS ou SQL)
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             DATA WAREHOUSE                                   │
│                                (DW_Univ)                                     │
│                                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │ dim_etudiant │    │ dim_filiere  │    │ dim_niveau   │                  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘                  │
│         │                   │                   │                           │
│         └───────────────────┼───────────────────┘                           │
│                             │                                               │
│                             ▼                                               │
│                    ┌─────────────────┐                                      │
│                    │    fait_note    │                                      │
│                    └─────────────────┘                                      │
│                             │                                               │
│         ┌───────────────────┼───────────────────┐                          │
│         │                   │                   │                           │
│         ▼                   ▼                   ▼                           │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │  dim_cours   │    │dim_enseignant│    │  dim_temps   │                  │
│  └──────────────┘    └──────────────┘    └──────────────┘                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ Power BI / Tableau
                                      ▼
                              ┌─────────────────┐
                              │    DASHBOARD    │
                              └─────────────────┘
```

---

# RÉCAPITULATIF DES FICHIERS

| Fichier | Contenu | À exécuter |
|---------|---------|------------|
| `01_create_database_univ.sql` | Création de la base transactionnelle | Une fois |
| `02_create_dw_univ.sql` | Création du Data Warehouse | Une fois |
| `03_etl_load_dw.sql` | Chargement des données (ETL) | Après génération des données |
| `04_queries_analysis.sql` | Requêtes d'analyse | Après chargement du DW |

---

# QUESTIONS FRÉQUENTES

**Pourquoi ne pas avoir mis de clés étrangères dans le DW ?**
Les clés étrangères ralentissent les INSERT en masse. L'ETL garantit l'intégrité.

**Pourquoi dim_temps est générée manuellement ?**
Le temps est universel. Il n'y a pas de table "temps" dans la source.

**Pourquoi la table inscription n'est pas dans le DW ?**
Son information (niveau) est déjà stockée dans fait_note. La jointure pendant l'ETL suffit.

**Pourquoi garder les mêmes ID entre source et DW ?**
Pour simplifier l'ETL. Pas besoin de Lookups dans SSIS.

---

