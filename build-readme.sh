#!/usr/bin/env bash
set -euo pipefail

OUTPUT_README="README.md"
HEADER_FILE="intro.md"

# 1. Vérifier la présence du fichier d'en-tête
if [ ! -f "$HEADER_FILE" ]; then
    echo "Erreur : Le fichier d'en-tête $HEADER_FILE est introuvable." >&2
    exit 1
fi

echo "Génération de la page $OUTPUT_README..."

# 2. Copier l'en-tête de base dans le README principal
cat "$HEADER_FILE" > "$OUTPUT_README"

# Ajouter la section "Liste des scripts"
echo "## 📂 Liste des scripts" >> "$OUTPUT_README"
echo "" >> "$OUTPUT_README"

for dir in */; do
    # Ignorer les dossiers cachés (comme .git)
    [[ "$dir" =~ ^\. ]] && continue
    
    if [ -f "${dir}README.md" ]; then
        # Extraire la 1ère ligne, nettoyer les retours chariots et forcer le titre en niveau 3 (###)
        head -n 1 "${dir}README.md" | tr -d '\r' | sed -E 's/^[^#]*([#]+)/###/' >> "$OUTPUT_README"
        
        # Forcer un saut de ligne pour séparer le titre du texte
        echo "" >> "$OUTPUT_README"
        
        # Extraire la description en s'arrêtant *avant* la prochaine ligne "##"
        tail -n +2 "${dir}README.md" | tr -d '\r' | awk '/^##/ {exit} {print}' >> "$OUTPUT_README"
        
        # Ajouter le lien vers la documentation complète
        echo -e "\n[👉 Voir la documentation complète et l'usage de ce script](./${dir}README.md)\n" >> "$OUTPUT_README"
        
        # Un seul séparateur propre entre chaque script
        echo "---" >> "$OUTPUT_README"
        echo "" >> "$OUTPUT_README"
    fi
done

echo "Mise à jour de $OUTPUT_README terminée avec succès !"