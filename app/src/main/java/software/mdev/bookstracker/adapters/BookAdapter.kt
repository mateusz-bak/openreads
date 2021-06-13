package software.mdev.bookstracker.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import kotlinx.android.synthetic.main.item_book.view.*
import software.mdev.bookstracker.other.Constants
import java.text.SimpleDateFormat
import java.util.*

class BookAdapter(
    var context: Context,
    val whichFragment: String

) : RecyclerView.Adapter<BookAdapter.BookViewHolder>() {
    inner class BookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback = object : DiffUtil.ItemCallback<Book>() {
        override fun areItemsTheSame(oldItem: Book, newItem: Book): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Book, newItem: Book): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BookViewHolder {
        return BookViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_book, parent,false))
    }

    private var onBookClickListener: ((Book) -> Unit)? = null

    override fun onBindViewHolder(holder: BookViewHolder, position: Int) {
        val curBook = differ.currentList[position]
        holder.itemView.apply {
            tvBookTitle.text = curBook.bookTitle
            tvBookAuthor.text = curBook.bookAuthor

            var stringPages = curBook.bookNumberOfPages.toString() +
                    holder.itemView.getContext().getString(R.string.space) +
                    holder.itemView.getContext().getString(R.string.pages)

            tvNumberOfPages.text = stringPages
            tvNumberOfPages.visibility = View.GONE
            tvDateFinished.visibility = View.GONE

            if(curBook.bookFinishDate == "none" || curBook.bookFinishDate == "null") {
                tvDateFinished.text = holder.itemView.getContext().getString(R.string.not_set)
            } else {
                var bookFinishTimeStampLong = curBook.bookFinishDate.toLong()
                tvDateFinished.text = convertLongToTime(bookFinishTimeStampLong)
            }

            val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
            val sortOrder = sharedPref.getString(
                Constants.SHARED_PREFERENCES_KEY_SORT_ORDER,
                Constants.SORT_ORDER_TITLE_ASC
            )

            if (sortOrder == Constants.SORT_ORDER_PAGES_DESC || sortOrder == Constants.SORT_ORDER_PAGES_ASC) {
                tvNumberOfPages.visibility = View.VISIBLE
            }
            if (sortOrder == Constants.SORT_ORDER_DATE_DESC || sortOrder == Constants.SORT_ORDER_DATE_ASC) {
                tvDateFinished.visibility = View.VISIBLE
            }

            when (whichFragment ){
                Constants.BOOK_STATUS_READ -> rbRatingIndicator.rating = curBook.bookRating
            }
            when (curBook.bookStatus ){
                Constants.BOOK_STATUS_READ -> {
                    ivInProgressIndicator.visibility = View.GONE
                    ivToReadIndicator.visibility = View.GONE
                    rbRatingIndicator.visibility = View.VISIBLE
                    rbRatingIndicator.rating = curBook.bookRating
                }
                Constants.BOOK_STATUS_IN_PROGRESS -> {
                    rbRatingIndicator.visibility = View.GONE
                    ivToReadIndicator.visibility = View.GONE
                    ivInProgressIndicator.visibility = View.VISIBLE
                    tvNumberOfPages.visibility = View.GONE
                    tvDateFinished.visibility = View.GONE
                }
                Constants.BOOK_STATUS_TO_READ -> {
                    rbRatingIndicator.visibility = View.GONE
                    ivInProgressIndicator.visibility = View.GONE
                    ivToReadIndicator.visibility = View.VISIBLE
                    tvNumberOfPages.visibility = View.GONE
                    tvDateFinished.visibility = View.GONE
                }
            }
        }

        holder.itemView.apply {
            setOnClickListener {
                onBookClickListener?.let { it(curBook) }
            }
        }
    }

    fun setOnBookClickListener(listener: (Book) -> Unit) {
        onBookClickListener = listener
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }
}