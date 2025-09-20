# FrankenPHP Symfony Boilerplate

Un boilerplate moderne pour créer des applications Symfony avec FrankenPHP, offrant des performances exceptionnelles grâce au serveur web intégré et au mode worker.

## 🚀 Fonctionnalités

- **FrankenPHP** : Serveur web moderne avec support HTTP/2, HTTP/3 et HTTPS automatique
- **Mode Worker** : Performances ultra-rapides avec persistence en mémoire
- **Configuration multi-environnements** : Développement et production séparés
- **Docker Compose** : Orchestration simplifiée avec PostgreSQL
- **Makefile** : Commandes facilitées pour tous les cas d'usage
- **Auto-détection** : Création automatique ou configuration de projets existants

## 📋 Prérequis

- Docker et Docker Compose
- Make (optionnel mais recommandé)
- Git

## 🛠️ Installation et Création d'un Projet

### Installation Automatique

La commande `make install` détecte automatiquement s'il s'agit d'un nouveau projet ou d'un projet existant :

```bash
# Clone ou télécharge ce boilerplate
git clone <votre-repo> mon-projet
cd mon-projet

# Installation automatique
make install
```

### Création d'un Nouveau Projet

#### Projet Symfony Webapp (recommandé)
```bash
make create-project
# Ou avec version spécifique
SYMFONY_VERSION=7.1.* make create-project
```

#### Projet API Symfony
```bash
make create-api
```

#### Variantes par version
```bash
make create-project-7.1    # Symfony 7.1
make create-project-6.4    # Symfony 6.4 LTS  
make create-project-dev    # Version de développement
```

### Configuration d'un Projet Existant

Si vous avez déjà un projet Symfony, placez les fichiers dans le répertoire et lancez :

```bash
make setup-existing
```

## 🔧 Développement

### Démarrage Rapide

```bash
# Démarre l'environnement de développement
make up

# Ou explicitement
make up-dev
```

**Accès :**
- **HTTP** : http://localhost:8080
- **HTTPS** : https://localhost:8443
- **HTTP/3** : https://localhost:8443 (UDP)

### Mode Worker (Performance)

Le mode worker garde votre application en mémoire pour des performances ultra-rapides :

```bash
# Active le mode worker
make worker

# Désactive le mode worker
make worker-stop
```

### Commandes Utiles

```bash
# Logs en temps réel
make logs

# Shell dans le conteneur
make shell

# Commandes Symfony
make sf c=debug:router
make sf c=make:controller HomeController

# Commandes Composer
make composer c="require symfony/mailer"

# Base de données
make db-create
make db-migrate
make db-fixtures
make db-reset        # Reset complet

# Cache
make cache-clear
make cache-warmup

# Tests
make test
make test-coverage

# Informations système
make info
make status
```

## 📁 Structure des Fichiers

```
├── docker/
│   └── php/
│       ├── Dockerfile              # Image FrankenPHP personnalisée
│       └── docker-entrypoint.sh    # Script d'entrée
├── docker-compose.yml              # Configuration de base
├── docker-compose.override.yml     # Override développement (auto)
├── docker-compose.prod.yml         # Configuration production
├── Caddyfile                       # Configuration serveur web
├── .env.docker                     # Variables d'environnement
├── Makefile                        # Commandes automatisées
└── README.md                       # Cette documentation
```

## 📊 Configuration des Variables

Modifiez `.env.docker` selon vos besoins :

```bash
# Projet
PROJECT_NAME=mon-projet
HTTP_PORT=8080
HTTPS_PORT=8443

# Base de données
DB_NAME=mon_projet
DB_PORT=5432

# FrankenPHP
SERVER_NAME=localhost
FRANKENPHP_CONFIG=                    # Vide par défaut

# Symfony
SYMFONY_VERSION=7.3.*
PROJECT_TYPE=webapp                   # ou 'api'
```

## 🚀 Déploiement en Production

### 1. Préparation

Configurez les variables de production dans `.env.docker` :

