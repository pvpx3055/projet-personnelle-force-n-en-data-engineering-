-- =====================================================
-- TITRE : Requêtes d'analyse
-- OBJECTIF : Répondre aux questions du cahier des charges
-- =====================================================

USE DW_Univ;
GO

-- =====================================================
-- ANALYSE 1 : Moyenne par étudiant
-- =====================================================
SELECT TOP 10
    e.nom,
    e.prenom,
    ROUND(AVG(f.valeur_note), 2) as moyenne_generale
FROM fait_note f
JOIN dim_etudiant e ON f.id_etudiant_dim = e.id_etudiant_dim
GROUP BY e.nom, e.prenom
ORDER BY moyenne_generale DESC;

-- =====================================================
-- ANALYSE 2 : Moyenne par filière
-- =====================================================
SELECT 
    fi.libelle as filiere,
    ROUND(AVG(f.valeur_note), 2) as moyenne
FROM fait_note f
JOIN dim_filiere fi ON f.id_filiere_dim = fi.id_filiere_dim
GROUP BY fi.libelle
ORDER BY moyenne DESC;

-- =====================================================
-- ANALYSE 3 : Moyenne par niveau (L1, L2, L3)
-- =====================================================
SELECT 
    n.libelle as niveau,
    ROUND(AVG(f.valeur_note), 2) as moyenne
FROM fait_note f
JOIN dim_niveau n ON f.id_niveau_dim = n.id_niveau_dim
GROUP BY n.libelle, n.id_niveau_dim
ORDER BY n.id_niveau_dim;

-- =====================================================
-- ANALYSE 4 : Meilleurs et pires cours
-- =====================================================
SELECT TOP 5
    c.nom_cour,
    ROUND(AVG(f.valeur_note), 2) as moyenne,
    COUNT(*) as nb_notes
FROM fait_note f
JOIN dim_cours c ON f.id_cours_dim = c.id_cours_dim
GROUP BY c.nom_cour
ORDER BY moyenne DESC;

-- Pires cours
SELECT TOP 5
    c.nom_cour,
    ROUND(AVG(f.valeur_note), 2) as moyenne,
    COUNT(*) as nb_notes
FROM fait_note f
JOIN dim_cours c ON f.id_cours_dim = c.id_cours_dim
GROUP BY c.nom_cour
ORDER BY moyenne ASC;

-- =====================================================
-- ANALYSE 5 : Moyenne par enseignant
-- =====================================================
SELECT 
    ens.nom,
    ens.prenom,
    ROUND(AVG(f.valeur_note), 2) as moyenne
FROM fait_note f
JOIN dim_enseignant ens ON f.id_enseignant_dim = ens.id_enseignant_dim
GROUP BY ens.nom, ens.prenom
ORDER BY moyenne DESC;

-- =====================================================
-- ANALYSE 6 : Comparaison Devoir vs Examen
-- =====================================================
SELECT 
    f.type_evaluation,
    ROUND(AVG(f.valeur_note), 2) as moyenne,
    MIN(f.valeur_note) as note_min,
    MAX(f.valeur_note) as note_max,
    COUNT(*) as nb_notes
FROM fait_note f
GROUP BY f.type_evaluation;

-- =====================================================
-- ANALYSE 7 : Évolution dans le temps (par année)
-- =====================================================
SELECT 
    t.annee,
    ROUND(AVG(f.valeur_note), 2) as moyenne,
    COUNT(*) as nb_notes
FROM fait_note f
JOIN dim_temps t ON f.id_temps_dim = t.id_temps
GROUP BY t.annee
ORDER BY t.annee;

-- =====================================================
-- ANALYSE 8 : Évolution par semestre
-- =====================================================
SELECT 
    t.annee,
    t.semestre,
    ROUND(AVG(f.valeur_note), 2) as moyenne
FROM fait_note f
JOIN dim_temps t ON f.id_temps_dim = t.id_temps
GROUP BY t.annee, t.semestre
ORDER BY t.annee, t.semestre;

-- =====================================================
-- ANALYSE 9 : Taux de réussite par niveau (note >= 10)
-- =====================================================
SELECT 
    n.libelle as niveau,
    COUNT(CASE WHEN f.valeur_note >= 10 THEN 1 END) * 100.0 / COUNT(*) as taux_reussite,
    ROUND(AVG(f.valeur_note), 2) as moyenne
FROM fait_note f
JOIN dim_niveau n ON f.id_niveau_dim = n.id_niveau_dim
GROUP BY n.libelle, n.id_niveau_dim
ORDER BY n.id_niveau_dim;

-- =====================================================
-- ANALYSE 10 : Top 5 des meilleurs étudiants par filière
-- =====================================================
WITH ranked AS (
    SELECT 
        fi.libelle as filiere,
        e.nom,
        e.prenom,
        ROUND(AVG(f.valeur_note), 2) as moyenne,
        ROW_NUMBER() OVER (PARTITION BY fi.libelle ORDER BY AVG(f.valeur_note) DESC) as rang
    FROM fait_note f
    JOIN dim_etudiant e ON f.id_etudiant_dim = e.id_etudiant_dim
    JOIN dim_filiere fi ON f.id_filiere_dim = fi.id_filiere_dim
    GROUP BY fi.libelle, e.nom, e.prenom
)
SELECT filiere, nom, prenom, moyenne
FROM ranked
WHERE rang <= 5
ORDER BY filiere, rang;
