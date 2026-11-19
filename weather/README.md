## weather

`weather` affiche les conditions météorologiques actuelles et les températures
minimale et maximale du jour pour une ville.

Le script utilise les services de géocodage et de prévisions d'Open-Meteo. Une
connexion Internet est nécessaire. Aucune clé API n'est requise.

### Prérequis

- Bash
- `curl` pour les requêtes aux services Open-Meteo
- `jq` pour traiter les réponses JSON

Sur Debian ou Ubuntu, installez les dépendances avec :

```bash
sudo apt install curl jq
```

### Installation

Les commandes suivantes installent le script dans `~/.local/bin` :

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL \
  -o "$HOME/.local/bin/weather" \
  https://raw.githubusercontent.com/FranckBlanchard/shell-scripts/master/weather/weather.sh
chmod +x "$HOME/.local/bin/weather"
```

Assurez-vous que `~/.local/bin` figure dans votre variable `PATH`. Pour la
session courante, vous pouvez l'ajouter avec :

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Pour conserver ce réglage, ajoutez cette commande au fichier de configuration
de votre shell, par exemple `~/.bashrc` pour Bash.

### Utilisation

Indiquez le nom d'une ville, et éventuellement une région ou un pays pour
préciser le lieu :

```bash
weather Paris France
weather "Trois-rivières Québec Canada"
```

Pour afficher la réponse météo au format JSON :

```bash
weather Paris --json
```

### Options

| Option | Description |
| --- | --- |
| `--json` | Affiche la réponse météo au format JSON |
| `-h`, `--help` | Affiche l'aide |
| `-v`, `--version` | Affiche la version du script et vérifie si une version plus récente est disponible |
