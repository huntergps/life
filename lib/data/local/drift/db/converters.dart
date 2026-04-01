import 'dart:convert';
import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class NullableStringListConverter
    extends NullAwareTypeConverter<List<String>, String> {
  const NullableStringListConverter();

  @override
  List<String> requireFromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String requireToSql(List<String> value) => jsonEncode(value);
}
