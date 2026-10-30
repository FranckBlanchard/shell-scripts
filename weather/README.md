## weather

**weather** affiche la météo actuel d'une ville dans le monde.

### Installation

Copier le script dans un répertoire et rendez le exécutable avec la commande :
	
```Bash
chmod +x weather.sh
```
Imaginons que vous ayez un repertoire */scripts* dans votre repertoire personnel dans lequel vous avez copier **weather.sh**

```Bash
chmod +x ~/scripts/weather.sh
```

Pour aller plus loin, vous pouvez avoir un répertoire */bin* dans votre *home*, et que celui-ci fasse partie du **PATH** de votre système
vous pous pouvez faire un lien symboloque comme ceci:100:

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
