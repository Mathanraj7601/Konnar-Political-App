import 'dart:typed_data';

class RegistrationDraft {
  String name;
  String mobile;
  DateTime? dob;
  int age;
  String? gender;
  String? bloodGroup;
  String? profileImagePath;
  Uint8List? profileImageBytes;

  String? fatherName;
  String? voterId;
  String? aadhaarNumber;
  String? idProofPath;
  Uint8List? idProofBytes;
  String? idProofName;

  String? street;
  String? doorNumber;
  String? village;
  String? union;
  String? pincode;
  String? district;
  String? constituency;
  String? state;

  RegistrationDraft({
    this.name = '',
    this.mobile = '',
    this.dob,
    this.age = 0,
    this.gender,
    this.bloodGroup,
    this.profileImagePath,
    this.profileImageBytes,
    this.fatherName,
    this.voterId,
    this.aadhaarNumber,
    this.idProofPath,
    this.idProofBytes,
    this.idProofName,
    this.street,
    this.doorNumber,
    this.village,
    this.union,
    this.pincode,
    this.district,
    this.constituency,
    this.state = "Tamil Nadu",
  });
}
