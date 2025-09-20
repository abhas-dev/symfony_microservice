include .env.docker
export

# Detect current user ID and Group ID
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
USER_NAME := $(shell whoami)

# Configuration par défaut
SYMFONY_VERSION ?= lts
PROJECT_TYPE ?= webapp
STABILITY ?= stable
INIT_GIT ?= true

.PHONY: help build up down install create-project create-api reset logs shell fix-permissions

help: ## Affiche l'aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construit les images Docker
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose build

up: ## Démarre les conteneurs
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose up -d

down: ## Arrête les conteneurs
	docker compose down

clean: ## Nettoie tous les conteneurs, réseaux et volumes (dangereux!)
	docker compose down -v --remove-orphans
	docker system prune -f

# Installation avec auto-détection du type de projet
install: build ## Installation complète (auto-détecte nouveau/existant)
	@if [ ! -f "composer.json" ]; then \
		echo "🚀 Nouveau projet détecté - création en cours..."; \
		make create-project; \
	else \
		echo "📁 Projet existant détecté - configuration en cours..."; \
		make setup-existing; \
	fi
	@echo "✅ Installation terminée ! Accédez à http://localhost:${HTTP_PORT}"

create-project: ## Crée un nouveau projet Symfony webapp
	SYMFONY_VERSION=$(SYMFONY_VERSION) PROJECT_TYPE=webapp STABILITY=$(STABILITY) INIT_GIT=$(INIT_GIT) \
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) \
	docker compose run --rm -e SYMFONY_VERSION=$(SYMFONY_VERSION) -e PROJECT_TYPE=webapp -e STABILITY=$(STABILITY) -e INIT_GIT=$(INIT_GIT) frankenphp php -v
	make up
	make fix-permissions

create-api: ## Crée un nouveau projet Symfony API
	SYMFONY_VERSION=$(SYMFONY_VERSION) PROJECT_TYPE=api STABILITY=$(STABILITY) INIT_GIT=$(INIT_GIT) \
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) \
	docker compose run --rm -e SYMFONY_VERSION=$(SYMFONY_VERSION) -e PROJECT_TYPE=api -e STABILITY=$(STABILITY) -e INIT_GIT=$(INIT_GIT) frankenphp php -v
	make up
	make fix-permissions

setup-existing: ## Configure un projet existant
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) \
	docker compose run --rm -e INIT_GIT=$(INIT_GIT) frankenphp php -v
	make up
	make fix-permissions

# Variantes de création avec versions spécifiques
create-project-7.1: ## Crée un projet Symfony 7.1
	SYMFONY_VERSION=7.1.* make create-project

create-project-6.4: ## Crée un projet Symfony 6.4 LTS
	SYMFONY_VERSION=6.4.* make create-project

create-project-dev: ## Crée un projet avec la version de développement
	SYMFONY_VERSION=dev-main STABILITY=dev make create-project

# Gestion Git
git-init: ## Initialise Git dans un projet existant
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) \
	docker compose run --rm frankenphp sh -c "git init . && git add . && git commit -m 'Initial commit'"

git-reset: ## Reset Git (attention: supprime l'historique)
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) \
	docker compose run --rm frankenphp sh -c "rm -rf .git && git init . && git add . && git commit -m 'Reset commit'"

reset: down ## Reset complet du projet
	docker compose down -v
	rm -rf src/ config/ public/ var/ vendor/ composer.* symfony.* .env .env.test .git/
	make install

reset-keep-git: down ## Reset du projet en gardant Git
	docker compose down -v
	rm -rf src/ config/ public/ var/ vendor/ composer.* symfony.* .env .env.test
	INIT_GIT=false make install

fix-permissions: ## Répare les permissions des fichiers
	chown -R $(USER_ID):$(GROUP_ID) .
	chmod -R 755 var/ 2>/dev/null || true
	chmod -R 755 public/ 2>/dev/null || true

logs: ## Affiche les logs
	docker compose logs -f

shell: ## Accès shell au conteneur FrankenPHP
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp bash

# Commandes Symfony
sf: ## Exécute une commande Symfony (ex: make sf c=debug:router)
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console $(c)

composer: ## Exécute une commande Composer (ex: make composer c="require package")
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp composer $(c)

# Base de données
db-create: ## Crée la base de données
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console doctrine:database:create --if-not-exists

db-drop: ## Supprime la base de données
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console doctrine:database:drop --force --if-exists

db-migrate: ## Exécute les migrations
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console doctrine:migrations:migrate --no-interaction

db-fixtures: ## Charge les fixtures
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console doctrine:fixtures:load --no-interaction

db-reset: db-drop db-create db-migrate db-fixtures ## Reset complet de la base de données

# Cache et environnement
cache-clear: ## Vide le cache
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console cache:clear

cache-warmup: ## Préchauffe le cache
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/console cache:warmup

# Tests et qualité
test: ## Lance les tests
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/phpunit

test-coverage: ## Lance les tests avec couverture
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose exec frankenphp php bin/phpunit --coverage-html var/coverage

# Environnements
up-dev: up ## Démarre en mode développement (alias pour up)

up-prod: ## Démarre en mode production
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

down-prod: ## Arrête l'environnement de production
	docker compose -f docker-compose.yml -f docker-compose.prod.yml down

build-prod: ## Construit les images pour la production
	USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID) USER_NAME=$(USER_NAME) docker compose -f docker-compose.yml -f docker-compose.prod.yml build

# FrankenPHP Worker Mode
worker: ## Démarre avec le mode worker activé (dev)
	FRANKENPHP_CONFIG="worker ./public/index.php" make up

worker-stop: ## Arrête le mode worker (dev)
	FRANKENPHP_CONFIG="" make up

# Informations
info: ## Affiche les informations du projet
	@echo "📊 Informations du projet:"
	@echo "- Version PHP: $(shell docker compose exec frankenphp php -v | head -n1)"
	@echo "- Version Composer: $(shell docker compose exec frankenphp composer --version)"
	@echo "- Version Symfony CLI: $(shell docker compose exec frankenphp symfony version)"
	@if [ -f "composer.json" ]; then \
		echo "- Version Symfony: $(shell docker compose exec frankenphp php bin/console --version 2>/dev/null || echo 'Non installé')"; \
	fi
	@echo "- Port HTTP: ${HTTP_PORT}"
	@echo "- Port HTTPS: ${HTTPS_PORT}"
	@echo "- Port HTTP/3: ${HTTP3_PORT}"
	@echo "- Port DB: ${DB_PORT}"
	@echo "- Nom DB: ${DB_NAME}"
	@echo "- Server Name: ${SERVER_NAME}"

status: ## Affiche le statut des conteneurs
	docker compose ps