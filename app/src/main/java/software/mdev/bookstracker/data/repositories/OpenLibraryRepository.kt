package software.mdev.bookstracker.data.repositories

import software.mdev.bookstracker.api.RetrofitInstance

class OpenLibraryRepository {

    suspend fun searchBooksInOpenLibrary(searchQuery: String) =
        RetrofitInstance.api.getBooksFromOpenLibrary(searchQuery)

    suspend fun getBookFromISBN(isbn: String) =
        RetrofitInstance.apiOLID.getBookFromISBN(isbn)

    suspend fun getBookFromOLID(olid: String) =
        RetrofitInstance.apiOLID.getBookFromOLID(olid)

    suspend fun getAuthorFromOLID(authors: String) =
        RetrofitInstance.apiAuthors.getAuthorFromOLID(authors)
}