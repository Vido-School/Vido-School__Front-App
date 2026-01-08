class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profilePicture;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? identityDocument;
  final bool dataProcessingConsent;
  final bool imageRightsConsent;
  final List<dynamic> communicationPreferences;
  final Map<String, dynamic> languages;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final DateTime dateJoined;
  final bool isActive;
  final bool isStaff;
  final String type; // Correspond à 'role' dans votre ancien modèle
  final String verificationStatus;
  final DateTime? verificationRequestedDate;
  final DateTime? verificationCompletedDate;
  final String? verificationNotes;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.type,
    required this.verificationStatus,
    required this.dateJoined,
    required this.isActive,
    required this.isStaff,
    this.phoneNumber,
    this.dateOfBirth,
    this.profilePicture,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.identityDocument,
    this.dataProcessingConsent = false,
    this.imageRightsConsent = false,
    this.communicationPreferences = const [],
    this.languages = const {},
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.verificationRequestedDate,
    this.verificationCompletedDate,
    this.verificationNotes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Creating UserModel from JSON: $json');
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? 'N/A', // Changed default
      lastName: json['last_name'] as String? ?? 'N/A', // Changed default
      type: json['type'] as String? ?? 'student',
      verificationStatus:
          json['verification_status'] as String? ?? 'unverified',
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? false,
      isStaff: json['is_staff'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      profilePicture: json['profile_picture'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      country: json['country'],
      identityDocument: json['identity_document'],
      dataProcessingConsent: json['data_processing_consent'] ?? false,
      imageRightsConsent: json['image_rights_consent'] ?? false,
      communicationPreferences: json['communication_preferences'] ?? [],
      languages: Map<String, dynamic>.from(json['languages'] ?? {}),
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelation: json['emergency_contact_relation'],
      verificationRequestedDate: json['verification_requested_date'] != null
          ? DateTime.parse(json['verification_requested_date'])
          : null,
      verificationCompletedDate: json['verification_completed_date'] != null
          ? DateTime.parse(json['verification_completed_date'])
          : null,
      verificationNotes: json['verification_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'type': type,
      'verification_status': verificationStatus,
      'date_joined': dateJoined.toIso8601String(),
      'is_active': isActive,
      'is_staff': isStaff,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_picture': profilePicture,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'identity_document': identityDocument,
      'data_processing_consent': dataProcessingConsent,
      'image_rights_consent': imageRightsConsent,
      'communication_preferences': communicationPreferences,
      'languages': languages,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'verification_requested_date': verificationRequestedDate
          ?.toIso8601String(),
      'verification_completed_date': verificationCompletedDate
          ?.toIso8601String(),
      'verification_notes': verificationNotes,
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profilePicture,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? identityDocument,
    bool? dataProcessingConsent,
    bool? imageRightsConsent,
    List<dynamic>? communicationPreferences,
    Map<String, dynamic>? languages,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    DateTime? dateJoined,
    bool? isActive,
    bool? isStaff,
    String? type,
    String? verificationStatus,
    DateTime? verificationRequestedDate,
    DateTime? verificationCompletedDate,
    String? verificationNotes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      identityDocument: identityDocument ?? this.identityDocument,
      dataProcessingConsent:
          dataProcessingConsent ?? this.dataProcessingConsent,
      imageRightsConsent: imageRightsConsent ?? this.imageRightsConsent,
      communicationPreferences:
          communicationPreferences ?? this.communicationPreferences,
      languages: languages ?? this.languages,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      dateJoined: dateJoined ?? this.dateJoined,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      type: type ?? this.type,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationRequestedDate:
          verificationRequestedDate ?? this.verificationRequestedDate,
      verificationCompletedDate:
          verificationCompletedDate ?? this.verificationCompletedDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }

  bool get isVerified => verificationStatus == 'verified';
  bool get isPendingVerification => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
}
