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
  });

  factory MemberCard.fromJson(Map<String, dynamic> json) {
    return MemberCard(
      partyName: (json["partyName"] ?? "").toString(),
      memberName: (json["memberName"] ?? "").toString(),
      memberId: (json["memberId"] ?? "").toString(),
      mobileNumber: (json["mobileNumber"] ?? "").toString(),
      address: (json["address"] ?? "").toString(),
      dob:
          DateTime.tryParse((json["dob"] ?? "").toString()) ??
          DateTime(1970, 1, 1),
      age: int.tryParse((json["age"] ?? "0").toString()) ?? 0,
      memberQrPayload: (json["memberQrPayload"] ?? "").toString(),
      profileImageUrl: json["profileImageUrl"]?.toString(),
    );
  }
}
