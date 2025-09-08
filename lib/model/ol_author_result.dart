import 'dart:convert';

OLAuthorResult openLibraryAuthorResultFromJson(String str) =>
    OLAuthorResult.fromJson(json.decode(str));

class OLAuthorResult {
  OLAuthorResult({
    this.name,
    this.key,
  });

  final String? name;
  final String? key;

  factory OLAuthorResult.fromJson(Map<String, dynamic> json) {
    return OLAuthorResult(
      name: json["name"],
      key: json["key"],
    );
  }
}
