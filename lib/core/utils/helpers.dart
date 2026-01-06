/// Currency formatting utilities
class CurrencyHelper {
  CurrencyHelper._();

  /// Format number as Indonesian Rupiah
  /// Example: 350000 -> "Rp 350.000"
  static String formatRupiah(num amount, {bool showSymbol = true}) {
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return showSymbol ? 'Rp $formatted' : formatted;
  }

  /// Format price per hour
  /// Example: 350000 -> "Rp 350.000/jam"
  static String formatPricePerHour(num amount) {
    return '${formatRupiah(amount)}/jam';
  }

  /// Parse formatted currency string back to number
  /// Example: "Rp 350.000" -> 350000
  static int? parseRupiah(String formatted) {
    final cleaned = formatted
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return int.tryParse(cleaned);
  }
}

/// Date formatting utilities
class DateHelper {
  DateHelper._();

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  /// Format date as "12 Januari 2024"
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  /// Format date as "Senin, 12 Jan 2024"
  static String formatDateWithDay(DateTime date) {
    final dayName = _dayNames[date.weekday - 1];
    final monthShort = _monthNames[date.month - 1].substring(0, 3);
    return '$dayName, ${date.day} $monthShort ${date.year}';
  }

  /// Format time as "08:30"
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format datetime as "12 Jan, 08:30"
  static String formatDateTime(DateTime date) {
    final monthShort = _monthNames[date.month - 1].substring(0, 3);
    return '${date.day} $monthShort, ${formatTime(date)}';
  }

  /// Get relative time string (e.g., "5 menit lalu", "Kemarin")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    }
    if (difference.inDays == 1) {
      return 'Kemarin';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    }
    return formatDate(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}

/// String utilities
class StringHelper {
  StringHelper._();

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Get initials from name
  /// Example: "John Doe" -> "JD"
  static String getInitials(String name, {int count = 2}) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    
    final initials = parts.take(count).map((p) => p[0].toUpperCase()).join();
    return initials;
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Check if string is valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if string is valid phone number (Indonesian format)
  static bool isValidPhone(String phone) {
    return RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$').hasMatch(phone);
  }
}

/// Distance utilities
class DistanceHelper {
  DistanceHelper._();

  /// Format distance in km or m
  /// Example: 1500 -> "1.5 km", 500 -> "500 m"
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  /// Format duration in hours and minutes
  /// Example: 90 -> "1 jam 30 menit"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours jam';
    }
    return '$hours jam $mins menit';
  }

  /// Format ETA
  /// Example: 15 -> "~15 menit"
  static String formatEta(int minutes) {
    return '~${formatDuration(minutes)}';
  }
}
