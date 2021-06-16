package software.mdev.bookstracker.data.db.entities

import java.io.Serializable

data class Year (
        var year: String,
        var yearBooks: Int,
        var yearPages: Int,
        var avgRating: Float
): Serializable{
        var id: Int? = null
}