# Instructions de Connexion au Backend

## ✅ Modifications effectuées

### 1. Configuration centralisée de l'API
- ✅ Création de `lib/core/constants/api_config.dart` pour gérer l'URL de base de l'API
- ✅ Mise à jour de `api_endpoints.dart` pour utiliser la configuration centralisée
- ✅ Configuration flexible pour différents environnements (local, émulateur, production)

### 2. Correction des données d'inscription
- ✅ Alignement des données d'inscription étudiant avec le sérialiseur backend
- ✅ Le sérialiseur accepte uniquement: `current_level`, `major`, `interests`
- ✅ Les autres champs peuvent être mis à jour via le profil après l'inscription

### 3. Gestion des tokens
- ✅ Sauvegarde automatique des tokens (access + refresh) dans SharedPreferences
- ✅ Mise à jour de `AuthProvider.login()` pour sauvegarder les tokens
- ✅ Correction du service de login pour retourner le refreshToken

## 🚀 Configuration initiale

### 1. Configurer l'URL de l'API

Ouvrez `lib/core/constants/api_config.dart` et modifiez l'URL selon votre environnement:

**Pour développement local (Windows/Mac/Linux):**
```dart
static const String baseUrl = "http://127.0.0.1:8000";
```

**Pour émulateur Android:**
```dart
static const String baseUrl = "http://10.0.2.2:8000";
```

**Pour appareil physique (même réseau WiFi):**
```dart
static const String baseUrl = "http://VOTRE_IP_LOCALE:8000";
// Exemple: http://192.168.1.100:8000
```

### 2. Démarrer le backend Django

```bash
cd "D:\ENTREPRISE Freelance\VIDO EMPIRE\VIDO GROUP\VIDO TECH\PROJETS\VIDO SCHOOL\Vido-School__backend"
python manage.py runserver
```

Le serveur devrait être accessible sur `http://127.0.0.1:8000`

### 3. Vérifier la configuration CORS

Assurez-vous que dans `vido_school/settings/dev.py`:
```python
CORS_ALLOW_ALL_ORIGINS = True
```

## 🧪 Test de l'inscription

### Test d'inscription étudiant

1. Lancez l'application Flutter
2. Naviguez vers l'écran d'inscription étudiant
3. Remplissez les champs obligatoires:
   - Email
   - Mot de passe (min 8 caractères)
   - Prénom
   - Nom
   - Téléphone
   - Date de naissance
   - Document d'identité
   - Niveau actuel (current_level) - **OBLIGATOIRE**
   - Spécialité (major) - optionnel
   - Centres d'intérêt (interests) - optionnel

4. Soumettez le formulaire
5. Vérifiez dans les logs du backend que l'inscription est réussie
6. Vérifiez que l'utilisateur est automatiquement connecté après l'inscription

### Vérification dans la base de données

Connectez-vous à votre base de données et vérifiez:
```sql
SELECT * FROM accounts_user WHERE email = 'email_test@example.com';
SELECT * FROM accounts_student WHERE user_id = (SELECT id FROM accounts_user WHERE email = 'email_test@example.com');
```

## 🔍 Dépannage

### Erreur: "Erreur de connexion"
- ✅ Vérifiez que le backend Django est démarré
- ✅ Vérifiez l'URL dans `api_config.dart`
- ✅ Vérifiez que le port 8000 n'est pas utilisé par un autre service

### Erreur: "CORS policy"
- ✅ Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` dans les settings de développement
- ✅ Vérifiez que `corsheaders` est dans `INSTALLED_APPS`

### Erreur: "Les mots de passe ne correspondent pas"
- ✅ Le backend vérifie que `password` et `password_confirm` sont identiques
- ✅ Vérifiez que les deux champs sont bien remplis

### Erreur: "current_level is required"
- ✅ Le champ `current_level` est obligatoire pour l'inscription étudiant
- ✅ Assurez-vous qu'il est bien rempli dans le formulaire

### Les tokens ne sont pas sauvegardés
- ✅ Vérifiez que `SharedPreferences` est bien importé
- ✅ Vérifiez les logs pour voir si une erreur se produit lors de la sauvegarde

## 📝 Notes importantes

1. **Champs d'inscription étudiant**: Seuls `current_level`, `major`, et `interests` sont acceptés lors de l'inscription. Les autres champs (institution_name, academic_year, etc.) peuvent être mis à jour via le profil après l'inscription.

2. **Document d'identité**: Le champ `identity_document` n'est pas encore géré dans le sérialiseur d'inscription étudiant. Il faudra peut-être l'ajouter au backend ou le gérer séparément.

3. **Tokens**: Les tokens sont automatiquement sauvegardés dans SharedPreferences et utilisés pour les requêtes suivantes.

4. **Refresh Token**: Le refresh token est utilisé automatiquement quand le access token expire.

## 🔄 Prochaines étapes

1. Tester l'inscription pour les autres types d'utilisateurs (élève, enseignant, conseiller)
2. Implémenter la mise à jour du profil pour compléter les informations après l'inscription
3. Ajouter la gestion des fichiers (document d'identité) si nécessaire
4. Tester sur différents appareils et environnements

