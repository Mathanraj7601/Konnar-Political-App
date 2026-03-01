class Citizen {
  final String name;
  final String mobileNumber;
  final int age;
  final DateTime dateOfBirth;
  final String street;
  final String ward;
  final String voterId;
  final String pincode;
  final String district;
  final DateTime registeredAt;

  Citizen({
    required this.name,
    required this.mobileNumber,
    required this.age,
    required this.dateOfBirth,
    required this.street,
    required this.ward,
    required this.voterId,
    required this.pincode,
    required this.district,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
      'age': age,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'street': street,
      'ward': ward,
      'voterId': voterId,
      'pincode': pincode,
      'district': district,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      age: json['age'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      street: json['street'],
      ward: json['ward'],
      voterId: json['voterId'],
      pincode: json['pincode'],
      district: json['district'],
      registeredAt: DateTime.parse(json['registeredAt']),
    );
  }

  @override
  String toString() {
    return 'Citizen{name: $name, mobile: $mobileNumber, voterId: $voterId}';
  }
}
