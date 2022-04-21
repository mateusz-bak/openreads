package software.mdev.bookstracker.adapters

import android.content.Context
import android.content.res.ColorStateList
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.chip.Chip
import com.google.gson.Gson
import kotlinx.android.synthetic.main.item_book_detail.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.BookDetail
import software.mdev.bookstracker.other.Constants

class BookDetailsAdapter(
    var context: Context,
) : RecyclerView.Adapter<BookDetailsAdapter.BookDetailsViewHolder>() {
    inner class BookDetailsViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback = object : DiffUtil.ItemCallback<BookDetail>() {
        override fun areItemsTheSame(oldItem: BookDetail, newItem: BookDetail): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: BookDetail, newItem: BookDetail): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BookDetailsViewHolder {
        return BookDetailsViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.item_book_detail, parent, false)
        )
    }

    override fun onBindViewHolder(holder: BookDetailsViewHolder, position: Int) {
        val detail = differ.currentList[position]
        holder.itemView.apply {
            initLayouts(this)

            when (detail.id) {
                Constants.detailStartDate -> setStartDate(this, detail.value)
                Constants.detailFinishDate -> setFinishDate(this, detail.value)
                Constants.detailReadingTime -> setReadingTime(this, detail.value)
                Constants.detailPages -> setPages(this, detail.value)
                Constants.detailPublishYear -> setPublishYear(this, detail.value)
                Constants.detailTags -> setTags(this, detail.value)
                Constants.detailISBN -> setISBN(this, detail.value)
                Constants.detailOLID -> setOLID(this, detail.value)
                Constants.detailNotes -> setNotes(this, detail.value)
                Constants.detailUrl -> setOLIDURL(this, detail.value)
            }
        }
    }

    private fun setOLIDURL(view: View, detail: String) {
        view.clOLIDURL.visibility = View.VISIBLE
        view.tvBookURL.text = detail
    }

    private fun setNotes(view: View, detail: String) {
        view.clNotes.visibility = View.VISIBLE
        view.tvNotes.text = detail
    }

    private fun setOLID(view: View, detail: String) {
        view.clOLID.visibility = View.VISIBLE
        view.tvBookOLID.text = detail
    }

    private fun setISBN(view: View, detail: String) {
        view.clISBN.visibility = View.VISIBLE
        view.tvBookISBN.text = detail
    }

    private fun setPublishYear(view: View, detail: String) {
        view.clPublishYear.visibility = View.VISIBLE
        view.tvBookPublishYear.text = detail
    }

    private fun setPages(view: View, detail: String) {
        view.clPages.visibility = View.VISIBLE
        view.tvBookPages.text = detail
    }


    private fun setReadingTime(view: View, detail: String) {
        view.clReadingTime.visibility = View.VISIBLE
        view.tvBookReadingTime.text = detail
    }

    private fun setFinishDate(view: View, detail: String) {
        view.clDateFinished.visibility = View.VISIBLE
        view.tvDateFinished.text = detail
    }

    private fun setStartDate(view: View, detail: String) {
        view.clDateStarted.visibility = View.VISIBLE
        view.tvDateStarted.text = detail
    }

    private fun setTags(view: View, detail: String) {
        view.clTags.visibility = View.VISIBLE

        val tags: List<String>? = Gson().fromJson(detail, Array<String>::class.java)?.toList()

        view.cgTags.removeAllViews()

        // add up to date chips
        if (tags != null) {
            for (tag in tags) {
                val chip = Chip(context)
                chip.isCloseIconVisible = false
                chip.text = tag
                chip.isCloseIconEnabled = false
                chip.isClickable = false
                chip.isCheckable = false
                chip.chipBackgroundColor = ColorStateList.valueOf(getThemeAccentColor(context))
                chip.setTextColor(context.getColor(R.color.colorDefaultBg))
                view.cgTags.addView(chip as View)
            }
        }
    }

    private fun initLayouts(view: View) {
        view.clTags.visibility = View.GONE
        view.clDateStarted.visibility = View.GONE
        view.clDateFinished.visibility = View.GONE
        view.clReadingTime.visibility = View.GONE
        view.clPages.visibility = View.GONE
        view.clPublishYear.visibility = View.GONE
        view.clISBN.visibility = View.GONE
        view.clOLID.visibility = View.GONE
        view.clNotes.visibility = View.GONE
        view.clOLIDURL.visibility = View.GONE
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    private fun getThemeAccentColor(context: Context): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(R.attr.colorAccent, value, true)
        return value.data
    }
}
