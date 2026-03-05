import "package:intl/intl.dart";

int calculateAge(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;

  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age -= 1;
  }

  return age;
}

String formatDateLong(DateTime date) {
  return DateFormat("dd MMM yyyy").format(date);
}

String formatDateIso(DateTime date) {
  return DateFormat("yyyy-MM-dd").format(date);
}
