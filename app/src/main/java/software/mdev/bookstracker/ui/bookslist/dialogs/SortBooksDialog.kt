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


class SortBooksDialog(context: Context, var sortBooksDialogListener: SortBooksDialogListener, var sortOrder: String?) : AppCompatDialog(context) {

    var whatIsClicked: String = Constants.BOOK_STATUS_NOTHING

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_sort_books)
        var accentColor = getAccentColor(context.applicationContext)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        ivSortTitle.isClickable = false
        ivSortAuthor.isClickable = false
        ivSortRating.isClickable = false
        ivSortPages.isClickable = false
        ivSortStartDate.isClickable = false
        ivSortFinishDate.isClickable = false

        when (sortOrder) {
            Constants.SORT_ORDER_TITLE_DESC -> {
                ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clTitle.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_TITLE_DESC
                ivSortTitle.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_TITLE_ASC -> {
                ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clTitle.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_TITLE_ASC
                ivSortTitle.animate().rotation( 0F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_AUTHOR_DESC -> {
                ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_AUTHOR_DESC
                ivSortAuthor.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_AUTHOR_ASC -> {
                ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_AUTHOR_ASC
                ivSortAuthor.animate().rotation( 0F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_RATING_DESC -> {
                ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clRating.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_RATING_DESC
                ivSortRating.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_RATING_ASC -> {
                ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clRating.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_RATING_ASC
                ivSortRating.animate().rotation( 0F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_PAGES_DESC -> {
                ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clPages.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_PAGES_DESC
                ivSortPages.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_PAGES_ASC -> {
                ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clPages.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_PAGES_ASC
                ivSortPages.animate().rotation( 0F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_START_DATE_DESC -> {
                ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clStartDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_START_DATE_DESC
                ivSortStartDate.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_START_DATE_ASC -> {
                ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clStartDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_START_DATE_ASC
                ivSortStartDate.animate().rotation( 0F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_FINISH_DATE_DESC -> {
                ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clFinishDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_FINISH_DATE_DESC
                ivSortFinishDate.animate().rotation( 180F).setDuration(1L).start()
            }
            Constants.SORT_ORDER_FINISH_DATE_ASC -> {
                ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clFinishDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_FINISH_DATE_ASC
                ivSortFinishDate.animate().rotation( 0F).setDuration(1L).start()
            }
        }

        clTitle.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_TITLE_ASC -> ivSortTitleDescSelected()
                else -> ivSortTitleAscSelected()
            }
        }

        clAuthor.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_AUTHOR_ASC -> ivSortAuthorDescSelected()
                else -> ivSortAuthorAscSelected()
            }
        }

        clRating.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_RATING_ASC -> ivSortRatingDescSelected()
                else -> ivSortRatingAscSelected()
            }
        }

        clPages.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_PAGES_ASC -> ivSortPagesDescSelected()
                else -> ivSortPagesAscSelected()
            }
        }

        clStartDate.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_START_DATE_ASC -> ivSortStartDateDescSelected()
                else -> ivSortStartDateAscSelected()
            }
        }

        clFinishDate.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_FINISH_DATE_ASC -> ivSortFinishDateDescSelected()
                else -> ivSortFinishDateAscSelected()
            }
        }

        btnSorterExecute.setOnClickListener {
            sortBooksDialogListener.onSaveButtonClicked(whatIsClicked)
            dismiss()
        }
    }

    private fun ivSortTitleDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_selected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_TITLE_DESC
        ivSortTitle.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortTitleAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_selected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_TITLE_ASC
        ivSortTitle.animate().rotation( 0F).setDuration(350L).start()
    }

    private fun ivSortAuthorDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_AUTHOR_DESC
        ivSortAuthor.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortAuthorAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_AUTHOR_ASC
        ivSortAuthor.animate().rotation( 0F).setDuration(350L).start()
    }

    private fun ivSortRatingDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_selected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_RATING_DESC
        ivSortRating.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortRatingAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_selected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_RATING_ASC
        ivSortRating.animate().rotation( 0F).setDuration(350L).start()
    }

    private fun ivSortPagesDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_selected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_PAGES_DESC
        ivSortPages.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortPagesAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_selected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_PAGES_ASC
        ivSortPages.animate().rotation( 0F).setDuration(350L).start()
    }

    private fun ivSortStartDateDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_selected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_START_DATE_DESC
        ivSortStartDate.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortStartDateAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_selected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_START_DATE_ASC
        ivSortStartDate.animate().rotation( 0F).setDuration(350L).start()
    }

    private fun ivSortFinishDateDescSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_selected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))

        whatIsClicked = Constants.SORT_ORDER_FINISH_DATE_DESC
        ivSortFinishDate.animate().rotation( 180F).setDuration(350L).start()
    }

    private fun ivSortFinishDateAscSelected() {
        ivSortTitle.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortAuthor.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRating.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPages.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortStartDate.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortFinishDate.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clStartDate.setBackgroundResource(R.drawable.sort_background_unselected)
        clFinishDate.setBackgroundResource(R.drawable.sort_background_selected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortStartDate.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortFinishDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))

        whatIsClicked = Constants.SORT_ORDER_FINISH_DATE_ASC
        ivSortFinishDate.animate().rotation( 0F).setDuration(350L).start()
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor = ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor = ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor = ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor = ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}
