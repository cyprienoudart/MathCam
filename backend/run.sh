#!/bin/bash

# Script d'initialisation pour le backend de MathCam

# Vérifier si Python est installé
if ! [ -x "$(command -v python3)" ]; then
  echo 'Erreur: Python 3 n'est pas installé.' >&2
  exit 1
fi

# Installer les dépendances si nécessaire
echo "Installation des dépendances..."
pip3 install -r requirements.txt

# Démarrer le serveur API
echo "Démarrage du serveur API MathCam..."
python3 -m api.main

# Ce script devrait être exécuté depuis le répertoire backend:
# cd backend && bash run.sh 