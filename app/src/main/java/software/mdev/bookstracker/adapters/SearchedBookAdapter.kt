package software.mdev.bookstracker.adapters

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_book_searched.view.*
import software.mdev.bookstracker.api.OpenLibraryBook

class SearchedBookAdapter : RecyclerView.Adapter<SearchedBookAdapter.OpenLibraryBookViewHolder>() {
    inner class OpenLibraryBookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback = object : DiffUtil.ItemCallback<OpenLibraryBook>() {
        override fun areItemsTheSame(oldItem: OpenLibraryBook, newItem: OpenLibraryBook): Boolean {
            return oldItem._version_ == newItem._version_
        }

        override fun areContentsTheSame(
            oldItem: OpenLibraryBook,
            newItem: OpenLibraryBook
        ): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): OpenLibraryBookViewHolder {
        return OpenLibraryBookViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.item_book_searched, parent, false)
        )
    }

    private var onBookClickListener: ((OpenLibraryBook) -> Unit)? = null

    override fun onBindViewHolder(holder: OpenLibraryBookViewHolder, position: Int) {
        val curBook = differ.currentList[position]

        if (curBook.isbn != null)
            Log.d("eloo isbn list", curBook.isbn.toString())

        holder.itemView.apply {

            if (curBook.title != null)
                tvBookTitle.text = curBook.title
            else
                tvBookTitle.text = "UNKNOWN"

            if (curBook.author_name != null)
                tvBookAuthor.text = curBook.author_name[0]
            else
                tvBookAuthor.text = "UNKNOWN"

        }

        holder.itemView.apply {
            setOnClickListener {
                onBookClickListener?.let { it(curBook) }
            }
        }
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    fun setOnBookClickListener(listener: (OpenLibraryBook) -> Unit) {
        onBookClickListener = listener
    }
}