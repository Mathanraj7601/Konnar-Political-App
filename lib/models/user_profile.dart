class UserProfile {
  final String id;
  final String name;
  final String mobile;
  final DateTime dob;
  final int age;
  final String street;
  final String doorNumber;
  final String village;
  final String taluk;
  final String pincode;
  final String memberId;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.mobile,
    required this.dob,
    required this.age,
    required this.street,
    required this.doorNumber,
    required this.village,
    required this.taluk,
    required this.pincode,
    required this.memberId,
    this.createdAt,
  });

  String get address => "$doorNumber, $street, $village, $taluk - $pincode";

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) {
        return fallback ?? DateTime(1970, 1, 1);
      }

      return DateTime.tryParse(value.toString()) ??
          (fallback ?? DateTime(1970, 1, 1));
    }

    return UserProfile(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      mobile: (json["mobile"] ?? "").toString(),
      dob: parseDate(json["dob"]),
      age: int.tryParse((json["age"] ?? "0").toString()) ?? 0,
      street: (json["street"] ?? "").toString(),
      doorNumber: (json["doorNumber"] ?? json["door_number"] ?? "").toString(),
      village: (json["village"] ?? "").toString(),
      taluk: (json["taluk"] ?? "").toString(),
      pincode: (json["pincode"] ?? "").toString(),
      memberId: (json["memberId"] ?? json["member_id"] ?? "").toString(),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : DateTime.tryParse((json["created_at"] ?? "").toString()),
    );
  }
}
