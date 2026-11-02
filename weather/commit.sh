#!/usr/bin/env bash

set -euo pipefail

VERSION_FILE="VERSION"

#
# Vérifications
#
if [[ ! -f "$VERSION_FILE" ]]; then
    echo "Erreur : fichier VERSION introuvable."
    exit 1
fi

#
# Détection du projet
#
PROJECT_NAME="${PWD##*/}"

echo "Répertoire détecté : $PROJECT_NAME"
read -rp "Confirmer ? [O/n] : " CONFIRM

if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
    read -rp "Nom du projet : " PROJECT_NAME
fi

echo

#
# Sélection du type de commit.
#
# Le type choisi détermine :
# - le préfixe du message Git (feat, fix, refactor, etc.)
# - la règle d'incrémentation de version
#
# Convention :
#   feat      : nouvelle fonctionnalité      -> X.Y+1.0
#   fix       : correction de bug            -> X.Y.Z+1
#   refactor  : réorganisation du code       -> X.Y.Z+1
#   docs      : documentation                -> X.Y.Z+1
#   chore     : maintenance                  -> X.Y.Z+1
#   major     : changement majeur            -> X+1.0.0
#
echo "Type de commit :"
echo "1) feat     : nouvelle fonctionnalité (+0.1.0)"
echo "2) fix      : correction de bug      (+0.0.1)"
echo "3) refactor : réorganisation du code (+0.0.1)"
echo "4) docs     : documentation          (+0.0.1)"
echo "5) chore    : maintenance            (+0.0.1)"
echo "6) major    : changement majeur      (+1.0.0)"
echo

read -rp "Choix : " CHOICE

case "$CHOICE" in
    1)
        TYPE="feat"
        ;;
    2)
        TYPE="fix"
        ;;
    3)
        TYPE="refactor"
        ;;
    4)
        TYPE="docs"
        ;;
    5)
        TYPE="chore"
        ;;
    6)
        TYPE="major"
        ;;
    *)
        echo "Choix invalide."
        exit 1
        ;;
esac

echo

#
# Lecture version actuelle
#
CURRENT_VERSION=$(<"$VERSION_FILE")

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

#
# Calcul nouvelle version
#
case "$TYPE" in
    feat)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    *)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

#
# Message
#
read -rp "Message : " MESSAGE

COMMIT_MESSAGE="${TYPE}(${PROJECT_NAME}): ${MESSAGE}"

echo
echo "-------------------------------------"
echo "Projet   : $PROJECT_NAME"
echo "Type     : $TYPE"
echo "Version  : $CURRENT_VERSION -> $NEW_VERSION"
echo
echo "$COMMIT_MESSAGE"
echo "-------------------------------------"
echo

read -rp "Continuer ? [O/n] : " CONFIRM_COMMIT

if [[ "$CONFIRM_COMMIT" =~ ^[Nn]$ ]]; then
    echo "Opération annulée."
    exit 0
fi

#
# Mise à jour du fichier VERSION
#
echo "$NEW_VERSION" > "$VERSION_FILE"

#
# Mise à jour de la variable VERSION dans le script principal
#
SCRIPT_FILE="${PROJECT_NAME}.sh"

if [[ -f "$SCRIPT_FILE" ]]; then
    sed -i \
        "s/^VERSION=\"[0-9.]*\"$/VERSION=\"$NEW_VERSION\"/" \
        "$SCRIPT_FILE"

    echo "Version mise à jour dans $SCRIPT_FILE"
else
    echo "Attention : $SCRIPT_FILE introuvable."
fi

#
# Git
#

#
# Ajout des fichiers modifiés à l'index Git
#
git add .
#
# Affiche les modifications qui seront incluses dans le commit
#
echo
echo "-------------------------------------"
echo "État Git avant le commit"
echo "-------------------------------------"
git status
echo

read -rp "Créer le commit ? [O/n] : " CONFIRM_GIT_COMMIT

if [[ "$CONFIRM_GIT_COMMIT" =~ ^[Nn]$ ]]; then
    echo "Commit annulé."
    exit 0
fi
#
# Création du commit avec le message généré
#
git commit -m "$COMMIT_MESSAGE"
echo
echo "✅ Commit créé avec succès"

#
# Demande si les modifications doivent être publiées
#
read -rp "Publier sur GitHub (git push) ? [O/n] : " CONFIRM_PUSH

if [[ ! "$CONFIRM_PUSH" =~ ^[Nn]$ ]]; then
    git push

    echo
    echo "✅ Modifications publiées"
else
    echo
    echo "ℹ️ Commit créé localement uniquement"
fi

echo
echo "✅ Version : $NEW_VERSION"
