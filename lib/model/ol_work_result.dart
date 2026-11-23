import 'dart:convert';

OLWorkResult openLibraryWorkResultFromJson(String str) =>
    OLWorkResult.fromJson(json.decode(str));

class OLWorkResult {
  OLWorkResult({
    this.description,
    this.authorKeys,
  });

  final String? description;
  final List<String>? authorKeys;

  factory OLWorkResult.fromJson(Map<String, dynamic> json) => OLWorkResult(
        description: json["description"] is Map
            ? (json["description"]["value"] ?? json["description"])
            : json["description"],
        authorKeys: json["authors"] == null
            ? null
            : List<String>.from(json["authors"]
                .where((x) => x["author"] is Map && x["author"]["key"] != null)
                .map((x) => x["author"]["key"])),
      );
}
