package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_language.view.*
import software.mdev.bookstracker.data.db.entities.Language

class LanguageAdapter : RecyclerView.Adapter<LanguageAdapter.LanguageBookViewHolder>() {
    inner class LanguageBookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback = object : DiffUtil.ItemCallback<Language>() {
        override fun areItemsTheSame(
            oldItem: Language,
            newItem: Language
        ): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(
            oldItem: Language,
            newItem: Language
        ): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LanguageBookViewHolder {
        return LanguageBookViewHolder(
            LayoutInflater.from(parent.context)
                .inflate(R.layout.item_language, parent, false)
        )
    }

    override fun onBindViewHolder(holder: LanguageBookViewHolder, position: Int) {
        val curLanguage = differ.currentList[position]

        holder.itemView.apply {
            cbLanguage.text = curLanguage.language6392B
        }
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }
}