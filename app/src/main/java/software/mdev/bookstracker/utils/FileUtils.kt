package software.mdev.bookstracker.utils

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns


object FileUtils {
    fun getFilenameFromUri(context: Context, uri: Uri?): String? {
        var cursor: Cursor? = null
        try {
            cursor = context.contentResolver.query(uri!!, null, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                val index: Int = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                return cursor.getString(index)
            }
        } finally {
            cursor?.close()
        }
        return null
    }
}