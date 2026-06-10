/// String extensions for the entire platform
extension StringExtensions on String {
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get capitalizeWords => split(' ').map((w) => w.capitalize).join(' ');
  String get initials => split(' ').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase()).take(2).join();
  String get toPhoneFormatted {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+48') && cleaned.length == 12) {
      return '+48 ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }
    return this;
  }
  bool get isValidPhone => RegExp(r'^\+48\d{9}$').hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  bool get isValidEmail => RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(this);
  String truncate(int maxLength) => length > maxLength ? '${substring(0, maxLength)}...' : this;
}

extension DateTimeExtensions on DateTime {
  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'przed chwilą';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
    if (diff.inHours < 24) return '${diff.inHours}h temu';
    if (diff.inDays < 7) return '${diff.inDays} dni temu';
    return polish;
  }
  String get polish {
    const m = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return '$day ${m[month - 1]} $year';
  }
  String get timeStr => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  int get age => DateTime.now().difference(this).inDays ~/ 365;
  bool get isToday => DateTime.now().difference(this).inDays == 0 && day == DateTime.now().day;
  bool get isYesterday => DateTime.now().difference(this).inDays == 1;
}
