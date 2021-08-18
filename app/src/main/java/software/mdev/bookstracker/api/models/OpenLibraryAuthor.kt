package software.mdev.bookstracker.api.models

data class OpenLibraryAuthor(
    val alternate_names: List<String>,
    val bio: Bio,
    val birth_date: String,
    val created: Created,
    val entity_type: String,
    val key: String,
    val last_modified: LastModified,
    val latest_revision: Int,
    val links: List<Link>,
    val name: String,
    val personal_name: String,
    val photos: List<Int>,
    val remote_ids: RemoteIds,
    val revision: Int,
    val source_records: List<String>,
    val title: String,
    val type: Type,
    val wikipedia: String
) {
    data class Bio(
        val type: String,
        val value: String
    )

    data class Created(
        val type: String,
        val value: String
    )

    data class LastModified(
        val type: String,
        val value: String
    )

    data class Link(
        val title: String,
        val type: Type,
        val url: String
    ) {
        data class Type(
            val key: String
        )
    }

    data class RemoteIds(
        val isni: String,
        val viaf: String,
        val wikidata: String
    )

    data class Type(
        val key: String
    )
}