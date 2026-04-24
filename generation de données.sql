-- =====================================================
-- TITRE : Génération des données de test
-- OBJECTIF : Créer 270 étudiants, 810 inscriptions, 64800 notes
-- =====================================================

USE database_univ;
GO

-- =====================================================
-- SUPPRESSION DES DONNEES EXISTANTES
-- =====================================================
DELETE FROM note;
DELETE FROM inscription;
DELETE FROM cours;
DELETE FROM etudiant;
GO

DBCC CHECKIDENT ('etudiant', RESEED, 0);
DBCC CHECKIDENT ('inscription', RESEED, 0);
DBCC CHECKIDENT ('note', RESEED, 0);
GO

-- =====================================================
-- LISTES DES PRENOMS ET NOMS (30 chacun)
-- =====================================================
DECLARE @prenoms TABLE (id INT IDENTITY, prenom VARCHAR(20));
INSERT INTO @prenoms (prenom) VALUES 
('Emma'),('Lucas'),('Chloe'),('Hugo'),('Lea'),('Louis'),('Manon'),('Arthur'),('Ines'),('Gabriel'),
('Juliette'),('Adam'),('Sarah'),('Raphael'),('Camille'),('Paul'),('Alice'),('Nathan'),('Lisa'),('Maxime'),
('Jade'),('Thomas'),('Eva'),('Theo'),('Lina'),('Antoine'),('Zoe'),('Alexandre'),('Anna'),('Baptiste');

DECLARE @noms TABLE (id INT IDENTITY, nom VARCHAR(20));
INSERT INTO @noms (nom) VALUES
('Dupont'),('Martin'),('Bernard'),('Petit'),('Durand'),('Robert'),('Moreau'),('Simon'),('Laurent'),('Michel'),
('Garcia'),('David'),('Bertrand'),('Roux'),('Vincent'),('Fournier'),('Morel'),('Girard'),('Andre'),('Lefevre'),
('Mercier'),('Dupuis'),('Lambert'),('Henry'),('Roussel'),('Colin'),('Arnaud'),('Perrin'),('Morin'),('Rousseau');

-- =====================================================
-- GENERATION DES ETUDIANTS (270)
-- =====================================================
-- 3 filieres × 90 etudiants = 270
-- (90 etudiants = 30 L1 + 30 L2 + 30 L3)
DECLARE @filiere_id INT;
DECLARE @compteur INT;
DECLARE @nom_choisi VARCHAR(20);
DECLARE @prenom_choisi VARCHAR(20);

DECLARE curseur_filiere CURSOR FOR SELECT id_filiere FROM filiere;
OPEN curseur_filiere;

FETCH NEXT FROM curseur_filiere INTO @filiere_id;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @compteur = 1;
    WHILE @compteur <= 90
    BEGIN
        SELECT TOP 1 @nom_choisi = nom FROM @noms ORDER BY NEWID();
        SELECT TOP 1 @prenom_choisi = prenom FROM @prenoms ORDER BY NEWID();
        
        INSERT INTO etudiant (nom, prenom, filiere)
        VALUES (@nom_choisi, @prenom_choisi, @filiere_id);
        
        SET @compteur = @compteur + 1;
    END
    FETCH NEXT FROM curseur_filiere INTO @filiere_id;
END

CLOSE curseur_filiere;
DEALLOCATE curseur_filiere;

-- =====================================================
-- GENERATION DES INSCRIPTIONS (810)
-- =====================================================
-- Chaque étudiant a 3 inscriptions (L1, L2, L3)

DECLARE @etudiant_id INT;
DECLARE @annee_num INT;

DECLARE curseur_etudiant CURSOR FOR SELECT id_etudiant FROM etudiant;
OPEN curseur_etudiant;

FETCH NEXT FROM curseur_etudiant INTO @etudiant_id;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @annee_num = 1;
    WHILE @annee_num <= 3
    BEGIN
        INSERT INTO inscription (id_etudiant, id_niveau, annee_scolaire, date_debut, date_fin)
        VALUES (
            @etudiant_id,
            @annee_num,
            CASE @annee_num 
                WHEN 1 THEN '2021-2022'
                WHEN 2 THEN '2022-2023'
                ELSE '2023-2024'
            END,
            CASE @annee_num
                WHEN 1 THEN '2021-09-01'
                WHEN 2 THEN '2022-09-01'
                ELSE '2023-09-01'
            END,
            CASE @annee_num
                WHEN 1 THEN '2022-06-30'
                WHEN 2 THEN '2023-06-30'
                ELSE '2024-06-30'
            END
        );
        SET @annee_num = @annee_num + 1;
    END
    FETCH NEXT FROM curseur_etudiant INTO @etudiant_id;
