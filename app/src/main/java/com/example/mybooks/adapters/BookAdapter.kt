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
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.inprogressbooks.EditInProgressBookDialog
import com.example.mybooks.ui.bookslist.inprogressbooks.EditInProgressBookDialogListener
import com.example.mybooks.ui.bookslist.readbooks.EditReadBookDialog
import com.example.mybooks.ui.bookslist.readbooks.EditReadBookDialogListener
import com.example.mybooks.ui.bookslist.toreadbooks.EditToReadBookDialog
import com.example.mybooks.ui.bookslist.toreadbooks.EditToReadBookDialogListener
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.item_read_book.view.*

class BookAdapter(

    private val viewModel: BooksViewModel,
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

    override fun onBindViewHolder(holder: BookViewHolder, position: Int) {
        val curBook = differ.currentList[position]
        holder.itemView.apply {
            tvBookTitle.text = curBook.bookTitle
            tvBookAuthor.text = curBook.bookAuthor

            when (whichFragment ){
                "read" -> rbRatingIndicator.rating = curBook.bookRating
            }
        }

        class UndoBookDeletion : View.OnClickListener {
            override fun onClick(view: View) {
                viewModel.upsert(curBook)
            }
        }

        holder.itemView.ivDeleteBook.setOnClickListener{
            viewModel.delete(curBook)

            Snackbar.make(it, "Book Deleted", Snackbar.LENGTH_LONG)
                .setAction("Undo", UndoBookDeletion())
                .show()
        }

        holder.itemView.ivEditBook.setOnClickListener {
            when (whichFragment ){
                "read" -> EditReadBookDialog(context, curBook,
                    object: EditReadBookDialogListener {
                        override fun onSaveButtonClicked(item: Book) {
                            viewModel.delete(curBook)
                            viewModel.upsert(item)
                        }
                    }
                ).show()
                "in_progress" -> EditInProgressBookDialog(context, curBook,
                    object: EditInProgressBookDialogListener {
                        override fun onSaveButtonClicked(item: Book) {
                            viewModel.delete(curBook)
                            viewModel.upsert(item)
                        }
                    }
                ).show()
                "to_read" -> EditToReadBookDialog(context, curBook,
                    object: EditToReadBookDialogListener {
                        override fun onSaveButtonClicked(item: Book) {
                            viewModel.delete(curBook)
                            viewModel.upsert(item)
                        }
                    }
                ).show()
            }
        }
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }
}