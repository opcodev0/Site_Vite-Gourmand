# Site_Vite-Gourmand

### README — Déploiement local du projet Julie & José

## Présentation du projet

Julie & José est une application web de gestion et de commande pour un service traiteur gastronomique.

Le projet contient :

- une page d’accueil moderne,
- un système de connexion sécurisé,
- une gestion des menus,
- un espace de commande interactif,
- un espace employé complet,
- une gestion des avis clients,
- des fonctionnalités RGPD et sécurité.

---

# Technologies utilisées

## Front-end

- React.js
- TailwindCSS
- JavaScript

## Back-end

- Node.js
- Express.js

## Base de données

- MongoDB

---

# Prérequis

Avant de lancer le projet, il est nécessaire d’installer :

- Node.js
- npm
- MongoDB

Téléchargements officiels :

- https://nodejs.org
- https://www.mongodb.com

---

# Installation du projet

## 1. Cloner le projet

```bash
git clone https://github.com/votre-projet/julie-jose.git
```

---

## 2. Accéder au dossier

```bash
cd julie-jose
```

---

## 3. Installer les dépendances

### Front-end

```bash
cd client
npm install
```

### Back-end

```bash
cd ../server
npm install
```

---

# Configuration des variables d’environnement

Créer un fichier `.env` dans le dossier `server`.

Exemple :

```env
PORT=5000
MONGO_URI=votre_url_mongodb
JWT_SECRET=votre_cle_secrete
```

---

# Lancer le projet

## Démarrer le serveur back-end

Depuis le dossier `server` :

```bash
npm run dev
```

Le serveur démarre sur :

```bash
http://localhost:5000
```

---

## Démarrer le front-end

Depuis le dossier `client` :

```bash
npm run dev
```

Le site sera disponible sur :

```bash
http://localhost:5173
```

---

# Fonctionnalités principales

## Espace public

- Consultation des menus
- Filtres dynamiques
- Avis clients
- Présentation de l’entreprise

## Authentification

- Connexion
- Création de compte
- Mot de passe oublié
- Validation RGPD

## Commandes

- Tunnel de commande multi-étapes
- Calcul dynamique de livraison
- Réductions automatiques

## Espace employé

- Gestion des commandes
- Gestion des menus
- Validation des avis
- Gestion des horaires
- Notifications dynamiques

---

# Sécurité

Le projet applique plusieurs mesures de sécurité :

- Hash des mots de passe
- Validation des formulaires
- Protection contre les injections SQL
- Protection XSS
- Gestion des accès employés
- Respect du RGPD

---

# Structure du projet

```bash
julie-jose/
│
├── client/
│   ├── src/
│   ├── components/
│   ├── pages/
│   └── assets/
│
├── server/
│   ├── controllers/
│   ├── routes/
│   ├── models/
│   ├── middleware/
│   └── config/
│
└── README.md
```

---

# Auteur

Projet réalisé pour le développement de la plateforme traiteur Julie & José.
