import 'dart:convert';

OLWorkResult openLibraryWorkResultFromJson(String str) =>
    OLWorkResult.fromJson(json.decode(str));

class OLWorkResult {
  OLWorkResult({
    this.description,
  });

  final String? description;

  factory OLWorkResult.fromJson(Map<String, dynamic> json) => OLWorkResult(
        description: json["description"] is Map
            ? (json["description"]["value"] ?? json["description"])
            : json["description"],
      );
}
