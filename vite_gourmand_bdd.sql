-- =============================================================
--  VITE & GOURMAND — Base de données relationnelle (MySQL)
--  Fichier : vite_gourmand_bdd.sql
--  Description : Création des tables + données de test
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 1. UTILISATEURS & RÔLES
-- -------------------------------------------------------------

CREATE TABLE role (
    id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle   ENUM('utilisateur','employe','administrateur') NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE utilisateur (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(100)  NOT NULL,
    prenom          VARCHAR(100)  NOT NULL,
    email           VARCHAR(255)  NOT NULL UNIQUE,
    mot_de_passe    VARCHAR(255)  NOT NULL,          -- bcrypt hash
    gsm             VARCHAR(20)   DEFAULT NULL,
    adresse         TEXT          DEFAULT NULL,
    id_role         INT UNSIGNED  NOT NULL,
    actif           TINYINT(1)    NOT NULL DEFAULT 1, -- désactivation compte employé
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (id_role) REFERENCES role(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------
-- 2. CATALOGUE : THÈMES, RÉGIMES, PLATS, MENUS
-- -------------------------------------------------------------

CREATE TABLE theme (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE  -- Noël, Pâques, Classique, Événement
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE regime (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE  -- Classique, Végétarien, Vegan
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE allergene (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE type_plat (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE  -- Entrée, Plat, Dessert, Fromage…
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plat (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom         VARCHAR(200) NOT NULL,
    id_type     INT UNSIGNED NOT NULL,
    CONSTRAINT fk_plat_type FOREIGN KEY (id_type) REFERENCES type_plat(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table pivot : plat ↔ allergène (un plat peut avoir plusieurs allergènes)
CREATE TABLE plat_allergene (
    id_plat      INT UNSIGNED NOT NULL,
    id_allergene INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_plat, id_allergene),
    CONSTRAINT fk_pa_plat      FOREIGN KEY (id_plat)      REFERENCES plat(id)      ON DELETE CASCADE,
    CONSTRAINT fk_pa_allergene FOREIGN KEY (id_allergene) REFERENCES allergene(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE menu (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    titre               VARCHAR(200) NOT NULL,
    description         TEXT         DEFAULT NULL,
    id_theme            INT UNSIGNED NOT NULL,
    id_regime           INT UNSIGNED NOT NULL,
    personnes_min       INT UNSIGNED NOT NULL DEFAULT 1,
    prix_base           DECIMAL(8,2) NOT NULL,  -- prix pour personnes_min
    stock               INT UNSIGNED NOT NULL DEFAULT 0,
    conditions          TEXT         DEFAULT NULL,
    actif               TINYINT(1)   NOT NULL DEFAULT 1,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_menu_theme  FOREIGN KEY (id_theme)  REFERENCES theme(id),
    CONSTRAINT fk_menu_regime FOREIGN KEY (id_regime) REFERENCES regime(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table pivot : menu ↔ plat  (un plat peut figurer dans plusieurs menus)
CREATE TABLE menu_plat (
    id_menu INT UNSIGNED NOT NULL,
    id_plat INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_menu, id_plat),
    CONSTRAINT fk_mp_menu FOREIGN KEY (id_menu) REFERENCES menu(id) ON DELETE CASCADE,
    CONSTRAINT fk_mp_plat FOREIGN KEY (id_plat) REFERENCES plat(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Images d'un menu (galerie)
CREATE TABLE menu_image (
    id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_menu  INT UNSIGNED  NOT NULL,
    url      VARCHAR(500)  NOT NULL,
    ordre    TINYINT       NOT NULL DEFAULT 0,
    CONSTRAINT fk_mi_menu FOREIGN KEY (id_menu) REFERENCES menu(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------
-- 3. HORAIRES
-- -------------------------------------------------------------

CREATE TABLE horaire (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    jour        TINYINT NOT NULL,          -- 0=Lundi … 6=Dimanche
    heure_ouv   TIME    DEFAULT NULL,
    heure_ferm  TIME    DEFAULT NULL,
    ferme       TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------
-- 4. COMMANDES
-- -------------------------------------------------------------

CREATE TABLE statut_commande (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle ENUM(
        'en_attente',
        'acceptee',
        'en_preparation',
        'en_livraison',
        'livree',
        'attente_retour_materiel',
        'terminee',
        'annulee'
    ) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE commande (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reference           VARCHAR(20)   NOT NULL UNIQUE,   -- CMD-YYYY-XXXX
    id_utilisateur      INT UNSIGNED  NOT NULL,
    id_menu             INT UNSIGNED  NOT NULL,
    id_statut           INT UNSIGNED  NOT NULL,
    nb_personnes        INT UNSIGNED  NOT NULL,
    date_prestation     DATE          NOT NULL,
    heure_prestation    TIME          NOT NULL,
    adresse_prestation  TEXT          NOT NULL,
    distance_km         DECIMAL(6,2)  NOT NULL DEFAULT 0.00,
    prix_menu           DECIMAL(8,2)  NOT NULL,
    prix_livraison      DECIMAL(8,2)  NOT NULL DEFAULT 5.00,
    reduction_pct       DECIMAL(4,2)  NOT NULL DEFAULT 0.00,  -- 10.00 si éligible
    prix_total          DECIMAL(8,2)  NOT NULL,
    motif_annulation    TEXT          DEFAULT NULL,
    contact_annulation  ENUM('gsm','mail') DEFAULT NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cmd_user    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id),
    CONSTRAINT fk_cmd_menu    FOREIGN KEY (id_menu)        REFERENCES menu(id),
    CONSTRAINT fk_cmd_statut  FOREIGN KEY (id_statut)      REFERENCES statut_commande(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Historique de tous les changements de statut d'une commande
CREATE TABLE commande_suivi (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_commande     INT UNSIGNED  NOT NULL,
    id_statut       INT UNSIGNED  NOT NULL,
    id_employe      INT UNSIGNED  DEFAULT NULL,  -- qui a changé le statut
    commentaire     TEXT          DEFAULT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cs_commande FOREIGN KEY (id_commande) REFERENCES commande(id) ON DELETE CASCADE,
    CONSTRAINT fk_cs_statut   FOREIGN KEY (id_statut)   REFERENCES statut_commande(id),
    CONSTRAINT fk_cs_employe  FOREIGN KEY (id_employe)  REFERENCES utilisateur(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------
-- 5. AVIS
-- -------------------------------------------------------------

CREATE TABLE avis (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_commande     INT UNSIGNED  NOT NULL UNIQUE,  -- 1 avis max par commande
    id_utilisateur  INT UNSIGNED  NOT NULL,
    note            TINYINT       NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire     TEXT          DEFAULT NULL,
    valide          TINYINT(1)    NOT NULL DEFAULT 0,  -- validé par un employé
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avis_commande FOREIGN KEY (id_commande)    REFERENCES commande(id)    ON DELETE CASCADE,
    CONSTRAINT fk_avis_user     FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------
-- 6. CONTACTS
-- -------------------------------------------------------------

CREATE TABLE contact (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(255) NOT NULL,
    titre       VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL,
    lu          TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
--  DONNÉES DE TEST (fixtures)
-- =============================================================

-- Rôles
INSERT INTO role (libelle) VALUES
    ('utilisateur'),
    ('employe'),
    ('administrateur');

-- Thèmes
INSERT INTO theme (libelle) VALUES
    ('Noël'), ('Pâques'), ('Classique'), ('Événement');

-- Régimes
INSERT INTO regime (libelle) VALUES
    ('Classique'), ('Végétarien'), ('Vegan');

-- Allergènes
INSERT INTO allergene (libelle) VALUES
    ('Gluten'), ('Lait'), ('Œufs'), ('Arachides'),
    ('Fruits à coque'), ('Soja'), ('Céleri'), ('Moutarde'),
    ('Sésame'), ('Poissons'), ('Crustacés'), ('Mollusques'),
    ('Lupin'), ('Anhydride sulfureux');

-- Types de plat
INSERT INTO type_plat (libelle) VALUES
    ('Amuse-bouche'), ('Entrée'), ('Plat'), ('Accompagnement'),
    ('Fromage'), ('Dessert');

-- Utilisateurs (mot de passe = "Password1!" haché bcrypt — à changer en prod)
INSERT INTO utilisateur (nom, prenom, email, mot_de_passe, gsm, adresse, id_role, actif) VALUES
    ('Administrateur', 'José',  'jose@vitegourmand.fr',  '$2y$12$exampleHashAdminXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '05 56 00 00 01', '1 place de la Victoire, 33000 Bordeaux', 3, 1),
    ('Dupont',    'Jean-Luc', 'jeanluc@vitegourmand.fr', '$2y$12$exampleHashEmpXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '05 56 00 00 02', '5 rue du Commerce, 33000 Bordeaux',      2, 1),
    ('Martin',   'Marie',    'marie@client.fr',          '$2y$12$exampleHashUserXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '06 12 34 56 78', '12 rue des Pins, 33000 Bordeaux',         1, 1),
    ('Leroy',    'Sophie',   'sophie@client.fr',         '$2y$12$exampleHashUser2XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX','06 98 76 54 32', '8 avenue Gambetta, 33000 Bordeaux',       1, 1);

-- Statuts de commande
INSERT INTO statut_commande (libelle) VALUES
    ('en_attente'), ('acceptee'), ('en_preparation'),
    ('en_livraison'), ('livree'), ('attente_retour_materiel'),
    ('terminee'), ('annulee');

-- Horaires (0=Lun, 1=Mar, 2=Mer, 3=Jeu, 4=Ven, 5=Sam, 6=Dim)
INSERT INTO horaire (jour, heure_ouv, heure_ferm, ferme) VALUES
    (0, '09:00', '19:00', 0),
    (1, '09:00', '19:00', 0),
    (2, '09:00', '19:00', 0),
    (3, '09:00', '19:00', 0),
    (4, '09:00', '19:00', 0),
    (5, '10:00', '18:00', 0),
    (6, '10:00', '14:00', 0);

-- Plats
INSERT INTO plat (nom, id_type) VALUES
    ('Foie gras maison & toast brioche',      2),  -- Entrée
    ('Velouté de châtaignes',                 2),
    ('Chapon rôti aux marrons',               3),  -- Plat
    ('Gratin dauphinois',                     4),  -- Accompagnement
    ('Bûche glacée signature',                6),  -- Dessert
    ('Asperges blanches sauce mousseline',    2),
    ('Gigot d\'agneau & légumes printaniers', 3),
    ('Charlotte aux fraises',                 6),
    ('Salade de chèvre chaud & noix',         2),
    ('Magret de canard & gratin',             3),
    ('Tarte Tatin maison',                    6),
    ('Tartare de légumes & herbes fraîches',  2),
    ('Risotto aux champignons & parmesan',    3),
    ('Fondant au chocolat & coulis framboise',6),
    ('Gaspacho andalou maison',               2),
    ('Curry de légumes & riz thaï',           3),
    ('Salade de fruits exotiques & sorbet',   6),
    ('Verrines de saumon fumé & crème citronnée', 1), -- Amuse-bouche
    ('Tartare de bœuf & truffe',              2),
    ('Filet de bœuf Wellington',              3),
    ('Mille-feuille vanille bourbon',         6),
    ('Fromages affinés',                      5);  -- Fromage

-- Allergènes des plats
INSERT INTO plat_allergene (id_plat, id_allergene) VALUES
    (1,1),(1,2),   -- Foie gras : Gluten, Lait
    (2,2),         -- Velouté : Lait
    (4,2),         -- Gratin : Lait
    (5,1),(5,2),(5,3), -- Bûche : Gluten, Lait, Œufs
    (6,2),(6,3),(6,8), -- Asperges : Lait, Œufs, Moutarde
    (9,5),         -- Salade chèvre : Fruits à coque
    (10,2),        -- Magret : Lait
    (11,1),(11,2), -- Tarte Tatin : Gluten, Lait
    (13,2),(13,3), -- Risotto : Lait, Œufs
    (14,2),(14,3), -- Fondant : Lait, Œufs
    (15,7),        -- Gaspacho : Céleri
    (16,9),        -- Curry : Sésame
    (18,10),       -- Verrines saumon : Poissons
    (19,2),(19,3),(19,8), -- Tartare bœuf : Lait, Œufs, Moutarde
    (20,1),(20,2), -- Wellington : Gluten, Lait
    (21,1),(21,2),(21,3); -- Mille-feuille : Gluten, Lait, Œufs

-- Menus
INSERT INTO menu (titre, description, id_theme, id_regime, personnes_min, prix_base, stock, conditions) VALUES
    ('Menu Festif de Noël',
     'Un menu raffiné pour sublimer votre réveillon. Foie gras maison, chapon rôti aux marrons et bûche glacée signature.',
     1, 1, 8, 185.00, 5,
     'Commande requise minimum 7 jours avant la prestation. Conservation entre 0°C et 4°C. Matériel de service fourni à restituer sous 10 jours ouvrés.'),

    ('Menu Pâques Tradition',
     'La tradition pascale revisitée avec finesse. Un menu printanier autour de l\'agneau de lait et des légumes de saison.',
     2, 1, 6, 95.00, 12,
     'Commande minimum 5 jours avant la prestation. Menu disponible uniquement en période pascale (mars–avril).'),

    ('Formule Classique Conviviale',
     'Notre formule intemporelle, parfaite pour tous les rassemblements. Un menu équilibré et savoureux.',
     3, 1, 10, 65.00, 20,
     'Commande requise minimum 3 jours avant la prestation. Livraison dans un rayon de 30 km autour de Bordeaux.'),

    ('Banquet Végétarien Printemps',
     'Un festin entièrement végétarien, coloré et généreux. Des légumes de saison sublimés par nos chefs.',
     4, 2, 8, 72.00, 8,
     'Commande minimum 4 jours avant la prestation. Produits certifiés sans viande ni poisson.'),

    ('Menu Vegan Été',
     'Notre proposition 100 % végétale, fraîche et inventive. Un menu vegan élaboré à partir de produits locaux.',
     3, 3, 5, 58.00, 15,
     'Commande minimum 3 jours avant. Aucun produit d\'origine animale. Emballages recyclables fournis.'),

    ('Gala Prestige Événementiel',
     'Notre offre la plus exclusive pour vos événements d\'exception. Cocktail dînatoire raffiné et service à table.',
     4, 1, 20, 240.00, 3,
     'Commande minimum 14 jours avant. Matériel haut de gamme fourni à restituer sous 10 jours ouvrés. Facturation de 600 € en cas de non-restitution (CGV art. 8).');

-- Plats par menu
INSERT INTO menu_plat (id_menu, id_plat) VALUES
    (1,1),(1,2),(1,3),(1,4),(1,5),          -- Noël
    (2,6),(2,7),(2,22),(2,8),               -- Pâques
    (3,9),(3,10),(3,22),(3,11),             -- Classique
    (4,12),(4,13),(4,14),                   -- Végétarien
    (5,15),(5,16),(5,17),                   -- Vegan
    (6,18),(6,19),(6,20),(6,21);            -- Gala

-- Commandes de test
INSERT INTO commande
    (reference, id_utilisateur, id_menu, id_statut, nb_personnes,
     date_prestation, heure_prestation, adresse_prestation,
     distance_km, prix_menu, prix_livraison, reduction_pct, prix_total)
VALUES
    ('CMD-2024-001', 3, 1, 7, 10,
     '2024-12-24', '19:00:00', '12 rue des Pins, 33000 Bordeaux',
     0.00, 231.25, 5.00, 10.00, 236.25),

    ('CMD-2024-002', 3, 3, 7, 12,
     '2024-10-12', '13:00:00', 'Salle des fêtes, 33100 Bordeaux',
     0.00, 78.00, 5.00, 0.00, 83.00),

    ('CMD-2025-003', 4, 4, 3, 8,
     '2025-04-20', '12:30:00', '8 avenue Gambetta, 33000 Bordeaux',
     0.00, 72.00, 5.00, 0.00, 77.00);

-- Suivi de commande
INSERT INTO commande_suivi (id_commande, id_statut, id_employe, commentaire) VALUES
    (1, 1, NULL,  'Commande reçue automatiquement'),
    (1, 2, 2,     'Validée par Jean-Luc'),
    (1, 3, 2,     'Mise en préparation'),
    (1, 4, 2,     'Partie en livraison'),
    (1, 5, 2,     'Livrée avec succès'),
    (1, 7, 2,     'Commande terminée'),
    (2, 1, NULL,  'Commande reçue automatiquement'),
    (2, 2, 2,     NULL),
    (2, 3, 2,     NULL),
    (2, 4, 2,     NULL),
    (2, 5, 2,     NULL),
    (2, 7, 2,     NULL),
    (3, 1, NULL,  'Commande reçue automatiquement'),
    (3, 2, 2,     'Acceptée'),
    (3, 3, 2,     'En cours de préparation');

-- Avis
INSERT INTO avis (id_commande, id_utilisateur, note, commentaire, valide) VALUES
    (2, 3, 4, 'Très bon repas, service impeccable. Légèrement en retard mais qualité irréprochable.', 1);

-- Contact de test
INSERT INTO contact (email, titre, description) VALUES
    ('contact@example.fr', 'Demande de devis', 'Bonjour, nous souhaiterions un devis pour un événement de 50 personnes en juillet.');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
--  FIN DU SCRIPT
-- =============================================================
