package software.mdev.bookstracker.other

import android.graphics.*
import com.squareup.picasso.Transformation

class RoundCornersTransform(private val radiusInPx: Float) : Transformation {

    override fun transform(source: Bitmap): Bitmap {
        val config = if (source.config != null) source.config else Bitmap.Config.ARGB_8888
        val bitmap = Bitmap.createBitmap(source.width, source.height, config)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.DITHER_FLAG)
        val shader = BitmapShader(source, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        paint.shader = shader
        val rect = RectF(0.0f, 0.0f, source.width.toFloat(), source.height.toFloat())
        canvas.drawRoundRect(rect, radiusInPx, radiusInPx, paint)
        source.recycle()

        return bitmap
    }

    override fun key(): String {
        return "round_corners"
    }

}