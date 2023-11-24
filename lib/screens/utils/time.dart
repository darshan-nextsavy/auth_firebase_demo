class Time {
  static String getTimeTitle(time) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    int currentdate = DateTime.now().microsecondsSinceEpoch;
    var postMicro = Duration(microseconds: time);
    var currentDateMicro = Duration(microseconds: currentdate);
    int second = currentDateMicro.inSeconds - postMicro.inSeconds;
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(time);

    if (second < 60) {
      return '$second second ago';
    } else if (second < 3600) {
      return '${(second / 60).toStringAsFixed(0)} min ago';
    } else if (second < 3600 * 24) {
      return '${(second / 3600).toStringAsFixed(0)} hour ago';
    } else if (second < 3600 * 24 * 2) {
      return 'Yester day';
    } else {
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
