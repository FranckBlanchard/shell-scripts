## Start-Webserver

`start-webserveur` démarre le serveur Web intégré de PHP pour le projet situé
dans le répertoire courant.

Le serveur écoute sur `localhost:8000` et utilise le dossier `public/` comme
racine Web. Ce serveur est destiné au développement et ne doit pas être utilisé
en production.

### Prérequis

- PHP en ligne de commande (`php`)
- Un dossier `public/` à la racine du projet PHP
- L'extension Xdebug, chargée sous le nom `xdebug.so`

Le script active l'affichage des erreurs et configure le débogage à distance
avec des options de configuration Xdebug 2. Avec Xdebug 3, adaptez ces options
dans le script à la configuration de votre environnement.

### Installation

Copiez `start-webserveur` à la racine de votre projet PHP, puis rendez-le
exécutable :

```bash
chmod +x start-webserveur
```

### Utilisation

Depuis la racine du projet, lancez :

```bash
./start-webserveur
```

Ouvrez ensuite [http://localhost:8000](http://localhost:8000) dans votre
navigateur. Pour arrêter le serveur, utilisez `Ctrl+C` dans le terminal.

### Personnalisation

Le port, le dossier racine et les options PHP/Xdebug sont définis dans le
script `start-webserveur`. Modifiez-les selon les besoins de votre projet.

Consultez la [documentation du serveur Web intégré de PHP](https://www.php.net/manual/fr/features.commandline.webserver.php)
pour plus d'informations.
