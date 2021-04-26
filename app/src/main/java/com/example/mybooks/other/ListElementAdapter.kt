package com.example.mybooks.other

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.mybooks.R
import com.example.mybooks.data.db.entities.ListElement
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.EditDialogListener
import com.example.mybooks.ui.bookslist.EditListElementDialog
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.item_list_element.view.*

class ListElementAdapter(

    var books: List<ListElement>,
    private val viewModel: BooksViewModel,
    var context: Context

) : RecyclerView.Adapter<ListElementAdapter.ListElementViewHolder>() {

    inner class ListElementViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ListElementViewHolder {
        return ListElementViewHolder(
            LayoutInflater.from(parent.context).inflate(
                R.layout.item_list_element,
                parent,
                false
            )
        )
    }

    override fun onBindViewHolder(holder: ListElementViewHolder, position: Int) {
        val curBook = books[position]
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
            EditListElementDialog(context, curBook,
                object: EditDialogListener {
                    override fun onSaveButtonClicked(item: ListElement) {

                        viewModel.delete(curBook)
                        viewModel.upsert(item)
                    }
                }
            ).show()
        }
    }

    override fun getItemCount(): Int {
        return books.size
    }
}