import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:openreads/model/book_from_backup_v3.dart';

class Book {
  int? id;
  String title;
  String author;
  int status;
  bool favourite;
  bool deleted;
  int? rating;
  String? startDate;
  String? finishDate;
  int? pages;
  int? publicationYear;
  String? isbn;
  String? olid;
  String? tags;
  String? myReview;
  final Uint8List? cover;
  final String? blurHash;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.status,
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
    this.cover,
    this.blurHash,
  });

  factory Book.fromJSON(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      status: json['status'],
      rating: json['rating'],
      favourite: (json['favourite'] == 1) ? true : false,
      deleted: (json['deleted'] == 1) ? true : false,
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      pages: json['pages'],
      publicationYear: json['publication_year'],
      isbn: json['isbn'],
      olid: json['olid'],
      tags: json['tags'],
      myReview: json['my_review'],
      cover: json['cover'] != null
          ? Uint8List.fromList(json['cover'].cast<int>().toList())
          : null,
      blurHash: json['blur_hash'],
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
              .toIso8601String()
          : null,
      finishDate: oldBook.bookFinishDate != null &&
              oldBook.bookFinishDate != 'none' &&
              oldBook.bookFinishDate != 'null'
          ? DateTime.fromMillisecondsSinceEpoch(
                  int.parse(oldBook.bookFinishDate!))
              .toIso8601String()
          : null,
      pages: oldBook.bookNumberOfPages,
      publicationYear: oldBook.bookPublishYear,
      isbn: oldBook.bookISBN13 ?? oldBook.bookISBN10,
      olid: oldBook.bookOLID,
      tags: oldBook.bookTags != null && oldBook.bookTags != 'null'
          ? jsonDecode(oldBook.bookTags!).join('|||||')
          : null,
      myReview: oldBook.bookNotes,
      cover: oldBook.bookCoverImg,
      blurHash: blurHash,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'status': status,
      'rating': rating,
      'favourite': favourite ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'start_date': startDate,
      'finish_date': finishDate,
      'pages': pages,
      'publication_year': publicationYear,
      'isbn': isbn,
      'olid': olid,
      'tags': tags,
      'my_review': myReview,
      'cover': cover,
      'blur_hash': blurHash,
    };
  }
}
