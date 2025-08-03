// ignore_for_file: avoid_print

class Earthquake {
  final String earthquakeId;
  final String provider;
  final String title;
  final String date;
  final double mag;
  final double depth;
  final Map<String, dynamic> geojson;
  final Map<String, dynamic> locationProperties;
  final DateTime dateTime;
  final int createdAt;
  final String locationTz;

  Earthquake({
    required this.earthquakeId,
    required this.provider,
    required this.title,
    required this.date,
    required this.mag,
    required this.depth,
    required this.geojson,
    required this.locationProperties,
    required this.dateTime,
    required this.createdAt,
    required this.locationTz,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    try {
      // DateTime parsing için daha güvenli bir yaklaşım
      DateTime parseDateTime(dynamic dateTimeValue) {
        if (dateTimeValue == null) return DateTime.now();

        String dateTimeString = dateTimeValue.toString();

        // Farklı tarih formatlarını deneyelim
        try {
          // ISO 8601 format
          if (dateTimeString.contains('T')) {
            return DateTime.parse(dateTimeString);
          }

          // Space ile ayrılmış format
          if (dateTimeString.contains(' ')) {
            final replacedString = dateTimeString.replaceAll(' ', 'T');
            return DateTime.parse(replacedString);
          }

          // Diğer formatlar için parse denemesi
          return DateTime.parse(dateTimeString);
        } catch (e) {
          print('DateTime parse hatası: $e, değer: $dateTimeString');
          return DateTime.now();
        }
      }

      // Numeric değerleri güvenli bir şekilde parse etme
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          return double.tryParse(value) ?? 0.0;
        }
        return 0.0;
      }

      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          return int.tryParse(value) ?? 0;
        }
        return 0;
      }

      // Güvenli string parsing
      String parseString(dynamic value, String defaultValue) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      // Map parsing için güvenli yaklaşım
      Map<String, dynamic> parseMap(dynamic value) {
        if (value == null) return <String, dynamic>{};
        if (value is Map<String, dynamic>) return value;
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
        return <String, dynamic>{};
      }

      return Earthquake(
        earthquakeId: parseString(json['earthquake_id'], ''),
        provider: parseString(json['provider'], 'Unknown'),
        title: parseString(json['title'], 'Bilinmeyen Deprem'),
        date: parseString(json['date'], ''),
        mag: parseDouble(json['mag']),
        depth: parseDouble(json['depth']),
        geojson: parseMap(json['geojson']),
        locationProperties: parseMap(json['location_properties']),
        dateTime: parseDateTime(json['date_time']),
        createdAt: parseInt(json['created_at']),
        locationTz: parseString(json['location_tz'], 'Unknown'),
      );
    } catch (e) {
      print('Earthquake.fromJson hatası: $e');
      print('JSON data: $json');
      rethrow; // Hatayı yukarı fırlat ki debug edilebilsin
    }
  }

  @override
  String toString() {
    return 'Earthquake{earthquakeId: $earthquakeId, title: $title, mag: $mag, dateTime: $dateTime}';
  }
}
