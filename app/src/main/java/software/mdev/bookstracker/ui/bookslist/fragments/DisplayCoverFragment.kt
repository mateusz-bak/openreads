package software.mdev.bookstracker.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.fragment_display_cover.*
import kotlinx.android.synthetic.main.fragment_read.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel


class DisplayCoverFragment : Fragment(R.layout.fragment_display_cover) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayCoverFragmentArgs by navArgs()
    lateinit var coverID: String
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        coverID = args.cover

        var action = true

        if (coverID == Constants.DATABASE_EMPTY_VALUE) {
            ivBookCover.visibility = View.GONE
        } else {
            val circularProgressDrawable = CircularProgressDrawable(view.context)
            circularProgressDrawable.strokeWidth = 5f
            circularProgressDrawable.centerRadius = 30f
            circularProgressDrawable.setColorSchemeColors(
                ContextCompat.getColor(
                    view.context,
                    R.color.grey
                )
            )
            circularProgressDrawable.start()

            var coverUrl = "https://covers.openlibrary.org/b/id/$coverID-L.jpg"

            Picasso
                .get()
                .load(coverUrl)
                .placeholder(circularProgressDrawable)
                .error(R.drawable.ic_baseline_error_outline_24)
                .transform(RoundCornersTransform(16.0f))
                .into(ivBookCover)
        }

        ivBookCover.setOnClickListener {
            if (action) {
                action = false
                ivBookCover.animate().scaleX(1.5F).setDuration(500L).start()
                ivBookCover.animate().scaleY(1.5F).setDuration(500L).start()
            } else {
                action = true
                ivBookCover.animate().scaleX(1F).setDuration(500L).start()
                ivBookCover.animate().scaleY(1F).setDuration(500L).start()
            }
        }
    }
}