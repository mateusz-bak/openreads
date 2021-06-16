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
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.ui.bookslist.fragments.StatisticsFragment
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.math.RoundingMode
import java.text.DecimalFormat

class StatisticsAdapter(
    private val statisticsFragment: StatisticsFragment,
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
        val booksRepository = BooksRepository(database)
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)

        viewModel = ViewModelProvider(statisticsFragment, booksViewModelProviderFactory).get(
            BooksViewModel::class.java
        )

        val factory = BooksViewModelProviderFactory(booksRepository)
        val viewModel =
            ViewModelProviders.of(statisticsFragment, factory).get(BooksViewModel::class.java)

        return StatisticsViewHolder(view)
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    override fun onBindViewHolder(holder: StatisticsViewHolder, position: Int) {
        val curYear = differ.currentList[position]
        val df = DecimalFormat("#.#")
        df.roundingMode = RoundingMode.CEILING

        if (position == 0 && curYear.yearBooks == 0) {
            holder.itemView.apply {
                tvLooksEmptyStatistics.visibility = View.VISIBLE
                ivBooksRead.visibility = View.GONE
                ivPagesRead.visibility = View.GONE
                rbAvgRatingIndicator.visibility = View.GONE
                tvBooksReadTitle.visibility = View.GONE
                tvBooksRead.visibility = View.GONE
                tvPagesReadTitle.visibility = View.GONE
                tvPagesRead.visibility = View.GONE
                tvAvgRatingTitle.visibility = View.GONE
                tvAvgRating.visibility = View.GONE
            }
        } else {
            holder.itemView.tvLooksEmptyStatistics.visibility = View.GONE
        }

        holder.itemView.apply {
            tvBooksRead.text = curYear.yearBooks.toString()
            tvPagesRead.text = curYear.yearPages.toString()
            rbAvgRatingIndicator.rating = curYear.avgRating
            when (curYear.avgRating) {
                0F -> tvAvgRating.text = "0.0"
                1F -> tvAvgRating.text = "1.0"
                2F -> tvAvgRating.text = "2.0"
                3F -> tvAvgRating.text = "3.0"
                4F -> tvAvgRating.text = "4.0"
                5F -> tvAvgRating.text = "5.0"
                else -> tvAvgRating.text = df.format(curYear.avgRating)
            }
        }
    }
}