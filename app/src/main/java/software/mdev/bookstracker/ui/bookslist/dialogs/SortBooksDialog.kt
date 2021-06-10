package software.mdev.bookstracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.Window
import software.mdev.bookstracker.R
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import kotlinx.android.synthetic.main.dialog_sort_books.*
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_NOTHING
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_ACCENT
import software.mdev.bookstracker.other.Constants.SORT_ORDER_AUTHOR_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_AUTHOR_DESC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_RATING_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_RATING_DESC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_TITLE_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_TITLE_DESC
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_AMBER_500


class SortBooksDialog(context: Context, var sortBooksDialogListener: SortBooksDialogListener, var sortOrder: String?) : AppCompatDialog(context) {

    var whatIsClicked: String = BOOK_STATUS_NOTHING

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_sort_books)
        var accentColor = getAccentColor(context.applicationContext)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        when (sortOrder) {
            SORT_ORDER_TITLE_DESC -> ivSortTitleDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            SORT_ORDER_TITLE_ASC -> ivSortTitleAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            SORT_ORDER_AUTHOR_DESC -> ivSortAuthorDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            SORT_ORDER_AUTHOR_ASC -> ivSortAuthorAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            SORT_ORDER_RATING_DESC -> ivSortRatingDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            SORT_ORDER_RATING_ASC -> ivSortRatingAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
        }

        ivSortTitleDesc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_TITLE_DESC
        }

        ivSortTitleAsc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_TITLE_ASC
        }

        ivSortAuthorDesc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_AUTHOR_DESC
        }

        ivSortAuthorAsc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_AUTHOR_ASC
        }

        ivSortRatingDesc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_RATING_DESC
        }

        ivSortRatingAsc.setOnClickListener {
            ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivSortRatingAsc.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = SORT_ORDER_RATING_ASC
        }

        btnSorterExecute.setOnClickListener {
            sortBooksDialogListener.onSaveButtonClicked(whatIsClicked)
            dismiss()
        }
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            SHARED_PREFERENCES_KEY_ACCENT,
            THEME_ACCENT_AMBER_500
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_AMBER_500 -> accentColor = ContextCompat.getColor(context, R.color.amber_500)
            Constants.THEME_ACCENT_BLUE_500 -> accentColor = ContextCompat.getColor(context, R.color.blue_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_INDIGO_500 -> accentColor = ContextCompat.getColor(context, R.color.indigo_500)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_500 -> accentColor = ContextCompat.getColor(context, R.color.pink_500)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}
