package software.mdev.bookstracker.api.models

data class OpenLibraryOLIDResponse(
    var authors: List<Author>,
    val classifications: Classifications,
    val contributions: List<String>,
    val covers: List<Int>,
    val created: Created,
    val first_sentence: FirstSentence,
    val identifiers: Identifiers,
    val isbn_10: List<String>,
    val isbn_13: List<String>,
    val key: String,
    val languages: List<Language>,
    val last_modified: LastModified,
    val latest_revision: Int,
    val local_id: List<String>,
    val number_of_pages: Int,
    val ocaid: String,
    val publish_date: String,
    val publishers: List<String>,
    val revision: Int,
    val source_records: List<String>,
    val title: String,
    val type: Type,
    val works: List<Work>
) {
    data class Author(
        var key: String
    )

    class Classifications(
    )

    data class Created(
        val type: String,
        val value: String
    )

    data class FirstSentence(
        val type: String,
        val value: String
    )

    data class Identifiers(
        val goodreads: List<String>,
        val librarything: List<String>
    )

    data class Language(
        val key: String
    )

    data class LastModified(
        val type: String,
        val value: String
    )

    data class Type(
        val key: String
    )

    data class Work(
        val key: String
    )
}