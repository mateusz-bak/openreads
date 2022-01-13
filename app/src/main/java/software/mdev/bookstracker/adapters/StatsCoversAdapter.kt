package software.mdev.bookstracker.adapters

import android.content.Context
import android.graphics.BitmapFactory
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_stats_cover.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book

class StatsCoversAdapter(
    var context: Context

) : RecyclerView.Adapter<StatsCoversAdapter.BookViewHolder>() {
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
            LayoutInflater.from(parent.context).inflate(R.layout.item_stats_cover, parent, false)
        )
    }

    override fun onBindViewHolder(holder: BookViewHolder, position: Int) {
        val curBook = differ.currentList[position]
        holder.itemView.apply {
            curBook.bookCoverImg?.let { setCover(this, it) }
        }
    }

    private fun setCover(view: View, bookCoverImg: ByteArray) {
        val bmp = BitmapFactory.decodeByteArray(bookCoverImg, 0, bookCoverImg.size)
        view.ivCover.setImageBitmap(bmp)
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }
}