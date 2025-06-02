class AppUser {
  final String uid;
  final String name;
  final String email;
  final String profilePhoto;
  final String role;
  final bool onboarded;
  final Map<String, dynamic> settings;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePhoto,
    required this.role,
    required this.onboarded,
    required this.settings,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePhoto: data['profilePhoto'] ?? '',
      role: data['role'] ?? 'user',
      onboarded: data['onboarded'] ?? false,
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
    );
  }
}
