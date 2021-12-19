package software.mdev.bookstracker.other

import androidx.room.TypeConverter
import com.google.gson.Gson

class Converters {
    @TypeConverter
    fun intArrayToJson(value: Array<Int>?) = Gson().toJson(value)

    @TypeConverter
    fun jsonToIntArray(value: String) = Gson().fromJson(value, Array<Int>::class.java)

    @TypeConverter
    fun stringArrayToJson(value: Array<String>?) = Gson().toJson(value)

    @TypeConverter
    fun jsonToStringArray(value: String?) = Gson().fromJson(value, Array<String>::class.java)
}