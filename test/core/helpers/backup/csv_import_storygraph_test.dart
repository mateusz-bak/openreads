import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/backup/csv_import_storygraph.dart';
import 'package:openreads/model/book.dart';

List<Book> _parseFixture(String name) {
  final csvString = File('test/fixtures/$name').readAsStringSync();

  return CSVImportStoryGraph.parseBooks(csvString)!;
}

void main() {
  group('StoryGraph export from 2026', () {
    final books = _parseFixture('storygraph_2026.csv');
    Book book(String title) => books.firstWhere((e) => e.title == title);

    test('parses every row', () {
      expect(books.length, 9);
    });

    test('keeps titles with commas and non-ASCII characters', () {
      expect(book('Guns, Germs, and Steel').author, 'Jared Diamond');
      expect(book('Cien años de soledad').author, 'Gabriel García Márquez');
    });

    test('keeps all authors', () {
      expect(book('Good Omens').author, 'Terry Pratchett, Neil Gaiman');
    });

    test('maps statuses', () {
      expect(book('Dune').status, BookStatus.read);
      expect(book('Cien años de soledad').status, BookStatus.inProgress);
      expect(book('Ulysses').status, BookStatus.unfinished);
      expect(book('Project Hail Mary').status, BookStatus.forLater);
    });

    test('maps formats', () {
      expect(book('Dune').bookFormat, BookFormat.hardcover);
      expect(book('Good Omens').bookFormat, BookFormat.paperback);
      expect(book('Cien años de soledad').bookFormat, BookFormat.ebook);
      expect(book('Ulysses').bookFormat, BookFormat.audiobook);
      expect(
          book('Advanced Dungeons & Dragons').bookFormat, BookFormat.paperback);
    });

    test('accepts only ISBNs', () {
      expect(book('Dune').isbn, '9780450000898');
      expect(book('Good Omens').isbn, '0060853980');
      expect(book('Project Hail Mary').isbn, null);
      expect(book('The Name of the Wind').isbn, null);
      expect(book('Advanced Dungeons & Dragons').isbn, null);
    });

    test('rounds ratings to half stars', () {
      expect(book('Dune').rating, 45);
      expect(book('Good Omens').rating, 50);
      expect(book('The Name of the Wind').rating, 45);
      expect(book('Pride and Prejudice').rating, 40);
      expect(book('Project Hail Mary').rating, null);
    });

    test('parses all readings', () {
      final readings = book('Dune').readings;
      expect(readings.length, 2);
      expect(readings[0].startDate, DateTime(2025, 1, 10));
      expect(readings[0].finishDate, DateTime(2025, 2, 10));
      expect(readings[1].startDate, DateTime(2019, 6, 1));
      expect(readings[1].finishDate, DateTime(2019, 7, 15));
    });

    test('parses a single date as the finish date', () {
      final readings = book('Good Omens').readings;
      expect(readings.length, 1);
      expect(readings[0].startDate, null);
      expect(readings[0].finishDate, DateTime(2024, 3, 20));
    });

    test('parses a reading without a finish date', () {
      final readings = book('Cien años de soledad').readings;
      expect(readings.length, 1);
      expect(readings[0].startDate, DateTime(2026, 10, 2));
      expect(readings[0].finishDate, null);
    });

    test('parses a not finished reading', () {
      final readings = book('Ulysses').readings;
      expect(readings.length, 1);
      expect(readings[0].startDate, DateTime(2023, 5, 2));
      expect(readings[0].finishDate, DateTime(2023, 6, 15));
    });

    test('adds no readings without dates', () {
      expect(book('Advanced Dungeons & Dragons').readings, isEmpty);
      expect(book('Project Hail Mary').readings, isEmpty);
    });

    test('parses the date added', () {
      expect(book('Dune').dateAdded, DateTime(2025, 1, 5));
    });

    test('cleans HTML from the review', () {
      expect(book('Dune').myReview, 'Spice & sand.');
      expect(book('Pride and Prejudice').myReview, 'Loved it');
      expect(book('Good Omens').myReview, null);
    });

    test('splits tags', () {
      expect(book('Dune').tags, 'sci-fi|||||classics');
      expect(book('Ulysses').tags, 'classics');
      expect(book('Good Omens').tags, null);
    });
  });

  group('StoryGraph export from 2024', () {
    final books = _parseFixture('storygraph_2024.csv');
    Book book(String title) => books.firstWhere((e) => e.title == title);

    test('parses every row', () {
      expect(books.length, 2);
    });

    test('parses day first dates', () {
      expect(book('The Hobbit').dateAdded, DateTime(2023, 8, 27));
      expect(book('Project Hail Mary').dateAdded, DateTime(2023, 9, 10));
    });

    test('parses the reading', () {
      final readings = book('The Hobbit').readings;
      expect(readings.length, 1);
      expect(readings[0].startDate, DateTime(2023, 8, 27));
      expect(readings[0].finishDate, DateTime(2023, 9, 14));
    });

    test('converts ratings without decimals', () {
      expect(book('The Hobbit').rating, 50);
      expect(book('Project Hail Mary').rating, 25);
    });

    test('cleans HTML from the review', () {
      expect(book('The Hobbit').myReview, 'Wonderful book.');
    });
  });

  group('StoryGraph edge cases', () {
    const header = 'Title,Authors,Contributors,ISBN/UID,Format,Read Status,'
        'Date Added,Last Date Read,Dates Read,Read Count,Moods,Pace,'
        'Character- or Plot-Driven?,Strong Character Development?,'
        'Loveable Characters?,Diverse Characters?,Flawed Characters?,'
        'Star Rating,Review,Content Warnings,Content Warning Description,'
        'Tags,Owned?';

    test('rejects a CSV that is not a StoryGraph export', () {
      const goodreads = 'Book Id,Title,Author,My Rating,Exclusive Shelf\n'
          '1,Dune,Frank Herbert,5,read';

      expect(CSVImportStoryGraph.parseBooks(goodreads), null);
      expect(CSVImportStoryGraph.parseBooks(''), null);
    });

    test('ignores a BOM added by Excel', () {
      final books = CSVImportStoryGraph.parseBooks(
        '﻿$header\n'
        'Dune,Frank Herbert,,,,read,2025/01/05,,,1,,,,,,,,,,,,,No',
      )!;

      expect(books.single.title, 'Dune');
    });

    test('skips rows without a title', () {
      final books = CSVImportStoryGraph.parseBooks(
        '$header\n'
        ',,,,,read,2025/01/05,,,1,,,,,,,,,,,,,No\n'
        'Dune,Frank Herbert,,,,read,2025/01/05,,,1,,,,,,,,,,,,,No\n',
      )!;

      expect(books.single.title, 'Dune');
    });

    test('keeps line breaks in the review', () {
      final books = CSVImportStoryGraph.parseBooks(
        '$header\n'
        'Dune,Frank Herbert,,,,read,2025/01/05,,,1,,,,,,,,,'
        '"<p>Great start.</p><p>Weak ending.</p>Line one<br>Line two",'
        ',,,No',
      )!;

      expect(
        books.single.myReview,
        'Great start.\nWeak ending.\nLine one\nLine two',
      );
    });

    test('rejects impossible dates instead of rolling them over', () {
      final books = CSVImportStoryGraph.parseBooks(
        '$header\n'
        'Dune,Frank Herbert,,,,read,08/27/2023,,2023/02/30,1,'
        ',,,,,,,,,,,,No',
      )!;

      expect(books.single.dateAdded.year, isNot(2025));
      expect(books.single.readings, isEmpty);
    });

    test('uses Last Date Read when Dates Read is empty', () {
      final books = CSVImportStoryGraph.parseBooks(
        '$header\n'
        'Dune,Frank Herbert,,,,read,14/09/2023,14/09/2023,,1,'
        ',,,,,,,,,,,,No',
      )!;

      expect(books.single.readings.single.startDate, null);
      expect(
        books.single.readings.single.finishDate,
        DateTime(2023, 9, 14),
      );
    });
  });
}
