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
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        when (sortOrder) {
            Constants.SORT_ORDER_TITLE_DESC -> {
                ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clTitle.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_TITLE_DESC
            }
            Constants.SORT_ORDER_TITLE_ASC -> {
                ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clTitle.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_TITLE_ASC
            }
            Constants.SORT_ORDER_AUTHOR_DESC -> {
                ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_AUTHOR_DESC
            }
            Constants.SORT_ORDER_AUTHOR_ASC -> {
                ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_AUTHOR_ASC
            }
            Constants.SORT_ORDER_RATING_DESC -> {
                ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clRating.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_RATING_DESC
            }
            Constants.SORT_ORDER_RATING_ASC -> {
                ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clRating.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_RATING_ASC
            }
            Constants.SORT_ORDER_PAGES_DESC -> {
                ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clPages.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_PAGES_DESC
            }
            Constants.SORT_ORDER_PAGES_ASC -> {
                ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clPages.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_PAGES_ASC
            }
            Constants.SORT_ORDER_DATE_DESC -> {
                ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_DATE_DESC
            }
            Constants.SORT_ORDER_DATE_ASC -> {
                ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                clDate.setBackgroundResource(R.drawable.sort_background_selected)
                tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
                whatIsClicked = Constants.SORT_ORDER_DATE_ASC
            }
        }

        ivSortTitleDesc.setOnClickListener {
            ivSortTitleDescSelected()
        }

        ivSortTitleAsc.setOnClickListener {
            ivSortTitleAscSelected()
        }

        ivSortAuthorDesc.setOnClickListener {
            ivSortAuthorDescSelected()
        }

        ivSortAuthorAsc.setOnClickListener {
            ivSortAuthorAscSelected()
        }

        ivSortRatingDesc.setOnClickListener {
            ivSortRatingDescSelected()
        }

        ivSortRatingAsc.setOnClickListener {
            ivSortRatingAscSelected()
        }

        ivSortPagesDesc.setOnClickListener {
            ivSortPagesDescSelected()
        }

        ivSortPagesAsc.setOnClickListener {
            ivSortPagesAscSelected()
        }

        ivSortDateDesc.setOnClickListener {
            ivSortDateDescSelected()
        }

        ivSortDateAsc.setOnClickListener {
            ivSortDateAscSelected()
        }



        tvSortTitle.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_TITLE_ASC -> ivSortTitleDescSelected()
                else -> ivSortTitleAscSelected()
            }
        }

        tvSortAuthor.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_AUTHOR_ASC -> ivSortAuthorDescSelected()
                else -> ivSortAuthorAscSelected()
            }
        }

        tvSortRating.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_RATING_ASC -> ivSortRatingDescSelected()
                else -> ivSortRatingAscSelected()
            }        }

        tvSortPages.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_PAGES_ASC -> ivSortPagesDescSelected()
                else -> ivSortPagesAscSelected()
            }        }

        tvSortDate.setOnClickListener {
            when (whatIsClicked) {
                Constants.SORT_ORDER_DATE_ASC -> ivSortDateDescSelected()
                else -> ivSortDateAscSelected()
            }        }

        btnSorterExecute.setOnClickListener {
            sortBooksDialogListener.onSaveButtonClicked(whatIsClicked)
            dismiss()
        }
    }

    private fun ivSortTitleDescSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_selected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_TITLE_DESC
        animateSortArrow()
    }

    private fun ivSortTitleAscSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_selected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_TITLE_ASC
        animateSortArrow()
    }

    private fun ivSortAuthorDescSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_AUTHOR_DESC
        animateSortArrow()
    }

    private fun ivSortAuthorAscSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_selected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_AUTHOR_ASC
        animateSortArrow()
    }

    private fun ivSortRatingDescSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_selected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_RATING_DESC
        animateSortArrow()
    }

    private fun ivSortRatingAscSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_selected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_RATING_ASC
        animateSortArrow()
    }

    private fun ivSortPagesDescSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_selected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_PAGES_DESC
        animateSortArrow()
    }

    private fun ivSortPagesAscSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_selected)
        clDate.setBackgroundResource(R.drawable.sort_background_unselected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.grey))

        whatIsClicked = Constants.SORT_ORDER_PAGES_ASC
        animateSortArrow()
    }

    private fun ivSortDateDescSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_selected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))

        whatIsClicked = Constants.SORT_ORDER_DATE_DESC
        animateSortArrow()
    }

    private fun ivSortDateAscSelected() {
        ivSortTitleDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey))
        ivSortTitleAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortAuthorAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortRatingAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortPagesAsc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateDesc.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
        ivSortDateAsc.setColorFilter(ContextCompat.getColor(context, R.color.design_default_color_on_primary), android.graphics.PorterDuff.Mode.SRC_IN)

        clTitle.setBackgroundResource(R.drawable.sort_background_unselected)
        clAuthor.setBackgroundResource(R.drawable.sort_background_unselected)
        clRating.setBackgroundResource(R.drawable.sort_background_unselected)
        clPages.setBackgroundResource(R.drawable.sort_background_unselected)
        clDate.setBackgroundResource(R.drawable.sort_background_selected)

        tvSortTitle.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortAuthor.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortRating.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortPages.setTextColor(ContextCompat.getColor(context, R.color.grey))
        tvSortDate.setTextColor(ContextCompat.getColor(context, R.color.design_default_color_on_primary))

        whatIsClicked = Constants.SORT_ORDER_DATE_ASC
        animateSortArrow()
    }

    private fun animateSortArrow() {
        when(whatIsClicked){
            Constants.SORT_ORDER_TITLE_DESC -> {
                if(ivSortTitleDesc.getRotation() < 180F){
                    ivSortTitleDesc.animate().rotation( 360F).start()
                }
                else {
                    ivSortTitleDesc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_TITLE_ASC -> {
                if(ivSortTitleAsc.getRotation() < 180F){
                    ivSortTitleAsc.animate().rotation( 360F).start()
                }
                else {
                    ivSortTitleAsc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_AUTHOR_DESC -> {
                if(ivSortAuthorDesc.getRotation() < 180F){
                    ivSortAuthorDesc.animate().rotation( 360F).start()
                }
                else {
                    ivSortAuthorDesc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_AUTHOR_ASC -> {
                if(ivSortAuthorAsc.getRotation() < 180F){
                    ivSortAuthorAsc.animate().rotation( 360F).start()
                }
                else {
                    ivSortAuthorAsc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_RATING_DESC -> {
                if(ivSortRatingDesc.getRotation() < 180F){
                    ivSortRatingDesc.animate().rotation( 360F).start()
                }
                else {
                    ivSortRatingDesc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_RATING_ASC -> {
                if(ivSortRatingAsc.getRotation() < 180F){
                    ivSortRatingAsc.animate().rotation( 360F).start()
                }
                else {
                    ivSortRatingAsc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_PAGES_DESC -> {
                if(ivSortPagesDesc.getRotation() < 180F){
                    ivSortPagesDesc.animate().rotation( 360F).start()
                }
                else {
                    ivSortPagesDesc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_PAGES_ASC -> {
                if(ivSortPagesAsc.getRotation() < 180F){
                    ivSortPagesAsc.animate().rotation( 360F).start()
                }
                else {
                    ivSortPagesAsc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_DATE_DESC -> {
                if(ivSortDateDesc.getRotation() < 180F){
                    ivSortDateDesc.animate().rotation( 360F).start()
                }
                else {
                    ivSortDateDesc.animate().rotation( 0F).start()
                }
            }
            Constants.SORT_ORDER_DATE_ASC -> {
                if(ivSortDateAsc.getRotation() < 180F){
                    ivSortDateAsc.animate().rotation( 360F).start()
                }
                else {
                    ivSortDateAsc.animate().rotation( 0F).start()
                }
            }
        }
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
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
