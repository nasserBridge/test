import 'package:intl/intl.dart';

List<String> getRecentMonths() {
  // Function that builds a list containing the most recent 13 months.

  // An empty list object to store the latest 13 months.
  List<String> months = [];

  DateTime now = DateTime.now(); // Variable with the current date.

  // Keep count from 0 to 13
  for (int i = 0; i < 13; i++) {
    DateTime date = DateTime(
        now.year, now.month - i, now.day); // subtract i months based on count
    String formattedMonth =
        DateFormat('MMMM yyyy').format(date); // Format: Month Year
    months.add(formattedMonth); // add month to list
  }

  return months;
}
