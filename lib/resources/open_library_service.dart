import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/model/ol_search_result.dart';
import 'package:openreads/model/ol_work_result.dart';

class OpenLibraryService {
  static const baseUrl = 'https://openlibrary.org/';
  static const coversBaseUrl = 'https://covers.openlibrary.org';

  Future<OLSearchResult> getResults({
    required String query,
    required int offset,
    required int limit,
    required OLSearchType searchType,
  }) async {
    final searchTypeKey = searchType == OLSearchType.general
        ? 'q'
        : searchType == OLSearchType.author
            ? 'author'
            : searchType == OLSearchType.title
                ? 'title'
                : searchType == OLSearchType.isbn
                    ? 'isbn'
                    : 'q';

    final response = await get(
      Uri.parse(
        '${baseUrl}search.json?$searchTypeKey=$query&limit=$limit&offset=$offset',
      ),
    );
    return openLibrarySearchResultFromJson(response.body);
  }

  Future<OLEditionResult> getEdition(String edition) async {
    final response = await get(
      Uri.parse('$baseUrl/books/$edition.json'),
    );
    return openLibraryEditionResultFromJson(response.body);
  }

  Future<OLWorkResult> getWork(String work) async {
    final response = await get(
      Uri.parse('$baseUrl$work.json'),
    );
    return openLibraryWorkResultFromJson(response.body);
  }

  Future<Uint8List?> getCover(String isbn) async {
    try {
      final response = await get(
        Uri.parse('$coversBaseUrl/b/isbn/$isbn-L.jpg'),
      );

      // If the response is less than 500 bytes,
      // probably the cover is not available
      if (response.bodyBytes.length < 500) return null;

      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }
}
