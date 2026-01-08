import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class RegisterStudentController {
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Contrôleurs pour les informations personnelles
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Contrôleurs pour les informations académiques
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController currentLevelController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController scholarshipTypeController =
      TextEditingController();
  final TextEditingController internshipSearchController =
      TextEditingController();
  final TextEditingController extracurricularActivitiesController =
      TextEditingController();
  final TextEditingController averageGradeController = TextEditingController();

  // Variables d'état
  bool isLoading = false;
  DateTime? dateOfBirth;
  PlatformFile? identityDocument;
  String identityFilePath = '';

  // Variables pour les listes de sélection
  List<String> selectedCommunicationPrefs = [];
  List<String> housingNeeds = [];
  List<String> computerSkills = [];
  List<String> interests = [];
  bool isScholarship = false;

  // Options pour les dropdowns
  final List<String> levelOptions = [
    'Licence 1',
    'Licence 2',
    'Licence 3',
    'Master 1',
    'Master 2',
    'Doctorat',
    'BTS 1',
    'BTS 2',
    'DUT 1',
    'DUT 2',
    'Classe préparatoire',
    'École d\'ingénieur',
    'École de commerce',
    'Autre',
  ];

  final List<String> majorOptions = [
    'Informatique',
    'Mathématiques',
    'Physique',
    'Chimie',
    'Biologie',
    'Médecine',
    'Droit',
    'Économie',
    'Gestion',
    'Marketing',
    'Communication',
    'Littérature',
    'Langues',
    'Histoire',
    'Géographie',
    'Psychologie',
    'Sociologie',
    'Arts',
    'Architecture',
    'Ingénierie',
    'Autre',
  ];

  final List<String> academicYearOptions = [
    '2024-2025',
    '2025-2026',
    '2026-2027',
    '2027-2028',
  ];

  final List<String> communicationPrefs = [
    'Email',
    'SMS',
    'Notifications push',
    'Courrier postal',
  ];

  final List<String> housingOptions = [
    'Résidence universitaire',
    'Appartement partagé',
    'Studio',
    'Famille d\'accueil',
    'Autre',
  ];

  final List<String> computerSkillOptions = [
    'Bureautique (Word, Excel, PowerPoint)',
    'Programmation',
    'Design graphique',
    'Montage vidéo',
    'Réseaux sociaux',
    'Bases de données',
    'Développement web',
    'Cybersécurité',
    'Intelligence artificielle',
    'Autre',
  ];

  final List<String> interestOptions = [
    'Sport',
    'Musique',
    'Lecture',
    'Cinéma',
    'Voyage',
    'Cuisine',
    'Photographie',
    'Jeux vidéo',
    'Art',
    'Sciences',
    'Technologie',
    'Bénévolat',
    'Entrepreneuriat',
    'Autre',
  ];

  RegisterStudentController(this.context);

  // Méthodes de validation
  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);
  String? validateField(String? value) => Validators.validateField(value);

  // Méthode pour sélectionner la date de naissance
  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 ans
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null && picked != dateOfBirth) {
      dateOfBirth = picked;
      dateOfBirthController.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
      _refresh();
    }
  }

  // Méthode pour sélectionner le document d'identité
  Future<void> pickIdentityDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        identityDocument = result.files.first;
        identityFilePath = identityDocument!.path ?? '';
        _refresh();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du fichier: $e')),
      );
    }
  }

  // Méthodes pour gérer les listes de sélection
  void toggleCommunicationPref(String pref) {
    if (selectedCommunicationPrefs.contains(pref)) {
      selectedCommunicationPrefs.remove(pref);
    } else {
      selectedCommunicationPrefs.add(pref);
    }
    _refresh();
  }

  void toggleHousingNeed(String need) {
    if (housingNeeds.contains(need)) {
      housingNeeds.remove(need);
    } else {
      housingNeeds.add(need);
    }
    _refresh();
  }

  void toggleComputerSkill(String skill) {
    if (computerSkills.contains(skill)) {
      computerSkills.remove(skill);
    } else {
      computerSkills.add(skill);
    }
    _refresh();
  }

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    _refresh();
  }

  void toggleScholarship(bool value) {
    isScholarship = value;
    if (!value) {
      scholarshipTypeController.clear();
    }
    _refresh();
  }

  // Formatage de la date pour l'API
  String _formatDateForAPI(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Méthode d'inscription
  Future<void> registerStudent() async {
    if (!formKey.currentState!.validate()) return;

    // Validation supplémentaire
    if (dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
        ),
      );
      return;
    }

    if (identityDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez télécharger votre document d\'identité'),
        ),
      );
      return;
    }

    isLoading = true;
    _refresh();

    try {
      // Préparer les données selon le sérialiseur backend
      // Le sérialiseur StudentRegistrationSerializer n'accepte que:
      // - current_level (requis)
      // - major (optionnel)
      // - interests (optionnel, liste)
      final body = {
        // Champs de base User (requis par UserRegistrationSerializer)
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "password_confirm": passwordController.text.trim(),
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "date_of_birth": _formatDateForAPI(dateOfBirth),
        "type": "student",
        
        // Champs optionnels User
        if (selectedCommunicationPrefs.isNotEmpty)
          "communication_preferences": selectedCommunicationPrefs,
        "data_processing_consent": true,
        "image_rights_consent": true,
        
        // Champs spécifiques Student (acceptés par le sérialiseur)
        "current_level": currentLevelController.text.trim(),
        if (majorController.text.trim().isNotEmpty)
          "major": majorController.text.trim(),
        if (interests.isNotEmpty)
          "interests": interests,
      };

      final response = await AuthService.registerStudent(body: body);

    // Connecter l'utilisateur automatiquement et sauvegarder les tokens
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(
      response['token'], 
      response['user'],
      refreshToken: response['refreshToken'],
    );

    // Rediriger vers la page de succès
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.successRegistration,
      (route) => false,
      arguments: response['user'],
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    isLoading = false;
    _refresh();
  }
}



  // Méthode pour rafraîchir l'interface
  void _refresh() {
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  // Méthode de nettoyage
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    institutionController.dispose();
    currentLevelController.dispose();
    majorController.dispose();
    academicYearController.dispose();
    studentIdController.dispose();
    scholarshipTypeController.dispose();
    internshipSearchController.dispose();
    extracurricularActivitiesController.dispose();
    averageGradeController.dispose();
  }
}
