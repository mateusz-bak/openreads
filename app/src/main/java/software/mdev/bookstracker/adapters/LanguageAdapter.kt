package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_language.view.*
import software.mdev.bookstracker.data.db.*
import software.mdev.bookstracker.data.db.entities.Language
import software.mdev.bookstracker.data.repositories.*
import software.mdev.bookstracker.ui.bookslist.fragments.AddBookSearchFragment
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory

class LanguageAdapter (
    private val addBookSearchFragment: AddBookSearchFragment,
    ) : RecyclerView.Adapter<LanguageAdapter.LanguageBookViewHolder>() {
    inner class LanguageBookViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    lateinit var viewModel: BooksViewModel

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
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_language, parent, false)

        createViewModel(view, addBookSearchFragment)

        return LanguageBookViewHolder(
            LayoutInflater.from(parent.context)
                .inflate(R.layout.item_language, parent, false)
        )
    }

    private fun createViewModel(view: View, addBookSearchFragment: AddBookSearchFragment) {
        val database = BooksDatabase(view.context)
        val yearDatabase = YearDatabase(view.context)
        val languageDatabase = LanguageDatabase(view.context)

        val booksRepository = BooksRepository(database)
        val yearRepository = YearRepository(yearDatabase)
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(languageDatabase)

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            booksRepository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        viewModel = ViewModelProvider(addBookSearchFragment, booksViewModelProviderFactory).get(
            BooksViewModel::class.java
        )
    }

    override fun onBindViewHolder(holder: LanguageBookViewHolder, position: Int) {
        val curLanguage = differ.currentList[position]

        holder.itemView.apply {
            cbLanguage.text = curLanguage.language6392B

            cbLanguage.isChecked = curLanguage.isSelected != 0

            cbLanguage.setOnClickListener {

                if (cbLanguage.isChecked) {
                    cbLanguage.isChecked = true

                    viewModel.selectLanguage(curLanguage.id)
                } else {
                    cbLanguage.isChecked = false
                    viewModel.unselectLanguage(curLanguage.id)
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }
}