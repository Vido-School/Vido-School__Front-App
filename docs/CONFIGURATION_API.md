# Configuration de l'API Backend

## Configuration de l'URL de base

L'URL de base de l'API est configurée dans le fichier `lib/core/constants/api_config.dart`.

### Pour différents environnements :

1. **Développement local (Windows/Mac/Linux)**
   ```dart
   static const String baseUrl = "http://127.0.0.1:8000";
   ```

2. **Émulateur Android**
   ```dart
   static const String baseUrl = "http://10.0.2.2:8000";
   ```
   Note: L'émulateur Android utilise `10.0.2.2` pour accéder à `localhost` de la machine hôte.

3. **Appareil physique (même réseau WiFi)**
   ```dart
   static const String baseUrl = "http://VOTRE_IP_LOCALE:8000";
   ```
   Exemple: `http://192.168.1.100:8000`
   
   Pour trouver votre IP locale:
   - Windows: `ipconfig` dans PowerShell
   - Mac/Linux: `ifconfig` ou `ip addr`

4. **Production**
   ```dart
   static const String baseUrl = "https://votre-domaine.com";
   ```

## Démarrage du backend

Assurez-vous que le serveur Django est démarré :

```bash
cd "D:\ENTREPRISE Freelance\VIDO EMPIRE\VIDO GROUP\VIDO TECH\PROJETS\VIDO SCHOOL\Vido-School__backend"
python manage.py runserver
```

Le serveur devrait être accessible sur `http://127.0.0.1:8000`

## Vérification de la connexion

1. Vérifiez que le backend est accessible en ouvrant `http://127.0.0.1:8000/api/accounts/` dans votre navigateur
2. Vérifiez les logs du backend pour voir les requêtes entrantes
3. Vérifiez que CORS est configuré correctement dans les settings Django

## Endpoints disponibles

- Inscription étudiant: `POST /api/accounts/register/student/`
- Inscription élève: `POST /api/accounts/register/pupil/`
- Inscription enseignant: `POST /api/accounts/register/teacher/`
- Inscription conseiller: `POST /api/accounts/register/advisor/`
- Connexion: `POST /api/accounts/login/`

## Dépannage

### Erreur de connexion
- Vérifiez que le backend est démarré
- Vérifiez l'URL dans `api_config.dart`
- Vérifiez les logs du backend pour les erreurs

### Erreur CORS
- Assurez-vous que `CORS_ALLOW_ALL_ORIGINS = True` dans les settings de développement
- Vérifiez que `corsheaders` est dans `INSTALLED_APPS`

### Erreur 401/403
- Vérifiez que les tokens sont correctement envoyés dans les headers
- Vérifiez que l'utilisateur est bien authentifié

