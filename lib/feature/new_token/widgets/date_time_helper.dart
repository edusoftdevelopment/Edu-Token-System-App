
class DateTimeHelper {
  static String getFormattedCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} '
        'at ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}
