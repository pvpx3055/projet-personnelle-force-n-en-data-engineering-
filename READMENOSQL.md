# README - BASE DE DONNÉES NoSQL (MongoDB)

## Projet : Système de Gestion des Notes des Étudiants

---

## DESCRIPTION

Ce projet implémente une base de données **NoSQL** avec MongoDB pour la gestion des notes des étudiants. Elle vient en complément de la base de données relationnelle SQL Server.

### Objectif

- Stocker les données des étudiants et leurs notes dans une structure **dénormalisée** (documents imbriqués)
- Permettre des analyses rapides sur les notes (moyennes, répartitions, tendances)
- Comparer l'approche NoSQL avec l'approche SQL du même projet

---

## TECHNOLOGIES

| Technologie | Version |
|-------------|---------|
| MongoDB | 5.0+ |
| MongoDB Compass | (recommandé pour l'interface graphique) |
| Langage | JavaScript (MongoDB Shell) |

---

## STRUCTURE DE LA BASE

### Base de données : `db_univ_nosql`

### Collections (2)

| Collection | Rôle | Nombre de documents |
|------------|------|---------------------|
| `cours` | Liste des cours enseignés | 15 |
| `etudiants` | Étudiants et leurs notes | 30 |

---

## STRUCTURE D'UN DOCUMENT `cours`

```json
{
    "nom": "Algorithmique",
    "coefficient": 5,
    "enseignant": "DUPONT Sophie",
    "filiere": "Informatique",
    "niveau": "L1"
}
```

| Champ | Type | Description |
|-------|------|-------------|
| `nom` | String | Nom du cours |
| `coefficient` | Number | Poids du cours dans la moyenne (2 à 5) |
| `enseignant` | String | Nom et prénom du professeur |
| `filiere` | String | Filière concernée (Informatique/Gestion/Anglais) |
| `niveau` | String | Niveau du cours (L1/L2/L3) |

---

## STRUCTURE D'UN DOCUMENT `etudiants`

```json
{
    "nom": "Dupont",
    "prenom": "Jean",
    "filiere": "Informatique",
    "historique_niveaux": [
        {
            "annee_scolaire": "2021-2022",
            "niveau": "L1",
            "date_debut": "2021-09-01",
            "date_fin": "2022-06-30"
        },
        {
            "annee_scolaire": "2022-2023",
            "niveau": "L2",
            "date_debut": "2022-09-01",
            "date_fin": "2023-06-30"
        },
        {
            "annee_scolaire": "2023-2024",
            "niveau": "L3",
            "date_debut": "2023-09-01",
            "date_fin": "2024-06-30"
        }
    ],
    "notes": [
        {
            "cours": "Algorithmique",
            "coefficient": 5,
            "enseignant": "DUPONT Sophie",
            "valeur": 15.5,
            "date": "2021-10-15",
            "type_evaluation": "Devoir",
            "semestre": 1,
            "annee_scolaire": "2021-2022",
            "niveau": "L1"
        }
    ]
}
```

### Champs de `notes`

| Champ | Type | Description |
|-------|------|-------------|
| `cours` | String | Nom du cours |
| `coefficient` | Number | Coefficient du cours |
| `enseignant` | String | Professeur ayant donné le cours |
| `valeur` | Number | Note sur 20 (0-20) |
| `date` | String (ISO date) | Date de l'évaluation |
| `type_evaluation` | String | "Devoir" ou "Exam" |
| `semestre` | Number | 1 (sept-déc) ou 2 (janv-juin) |
| `annee_scolaire` | String | Année scolaire (ex: "2021-2022") |
| `niveau` | String | Niveau au moment de la note (L1/L2/L3) |

---

## VOLUMES DE DONNÉES

| Élément | Nombre |
|---------|--------|
| Cours | 15 |
| Étudiants | 30 |
| Filières | 3 (Informatique, Gestion, Anglais) |
| Niveaux | 3 (L1, L2, L3) |
| Années scolaires | 3 (2021-2022, 2022-2023, 2023-2024) |
| Notes par étudiant | ~120 (40 par année) |
| **Total notes** | **~1 200** |

---

## DIFFÉRENCE AVEC LA VERSION SQL

| Critère | SQL Server | MongoDB |
|---------|------------|---------|
| Structure | 7 tables normalisées | 2 collections dénormalisées |
| Relations | Clés étrangères | Données imbriquées |
| Jointures | Oui (plusieurs tables) | Non (tout est dans le document) |
| Performance écriture | Rapide (normalisé) | Plus lent (duplication) |
| Performance lecture | Plus lent (jointures) | Rapide (pas de jointures) |
| Lecture d'un étudiant | 4-5 tables jointes | 1 seul document |

---

## PRINCIPALES REQUÊTES D'ANALYSE

### 1. Moyenne par étudiant

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: { nom: "$nom", prenom: "$prenom" }, moyenne: { $avg: "$notes.valeur" } } },
    { $sort: { moyenne: -1 } }
]);
```

### 2. Moyenne par filière

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: "$filiere", moyenne: { $avg: "$notes.valeur" } } }
]);
```

