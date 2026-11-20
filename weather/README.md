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

Téléchargez puis lancez le programme d'installation :

```bash
curl -fsSL \
  -o weather-install.sh \
  https://raw.githubusercontent.com/FranckBlanchard/shell-scripts/master/weather/install.sh &&
bash weather-install.sh
rm weather-install.sh
```

L'installation propose `~/.local/bin/weather` et demande confirmation avant
d'installer ou de remplacer le fichier. Elle télécharge la dernière version
publiée et vérifie le script avant de l'installer.

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

Pour mettre à jour le script installé :

```bash
weather --update
weather -u
```

### Options

| Option | Description |
| --- | --- |
| `--json` | Affiche la réponse météo au format JSON |
| `-u`, `--update` | Télécharge et installe la dernière version publiée |
| `-h`, `--help` | Affiche l'aide |
| `-v`, `--version` | Affiche la version du script et vérifie si une version plus récente est disponible |

### Publication d'une version (mainteneurs)

Depuis le répertoire `weather`, lancez `bash commit.sh`. Le script demande si le
commit publie une nouvelle version :

- **Oui** : incrémente `VERSION` et la version de `weather.sh`, puis crée un
  tag annoté `weather-vX.Y.Z`.
- **Non** : crée un commit de maintenance sans changer la version ni créer de
  tag.

Lors de la publication, le tag est poussé avant la branche afin que la version
annoncée dans `VERSION` soit déjà téléchargeable.
