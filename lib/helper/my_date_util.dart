import 'package:flutter/material.dart';

class MyDateUtil {
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    } else {
      return '${sent.day} ${_getMonth(sent)}';
    }
  }

  static String _getMonth(DateTime date) {
    int m = date.month;

    if (m == 1) return 'Jan';
    if (m == 2) return 'Feb';
    if (m == 3) return 'Mar';
    if (m == 4) return 'Apr';
    if (m == 5) return 'May';
    if (m == 6) return 'Jun';
    if (m == 7) return 'Jul';
    if (m == 8) return 'Aug';
    if (m == 9) return 'Sep';
    if (m == 10) return 'Oct';
    if (m == 11) return 'Nov';
    if (m == 12) return 'Dec';

    return '';
  }
}
