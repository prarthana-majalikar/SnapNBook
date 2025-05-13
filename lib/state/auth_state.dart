class UserSession {
  final String userId;
  final String email;
  final String role;
  final String idToken;
  final String accessToken;

  const UserSession({
    required this.userId,
    required this.email,
    required this.role,
    required this.idToken,
    required this.accessToken,
  });

  bool get isTechnician => role == 'technician';
}
