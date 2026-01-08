/// Configuration de l'API backend
/// 
/// Modifiez cette valeur selon votre environnement:
/// - Développement local: http://127.0.0.1:8000
/// - Émulateur Android: http://10.0.2.2:8000
/// - Réseau local: http://VOTRE_IP_LOCALE:8000
/// - Production: https://votre-domaine.com
class ApiConfig {
  // URL de base du backend Django
  // Pour Android Emulator, utilisez: http://10.0.2.2:8000
  // Pour iOS Simulator ou appareil physique, utilisez: http://127.0.0.1:8000 ou votre IP locale
  static const String baseUrl = "http://127.0.0.1:8000";
  
  // Préfixe de l'API
  static const String apiPrefix = "/api";
  
  // URL complète de l'API
  static String get apiBaseUrl => "$baseUrl$apiPrefix";
  
  // Timeout pour les requêtes HTTP (en secondes)
  static const int requestTimeout = 30;
  
  // Vérifier si on est en mode développement
  static bool get isDevelopment => const bool.fromEnvironment('dart.vm.product') == false;
}

