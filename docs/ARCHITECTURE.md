# Architecture de MathCam

## Vue d'ensemble

MathCam est une application mobile qui permet aux utilisateurs de résoudre des problèmes mathématiques en prenant une photo. L'architecture du projet est divisée en deux parties principales : le frontend (application iOS) et le backend (API et modèles ML).

## Structure des dossiers

```
MathCam/
├── frontend/                # Code source de l'application iOS
│   ├── MathCam/             # Projet Xcode
│   │   ├── MathCam.xcodeproj/
│   │   └── MathCam/         # Code source Swift
│   └── assets/              # Ressources partagées pour l'interface
├── backend/                 # Backend et modèles ML
│   ├── api/                 # API FastAPI
│   │   └── main.py          # Points d'entrée de l'API
│   ├── ml_models/           # Modèles de machine learning
│   │   ├── ocr/             # Reconnaissance optique des caractères
│   │   │   └── image_processor.py # Traitement d'image et OCR
│   │   └── math_solver/     # Résolution des équations
│   │       └── math_solver.py # Solveur d'équations
│   ├── utils/               # Outils partagés
│   └── requirements.txt     # Dépendances Python
└── docs/                    # Documentation
    └── ARCHITECTURE.md      # Ce document
```

## Frontend (iOS)

L'application iOS est développée avec SwiftUI et se compose de plusieurs vues principales :

- **ContentView**: Vue principale de l'application
- **CameraView**: Interface de capture photo
- **CalculatorView**: Calculatrice intégrée
- **HistoryView**: Historique des problèmes résolus
- **MenuView**: Paramètres et options

Le frontend communique avec le backend via deux moyens :
1. **ApiService**: Service Swift qui fait des appels HTTP à l'API FastAPI
2. **PythonBridge**: Pour les tests locaux sur macOS, permet d'appeler directement le solveur Python

## Backend

### API (FastAPI)

L'API expose deux endpoints principaux :
- **/solve** (POST): Accepte une image et retourne la solution au problème mathématique
- **/solve/text** (POST): Accepte une équation textuelle et retourne sa solution

### Modèles ML

L'architecture inclut deux modèles de machine learning principaux :

1. **OCR (Reconnaissance optique de caractères)**
   - Extrait les équations mathématiques des images
   - Prétraite les images pour améliorer la précision
   - Convertit les symboles mathématiques en texte

2. **Solveur mathématique**
   - Analyse et résout les équations mathématiques
   - Combine des approches symboliques et ML
   - Utilise SymPy pour la résolution symbolique
   - Intègre un modèle ML pour améliorer la résolution

## Flux de travail

1. L'utilisateur prend une photo d'un problème mathématique
2. L'image est envoyée à l'API backend
3. Le module OCR extrait l'équation
4. Le solveur mathématique résout l'équation
5. La solution est renvoyée à l'application
6. L'application affiche la solution à l'utilisateur

## Technologies utilisées

- **Frontend**:
  - SwiftUI, Combine
  - AVFoundation pour la capture photo
  - URLSession pour les appels réseau

- **Backend**:
  - FastAPI pour l'API REST
  - TensorFlow pour les modèles ML
  - OpenCV pour le traitement d'image
  - SymPy pour la résolution symbolique 