package software.mdev.bookstracker.api

data class OpenLibrarySearchTitleResponse(
    val docs: List<OpenLibraryBook>,
    val numFound: Int,
    val numFoundExact: Boolean,
    val num_found: Int,
    val start: Int
)