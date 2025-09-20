#!/bin/bash
set -e

create_symfony_project() {
    echo "🚀 Création d'un nouveau projet Symfony..."

    composer create-project symfony/skeleton:"${SYMFONY_VERSION:-lts}" tmp \
        --stability="${STABILITY:-stable}" \
        --prefer-dist \
        --no-progress \
        --no-interaction \
        --no-install \
        --no-scripts

    cd tmp
    cp -Rp . ..
    cd ..
    rm -rf tmp

    composer install --no-interaction --optimize-autoloader

    if [ "${PROJECT_TYPE:-webapp}" = "webapp" ]; then
        echo "📦 Installation des packages webapp..."
        composer require webapp --no-interaction
        composer require symfony/maker-bundle --dev --no-interaction
        composer require doctrine/doctrine-fixtures-bundle --dev --no-interaction
    fi

    # Configuration Docker pour Symfony Flex
    composer config --json extra.symfony.docker 'true'

#    if [ "${INIT_GIT:-true}" = "true" ]; then
#        echo "🔧 Initialisation du repository Git..."
#        git init .
#        git add .
#        git commit -m "Initial Symfony project setup" --quiet
#        echo "✅ Repository Git initialisé"
#    fi

    echo "✅ Projet Symfony créé avec succès!"
}

setup_existing_project() {
    echo "🔧 Configuration du projet existant..."

    if [ ! -d "vendor" ] || [ -z "$(ls -A vendor 2>/dev/null)" ]; then
        echo "📦 Installation des dépendances Composer..."
        composer install --no-interaction --optimize-autoloader
    fi

#    # Initialiser Git si pas déjà fait et demandé
#    if [ ! -d ".git" ] && [ "${INIT_GIT:-false}" = "true" ]; then
#        echo "🔧 Initialisation du repository Git..."
#        git init .
#        git add .
#        git commit -m "Initial commit for existing project" --quiet
#        echo "✅ Repository Git initialisé"
#    fi

    echo "✅ Projet existant configuré!"
}

# Function to fix permissions
fix_permissions() {
    if [ -d "var" ]; then
        chmod -R 777 var/ 2>/dev/null || true
    fi
    if [ -d "public" ]; then
        chmod -R 755 public/ 2>/dev/null || true
    fi
}

# Main logic
main() {
    # Configuration automatique pour FrankenPHP
    # Vérifier si c'est un nouveau projet ou existant
    if [ ! -f "composer.json" ]; then
        # Nouveau projet
        create_symfony_project
    else
        # Projet existant
        setup_existing_project
    fi

    # Corriger les permissions
    fix_permissions

    # Afficher les informations du projet si Symfony est installé
    if [ -f "bin/console" ]; then
        echo "📊 Informations du projet:"
        php bin/console about --env=dev 2>/dev/null || echo "Symfony installé mais non configuré"
    fi

    # Lancer FrankenPHP par défaut si aucune commande spécifiée
    if [ $# -eq 0 ]; then
        exec frankenphp run
    else
        exec "$@"
    fi
}

# Appeler la fonction principale avec tous les arguments
main "$@"
