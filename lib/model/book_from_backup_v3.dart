import 'package:flutter/foundation.dart';

class BookFromBackupV3 {
  final int? id;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookStatus;
  final double? bookRating;
  final int? bookIsFav;
  final int? bookIsDeleted;
  final String? bookStartDate;
  final String? bookFinishDate;
  final int? bookNumberOfPages;
  final int? bookPublishYear;
  final String? bookISBN13;
  final String? bookISBN10;
  final String? bookOLID;
  final String? bookTags;
  final String? bookNotes;
  final Uint8List? bookCoverImg;

  BookFromBackupV3({
    this.id,
    this.bookTitle,
    this.bookAuthor,
    this.bookStatus,
    this.bookRating,
    this.bookIsFav,
    this.bookIsDeleted,
    this.bookStartDate,
    this.bookFinishDate,
    this.bookNumberOfPages,
    this.bookPublishYear,
    this.bookISBN13,
    this.bookISBN10,
    this.bookOLID,
    this.bookTags,
    this.bookNotes,
    this.bookCoverImg,
  });

  factory BookFromBackupV3.fromJson(Map<String, dynamic> json) {
    return BookFromBackupV3(
      id: json['id'] as int?,
      bookTitle: json['item_bookTitle'] as String?,
      bookAuthor: json['item_bookAuthor'] as String?,
      bookStatus: json['item_bookStatus'] as String?,
      bookRating: json['item_bookRating'] as double?,
      bookIsFav: json['item_bookIsFav'] as int?,
      bookIsDeleted: json['item_bookIsDeleted'] as int?,
      bookStartDate: json['item_bookStartDate'] as String?,
      bookFinishDate: json['item_bookFinishDate'] as String?,
      bookNumberOfPages: json['item_bookNumberOfPages'] as int?,
      bookPublishYear: json['item_bookPublishYear'] as int?,
      bookISBN13: json['item_bookISBN13'] as String?,
      bookISBN10: json['item_bookISBN10'] as String?,
      bookOLID: json['item_bookOLID'] as String?,
      bookTags: json['item_bookTags'] as String?,
      bookNotes: json['item_bookNotes'] as String?,
      bookCoverImg: json['item_bookCoverImg'] as Uint8List?,
    );
  }
}
