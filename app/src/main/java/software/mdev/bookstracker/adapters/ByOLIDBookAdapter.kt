package software.mdev.bookstracker.adapters

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.squareup.picasso.Picasso
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_book_searched_by_olid.view.*
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse

class ByOLIDBookAdapter : RecyclerView.Adapter<ByOLIDBookAdapter.OpenLibraryBookViewHolder>() {
    inner class OpenLibraryBookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    var selectedAuthorsName: String = ""

    private val differCallback = object : DiffUtil.ItemCallback<OpenLibraryOLIDResponse>() {
        override fun areItemsTheSame(
            oldItem: OpenLibraryOLIDResponse,
            newItem: OpenLibraryOLIDResponse
        ): Boolean {
            return oldItem.key == newItem.key
        }

        override fun areContentsTheSame(
            oldItem: OpenLibraryOLIDResponse,
            newItem: OpenLibraryOLIDResponse
        ): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): OpenLibraryBookViewHolder {
        return OpenLibraryBookViewHolder(
            LayoutInflater.from(parent.context)
                .inflate(R.layout.item_book_searched_by_olid, parent, false)
        )
    }

    private var onBookClickListener: ((OpenLibraryOLIDResponse) -> Unit)? = null

    override fun onBindViewHolder(holder: OpenLibraryBookViewHolder, position: Int) {
        val curBook = differ.currentList[position]

            holder.itemView.apply {

                if (curBook != null) {
                    if (curBook.title != null)
                        tvBookTitle.text = curBook.title

                    tvBookAuthor.text = selectedAuthorsName

                    if (curBook.isbn_13 != null) {
                        var isbn = "ISBN: " + curBook.isbn_13[0]
                        tvBookISBN.text = isbn
                    } else if (curBook.isbn_10 != null) {
                        var isbn = "ISBN: " + curBook.isbn_10[0]
                        tvBookISBN.text = isbn
                    }

                    if(curBook.number_of_pages != null) {
                        var pages = curBook.number_of_pages.toString() + " pages"
                        tvBookPages.text = pages
                    }

                    if (curBook.languages != null) {
                        var language = curBook.languages[0].key.replace("/languages/", "")
                        tvBookLanguage.text = language
                    }

                    if (curBook.key != null) {
                        var olid = curBook.key.replace("/books/", "")
                        olid = "OLID: $olid"
                        tvBookOLID.text = olid
                    }

                    if (curBook.covers != null) {
                        val circularProgressDrawable = CircularProgressDrawable(this.context)
                        circularProgressDrawable.strokeWidth = 5f
                        circularProgressDrawable.centerRadius = 30f
                        circularProgressDrawable.start()

                        var coverID = curBook.covers[0].toString()
                        var coverUrl = "https://covers.openlibrary.org/b/id/$coverID-M.jpg"
                        Picasso
                            .get()
                            .load(coverUrl)
                            .placeholder(circularProgressDrawable)
                            .error(R.drawable.ic_baseline_error_outline_24)
                            .into(ivBookCover)
                    }
                }
            }

        holder.itemView.apply {
            setOnClickListener {
                onBookClickListener?.let { it(curBook) }
            }
        }
    }

//    fun setOnBookClickListener(listener: (Book) -> Unit) {
//        onBookClickListener = listener
//    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    fun setOnBookClickListener(listener: (OpenLibraryOLIDResponse) -> Unit) {
        onBookClickListener = listener
    }
}