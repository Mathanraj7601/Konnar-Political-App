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

  String? street;
  String? doorNumber;
  String? village;
  String? pincode;
  String? district;
  String? constituency;
  String? state;

  RegistrationDraft({
    this.name = '',
    this.mobile = '',
    this.dob,
    this.age = 0,
    this.gender = 'Male',
    this.bloodGroup,
    this.profileImagePath,
    this.profileImageBytes,
    this.fatherName,
    this.voterId,
    this.aadhaarNumber,
    this.idProofPath,
    this.street,
    this.doorNumber,
    this.village,
    this.pincode,
    this.district,
    this.constituency,
    this.state = "Tamil Nadu",
  });
}
