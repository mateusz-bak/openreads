package software.mdev.bookstracker.api

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query
import software.mdev.bookstracker.api.models.OpenLibrarySearchTitleResponse

interface BooksAPI {
    @GET("search.json")
    suspend fun getBooksFromOpenLibrary(
        @Query("q")
        title: String
    ): Response<OpenLibrarySearchTitleResponse>
}