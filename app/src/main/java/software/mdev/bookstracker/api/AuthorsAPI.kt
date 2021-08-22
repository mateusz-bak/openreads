package software.mdev.bookstracker.api

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path
import software.mdev.bookstracker.api.models.OpenLibraryAuthor

interface AuthorsAPI {
    @GET("authors/{authors}.json")
    suspend fun getAuthorFromOLID(
        @Path("authors")
        authors: String
    ): Response<OpenLibraryAuthor>
}