### 3. Moyenne par niveau (L1/L2/L3)

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: "$notes.niveau", moyenne: { $avg: "$notes.valeur" } } },
    { $sort: { "_id": 1 } }
]);
```

### 4. Meilleurs cours

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: "$notes.cours", moyenne: { $avg: "$notes.valeur" } } },
    { $sort: { moyenne: -1 } },
    { $limit: 5 }
]);
```

### 5. Comparaison Devoir vs Examen

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: "$notes.type_evaluation", moyenne: { $avg: "$notes.valeur" } } }
]);
```

### 6. Évolution par année scolaire

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: "$notes.annee_scolaire", moyenne: { $avg: "$notes.valeur" } } },
    { $sort: { "_id": 1 } }
]);
```

### 7. Top 10 des meilleurs étudiants

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { _id: { nom: "$nom", prenom: "$prenom", filiere: "$filiere" }, moyenne: { $avg: "$notes.valeur" } } },
    { $sort: { moyenne: -1 } },
    { $limit: 10 }
]);
```

### 8. Répartition des notes par tranche

```javascript
db.etudiants.aggregate([
    { $unwind: "$notes" },
    { $group: { 
        _id: {
            $switch: {
                branches: [
                    { case: { $lt: ["$notes.valeur", 10] }, then: "0-10 (Échec)" },
                    { case: { $lt: ["$notes.valeur", 12] }, then: "10-12 (Passable)" },
                    { case: { $lt: ["$notes.valeur", 14] }, then: "12-14 (Assez bien)" },
                    { case: { $lt: ["$notes.valeur", 16] }, then: "14-16 (Bien)" },
                    { case: { $lt: ["$notes.valeur", 18] }, then: "16-18 (Très bien)" }
                ],
                default: "18-20 (Excellent)"
            }
        },
        count: { $sum: 1 }
    } },
    { $sort: { "_id": 1 } }
]);
```

---

## COMMENT EXÉCUTER LE SCRIPT

### Via MongoDB Compass

1. Ouvrir MongoDB Compass
2. Se connecter à `mongodb://localhost:27017` (par défaut)
3. Cliquer sur `Create Database`
4. Ouvrir l'onglet `mongosh` (en bas)
5. Copier-coller le script complet
6. Exécuter (Entrée)

### Via mongosh (terminal)

```bash
mongosh
use db_univ_nosql
load("script_mongodb.js")  # ou copier-coller le script
```

---

## VÉRIFICATION DE L'INSTALLATION

Une fois le script exécuté, vérifier :

```javascript
// Nombre d'étudiants
db.etudiants.countDocuments();  // Doit afficher 30

// Nombre de cours
db.cours.countDocuments();  // Doit afficher 15

// Total des notes
let total = 0;
db.etudiants.find().forEach(e => { total += e.notes.length; });
print(total);  // Environ 1 200
```

---

## COMPARAISON SQL VS NOSQL DANS CE PROJET

| Aspect | SQL (database_univ) | NoSQL (db_univ_nosql) |
|--------|---------------------|----------------------|
| Nombre de tables | 7 | 2 |
| Jointures nécessaires | Oui | Non |
| Redondance des données | Minimale | Élevée (notes dans chaque étudiant) |
| Requête pour moyenne par étudiant | 2 tables | 1 collection |
| Gestion des mises à jour | Simple | Complexe (mettre à jour tous les étudiants) |
| Idéal pour | Opérations quotidiennes (écritures) | Analyses (lectures) |

---

## FICHIERS DU PROJET

```
projet-mongodb/
├── README.md                    # Ce fichier
├── script_mongodb.sql           # Script complet de génération
├── requetes_analyse.js          # Toutes les requêtes d'analyse
└── export/                      # Dossier pour exports
    ├── etudiants.json           # Export des étudiants
    └── cours.json               # Export des cours
```

---

## EXPORT DES DONNÉES (optionnel)

```javascript
// Exporter en JSON
mongoexport --db db_univ_nosql --collection etudiants --out etudiants.json
mongoexport --db db_univ_nosql --collection cours --out cours.json
```

---

## AUTEUR

Projet réalisé dans le cadre d'un cursus Data Engineering.

---

## DATE

2024

---

## LICENCE

Projet pédagogique - Utilisation libre pour apprentissage.
