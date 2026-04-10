class MemberCard {
  final String? memberIdString;
  final String? fullName;
  final String? fatherName;
  final String? mobileNumber;
  final String? district;
  final String? constituency;
  final String? bloodGroup;
  final DateTime? dob;
  final String? gender;
  final DateTime? dateOfJoining;
  final String? profileImageUrl;
  final String? memberQrPayload;

  String? get memberName => fullName;
  String? get memberId => memberIdString;

  MemberCard({
    this.memberIdString,
    this.fullName,
    this.fatherName,
    this.mobileNumber,
    this.district,
    this.constituency,
    this.bloodGroup,
    this.dob,
    this.gender,
    this.dateOfJoining,
    this.profileImageUrl,
    this.memberQrPayload,
  });

  factory MemberCard.fromJson(Map<String, dynamic> json) {
    return MemberCard(
      memberIdString: json['member_id_string']?.toString(),
      fullName: json['full_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      district: json['district']?.toString(),
      constituency: json['constituency']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      dob: json['dob'] != null 
          ? DateTime.tryParse(json['dob'].toString()) 
          : null,
      gender: json['gender']?.toString(),
      dateOfJoining: json['date_of_joining'] != null
          ? DateTime.tryParse(json['date_of_joining'].toString())
          : null,
      profileImageUrl: json['profile_image_url']?.toString(),
      memberQrPayload: json['member_qr_payload']?.toString(),
    );
  }
}