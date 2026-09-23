class AppConstants {
  // 10.0.2.2 = host machine depuis l'émulateur Android
  // En production VPS : remplacer par https://ton-domaine.com/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Token storage key
  static const String tokenKey = 'auth_token';
  static const String userKey  = 'auth_user';
}
