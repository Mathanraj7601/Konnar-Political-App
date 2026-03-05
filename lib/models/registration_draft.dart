class RegistrationDraft {
  final String name;
  final String mobile;
  final DateTime dob;
  final int age;
  final String? profileImagePath;

  const RegistrationDraft({
    required this.name,
    required this.mobile,
    required this.dob,
    required this.age,
    this.profileImagePath,
  });
}
