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
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
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

        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

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
                vpStatistics.offscreenPageLimit = 1
                this.getYears(adapter)
            })

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
                listOfYears.add(Year())

                var years = calculateHowManyYearsForStats(books)
                var year: Int

                var booksAllTime = 0
                var pagesAllTime = 0
                var sumRatingAllTime = 0F

                var longestBookAllTime = "null"
                var longestBookAllTimeID = 0
                var longestBookValAllTime = 0

                var shortestBookAllTime = "null"
                var shortestBookAllTimeID = 0
                var shortestBookValAllTime = Int.MAX_VALUE

                var quickestReadAllTime = "null"
                var quickestReadAllTimeID = 0
                var quickestReadValAllTime = Long.MAX_VALUE

                var longestReadAllTime = "null"
                var longestReadAllTimeID = 0
                var longestReadValAllTime = Long.MIN_VALUE

                var readingTimeSumAllTime = 0L
                var averageReadingTimeNumOfBooksAllTime = 0L

                var booksByMonthsAllTime = arrayOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                var pagesByMonthsAllTime = arrayOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

                for (item_year in years) {
                    var booksInYear = 0
                    var pagesInYear = 0
                    var sumRatingInYear = 0F

                    var longestBook = "null"
                    var longestBookID = 0
                    var longestBookVal = 0

                    var shortestBook = "null"
                    var shortestBookID = 0
                    var shortestBookVal = Int.MAX_VALUE

                    var quickestRead = "null"
                    var quickestReadID = 0
                    var quickestReadVal = Long.MAX_VALUE

                    var longestRead = "null"
                    var longestReadID = 0
                    var longestReadVal = Long.MIN_VALUE

                    var readingTimeSum = 0L
                    var averageReadingTimeNumOfBooks = 0L

                    var booksByMonths = arrayOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                    var pagesByMonths = arrayOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)


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

                                // books by month
                                when (Functions().convertLongToMonth(item_book.bookFinishDate.toLong())){
                                    "01" -> {
                                        booksByMonths[0] += 1
                                        booksByMonthsAllTime[0] += 1
                                        pagesByMonths[0] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[0] += item_book.bookNumberOfPages
                                    }
                                    "02" -> {
                                        booksByMonths[1] += 1
                                        booksByMonthsAllTime[1] += 1
                                        pagesByMonths[1] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[1] += item_book.bookNumberOfPages
                                    }
                                    "03" -> {
                                        booksByMonths[2] += 1
                                        booksByMonthsAllTime[2] += 1
                                        pagesByMonths[2] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[2] += item_book.bookNumberOfPages
                                    }
                                    "04" -> {
                                        booksByMonths[3] += 1
                                        booksByMonthsAllTime[3] += 1
                                        pagesByMonths[3] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[3] += item_book.bookNumberOfPages
                                    }
                                    "05" -> {
                                        booksByMonths[4] += 1
                                        booksByMonthsAllTime[4] += 1
                                        pagesByMonths[4] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[4] += item_book.bookNumberOfPages
                                    }
                                    "06" -> {
                                        booksByMonths[5] += 1
                                        booksByMonthsAllTime[5] += 1
                                        pagesByMonths[5] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[5] += item_book.bookNumberOfPages
                                    }
                                    "07" -> {
                                        booksByMonths[6] += 1
                                        booksByMonthsAllTime[6] += 1
                                        pagesByMonths[6] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[6] += item_book.bookNumberOfPages
                                    }
                                    "08" -> {
                                        booksByMonths[7] += 1
                                        booksByMonthsAllTime[7] += 1
                                        pagesByMonths[7] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[7] += item_book.bookNumberOfPages
                                    }
                                    "09" -> {
                                        booksByMonths[8] += 1
                                        booksByMonthsAllTime[8] += 1
                                        pagesByMonths[8] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[8] += item_book.bookNumberOfPages
                                    }
                                    "10" ->
                                    {
                                        booksByMonths[9] += 1
                                        booksByMonthsAllTime[9] += 1
                                        pagesByMonths[9] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[9] += item_book.bookNumberOfPages
                                    }
                                    "11" -> {
                                        booksByMonths[10] += 1
                                        booksByMonthsAllTime[10] += 1
                                        pagesByMonths[10] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[10] += item_book.bookNumberOfPages
                                    }
                                    "12" -> {
                                        booksByMonths[11] += 1
                                        booksByMonthsAllTime[11] += 1
                                        pagesByMonths[11] += item_book.bookNumberOfPages
                                        pagesByMonthsAllTime[11] += item_book.bookNumberOfPages
                                    }
                                }

                                // longest book in a year
                                if (item_book.bookNumberOfPages > longestBookVal) {
                                    longestBookVal = item_book.bookNumberOfPages
                                    var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                    longestBook = string
                                    longestBookID = item_book.id!!
                                }

                                // longest book all time
                                if (item_book.bookNumberOfPages > longestBookValAllTime) {
                                    longestBookValAllTime = item_book.bookNumberOfPages
                                    var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                    longestBookAllTime = string
                                    longestBookAllTimeID = item_book.id!!
                                }

                                // shortest book in a year
                                if (item_book.bookNumberOfPages < shortestBookVal && item_book.bookNumberOfPages != 0) {
                                    shortestBookVal = item_book.bookNumberOfPages
                                    var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                    shortestBook = string
                                    shortestBookID = item_book.id!!
                                }

                                // shortest book all time
                                if (item_book.bookNumberOfPages < shortestBookValAllTime && item_book.bookNumberOfPages != 0) {
                                    shortestBookValAllTime = item_book.bookNumberOfPages
                                    var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                    shortestBookAllTime = string
                                    shortestBookAllTimeID = item_book.id!!
                                }


                                if (item_book.bookStartDate != "none" && item_book.bookStartDate != "null") {
                                    var readingTime = item_book.bookFinishDate.toLong() - item_book.bookStartDate.toLong()

                                    if (readingTime < quickestReadVal) {
                                        quickestReadVal = readingTime
                                        var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                        quickestRead = string
                                        quickestReadID = item_book.id!!
                                    }

                                    if (readingTime < quickestReadValAllTime) {
                                        quickestReadValAllTime = readingTime
                                        var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                        quickestReadAllTime = string
                                        quickestReadAllTimeID = item_book.id!!
                                    }

                                    readingTimeSum += readingTime
                                    averageReadingTimeNumOfBooks ++

                                    readingTimeSumAllTime += readingTime
                                    averageReadingTimeNumOfBooksAllTime ++
                                }

                                if (item_book.bookStartDate != "none" && item_book.bookStartDate != "null") {
                                    var readingTime = item_book.bookFinishDate.toLong() - item_book.bookStartDate.toLong()

                                    if (readingTime < quickestReadVal) {
                                        quickestReadVal = readingTime
                                        var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                        quickestRead = string
                                        quickestReadID = item_book.id!!
                                    }

                                    readingTimeSum += readingTime
                                    averageReadingTimeNumOfBooks ++
                                }

                                if (item_book.bookStartDate != "none" && item_book.bookStartDate != "null") {
                                    var readingTime = item_book.bookFinishDate.toLong() - item_book.bookStartDate.toLong()

                                    if (readingTime > longestReadVal) {
                                        longestReadVal = readingTime
                                        var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                        longestRead = string
                                        longestReadID = item_book.id!!
                                    }

                                    if (readingTime > longestReadValAllTime) {
                                        longestReadValAllTime = readingTime
                                        var string = item_book.bookTitle + " - " + item_book.bookAuthor
                                        longestReadAllTime = string
                                        longestReadAllTimeID = item_book.id!!
                                    }
                                }
                            }
                        }
                    }

                    var avgReadingTime = "0"
                    if (averageReadingTimeNumOfBooks != 0L)
                        avgReadingTime =(readingTimeSum/averageReadingTimeNumOfBooks).toString()

                    var avgPages = 0
                    if (booksInYear != 0)
                        avgPages = (pagesInYear/booksInYear)

                    var avgRating = 0F
                    if (booksInYear != 0)
                        avgRating = (sumRatingInYear/booksInYear)

                    listOfYears.add(Year(
                        item_year.toString(),
                        booksInYear,
                        pagesInYear,
                        avgRating,
                        0,
                        0,
                        quickestRead,
                        quickestReadID,
                        quickestReadVal.toString(),
                        longestBook,
                        longestBookID,
                        longestBookVal,
                        avgReadingTime,
                        avgPages,
                        shortestBook,
                        shortestBookID,
                        shortestBookVal,
                        booksByMonths,
                        pagesByMonths,
                        yearLongestReadBook = longestRead,
                        yearLongestReadBookID = longestReadID,
                        yearLongestReadVal = longestReadVal.toString()
                    ))
                }

                var avgReadingTimeAllTime = "0"
                if (averageReadingTimeNumOfBooksAllTime != 0L)
                    avgReadingTimeAllTime =(readingTimeSumAllTime/averageReadingTimeNumOfBooksAllTime).toString()

                var avgPagesAllTime = 0
                if (booksAllTime != 0)
                    avgPagesAllTime = (pagesAllTime/booksAllTime)

                var avgRatingAllTime = 0F
                if (booksAllTime != 0)
                    avgRatingAllTime = (sumRatingAllTime/booksAllTime)

                listOfYears[0] = Year("0000",
                    booksAllTime,
                    pagesAllTime,
                    avgRatingAllTime,
                    0,
                    0,
                    quickestReadAllTime,
                    quickestReadAllTimeID,
                    quickestReadValAllTime.toString(),
                    longestBookAllTime,
                    longestBookAllTimeID,
                    longestBookValAllTime,
                    avgReadingTimeAllTime,
                    avgPagesAllTime,
                    shortestBookAllTime,
                    shortestBookAllTimeID,
                    shortestBookValAllTime,
                    booksByMonthsAllTime,
                    pagesByMonthsAllTime,
                    yearLongestReadBook = longestReadAllTime,
                    yearLongestReadBookID = longestReadAllTimeID,
                    yearLongestReadVal = longestReadValAllTime.toString()
                )

                var readBooksAllTime = 0
                var inProgressBooksAllTime = 0
                var toReadBooksAllTime = 0
                var notFinishedBooksAllTime = 0

                viewModel.getBookCount(Constants.BOOK_STATUS_READ).observe(viewLifecycleOwner, Observer {it
                    if (it != null)
                        readBooksAllTime = it.toInt()

                    viewModel.getBookCount(Constants.BOOK_STATUS_IN_PROGRESS).observe(viewLifecycleOwner, Observer {
                        if (it != null)
                            inProgressBooksAllTime = it.toInt()

                        viewModel.getBookCount(Constants.BOOK_STATUS_TO_READ).observe(viewLifecycleOwner, Observer {
                            if (it != null)
                                toReadBooksAllTime = it.toInt()

                            viewModel.getBookCount(Constants.BOOK_STATUS_NOT_FINISHED).observe(viewLifecycleOwner, Observer {
                                if (it != null)
                                    notFinishedBooksAllTime = it.toInt()

                                listOfYears[0].yearReadBooks = readBooksAllTime
                                listOfYears[0].yearInProgressBooks = inProgressBooksAllTime
                                listOfYears[0].yearToReadBooks = toReadBooksAllTime
                                listOfYears[0].yearNotFinishedBooks = notFinishedBooksAllTime

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
                            })
                        })

                    })
                })
            })
    }

    private fun calculateHowManyYearsForStats(books: List<Book>): List<Int> {
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
        return years
    }

    private fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }
}