package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.squareup.picasso.Picasso
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_book_searched_by_olid.view.*
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.other.Resource

class FoundBookAdapter : RecyclerView.Adapter<FoundBookAdapter.OpenLibraryBookViewHolder>() {
    inner class OpenLibraryBookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback =
        object : DiffUtil.ItemCallback<Resource<OpenLibraryOLIDResponse>>() {
            override fun areItemsTheSame(
                oldItem: Resource<OpenLibraryOLIDResponse>,
                newItem: Resource<OpenLibraryOLIDResponse>
            ): Boolean {
                return oldItem.data?.key == newItem.data?.key
            }

            override fun areContentsTheSame(
                oldItem: Resource<OpenLibraryOLIDResponse>,
                newItem: Resource<OpenLibraryOLIDResponse>
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

    override fun onBindViewHolder(holder: OpenLibraryBookViewHolder, position: Int) {
        val curBook = differ.currentList[position]

        holder.itemView.apply {

            if (curBook != null) {

                if (curBook.data != null) {

                    if (curBook.data.title != null) {
                        val title = curBook.data.title
                        tvBookTitle.text = title
                    }

                    if (curBook.data.authors != null) {
                        var allAuthors = ""
                        for (author in curBook.data.authors) {
                            allAuthors += author.key
                            allAuthors += ", "
                        }
                        // TODO delete separator at the and of allAuthors string
                        tvBookAuthor.text = allAuthors
                    }

                    if (curBook.data.covers != null) {
                        val circularProgressDrawable = CircularProgressDrawable(this.context)
                        circularProgressDrawable.strokeWidth = 5f
                        circularProgressDrawable.centerRadius = 30f
                        circularProgressDrawable.setColorSchemeColors(
                            ContextCompat.getColor(
                                context,
                                R.color.grey
                            )
                        )
                        circularProgressDrawable.start()

                        var coverID = curBook.data.covers[0]
                        var coverUrl = "https://covers.openlibrary.org/b/id/$coverID-M.jpg"
                        Picasso
                            .get()
                            .load(coverUrl)
                            .placeholder(circularProgressDrawable)
                            .error(R.drawable.ic_baseline_error_outline_24)
                            .into(ivBookCover)
                    }

                    if (curBook.data.isbn_13 != null) {
                        var isbn13: String? = curBook.data.isbn_13[0]
                        var isbn = "ISBN: $isbn13"
                        tvBookISBN.text = isbn
                    } else if (curBook.data.isbn_10 != null){
                        var isbn10: String? = curBook.data.isbn_10[0]
                        var isbn = "ISBN: $isbn10"
                        tvBookISBN.text = isbn
                    }

                    if (curBook.data.number_of_pages != null) {
                        var pages: Int? = curBook.data.number_of_pages
                        var pagesString = "$pages pages"
                        tvBookPages.text = pagesString
                    }

                    if (curBook.data.languages != null) {
                        var languagesList = curBook.data.languages
                        var languagesString = ""

                        for (language in languagesList) {
                            languagesString += language.key.replace("/languages/", "")
                            languagesString += ", "
                        }
                        tvBookLanguage.text = languagesString
                    }

                    if (curBook.data.key != null) {
                        var olid = curBook.data.key.toString()
                        olid = olid.replace("/books/", "")
                        olid = "OLID: $olid"
                        tvBookOLID.text = olid
                    }
                }
            }
        }

//        holder.itemView.apply {
//            setOnClickListener {
//                onBookClickListener?.let { it(curBook) }
//            }
//        }
    }

//    fun setOnBookClickListener(listener: (Book) -> Unit) {
//        onBookClickListener = listener
//    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

//    fun setOnBookClickListener(listener: (OpenLibraryOLIDResponse) -> Unit) {
//        onBookClickListener = listener
//    }
}