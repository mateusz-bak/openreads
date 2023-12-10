import 'package:http/http.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/model/ol_search_result.dart';
import 'package:openreads/model/ol_work_result.dart';

class OpenLibraryService {
  Future<OLSearchResult> getResults({
    required String query,
    required int offset,
    required int limit,
    required OLSearchType searchType,
  }) async {
    const baseUrl = 'https://openlibrary.org/';

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
    const baseUrl = 'https://openlibrary.org';

    final response = await get(
      Uri.parse(
        '$baseUrl/books/$edition.json',
      ),
    );
    return openLibraryEditionResultFromJson(response.body);
  }

  Future<OLWorkResult> getWork(String work) async {
    const baseUrl = 'https://openlibrary.org';

    final response = await get(
      Uri.parse(
        '$baseUrl$work.json',
      ),
    );
    return openLibraryWorkResultFromJson(response.body);
  }
}
