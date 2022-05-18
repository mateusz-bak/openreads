package software.mdev.bookstracker.adapters

import android.content.Context
import android.graphics.BitmapFactory
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_not_finished.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import java.text.SimpleDateFormat
import java.util.*

class NotFinishedAdapter(
    var context: Context,

    ) : RecyclerView.Adapter<NotFinishedAdapter.BookViewHolder>() {
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
        return BookViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.item_not_finished, parent, false)
        )
    }

    private var onBookClickListener: ((Book) -> Unit)? = null
    private var onBookLongClickListener: ((Book) -> Unit)? = null

    override fun onBindViewHolder(holder: BookViewHolder, position: Int) {
        val curBook = differ.currentList[position]
        holder.itemView.apply {
            tvBookTitle.text = curBook.bookTitle
            tvBookAuthor.text = curBook.bookAuthor

            if (curBook.bookStartDate == "none" || curBook.bookStartDate == "null") {
                tvDateStarted.text = holder.itemView.getContext().getString(R.string.not_set)
            } else {
                var bookStartTimeStampLong = curBook.bookStartDate.toLong()
                tvDateStarted.text = convertLongToTime(bookStartTimeStampLong)
            }

            setCover(this, curBook.bookCoverImg)
        }

        holder.itemView.apply {
            setOnClickListener {
                onBookClickListener?.let { it(curBook) }
            }
            setOnLongClickListener {
                onBookLongClickListener?.let { it(curBook) }
                true
            }
        }
    }

    private fun setCover(view: View, bookCoverImg: ByteArray?) {
        if (bookCoverImg == null) {
            view.ivBookCover.visibility = View.GONE

            val tvBookTitleLayout = view.tvBookTitle.layoutParams as ConstraintLayout.LayoutParams
            tvBookTitleLayout.topToTop = ConstraintLayout.LayoutParams.PARENT_ID
            tvBookTitleLayout.marginStart = 0

            view.tvBookTitle.layoutParams = tvBookTitleLayout
        } else {
            view.ivBookCover.visibility = View.VISIBLE

            val tvBookTitleLayout = view.tvBookTitle.layoutParams as ConstraintLayout.LayoutParams
            tvBookTitleLayout.topToTop = view.ivBookCover.id
            tvBookTitleLayout.marginStart = 50

            view.tvBookTitle.layoutParams = tvBookTitleLayout

            val bmp = BitmapFactory.decodeByteArray(bookCoverImg, 0, bookCoverImg.size)
            view.ivBookCover.setImageBitmap(bmp)
        }
    }


    fun setOnBookClickListener(listener: (Book) -> Unit) {
        onBookClickListener = listener
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    private fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }
}
