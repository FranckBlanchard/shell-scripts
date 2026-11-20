#!/usr/bin/env bash

set -uo pipefail

GITHUB_RAW_BASE="https://raw.githubusercontent.com/FranckBlanchard/shell-scripts"
VERSION_URL="${GITHUB_RAW_BASE}/master/weather/VERSION"

if ! command -v curl >/dev/null 2>&1; then
    echo "Erreur : curl est requis pour installer weather." >&2
    exit 1
fi

if [[ -z "${HOME:-}" ]]; then
    echo "Erreur : la variable HOME n'est pas définie." >&2
    exit 1
fi

INSTALL_DIR="${HOME}/.local/bin"
INSTALL_PATH="${INSTALL_DIR}/weather"

read -r -p "Installer ou remplacer weather dans '$INSTALL_PATH' ? [O/n] : " CONFIRM_INSTALL
if [[ "$CONFIRM_INSTALL" =~ ^[Nn]$ ]]; then
    echo "Installation annulée."
    exit 0
fi

if [[ -d "$INSTALL_PATH" ]]; then
    echo "Erreur : '$INSTALL_PATH' est un répertoire." >&2
    exit 1
fi

if ! LATEST_VERSION=$(curl -fsSL --connect-timeout 10 --max-time 30 "$VERSION_URL"); then
    echo "Erreur : impossible de récupérer la dernière version." >&2
    exit 1
fi

if [[ ! "$LATEST_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Erreur : numéro de version distant invalide : '$LATEST_VERSION'." >&2
    exit 1
fi

SCRIPT_URL="${GITHUB_RAW_BASE}/weather-v${LATEST_VERSION}/weather/weather.sh"

if ! mkdir -p -- "$INSTALL_DIR"; then
    echo "Erreur : impossible de créer '$INSTALL_DIR'." >&2
    exit 1
fi

TEMP_FILE=$(mktemp "${INSTALL_PATH}.XXXXXX") || {
    echo "Erreur : impossible de créer un fichier temporaire dans '$INSTALL_DIR'." >&2
    exit 1
}
trap 'rm -f -- "$TEMP_FILE"' EXIT

if ! curl -fsSL --connect-timeout 10 --max-time 60 -o "$TEMP_FILE" "$SCRIPT_URL"; then
    echo "Erreur : téléchargement de weather v$LATEST_VERSION impossible." >&2
    exit 1
fi

if ! grep -Fqx -- "VERSION=\"$LATEST_VERSION\"" "$TEMP_FILE"; then
    echo "Erreur : le script téléchargé ne correspond pas à la version $LATEST_VERSION." >&2
    exit 1
fi

if ! bash -n "$TEMP_FILE"; then
    echo "Erreur : le script téléchargé contient une erreur de syntaxe." >&2
    exit 1
fi

if ! chmod 755 "$TEMP_FILE"; then
    echo "Erreur : impossible de rendre le script exécutable." >&2
    exit 1
fi

if ! mv -f -- "$TEMP_FILE" "$INSTALL_PATH"; then
    echo "Erreur : impossible d'installer weather dans '$INSTALL_PATH'." >&2
    exit 1
fi
trap - EXIT

echo "weather v$LATEST_VERSION a été installé dans '$INSTALL_PATH'."
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo "Attention : '$INSTALL_DIR' ne semble pas être dans votre PATH."
        echo "Ajoutez-le à la configuration de votre shell pour lancer 'weather'."
        ;;
esac
