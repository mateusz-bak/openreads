package software.mdev.bookstracker.other

import androidx.room.TypeConverter
import com.google.gson.Gson

class Converters {
    @TypeConverter
    fun intArrayToJson(value: Array<Int>?) = Gson().toJson(value)

    @TypeConverter
    fun jsonToIntArray(value: String) = Gson().fromJson(value, Array<Int>::class.java)

    @TypeConverter
    fun listToJson(value: List<String>?) = Gson().toJson(value)

    @TypeConverter
    fun jsonToList(value: String) = Gson().fromJson(value, Array<String>::class.java)?.toList()
}