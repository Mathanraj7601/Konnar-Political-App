import "package:intl/intl.dart";

class RegistrationRequest {
  final String name;
  final String mobile;
  final DateTime dob;
  final String street;
  final String doorNumber;
  final String village;
  final String taluk;
  final String pincode;
  final String verificationToken;

  const RegistrationRequest({
    required this.name,
    required this.mobile,
    required this.dob,
    required this.street,
    required this.doorNumber,
    required this.village,
    required this.taluk,
    required this.pincode,
    required this.verificationToken,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "dob": DateFormat("yyyy-MM-dd").format(dob),
      "street": street,
      "door_number": doorNumber,
      "village": village,
      "taluk": taluk,
      "pincode": pincode,
      "verification_token": verificationToken,
    };
  }
}
