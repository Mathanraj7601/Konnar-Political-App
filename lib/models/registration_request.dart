import "package:intl/intl.dart";

class RegistrationRequest {
  final String name;
  final String mobile;
  final DateTime dob;
  final String gender;
  final String? bloodGroup;
  final String fatherName;
  final String? voterId;
  final String? aadhaarNumber;
  final String street;
  final String doorNumber;
  final String village;
  final String? union;
  final String taluk;
  final String district;
  final String state;
  final String pincode;
  final String verificationToken;
  final String? profileImagePath;
  final String? idProofPath;

  const RegistrationRequest({
    required this.name,
    required this.mobile,
    required this.dob,
    required this.gender,
    this.bloodGroup,
    required this.fatherName,
    this.voterId,
    this.aadhaarNumber,
    required this.street,
    required this.doorNumber,
    required this.village,
    this.union,
    required this.taluk,
    required this.district,
    required this.state,
    required this.pincode,
    required this.verificationToken,
    this.profileImagePath,
    this.idProofPath,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "dob": DateFormat("yyyy-MM-dd").format(dob),
      "gender": gender,
      if (bloodGroup != null && bloodGroup!.isNotEmpty) "blood_group": bloodGroup,
      "father_name": fatherName,
      if (voterId != null && voterId!.isNotEmpty) "voter_id": voterId,
      if (aadhaarNumber != null && aadhaarNumber!.isNotEmpty) "aadhaar_number": aadhaarNumber,
      "street": street,
      "door_number": doorNumber,
      "village": village,
      if (union != null && union!.isNotEmpty) "union": union,
      "taluk": taluk,
      "district": district,
      "state": state,
      "pincode": pincode,
      "verification_token": verificationToken,
      if (profileImagePath != null && profileImagePath!.isNotEmpty) "profile_image_path": profileImagePath,
      if (idProofPath != null && idProofPath!.isNotEmpty) "id_proof_path": idProofPath,
    };
  }
}
