import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/additional_reading.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/reading_time.dart';

class Book {
  int? id;
  String title;
  String? subtitle;
  String author;
  String? description;
  int status;
  bool favourite;
  bool deleted;
  int? rating;
  DateTime? startDate;
  DateTime? finishDate;
  int? pages;
  int? publicationYear;
  String? isbn;
  String? olid;
  String? tags;
  String? myReview;
  String? notes;
  Uint8List? cover; // Not used since 2.2.0
  String? blurHash;
  BookFormat bookFormat;
  bool hasCover;
  ReadingTime? readingTime;
  List<AdditionalReading>? additionalReadings;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.status,
    this.subtitle,
    this.description,
    this.favourite = false,
    this.deleted = false,
    this.rating,
    this.startDate,
    this.finishDate,
    this.pages,
    this.publicationYear,
    this.isbn,
    this.olid,
    this.tags,
    this.myReview,
    this.notes,
    this.cover,
    this.blurHash,
    this.bookFormat = BookFormat.paperback,
    this.hasCover = false,
    this.readingTime,
    this.additionalReadings,
  });

  factory Book.empty() {
    return Book(
      id: null,
      title: '',
      author: '',
      status: 0,
      favourite: false,
      deleted: false,
      bookFormat: BookFormat.paperback,
      hasCover: false,
    );
  }

  factory Book.fromJSON(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      author: json['author'],
      description: json['description'],
      status: json['status'],
      rating: json['rating'],
      favourite: (json['favourite'] == 1) ? true : false,
      hasCover: (json['has_cover'] == 1) ? true : false,
      deleted: (json['deleted'] == 1) ? true : false,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      finishDate: json['finish_date'] != null
          ? DateTime.parse(json['finish_date'])
          : null,
      pages: json['pages'],
      publicationYear: json['publication_year'],
      isbn: json['isbn'],
      olid: json['olid'],
      tags: json['tags'],
      myReview: json['my_review'],
      notes: json['notes'],
      cover: json['cover'] != null
          ? Uint8List.fromList(json['cover'].cast<int>().toList())
          : null,
      blurHash: json['blur_hash'],
      bookFormat: json['book_type'] == 'audiobook'
          ? BookFormat.audiobook
          : json['book_type'] == 'ebook'
              ? BookFormat.ebook
              : json['book_type'] == 'hardcover'
                  ? BookFormat.hardcover
                  : json['book_type'] == 'paperback'
                      ? BookFormat.paperback
                      : BookFormat.paperback,
      readingTime: json['reading_time'] != null
          ? ReadingTime.fromMilliSeconds(json['reading_time'])
          : null,
      additionalReadings: json['additional_readings'] != null
          ? List<AdditionalReading>.from(json['additional_readings']
              .map((x) => AdditionalReading.fromString(x)))
          : null,
    );
  }

  Book copyWith(
      {String? title,
      String? author,
      int? status,
      String? subtitle,
      String? description,
      bool? favourite,
      bool? deleted,
      int? rating,
      DateTime? startDate,
      DateTime? finishDate,
      int? pages,
      int? publicationYear,
      String? isbn,
      String? olid,
      String? tags,
      String? myReview,
      String? notes,
      Uint8List? cover,
      String? blurHash,
      BookFormat? bookFormat,
      bool? hasCover,
      ReadingTime? readingTime,
      List<AdditionalReading>? additionalReadings,
      x}) {
    return Book(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      favourite: favourite ?? this.favourite,
      deleted: deleted ?? this.deleted,
      rating: rating ?? this.rating,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      pages: pages ?? this.pages,
      publicationYear: publicationYear ?? this.publicationYear,
      isbn: isbn ?? this.isbn,
      olid: olid ?? this.olid,
      tags: tags ?? this.tags,
      myReview: myReview ?? this.myReview,
      notes: notes ?? this.notes,
      cover: cover ?? this.cover,
      blurHash: blurHash ?? this.blurHash,
      bookFormat: bookFormat ?? this.bookFormat,
      hasCover: hasCover ?? this.hasCover,
      readingTime: readingTime ?? this.readingTime,
      additionalReadings: additionalReadings ?? this.additionalReadings,
    );
  }

  Book copyWithNullCover() {
    return Book(
      id: id,
      title: title,
      subtitle: subtitle,
      author: author,
      status: status,
      description: description,
      favourite: favourite,
      deleted: deleted,
      rating: rating,
      startDate: startDate,
      finishDate: finishDate,
      pages: pages,
      publicationYear: publicationYear,
      isbn: isbn,
      olid: olid,
      tags: tags,
      myReview: myReview,
      notes: notes,
      cover: null,
      blurHash: blurHash,
      bookFormat: bookFormat,
      hasCover: hasCover,
      readingTime: readingTime,
      additionalReadings: additionalReadings,
    );
  }

  factory Book.fromBookFromBackupV3(
      BookFromBackupV3 oldBook, String? blurHash) {
    return Book(
      title: oldBook.bookTitle ?? '',
      author: oldBook.bookAuthor ?? '',
      status: oldBook.bookStatus == 'not_finished'
          ? 3
          : oldBook.bookStatus == 'to_read'
              ? 2
              : oldBook.bookStatus == 'in_progress'
                  ? 1
                  : 0,
      rating: oldBook.bookRating != null
          ? (oldBook.bookRating! * 10).toInt()
          : null,
      favourite: oldBook.bookIsFav == 1,
      deleted: oldBook.bookIsDeleted == 1,
      startDate: oldBook.bookStartDate != null &&
              oldBook.bookStartDate != 'none' &&
              oldBook.bookStartDate != 'null'
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(oldBook.bookStartDate!))
          : null,
      finishDate: oldBook.bookFinishDate != null &&
              oldBook.bookFinishDate != 'none' &&
              oldBook.bookFinishDate != 'null'
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(oldBook.bookFinishDate!))
          : null,
      pages: oldBook.bookNumberOfPages,
      publicationYear: oldBook.bookPublishYear,
      isbn: oldBook.bookISBN13 ?? oldBook.bookISBN10,
      olid: oldBook.bookOLID,
      tags: oldBook.bookTags != null && oldBook.bookTags != 'null'
          ? jsonDecode(oldBook.bookTags!).join('|||||')
          : null,
      notes: oldBook.bookNotes,
      cover: oldBook.bookCoverImg,
      blurHash: blurHash,
      bookFormat: BookFormat.paperback,
      hasCover: false,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'author': author,
      'description': description,
      'status': status,
      'rating': rating,
      'favourite': favourite ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'start_date': startDate?.toIso8601String(),
      'finish_date': finishDate?.toIso8601String(),
      'pages': pages,
      'publication_year': publicationYear,
      'isbn': isbn,
      'olid': olid,
      'tags': tags,
      'my_review': myReview,
      'notes': notes,
      'cover': cover,
      'blur_hash': blurHash,
      'has_cover': hasCover ? 1 : 0,
      'book_type': bookFormat == BookFormat.audiobook
          ? 'audiobook'
          : bookFormat == BookFormat.ebook
              ? 'ebook'
              : bookFormat == BookFormat.hardcover
                  ? 'hardcover'
                  : bookFormat == BookFormat.paperback
                      ? 'paperback'
                      : 'paperback',
      'reading_time': readingTime?.milliSeconds,
      'additional_readings':
          additionalReadings?.map((x) => x.toString()).toList(),
    };
  }

  File? getCoverFile() {
    final fileExists =
        File('${appDocumentsDirectory.path}/$id.jpg').existsSync();

    if (fileExists) {
      return File('${appDocumentsDirectory.path}/$id.jpg');
    } else {
      return null;
    }
  }
}
