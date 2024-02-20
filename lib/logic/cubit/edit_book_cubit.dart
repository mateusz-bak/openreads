import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/reading_time.dart';

class EditBookCubit extends Cubit<Book> {
  EditBookCubit() : super(Book.empty());

  setBook(Book book) => emit(book);

  void updateBook(Uint8List? cover, BuildContext context) {
    if (state.id == null) return;

    bookCubit.updateBook(state, cover: cover, context: context);
  }

  void addNewBook(Uint8List? cover) {
    bookCubit.addBook(state, cover: cover);
  }

  void setStatus(BookStatus status) {
    final book = state.copyWith();

    emit(book.copyWith(status: status));
  }

  void setRating(double rating) {
    emit(state.copyWith(rating: (rating * 10).toInt()));
  }

  void setBookFormat(BookFormat bookFormat) {
    emit(state.copyWith(bookFormat: bookFormat));
  }

  void setTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void setSubtitle(String subtitle) {
    final book = state.copyWith();
    book.subtitle = subtitle.isNotEmpty ? subtitle : null;
    emit(book);
  }

  void setAuthor(String author) {
    emit(state.copyWith(author: author));
  }

  void setPages(String pages) {
    final book = state.copyWith();
    book.pages = pages.isEmpty ? null : int.parse(pages);
    emit(book);
  }

  void setDescription(String description) {
    final book = state.copyWith();
    book.description = description.isNotEmpty ? description : null;
    emit(book);
  }

  void setISBN(String isbn) {
    final book = state.copyWith();
    book.isbn = isbn.isNotEmpty ? isbn : null;
    emit(book);
  }

  void setOLID(String olid) {
    final book = state.copyWith();
    book.olid = olid.isNotEmpty ? olid : null;
    emit(book);
  }

  void setPublicationYear(String publicationYear) {
    final book = state.copyWith();
    book.publicationYear =
        publicationYear.isEmpty ? null : int.parse(publicationYear);

    emit(book);
  }

  void setMyReview(String myReview) {
    final book = state.copyWith();
    book.myReview = myReview.isNotEmpty ? myReview : null;

    emit(book);
  }

  void setNotes(String notes) {
    final book = state.copyWith();
    book.notes = notes.isNotEmpty ? notes : null;

    emit(book);
  }

  void setBlurHash(String? blurHash) {
    final book = state.copyWith();
    book.blurHash = blurHash;

    emit(book);
  }

  void setHasCover(bool hasCover) {
    final book = state.copyWith();
    book.hasCover = hasCover;

    emit(book);
  }

  void addNewTag(String tag) {
    // Remove space at the end of the string if exists
    if (tag.substring(tag.length - 1) == ' ') {
      tag = tag.substring(0, tag.length - 1);
    }

    // Remove illegal characters
    tag = tag.replaceAll('|', ''); //TODO: add same for @ in all needed places

    List<String> tags = state.tags == null ? [] : state.tags!.split('|||||');

    if (tags.contains(tag)) return;
    tags.add(tag);

    final book = state.copyWith();
    book.tags = tags.join('|||||');

    emit(book);
  }

  void removeTag(String tag) {
    List<String> tags = state.tags == null ? [] : state.tags!.split('|||||');

    if (!tags.contains(tag)) return;
    tags.remove(tag);

    final book = state.copyWith();
    book.tags = tags.isEmpty ? null : tags.join('|||||');

    emit(book);
  }

  void addNewReading(Reading reading) {
    List<Reading> readings = state.readings;

    readings.add(reading);

    final book = state.copyWith();
    book.readings = readings;

    emit(book);
  }

  void removeReading(int index) {
    List<Reading> readings = state.readings;

    readings.removeAt(index);

    final book = state.copyWith();
    book.readings = readings;

    emit(book);
  }

  void setReadingStartDate(DateTime? startDate, int index) {
    List<Reading> readings = state.readings;

    readings[index].startDate = startDate;

    final book = state.copyWith();
    book.readings = readings;

    emit(book);
  }

  setReadingFinishDate(DateTime? finishDate, int index) {
    List<Reading> readings = state.readings;

    readings[index].finishDate = finishDate;

    final book = state.copyWith();
    book.readings = readings;

    emit(book);
  }

  setCustomReadingTime(ReadingTime? readingTime, int index) {
    List<Reading> readings = state.readings;

    readings[index].customReadingTime = readingTime;

    final book = state.copyWith();
    book.readings = readings;

    emit(book);
  }
}

class EditBookCoverCubit extends Cubit<Uint8List?> {
  EditBookCoverCubit() : super(null);

  setCover(Uint8List? cover) {
    imageCache.clear();

    emit(cover);
  }

  deleteCover(int? bookID) async {
    if (bookID == null) return;

    emit(null);

    final coverExists = await File(
      '${appDocumentsDirectory.path}/$bookID.jpg',
    ).exists();

    if (coverExists) {
      await File(
        '${appDocumentsDirectory.path}/$bookID.jpg',
      ).delete();
    }
  }
}
