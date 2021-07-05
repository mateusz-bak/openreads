package software.mdev.bookstracker.api

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query

interface BooksAPI {
    @GET("search.json")
    suspend fun getBooksFromOpenLibrary(
        @Query("title")
        title: String
    ): Response<OpenLibrarySearchTitleResponse>
}