# Projet Flutter - ESP32

## Introduction

Ce projet est un projet de démonstration de communication entre un ESP32 et une application mobile Flutter.

## Application mobile

Notre application mobile permet de contrôler les composants de notre ESP32 à distance.

Voici les fonctionnalités de notre application :
- Allumer alternativement la LED Rouge (OFF) et la LED Verte (ON)
- Allumer la LED Rouge et Verte selon un seuil de luminosité défini
- Allumer la LED RGB en lui attribuant une couleur
- Lire la température du capteur TMP36gz (en degrés Celsius et Fahrenheit)
- Lire la luminosité du capteur de luminosité
- Enregistrer les valeurs de température et de luminosité dans Firebase (Firestore)
- Voir les statistiques de température (en degrés Celsius et Fahrenheit) et de luminosité dans un graphique
- Jouer une mélodie avec le Piezo Buzzer
- Option qui joue des [son funs](https://www.youtube.com/watch?v=2Qy9ycu-Rqo) à chaque intéraction avec le menu

### Musiques du Piezo Buzzer disponible :

- Mario
- Pacman
- Tetris
- Games of Thrones
- Harry Potter
- Star Wars

## ESP32

Nous avons développé une API REST sur notre ESP32 pour permettre la communication avec notre application mobile.

Notre ESP32 est équipé de plusieurs composants :
- LED Rouge
- LED Verte
- LED RGB
- Capteur de température TMP36gz
- Photocell
- Piezo Buzzer

Voici le repository de notre projet API REST pour un ESP32 : [ESP32](https://gitlab.com/MorganNavel/hai912i-iot-mobile)

Si vous souhaitez le schéma de câblage, vous pouvez le trouver au lien suivant : [Schéma de câblage](https://gitlab.com/MorganNavel/hai912i-iot-mobile/-/blob/29bbb5cf1da9feafff771e0cb4bbbae50548cef0/EasyEDA_Files/Schematic_ProjetESP.pdf)

## Prérequis

Pour pouvoir lancer notre application, vous devez avoir installé Flutter sur votre machine.
Pour cela, vous pouvez suivre les instructions sur le site officiel de Flutter : [Flutter](https://flutter.dev/docs/get-started/install)

## Installation

Pour installer notre application, vous devez cloner le repository sur votre machine.

```bash
git clone https://github.com/enzo-viguier/ESP32_Application.git
```

Ensuite, vous devez vous rendre dans le dossier du projet et lancer la commande suivante pour installer les dépendances.

```bash
flutter pub get
```

## Utilisation

Pour lancer l'application, vous devez connecter votre téléphone à votre ordinateur et lancer la commande suivante.

```bash
flutter run
```

## Auteurs

- [Enzo VIGUIER](https://github.com/enzo-viguier)
- [Morgan NAVEL](https://github.com/MorganNavel)
- [Tristan GAIDO](https://github.com/tristan-gaido)
