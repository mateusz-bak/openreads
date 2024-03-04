import 'dart:convert';
import 'package:openreads/core/constants/enums/enums.dart';

OLEditionResult openLibraryEditionResultFromJson(String str) =>
    OLEditionResult.fromJson(json.decode(str));

class OLEditionResult {
  OLEditionResult({
    this.publishers,
    this.numberOfPages,
    this.isbn10,
    this.covers,
    this.key,
    this.authors,
    this.ocaid,
    this.contributions,
    this.languages,
    this.classifications,
    this.sourceRecords,
    this.title,
    this.subtitle,
    this.identifiers,
    this.isbn13,
    this.localId,
    this.publishDate,
    this.works,
    this.type,
    this.latestRevision,
    this.revision,
    this.created,
    this.lastModified,
    this.physicalFormat,
  });

  final List<String>? publishers;
  final int? numberOfPages;
  final List<String>? isbn10;
  final List<int?>? covers;
  final String? key;
  final List<Type>? authors;
  final String? ocaid;
  final List<String>? contributions;
  final List<Type>? languages;
  final Classifications? classifications;
  final List<String>? sourceRecords;
  final String? title;
  final String? subtitle;
  final Identifiers? identifiers;
  final List<String>? isbn13;
  final List<String>? localId;
  final String? publishDate;
  final List<Type>? works;
  final Type? type;
  final int? latestRevision;
  final int? revision;
  final Created? created;
  final Created? lastModified;
  final BookFormat? physicalFormat;

  factory OLEditionResult.fromJson(Map<String, dynamic> json) {
    return OLEditionResult(
      publishers: json["publishers"] == null
          ? null
          : List<String>.from(json["publishers"].map((x) => x)),
      numberOfPages: json["number_of_pages"],
      isbn10: json["isbn_10"] == null
          ? null
          : List<String>.from(json["isbn_10"].map((x) => x)),
      covers: json["covers"] == null
          ? null
          : List<int?>.from(json["covers"].map((x) => x)),
      key: json["key"],
      authors: json["authors"] == null
          ? null
          : List<Type>.from(json["authors"].map((x) => Type.fromJson(x))),
      ocaid: json["ocaid"],
      contributions: json["contributions"] == null
          ? null
          : List<String>.from(json["contributions"].map((x) => x)),
      languages: json["languages"] == null
          ? null
          : List<Type>.from(json["languages"].map((x) => Type.fromJson(x))),
      classifications: json["classifications"] == null
          ? null
          : Classifications.fromJson(json["classifications"]),
      sourceRecords: json["source_records"] == null
          ? null
          : List<String>.from(json["source_records"].map((x) => x)),
      title: json["title"],
      subtitle: json["subtitle"],
      identifiers: json["identifiers"] == null
          ? null
          : Identifiers.fromJson(json["identifiers"]),
      isbn13: json["isbn_13"] == null
          ? null
          : List<String>.from(json["isbn_13"].map((x) => x)),
      localId: json["local_id"] == null
          ? null
          : List<String>.from(json["local_id"].map((x) => x)),
      publishDate: json["publish_date"],
      works: json["works"] == null
          ? null
          : List<Type>.from(json["works"].map((x) => Type.fromJson(x))),
      type: json["type"] == null ? null : Type.fromJson(json["type"]),
      latestRevision: json["latest_revision"],
      revision: json["revision"],
      created:
          json["created"] == null ? null : Created.fromJson(json["created"]),
      lastModified: json["last_modified"] == null
          ? null
          : Created.fromJson(json["last_modified"]),
      physicalFormat: json['physical_format'] != null
          ? json['physical_format'] == 'Hardcover'
              ? BookFormat.hardcover
              : json['physical_format'] == 'Mass Market Paperback'
                  ? BookFormat.paperback
                  : null
          : null,
    );
  }
}

class Type {
  Type({
    this.key,
  });

  final String? key;

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        key: json["key"],
      );
}

class Classifications {
  Classifications();

  factory Classifications.fromJson(Map<String, dynamic> json) =>
      Classifications();
}

class Created {
  Created({
    this.type,
    this.value,
  });

  final String? type;
  final String? value;

  factory Created.fromJson(Map<String, dynamic> json) => Created(
        type: json["type"],
        value: json["value"],
      );
}

class Identifiers {
  Identifiers({
    this.goodreads,
    this.librarything,
  });

  final List<String>? goodreads;
  final List<String>? librarything;

  factory Identifiers.fromJson(Map<String, dynamic> json) => Identifiers(
        goodreads: json["goodreads"] == null
            ? null
            : List<String>.from(json["goodreads"].map((x) => x)),
        librarything: json["librarything"] == null
            ? null
            : List<String>.from(json["librarything"].map((x) => x)),
      );
}