END

CLOSE curseur_etudiant;
DEALLOCATE curseur_etudiant;

-- =====================================================
-- GENERATION DES NOTES (64 800)
-- =====================================================
-- Calcul : 270 etudiants × 3 ans × 5 cours × 8 notes × 2 semestres = 64 800

DECLARE @inscription_curs_id INT;
DECLARE @etudiant_curs_id INT;
DECLARE @etudiant_filiere INT;
DECLARE @inscription_niveau INT;
DECLARE @annee_debut DATE;
DECLARE @cours_id INT;
DECLARE @semestre INT;
DECLARE @compteur_notes INT;
DECLARE @note_valeur DECIMAL(4,2);
DECLARE @date_note DATE;

DECLARE curseur_inscription CURSOR FOR 
SELECT i.id_inscription, i.id_etudiant, e.filiere, i.id_niveau, i.date_debut
FROM inscription i
JOIN etudiant e ON i.id_etudiant = e.id_etudiant;

OPEN curseur_inscription;

FETCH NEXT FROM curseur_inscription INTO @inscription_curs_id, @etudiant_curs_id, @etudiant_filiere, @inscription_niveau, @annee_debut;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE curseur_cours CURSOR FOR 
    SELECT id_cours FROM cours 
    WHERE filiere = @etudiant_filiere AND niveau = @inscription_niveau;
    
    OPEN curseur_cours;
    FETCH NEXT FROM curseur_cours INTO @cours_id;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @semestre = 1;
        WHILE @semestre <= 2
        BEGIN
            -- 6 DEVOIRS
            SET @compteur_notes = 1;
            WHILE @compteur_notes <= 6
            BEGIN
                SET @note_valeur = ROUND(6 + RAND(CHECKSUM(NEWID())) * 14, 2);
                
                IF @semestre = 1
                    SET @date_note = DATEADD(day, CAST(RAND(CHECKSUM(NEWID())) * 150 AS INT), @annee_debut);
                ELSE
                    SET @date_note = DATEADD(day, CAST(RAND(CHECKSUM(NEWID())) * 150 AS INT), DATEADD(month, 5, @annee_debut));
                
                INSERT INTO note (id_etudiant, id_cours, valeur, date, type_evaluation)
                VALUES (@etudiant_curs_id, @cours_id, @note_valeur, @date_note, 'Devoir');
                
                SET @compteur_notes = @compteur_notes + 1;
            END
            
            -- 2 EXAMENS
            SET @compteur_notes = 1;
            WHILE @compteur_notes <= 2
            BEGIN
                SET @note_valeur = ROUND(8 + RAND(CHECKSUM(NEWID())) * 12, 2);
                
                IF @semestre = 1
                    SET @date_note = DATEADD(day, 100 + CAST(RAND(CHECKSUM(NEWID())) * 50 AS INT), @annee_debut);
                ELSE
                    SET @date_note = DATEADD(day, 100 + CAST(RAND(CHECKSUM(NEWID())) * 50 AS INT), DATEADD(month, 5, @annee_debut));
                
                INSERT INTO note (id_etudiant, id_cours, valeur, date, type_evaluation)
                VALUES (@etudiant_curs_id, @cours_id, @note_valeur, @date_note, 'Exam');
                
                SET @compteur_notes = @compteur_notes + 1;
            END
            
            SET @semestre = @semestre + 1;
        END
        
        FETCH NEXT FROM curseur_cours INTO @cours_id;
    END
    
    CLOSE curseur_cours;
    DEALLOCATE curseur_cours;
    
    FETCH NEXT FROM curseur_inscription INTO @inscription_curs_id, @etudiant_curs_id, @etudiant_filiere, @inscription_niveau, @annee_debut;
END

CLOSE curseur_inscription;
DEALLOCATE curseur_inscription;

-- =====================================================
-- VERIFICATION DES VOLUMES
-- =====================================================
SELECT 'Etudiants' as TableName, COUNT(*) as Nb FROM etudiant
UNION SELECT 'Inscriptions', COUNT(*) FROM inscription
UNION SELECT 'Notes', COUNT(*) FROM note;
