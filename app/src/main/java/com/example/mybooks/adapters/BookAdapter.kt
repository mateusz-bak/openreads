package com.example.mybooks.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.example.mybooks.R
import com.example.mybooks.data.db.entities.Book
import kotlinx.android.synthetic.main.item_read_book.view.*

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

        when (whichFragment ){
            "read" -> return BookViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_read_book, parent,false))
            "in_progress" -> return BookViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_in_progress_book, parent,false))
            "to_read" -> return BookViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_to_read_book, parent,false))
        }

        return BookViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_read_book, parent,false))
    }

    private var onBookClickListener: ((Book) -> Unit)? = null

    override fun onBindViewHolder(holder: BookViewHolder, position: Int) {
        val curBook = differ.currentList[position]
        holder.itemView.apply {
            tvBookTitle.text = curBook.bookTitle
            tvBookAuthor.text = curBook.bookAuthor

            when (whichFragment ){
                "read" -> rbRatingIndicator.rating = curBook.bookRating
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
}