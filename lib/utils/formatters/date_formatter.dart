/// Date formatting utilities for the entire platform
class DateFormatter {
  DateFormatter._();

  static String relative(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'przed chwilą';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
    if (diff.inHours < 24) return '${diff.inHours}h temu';
    if (diff.inDays < 7) return '${diff.inDays} dni temu';
    return polish(dt);
  }

  static String polish(DateTime dt) {
    const m = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  static String time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String dayName(DateTime dt) {
    const d = ['poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek', 'sobota', 'niedziela'];
    return d[dt.weekday - 1];
  }

  static String conversationTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return 'Dziś, ${time(dt)}';
    if (now.difference(dt).inDays == 1) return 'Wczoraj, ${time(dt)}';
    return '${polish(dt)}, ${time(dt)}';
  }
}
