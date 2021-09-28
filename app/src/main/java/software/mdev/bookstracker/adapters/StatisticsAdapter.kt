package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_statistics.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.dialogs.ChallengeDialog
import software.mdev.bookstracker.ui.bookslist.dialogs.ChallengeDialogListener
import software.mdev.bookstracker.ui.bookslist.fragments.StatisticsFragment
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.math.RoundingMode
import java.text.DecimalFormat
import java.util.*

class StatisticsAdapter(
    private val statisticsFragment: StatisticsFragment,
    private val listOfYearsFromDb: List<Year>
) : RecyclerView.Adapter<StatisticsAdapter.StatisticsViewHolder>() {

    inner class StatisticsViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    lateinit var viewModel: BooksViewModel

    private val differCallback = object : DiffUtil.ItemCallback<Year>() {
        override fun areItemsTheSame(oldItem: Year, newItem: Year): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Year, newItem: Year): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StatisticsViewHolder {
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_statistics, parent, false)

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

        viewModel = ViewModelProvider(statisticsFragment, booksViewModelProviderFactory).get(
            BooksViewModel::class.java
        )

        val viewModel =
            ViewModelProviders.of(statisticsFragment, booksViewModelProviderFactory).get(BooksViewModel::class.java)

        return StatisticsViewHolder(view)
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    override fun onBindViewHolder(holder: StatisticsViewHolder, position: Int) {
        val curYear = differ.currentList[position]
        val df = DecimalFormat("#.#")
        df.roundingMode = RoundingMode.CEILING

        val foundYear: Year?
        if (position == 0) {
            val tvChallengeTitleText = holder.itemView.resources.getString(R.string.tvChallengeTitle) + " " + Calendar.getInstance().get(Calendar.YEAR).toString()
            holder.itemView.tvChallengeTitle.text = tvChallengeTitleText

            foundYear = listOfYearsFromDb.find {
                it.year == Calendar.getInstance().get(Calendar.YEAR).toString()
            }
        } else {
            val tvChallengeTitleText = holder.itemView.resources.getString(R.string.tvChallengeTitle) + " " + curYear.year
            holder.itemView.tvChallengeTitle.text = tvChallengeTitleText

            foundYear = listOfYearsFromDb.find { it.year == curYear.year }
        }

        if (position == 0 && curYear.yearBooks == 0) {
            holder.itemView.apply {
                tvLooksEmptyStatistics.visibility = View.VISIBLE

                clBooksRead.visibility = View.GONE

                clPagesRead.visibility = View.GONE

                clAvgRating.visibility = View.GONE

                clChallenge.visibility = View.GONE
            }
        } else {
            holder.itemView.tvLooksEmptyStatistics.visibility = View.GONE
        }

        var challengeBooksRead = "0"

        holder.itemView.apply {
            tvBooksReadValue.text = curYear.yearBooks.toString()

            tvPagesReadValue.text = curYear.yearPages.toString()

            tvAvgRatingValue.text = curYear.avgRating.toString()

            if (position == 0 && itemCount > 1) {
                if (differ.currentList[1].year == Calendar.getInstance().get(Calendar.YEAR)
                        .toString()
                ) {
                    challengeBooksRead = differ.currentList[1].yearBooks.toString()
                }
            } else {
                challengeBooksRead = curYear.yearBooks.toString()
            }

            var challengeBooksTarget = "null"
            if (foundYear?.yearChallengeBooks != null) {
                challengeBooksTarget = foundYear?.yearChallengeBooks.toString()
            }

            val tvChallengeText = "$challengeBooksRead / $challengeBooksTarget"
            tvChallengeValue.text = tvChallengeText
        }

        if (position == 0) {
            holder.itemView.clChallenge.setOnClickListener {
                callChallengeDialog(foundYear, it, challengeBooksRead)
            }

            holder.itemView.apply {
                if (foundYear == null) {
                    tvChallengeValue.text = resources.getText(R.string.tvChallengeNotSet)
                }
            }
        } else {
            holder.itemView.apply {
                if (foundYear == null) {
                    clChallenge.visibility = View.GONE
                }
            }
        }
    }

    private fun callChallengeDialog(foundYear: Year?, it: View, challengeBooksRead: String) {
        if (foundYear != null) {
            ChallengeDialog(it.context,
                foundYear,
                object : ChallengeDialogListener {
                    override fun onSaveButtonClicked(year: Year) {
                        viewModel.upsertYear(year)
                    }
                }
            ).show()
        } else {
            ChallengeDialog(it.context,
                Year(Calendar.getInstance().get(Calendar.YEAR).toString(), challengeBooksRead.toInt(), 0, 0F, null, 0),
                object : ChallengeDialogListener {
                    override fun onSaveButtonClicked(year: Year) {
                        viewModel.upsertYear(year)
                    }
                }
            ).show()
        }
    }
}