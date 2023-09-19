import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

class EditBookCubit extends Cubit<Book> {
  EditBookCubit() : super(Book.empty());

  setBook(Book book) => emit(book);

  void updateBook(File? coverFile) {
    if (state.id == null) return;

    bookCubit.updateBook(state, coverFile: coverFile);
  }

  void addNewBook(File? coverFile) {
    bookCubit.addBook(state, coverFile: coverFile);
  }

  void setStatus(int status) {
    final book = state.copyWith();

    // Book not started should not have a start date
    if (state.status == 2) {
      book.startDate = null;
    }

    // Book not finished should not have a finish date
    if (state.status != 0) {
      book.finishDate = null;
    }

    emit(book.copyWith(status: status));
  }

  void setRating(double rating) {
    emit(state.copyWith(rating: (rating * 10).toInt()));
  }

  void setBookType(BookType bookType) {
    emit(state.copyWith(bookType: bookType));
  }

  void setStartDate(DateTime? startDate) {
    final book = state.copyWith();
    book.startDate = startDate;

    emit(book);
  }

  void setFinishDate(DateTime? finishDate) {
    final book = state.copyWith();
    book.finishDate = finishDate;

    emit(book);
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
}

class EditBookCoverCubit extends Cubit<File?> {
  EditBookCoverCubit() : super(null);

  setCover(File? file) {
    emit(file);
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
