import 'package:json_annotation/json_annotation.dart';

class NullableDoubleConverter implements JsonConverter<double?, Object?> {
  const NullableDoubleConverter();

  @override
  double? fromJson(Object? json) {
    if (json == null) return null;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json);
    return null;
  }

  @override
  Object? toJson(double? value) => value;
}

class DoubleConverter implements JsonConverter<double, Object?> {
  const DoubleConverter();

  @override
  double fromJson(Object? json) {
    if (json is num) return json.toDouble();
    if (json is String) {
      final parsed = double.tryParse(json);
      if (parsed != null) return parsed;
    }
    throw FormatException('Expected numeric value, got: $json');
  }

  @override
  Object? toJson(double value) => value;
}
