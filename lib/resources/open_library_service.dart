import 'package:http/http.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/model/ol_search_result.dart';

class OpenLibraryService {
  Future<OLSearchResult> getResults(String query, int offset) async {
    const baseUrl = 'http://openlibrary.org/';
    const limit = '20';

    final response = await get(
      Uri.parse(
        '${baseUrl}search.json?q=$query&limit=$limit&offset=$offset',
      ),
    );
    return openLibrarySearchResultFromJson(response.body);
  }

  Future<OLEditionResult> getEdition(String edition) async {
    const baseUrl = 'http://openlibrary.org';

    final response = await get(
      Uri.parse(
        '$baseUrl$edition.json',
      ),
    );
    return openLibraryEditionResultFromJson(response.body);
  }
}
