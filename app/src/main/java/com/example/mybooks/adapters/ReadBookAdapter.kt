package com.example.mybooks.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.mybooks.R
import com.example.mybooks.data.db.entities.ReadBook
import com.example.mybooks.ui.bookslist.ReadBooksViewModel
import com.example.mybooks.ui.bookslist.EditReadBookDialogListener
import com.example.mybooks.ui.bookslist.EditReadBookDialog
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.item_read_book.view.*

class ReadBookAdapter(

    var readBooks: List<ReadBook>,
    private val viewModel: ReadBooksViewModel,
    var context: Context

) : RecyclerView.Adapter<ReadBookAdapter.ListElementViewHolder>() {

    inner class ListElementViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ListElementViewHolder {
        return ListElementViewHolder(
            LayoutInflater.from(parent.context).inflate(
                R.layout.item_read_book,
                parent,
                false
            )
        )
    }

    override fun onBindViewHolder(holder: ListElementViewHolder, position: Int) {
        val curBook = readBooks[position]
        holder.itemView.apply {
            tvBookTitle.text = curBook.bookTitle
            tvBookAuthor.text = curBook.bookAuthor
            rbRatingIndicator.rating = curBook.bookRating
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
            EditReadBookDialog(context, curBook,
                object: EditReadBookDialogListener {
                    override fun onSaveButtonClicked(item: ReadBook) {

                        viewModel.delete(curBook)
                        viewModel.upsert(item)
                    }
                }
            ).show()
        }
    }

    override fun getItemCount(): Int {
        return readBooks.size
    }
}