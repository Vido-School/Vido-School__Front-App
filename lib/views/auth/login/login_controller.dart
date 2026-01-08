import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class LoginController extends ChangeNotifier {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginController(this.context);

  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      final authData = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        authData['token'], 
        authData['user'],
        refreshToken: authData['refreshToken'],
      );

      // Ajoutez un debug print pour vérifier l'utilisateur
      debugPrint('Logged in user: ${authData['user'].toString()}');

      await AppRoutes.navigateToMainApp(context, authData['user']);
    } on ApiException catch (e) {
      print(e);
      final errorMsg = _getErrorMessage(e.statusCode);
      _showError(errorMsg);
    } catch (e) {
      _showError('Erreur inattendue: ${e.toString()}');
      print(e);
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Identifiants incorrects';
      case 500:
        return 'Erreur serveur - Veuillez réessayer plus tard';
      default:
        return 'Échec de la connexion';
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ignore: unused_element
  void _handleError(dynamic error) {
    String errorMessage = 'Erreur de connexion';

    if (error is Map<String, dynamic>) {
      errorMessage = error['message'] ?? error['detail'] ?? errorMessage;
    } else if (error is String) {
      errorMessage = error;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
    debugPrint('Login Error: $error');
  }

  void goToRegister() {
    if (context.mounted) {
      Navigator.pushNamed(context, AppRoutes.chooseRole);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
