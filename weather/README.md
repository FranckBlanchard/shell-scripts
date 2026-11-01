## weather

**weather** affiche la météo actuel d'une ville dans le monde.

### Installation

Vous pouvez télécharger directement le script depuis le dépôt et le rendre exécutable avec les commandes suivantes :

```bash
curl -o weather.sh https://raw.githubusercontent.com/FranckBlanchard/shell-scripts/master/weather/weather.sh
chmod +x weather.sh
```

Pour aller plus loin, vous pouvez avoir un répertoire */bin* dans votre *home*, et que celui-ci fasse partie du **PATH** de votre système
vous pous pouvez faire un lien symbolique comme ceci:

```Bash
ln -s $HOME/scripts/weather/weather.sh $HOME/bin/weather
```

Ainsi de n'importe quel répertoire vous pourrez avoir la météo avec la commande:

```Bash
weather Paris France
```

### Usage

Pour Lancer le script depuis le répertoire d'installation, c'est très simple, en ligne de commande tapez:

```Bash
./weather.sh Paris France
```
