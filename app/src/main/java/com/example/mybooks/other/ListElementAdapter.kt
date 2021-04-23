package com.example.mybooks.other

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.mybooks.R
import com.example.mybooks.data.db.entities.ListElement
import com.example.mybooks.ui.bookslist.BooksViewModel
import kotlinx.android.synthetic.main.item_list_element.view.*

class ListElementAdapter(

        var books: List<ListElement>,
        private val viewModel: BooksViewModel

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

        holder.itemView.ivDeleteBook.setOnClickListener{
            viewModel.delete(curBook)
        }
    }

    override fun getItemCount(): Int {
        return books.size
    }
}