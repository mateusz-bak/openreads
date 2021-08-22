package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.core.view.children
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.tabs.TabLayoutMediator
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.ListActivity
import kotlinx.android.synthetic.main.fragment_statistics.*
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper.ORIENTATION_HORIZONTAL
import software.mdev.bookstracker.adapters.StatisticsAdapter
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_NAME
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.text.SimpleDateFormat
import java.util.*


class StatisticsFragment : Fragment(R.layout.fragment_statistics) {

    lateinit var viewModel: BooksViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        view.hideKeyboard()

        val sharedPref = (activity as ListActivity).getSharedPreferences(
            SHARED_PREFERENCES_NAME,
            Context.MODE_PRIVATE
        )

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

        viewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java
        )

        var listOfYearsFromDb: List<Year>

        viewModel.getYears()
            .observe(viewLifecycleOwner, Observer { years ->
                listOfYearsFromDb = years
                val adapter = StatisticsAdapter(this, listOfYearsFromDb)
                vpStatistics.adapter = adapter
                this.getYears(adapter)
            })

        ivMore.setOnClickListener {
            it.hideKeyboard()
            findNavController().navigate(R.id.settingsFragment, null)
        }
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    private fun getYears(statisticsAdapter: StatisticsAdapter) {
        viewModel.getSortedBooksByFinishDateDesc(Constants.BOOK_STATUS_READ)
            .observe(viewLifecycleOwner, Observer { books ->
                var listOfYears = mutableListOf<Year>()
                listOfYears.add(Year("0000", 0, 0, 0F, 0, 0))

                var years = listOf<Int>()
                var year: Int

                for (item in books) {
                    if (item.bookFinishDate != "null" && item.bookFinishDate != "none") {
                        year = convertLongToYear(item.bookFinishDate.toLong()).toInt()
                        if (year !in years) {
                            years = years + year
                        }
                    }
                }

                var booksAllTime = 0
                var pagesAllTime = 0
                var sumRatingAllTime = 0F

                for (item_year in years) {
                    var booksInYear = 0
                    var pagesInYear = 0
                    var sumRatingInYear = 0F

                    for (item_book in books) {
                        if (item_book.bookFinishDate != "none" && item_book.bookFinishDate != "null") {
                            year = convertLongToYear(item_book.bookFinishDate.toLong()).toInt()
                            if (year == item_year) {
                                booksInYear++
                                booksAllTime++
                                pagesInYear += item_book.bookNumberOfPages
                                pagesAllTime += item_book.bookNumberOfPages
                                sumRatingInYear += item_book.bookRating
                                sumRatingAllTime += item_book.bookRating
                            }
                        }
                    }
                    listOfYears.add(Year(item_year.toString(), booksInYear, pagesInYear, (sumRatingInYear/booksInYear), 0, 0))
                }

                listOfYears[0] = Year("0000", booksAllTime, pagesAllTime, (sumRatingAllTime/booksAllTime), 0, 0)

                statisticsAdapter.differ.submitList(listOfYears)

                // bounce effect on viewpager2
                vpStatistics.children.filterIsInstance<RecyclerView>().firstOrNull()?.let {
                    OverScrollDecoratorHelper.setUpOverScroll(it, ORIENTATION_HORIZONTAL)
                }

                TabLayoutMediator(tlStatistics, vpStatistics) { tab, position ->
                    when (position) {
                        0 -> tab.text = getString(R.string.statistics_all)
                        else -> tab.text = listOfYears[position].year
                    }
                }.attach()
            }
            )
    }

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }
}