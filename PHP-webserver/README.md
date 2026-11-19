## Start-Webserver

`start-webserveur` démarre le serveur Web intégré de PHP pour le projet situé
dans le répertoire courant.

Le serveur écoute sur `localhost:8000` et utilise le dossier `public/` comme
racine Web. Ce serveur est destiné au développement et ne doit pas être utilisé
en production.

### Prérequis

- PHP en ligne de commande (`php`)
- `curl` pour télécharger le script
- Un dossier `public/` à la racine du projet PHP
- L'extension Xdebug, chargée sous le nom `xdebug.so`

Le script active l'affichage des erreurs et configure le débogage à distance
avec des options de configuration Xdebug 2. Avec Xdebug 3, adaptez ces options
dans le script à la configuration de votre environnement.

### Installation

Téléchargez le script directement à la racine de votre projet PHP. Dans le
terminal, placez-vous d'abord dans ce répertoire :

```bash
cd /chemin/vers/votre-projet
```

Téléchargez ensuite le fichier et rendez-le exécutable :

```bash
curl -fsSL \
  -o start-webserveur \
  https://raw.githubusercontent.com/FranckBlanchard/shell-scripts/master/PHP-webserver/start-webserveur
chmod +x start-webserveur
```

Le projet doit notamment contenir le dossier `public/`, qui sera utilisé comme
racine du serveur. L'installation peut être vérifiée en lançant le script
comme indiqué dans la section [Utilisation](#utilisation).

### Utilisation

Depuis la racine du projet, lancez :

```bash
./start-webserveur
```

Ouvrez ensuite [http://localhost:8000](http://localhost:8000) dans votre
navigateur. Pour arrêter le serveur, utilisez `Ctrl+C` dans le terminal.

### Personnalisation

Les paramètres sont regroupés au début du script `start-webserveur` :

- `HOST`, `PORT` et `DOCUMENT_ROOT` définissent l'adresse, le port et le dossier
  servi.
- `DISPLAY_ERRORS` contrôle l'affichage des erreurs PHP.
- Les variables `XDEBUG_*` configurent le débogage à distance.

Modifiez ces valeurs selon les besoins de votre projet. Les options passées à
PHP sont regroupées dans le tableau `PHP_OPTIONS`, une option par ligne.

Consultez la [documentation du serveur Web intégré de PHP](https://www.php.net/manual/fr/features.commandline.webserver.php)
pour plus d'informations.
