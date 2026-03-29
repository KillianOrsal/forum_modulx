============================================
ModulX - Guide d'installation et lancement

============================================

Prérequis :
-----------
- Flutter SDK installé (https://docs.flutter.dev/get-started/install)
- Dart SDK (inclus avec Flutter)
- Google Chrome installé


============================================
  1. INITIALISATION (après clone du projet)

============================================

Ouvrir un terminal à la racine du projet, puis :

  a) Installer les dépendances Flutter :

     flutter pub get

  b) Installer les dépendances du serveur :

     cd server
     dart pub get
     cd ..


============================================

  2. LANCEMENT

============================================

Il faut lancer 2 terminaux en parallèle :

  TERMINAL 1 — Serveur API (Dart) :

     cd server
     dart run bin/server.dart

     → Le serveur démarre sur http://localhost:8081
     → Gardez ce terminal ouvert


  TERMINAL 2 — Application Flutter (Web) :

     flutter run -d chrome

     → L'application s'ouvre dans Google Chrome
     → Gardez ce terminal ouvert


============================================

  3. UTILISATION

============================================

- Le site est accessible dans Chrome une fois lancé
- Créez un compte via "Se connecter" > "S'inscrire"
- Une fois connecté, vous pouvez :
    • Ajouter des modèles 3D
    • Commenter les modèles
    • Voir votre profil et gérer vos modèles

============================================

  4. ARRÊT

============================================

- Dans chaque terminal, appuyez sur Ctrl+C pour stopper
  le serveur et l'application Flutter.
