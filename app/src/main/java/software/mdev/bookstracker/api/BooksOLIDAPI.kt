package software.mdev.bookstracker.api

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse

interface BooksOLIDAPI {
    @GET("isbn/{isbn}")
    suspend fun getBookFromISBN(
        @Path("isbn")
        isbn: String
    ): Response<OpenLibraryOLIDResponse>

    @GET("books/{olid}.json")
    suspend fun getBookFromOLID(
        @Path("olid")
        olid: String
    ): Response<OpenLibraryOLIDResponse>
}