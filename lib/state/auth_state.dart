class UserSession {
  final String userId;
  final String email;
  final String role;
  final String idToken;
  final String accessToken;
  final String firstName;
  final String lastName;
  final String mobile;

  const UserSession({
    required this.userId,
    required this.email,
    required this.role,
    required this.idToken,
    required this.accessToken,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  bool get isTechnician => role == 'technician';

  String get fullName => '$firstName $lastName';
}
