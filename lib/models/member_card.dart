class MemberCard {
  final String partyName;
  final String memberName;
  final String memberId;
  final String mobileNumber;
  final String address;
  final DateTime dob;
  final int age;
  final String memberQrPayload;
  final String? profileImageUrl;
  final String? fatherName;
  final DateTime? dateOfJoining;
  final String? constituency;
  final String? district;

  const MemberCard({
    required this.partyName,
    required this.memberName,
    required this.memberId,
    required this.mobileNumber,
    required this.address,
    required this.dob,
    required this.age,
    required this.memberQrPayload,
    this.profileImageUrl,
    this.fatherName,
    this.dateOfJoining,
    this.constituency,
    this.district,
  });

  factory MemberCard.fromJson(Map<String, dynamic> json) {
    return MemberCard(
      partyName: (json["partyName"] ?? "").toString(),
      memberName: (json["memberName"] ?? json["full_name"] ?? "").toString(),
      memberId: (json["memberId"] ?? json["member_id_string"] ?? "").toString(),
      mobileNumber: (json["mobileNumber"] ?? json["mobile_number"] ?? "").toString(),
      address: (json["address"] ?? "").toString(),
      dob:
          DateTime.tryParse((json["dob"] ?? "").toString()) ??
          DateTime(1970, 1, 1),
      age: int.tryParse((json["age"] ?? "0").toString()) ?? 0,
      memberQrPayload: (json["memberQrPayload"] ?? "").toString(),
      profileImageUrl: json["profileImageUrl"]?.toString(),
      fatherName: (json["fatherName"] ?? json["father_name"] ?? "").toString(),
      dateOfJoining: DateTime.tryParse((json["dateOfJoining"] ?? json["date_of_joining"] ?? "").toString()),
      constituency: (json["constituency"] ?? "").toString(),
      district: (json["district"] ?? "").toString(),
    );
  }
}
