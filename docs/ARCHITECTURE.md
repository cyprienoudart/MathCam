# Architecture de MathCam

## Vue d'ensemble
MathCam est une application mobile qui permet aux utilisateurs de résoudre des problèmes mathématiques en prenant une photo. L'architecture du projet est divisée en deux parties principales : le frontend (application iOS) et le backend (API et modèles ML).

## Structure des dossiers

```
MathCam/
├── frontend/                # Code source de l'application iOS
│   ├── MathCam/             # Projet Xcode
│   │   ├── MathCam.xcodeproj/
│   │   ├── Core/            # Composants fondamentaux
│   │   │   ├── App/         # Point d'entrée de l'application
│   │   │   ├── Extensions/  # Extensions Swift
│   │   │   ├── Services/    # Services partagés (API, etc.)
│   │   │   └── Utils/       # Utilitaires et helpers
│   │   ├── Features/        # Fonctionnalités principales
│   │   │   ├── Camera/      # Capture d'image
│   │   │   │   ├── Views/
│   │   │   │   └── Components/
│   │   │   ├── MathSolver/  # Résolution des équations
│   │   │   │   ├── Views/
│   │   │   │   └── Models/
│   │   │   ├── History/     # Historique des calculs
│   │   │   │   ├── Views/
│   │   │   │   └── Models/
│   │   │   └── Settings/    # Paramètres de l'application
│   │   │       └── Views/
│   │   ├── UI/              # Composants d'interface réutilisables
│   │   │   ├── Components/  # Boutons, cartes, etc.
│   │   │   ├── Styles/      # Thèmes et styles
│   │   │   └── Modifiers/   # Modificateurs SwiftUI
│   │   └── Resources/       # Ressources (images, sons, etc.)
│   │       ├── Assets.xcassets/
│   │       └── Localizations/
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
L'application iOS est développée avec SwiftUI et suit une architecture modulaire organisée par fonctionnalités :

### Core
- App : Point d'entrée de l'application ( MathCamApp.swift , ContentView.swift )
- Services : Services partagés comme ApiService pour les appels réseau
- Extensions : Extensions Swift pour améliorer les fonctionnalités des types standard
- Utils : Utilitaires et helpers génériques

### Features
- Camera : Capture et traitement d'images
  - Views : CameraView , interfaces de capture photo
  - Components : Composants spécifiques à la caméra (contrôles, prévisualisation)
- MathSolver : Résolution des équations mathématiques
  - Views : EnhancedResultView , interfaces de résultat
  - Models : Modèles de données pour les équations et solutions
- History : Gestion de l'historique des calculs
  - Views : HistoryView , interface d'historique
  - Models : HistoryManager , gestion des données d'historique
- Settings : Paramètres de l'application
  - Views : SettingsView , interface des paramètres

### UI
- Components : Composants d'interface réutilisables
- Styles : Système de design ( DesignSystem.swift )
- Modifiers : Modificateurs SwiftUI personnalisés

### Resources
- Assets.xcassets : Images et ressources graphiques
- Localizations : Fichiers de traduction
Le frontend communique avec le backend via deux moyens :

1. ApiService : Service Swift qui fait des appels HTTP à l'API FastAPI
2. PythonBridge : Pour les tests locaux sur macOS, permet d'appeler directement le solveur Python

## Backend

### API (FastAPI)
L'API expose deux endpoints principaux :

- /solve (POST): Accepte une image et retourne la solution au problème mathématique
- /solve/text (POST): Accepte une équation textuelle et retourne sa solution

### Modèles ML
L'architecture inclut deux modèles de machine learning principaux :

1. OCR (Reconnaissance optique de caractères)
   
   - Extrait les équations mathématiques des images
   - Prétraite les images pour améliorer la précision
   - Convertit les symboles mathématiques en texte
2. Solveur mathématique
   
   - Analyse et résout les équations mathématiques
   - Combine des approches symboliques et ML
   - Utilise SymPy pour la résolution symbolique
   - Intègre un modèle ML pour améliorer la résolution

## Flux de travail
1. L'utilisateur prend une photo d'un problème mathématique via la fonctionnalité Camera
2. L'image est envoyée à l'API backend via ApiService
3. Le module OCR extrait l'équation
4. Le solveur mathématique résout l'équation
5. La solution est renvoyée à l'application
6. L'application affiche la solution à l'utilisateur dans EnhancedResultView
7. L'utilisateur peut sauvegarder le résultat dans l'historique

## Technologies utilisées
- Frontend :
  
  - SwiftUI, Combine pour l'interface utilisateur réactive
  - AVFoundation pour la capture photo
  - URLSession pour les appels réseau
  - Architecture modulaire par fonctionnalités
- Backend :
  
  - FastAPI pour l'API REST
  - TensorFlow pour les modèles ML
  - OpenCV pour le traitement d'image
  - SymPy pour la résolution symbolique


## Avantages de cette architecture
- Modularité : Chaque fonctionnalité est isolée et peut être développée indépendamment
- Maintenabilité : Organisation claire des fichiers par responsabilité
- Évolutivité : Facilité d'ajout de nouvelles fonctionnalités
- Réutilisabilité : Composants UI et services partagés entre les fonctionnalités
- Testabilité : Structure qui facilite l'écriture de tests unitaires et d'intégration