```bash
# Changez ces valeurs pour la production !
SERVER_NAME=votre-domaine.com
DB_PASSWORD=votre_mot_de_passe_securise
DB_USER=app_user
```

### 2. Déploiement

```bash
# Build des images pour la production
make build-prod

# Démarrage en production
make up-prod
```

### 3. Configuration Production Automatique

La configuration production active automatiquement :

- ✅ **Mode Worker** : `FRANKENPHP_CONFIG=worker ./public/index.php`
- ✅ **Environnement** : `APP_ENV=prod` et `APP_DEBUG=false`  
- ✅ **Restart Policy** : `unless-stopped`
- ✅ **Healthcheck** : Surveillance de l'application
- ✅ **Volumes séparés** : Isolation des données
- ✅ **Optimisations** : `tty=false` pour de meilleures performances

### 4. Commandes Production

```bash
# Arrêter la production
make down-prod

# Logs production
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f

# Shell en production
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec frankenphp bash
```

## 🔒 Sécurité Production

### Checklist de Sécurité

- [ ] Changez `DB_PASSWORD` dans `.env.docker`
- [ ] Configurez `SERVER_NAME` avec votre vrai domaine
- [ ] Utilisez des certificats SSL valides (auto-générés par Caddy)
- [ ] Fermez les ports non nécessaires
- [ ] Configurez un reverse proxy si nécessaire
- [ ] Activez les logs de sécurité

### Variables Sensibles

**Ne committez jamais :**
- Mots de passe de base de données
- Clés API
- Certificats privés

Utilisez des variables d'environnement ou des secrets Docker.

## 📚 Environnements Détaillés

### Développement (Automatique)
Fichier : `docker-compose.override.yml`

- 🔄 **Hot reload** : Modifications instantanées
- 🎨 **Logs colorés** : `tty: true`  
- 💾 **Volumes persistants** : Certificats SSL conservés
- 🐛 **Debug activé** : `APP_DEBUG=true`

### Production (Explicite)
Fichier : `docker-compose.prod.yml`

- ⚡ **Mode Worker** : Performances optimales
- 🔒 **Sécurité renforcée** : Debug désactivé
- 📊 **Monitoring** : Healthcheck intégré
- 🚀 **Auto-restart** : Redémarrage automatique
- 📦 **Volumes isolés** : Séparation production/dev

## 🛠️ Gestion Git

```bash
# Initialiser Git dans un projet existant
make git-init

# Reset Git (attention: supprime l'historique)
make git-reset
```

## 🔄 Maintenance

### Reset Complet
```bash
make reset           # Supprime tout (y compris Git)
make reset-keep-git  # Garde l'historique Git
```

### Permissions
```bash
make fix-permissions  # Corrige les permissions de fichiers
```

## 📈 Performances

### Mode Worker vs Mode Classique

| Mode | Requests/sec | Latence moyenne | Mémoire |
|------|-------------|----------------|---------|
| Classique | ~1,000 | 50ms | Variable |
| **Worker** | **~5,000+** | **10ms** | Stable |

### Optimisations Automatiques

- **HTTP/2** et **HTTP/3** activés
- **Compression Gzip/Brotli** automatique  
- **Cache d'opcodes** intégré
- **Persistence mémoire** en mode worker

## 🐛 Dépannage

### Problèmes Fréquents

**Port déjà utilisé :**
```bash
# Changez les ports dans .env.docker
HTTP_PORT=8081
HTTPS_PORT=8444
```

**Permissions :**
```bash
make fix-permissions
```

**Conteneurs bloqués :**
```bash
make down
docker system prune -f
make up
```

**Certificats SSL :**
Les certificats auto-signés sont normaux en développement. Acceptez-les dans votre navigateur.

## 📞 Support

- **Documentation FrankenPHP** : https://frankenphp.dev/fr/
- **Documentation Symfony** : https://symfony.com/doc
- **Issues** : Créez une issue sur le repository

---

**Enjoy coding with FrankenPHP! 🚀**