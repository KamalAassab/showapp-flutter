# ShowApp - Application de Gestion de Séries et Films

Une application Flutter pour gérer vos séries, films et animes préférés.

## Fonctionnalités

- Authentification utilisateur
- Gestion des shows (films, séries, animes)
- Ajout, modification et suppression de shows
- Interface utilisateur intuitive et responsive
- Stockage local des données
- Support multi-plateforme (Web, Android, iOS)

## Technologies Utilisées

- Flutter
- Dart
- HTTP pour les requêtes API
- Shared Preferences pour le stockage local
- Provider pour la gestion d'état

## Installation

1. Clonez le dépôt :
```bash
git clone [URL_DU_REPO]
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Lancez l'application :
```bash
flutter run
```

## Structure du Projet

```
lib/
├── config/
│   └── api_config.dart
├── screens/
│   ├── add_show_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── profile_page.dart
│   └── update_show_page.dart
├── services/
│   └── auth_service.dart
└── main.dart
```

## Captures d'écran

### Page d'accueil
<div style="display: flex; flex-wrap: wrap; gap: 20px; justify-content: center;">
  <img src="assets/screenshots/show_tv_show.png" alt="Liste des séries" width="200"/>
  <img src="assets/screenshots/show_movie.png" alt="Liste des films" width="200"/>
  <img src="assets/screenshots/show_anime.png" alt="Liste des animes" width="200"/>
</div>

### Gestion du profil
<div style="display: flex; flex-wrap: wrap; gap: 20px; justify-content: center;">
  <img src="assets/screenshots/edit_profile_1.png" alt="Page de profil" width="200"/>
  <img src="assets/screenshots/edit_profile_2.png" alt="Modification du profil" width="200"/>
</div>

### Modification d'un show
<div style="display: flex; flex-wrap: wrap; gap: 20px; justify-content: center;">
  <img src="assets/screenshots/edit_move_icon.png" alt="Icône de modification" width="200"/>
  <img src="assets/screenshots/edit_movie_page__update_page.png" alt="Page de modification" width="200"/>
</div>

### Ajout d'un show
<div style="display: flex; flex-wrap: wrap; gap: 20px; justify-content: center;">
  <img src="assets/screenshots/add_tv_show.png" alt="Page d'ajout de show" width="200"/>
</div>

## Configuration

1. Assurez-vous d'avoir Flutter installé sur votre machine
2. Configurez votre éditeur de code préféré (VS Code ou Android Studio)
3. Installez les extensions Flutter et Dart

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue sur GitHub.

---

## 🔐 **Connexion utilisateur** via l'API (authentification avec token JWT)
- 📄 **Affichage dynamique** des shows (classés par catégorie : films, animés, séries)
- ➕ **Ajout de show** (titre, description, catégorie, image)
- ✏️ **Mise à jour d'un show existant**
- ❌ **Suppression avec confirmation** (balayage latéral)
- 📸 **Sélection d'image** depuis la galerie ou l'appareil photo
- 🔄 **Rafraîchissement automatique** après chaque opération

---

## 🧱 Structure du Projet

```bash
.
├── backend/                # Backend Node.js + Express + SQLite
│   ├── server.js
│   ├── database.js
│   └── routes/
│       └── shows.js
├── flutter_app/            # Application Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/api_config.dart
│   │   ├── screens/
│   │   │   ├── login_page.dart
│   │   │   ├── home_page.dart
│   │   │   ├── profile_page.dart
│   │   │   ├── add_show_page.dart
│   │   │   └── update_show_page.dart
│   └── pubspec.yaml
