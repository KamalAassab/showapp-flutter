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
![Page d'accueil - Films](assets/screenshots/show movie.png)
![Page d'accueil - Séries](assets/screenshots/show tv show.png)
![Page d'accueil - Animes](assets/screenshots/show anime.png)
*Affichage des shows par catégorie (films, séries, animes)*

### Ajout d'un show
![Ajout d'un show](assets/screenshots/add tv show.png)
*Formulaire d'ajout d'un nouveau show avec image*

### Modification d'un show
![Modification d'un show - Page](assets/screenshots/edit movie page ( update page).png)
![Modification d'un show - Icône](assets/screenshots/edit move icon.png)
*Édition des détails d'un show existant*

### Profil utilisateur
![Profil utilisateur - Édition 1](assets/screenshots/edit profile 1.png)
![Profil utilisateur - Édition 2](assets/screenshots/edit profile 2.png)
*Gestion du profil utilisateur*

### Liste des shows
![Liste des shows](assets/screenshots/shows_list.png)
*Affichage de tous les shows avec possibilité de swipe pour éditer/supprimer*

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

## Fonctionnalités

- 🔐 **Connexion utilisateur** via l'API (authentification avec token JWT)
- 📄 **Affichage dynamique** des shows (classés par catégorie : films, animés, séries)
- ➕ **Ajout de show** (titre, description, catégorie, image)
- ✏️ **Mise à jour d'un show existant**
- ❌ **Suppression avec confirmation** (balayage latéral)
- 📸 **Sélection d'image** depuis la galerie ou l'appareil photo
- 🔄 **Rafraîchissement automatique** après chaque opération

---

## Structure du Projet

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