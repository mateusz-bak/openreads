import 'package:http/http.dart';
import 'package:openreads/model/open_library_search_result.dart';

class OpenLibraryService {
  Future<OpenLibrarySearchResult> getResults(String query, int offset) async {
    const baseUrl = 'http://openlibrary.org/';
    const limit = '20';

    final response = await get(
      Uri.parse(
        '${baseUrl}search.json?q=$query&limit=$limit&offset=$offset',
      ),
    );
    return openLibrarySearchResultFromJson(response.body);
  }
}
