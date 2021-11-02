package software.mdev.bookstracker.adapters

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.github.mikephil.charting.charts.PieChart
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.data.*
import com.github.mikephil.charting.formatter.DefaultValueFormatter
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter
import com.github.mikephil.charting.utils.ColorTemplate
import com.github.mikephil.charting.utils.MPPointF
import kotlinx.android.synthetic.main.item_statistics.view.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.ui.bookslist.dialogs.ChallengeDialog
import software.mdev.bookstracker.ui.bookslist.dialogs.ChallengeDialogListener
import software.mdev.bookstracker.ui.bookslist.fragments.StatisticsFragment
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.math.RoundingMode
import java.text.DecimalFormat
import java.util.*
import java.util.concurrent.TimeUnit
import com.github.mikephil.charting.components.Legend


class StatisticsAdapter(
    private val statisticsFragment: StatisticsFragment,
    private val listOfYearsFromDb: List<Year>
) : RecyclerView.Adapter<StatisticsAdapter.StatisticsViewHolder>() {

    private var monthsList = ArrayList<String>()

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

        if (curYear.year == "0000" && curYear.yearBooks == 0) {
            holder.itemView.apply {
                tvLooksEmptyStatistics.visibility = View.VISIBLE

                clBooksRead.visibility = View.GONE
                clPagesRead.visibility = View.GONE
                clAvgRating.visibility = View.GONE
                clChallenge.visibility = View.GONE
                clQuickestRead.visibility = View.GONE
                clLongestRead.visibility = View.GONE
                clBooksByMonth.visibility = View.GONE
                clPagesByMonth.visibility = View.GONE
                clAvgReadingTime.visibility = View.GONE
                clAvgPages.visibility = View.GONE
                clLongestBook.visibility = View.GONE
                clShortestBook.visibility = View.GONE
            }
        } else {
            holder.itemView.tvLooksEmptyStatistics.visibility = View.GONE
        }

        if (curYear.year == "0000" && curYear.yearBooks > 0) {
            holder.itemView.clBooksByStatus.visibility = View.VISIBLE
            setupBooksStatusChart(
                holder.itemView,
                curYear.yearReadBooks,
                curYear.yearInProgressBooks,
                curYear.yearToReadBooks
            )
        }
        else {
            holder.itemView.clBooksByStatus.visibility = View.GONE
        }

        var challengeBooksRead = "0"

        holder.itemView.apply {
            tvBooksReadValue.text = curYear.yearBooks.toString()

            tvPagesReadValue.text = curYear.yearPages.toString()

            tvAvgRatingValue.text = curYear.avgRating.toBigDecimal().setScale(1, RoundingMode.UP).toDouble().toString()

            if (curYear.yearQuickestBook == "null"){
                tvQuickestReadBook.text = holder.itemView.resources.getString(R.string.need_more_data)
                tvQuickestReadValue.visibility = View.GONE
            } else {
                var string = convertLongToDays(curYear.yearQuickestBookVal.toLong()) + " " + holder.itemView.resources.getString(R.string.days)
                tvQuickestReadBook.text = curYear.yearQuickestBook
                tvQuickestReadValue.text = string
            }

            if (curYear.yearLongestReadBook == "null"){
                tvLongestReadBook.text = holder.itemView.resources.getString(R.string.need_more_data)
                tvLongestReadValue.visibility = View.GONE
            } else {
                var string = convertLongToDays(curYear.yearLongestReadVal.toLong()) + " " + holder.itemView.resources.getString(R.string.days)
                tvLongestReadBook.text = curYear.yearLongestReadBook
                tvLongestReadValue.text = string
            }

            if (curYear.yearLongestBook == "null"){
                tvLongestBook.text = holder.itemView.resources.getString(R.string.need_more_data)
                tvLongestBookValue.visibility = View.GONE
            } else {
                var string = curYear.yearLongestBookVal.toString() + " " + holder.itemView.resources.getString(R.string.pages)
                tvLongestBookValue.text = string
                tvLongestBook.text = curYear.yearLongestBook
            }

            if (curYear.yearShortestBook == "null"){
                tvShortestBook.text = holder.itemView.resources.getString(R.string.need_more_data)
                tvShortestBookValue.visibility = View.GONE
            } else {
                var string = curYear.yearShortestBookVal.toString() + " " + holder.itemView.resources.getString(R.string.pages)
                tvShortestBookValue.text = string
                tvShortestBook.text = curYear.yearShortestBook
            }

            if (curYear.yearAvgReadingTime == "0" || curYear.yearAvgReadingTime == "null"){
                tvAvgReadingTimeValue.text = holder.itemView.resources.getString(R.string.need_more_data)
            } else {
                var string = convertLongToDays(curYear.yearAvgReadingTime.toLong()) + " " + holder.itemView.resources.getString(R.string.days)
                tvAvgReadingTimeValue.text = string
            }

            if (curYear.yearAvgPages == 0){
                tvAvgPagesValue.text = holder.itemView.resources.getString(R.string.need_more_data)
            } else {
                tvAvgPagesValue.text = curYear.yearAvgPages.toString()
            }



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

            var target = challengeBooksTarget
            var read = challengeBooksRead

            if (target != "null" && read != "null") {
                var challengePercent = ((read.toFloat()/target.toFloat())*100).toInt()
                pbChallenge.progress = challengePercent
            } else {
                pbChallenge.visibility = View.GONE
            }

            setupBooksByMonthChart(holder.itemView, curYear.yearBooksByMonth)
            setupPagesByMonthChart(holder.itemView, curYear.yearPagesByMonth)
        }

        if (position == 0) {
            holder.itemView.clChallenge.setOnClickListener {
                callChallengeDialog(foundYear, it, challengeBooksRead)
            }

            holder.itemView.apply {
                clChallenge.visibility = View.VISIBLE

                if (foundYear == null) {
                    tvChallengeValue.text = resources.getText(R.string.tvChallengeNotSet)
                }
            }
        } else {
            holder.itemView.apply {
                if (foundYear == null) {
                    clChallenge.visibility = View.GONE
                } else {
                    clChallenge.visibility = View.VISIBLE
                }
            }
        }

        // hints when "more data needed"
        holder.itemView.apply {
            val moreDataNeededDialog = this.context?.let { it1 ->
                AlertDialog.Builder(it1)
                    .setTitle(R.string.need_more_data_title)
                    .setMessage(R.string.need_more_data_message)
                    .setPositiveButton(R.string.warning_understand) { _, _ ->
                    }
                    .create()
            }

            if (curYear.yearQuickestBook == "null") {
                clQuickestRead.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }

            if (curYear.yearLongestReadBook == "null") {
                clLongestRead.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }

            if (curYear.yearShortestBook == "null") {
                clShortestBook.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }

            if (curYear.yearLongestBook == "null") {
                clLongestBook.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }

            if (curYear.yearAvgReadingTime == "0") {
                clAvgReadingTime.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }

            if (curYear.yearAvgPages == 0) {
                clAvgPages.setOnClickListener {
                    moreDataNeededDialog?.show()
                }
            }
        }
    }

    private fun setupBooksStatusChart(itemView: View,
                                      readBooks: Int,
                                      inProgressBooks: Int,
                                      toReadBooks: Int) {

        val pieChart: PieChart = itemView.findViewById(R.id.pcBooksByStatus)

        val noOfEmp = ArrayList<PieEntry>()

        noOfEmp.add(PieEntry(readBooks.toFloat(), itemView.resources.getString(R.string.readFragment)))
        noOfEmp.add(PieEntry(inProgressBooks.toFloat(), itemView.resources.getString(R.string.inProgressFragment)))
        noOfEmp.add(PieEntry(toReadBooks.toFloat(), itemView.resources.getString(R.string.toReadFragment)))

        val dataSet = PieDataSet(noOfEmp, "")

        dataSet.setDrawIcons(false)
        dataSet.sliceSpace = 3f
        dataSet.iconsOffset = MPPointF(0F, 40F)
        dataSet.selectionShift = 5f
        dataSet.setColors(*ColorTemplate.PASTEL_COLORS)

        val legend: Legend = pieChart.legend
        legend.verticalAlignment = Legend.LegendVerticalAlignment.TOP
        legend.horizontalAlignment = Legend.LegendHorizontalAlignment.LEFT
        legend.orientation = Legend.LegendOrientation.VERTICAL
        legend.setDrawInside(false)
        legend.xEntrySpace = 7f
        legend.yEntrySpace = 10f
        legend.textSize = 14f

        val data = PieData(dataSet)
        data.setValueTextSize(14f)
        data.setValueTextColor(Color.WHITE)
        data.setValueFormatter(DefaultValueFormatter(0))
        pieChart.data = data
        pieChart.highlightValues(null)
        pieChart.setHoleColor(itemView.resources.getColor(R.color.colorDefaultBg))
        pieChart.holeRadius = 45f

        pieChart.setDrawSliceText(false)
        pieChart.description.isEnabled = false

        pieChart.invalidate()
        pieChart.animateXY(400, 700)
    }

    private fun setupBooksByMonthChart(itemView: View, yearBooksByMonth: Array<Int>) {
        monthsList = arrayListOf(
            itemView.resources.getString(R.string.month_1_short),
            itemView.resources.getString(R.string.month_2_short),
            itemView.resources.getString(R.string.month_3_short),
            itemView.resources.getString(R.string.month_4_short),
            itemView.resources.getString(R.string.month_5_short),
            itemView.resources.getString(R.string.month_6_short),
            itemView.resources.getString(R.string.month_7_short),
            itemView.resources.getString(R.string.month_8_short),
            itemView.resources.getString(R.string.month_9_short),
            itemView.resources.getString(R.string.month_10_short),
            itemView.resources.getString(R.string.month_11_short),
            itemView.resources.getString(R.string.month_12_short)
        )

        val entries: ArrayList<BarEntry> = ArrayList()
        entries.add(BarEntry(0f, yearBooksByMonth[0].toFloat()))
        entries.add(BarEntry(1f, yearBooksByMonth[1].toFloat()))
        entries.add(BarEntry(2f, yearBooksByMonth[2].toFloat()))
        entries.add(BarEntry(3f, yearBooksByMonth[3].toFloat()))
        entries.add(BarEntry(4f, yearBooksByMonth[4].toFloat()))
        entries.add(BarEntry(5f, yearBooksByMonth[5].toFloat()))
        entries.add(BarEntry(6f, yearBooksByMonth[6].toFloat()))
        entries.add(BarEntry(7f, yearBooksByMonth[7].toFloat()))
        entries.add(BarEntry(8f, yearBooksByMonth[8].toFloat()))
        entries.add(BarEntry(9f, yearBooksByMonth[9].toFloat()))
        entries.add(BarEntry(10f, yearBooksByMonth[10].toFloat()))
        entries.add(BarEntry(11f, yearBooksByMonth[11].toFloat()))

        val barDataSet = BarDataSet(entries, "")
        barDataSet.setColors(*ColorTemplate.PASTEL_COLORS)

        var data = BarData(barDataSet)
        data.setValueFormatter(DefaultValueFormatter(0))

        // color of values
        data.setValueTextColor(itemView.resources.getColor(R.color.colorDefaultText))

        // size of values
        data.setValueTextSize(11F)

        itemView.rbcBooksByMonth.data = data

        //hide grid lines
        itemView.rbcBooksByMonth.axisLeft.setDrawGridLines(false)
        itemView.rbcBooksByMonth.xAxis.setDrawGridLines(false)
        itemView.rbcBooksByMonth.xAxis.setDrawAxisLine(false)

        //remove right y-axis
        itemView.rbcBooksByMonth.axisRight.isEnabled = false
        //remove left y-axis
        itemView.rbcBooksByMonth.axisLeft.isEnabled = false

        //remove legend
        itemView.rbcBooksByMonth.legend.isEnabled = false

        //remove description label
        itemView.rbcBooksByMonth.description.isEnabled = false

        //add animation
        itemView.rbcBooksByMonth.animateY(800)

        itemView.rbcBooksByMonth.xAxis.position = XAxis.XAxisPosition.BOTTOM

        itemView.rbcBooksByMonth.xAxis.valueFormatter = IndexAxisValueFormatter(monthsList)

        //change x axis label's color
        itemView.rbcBooksByMonth.xAxis.textColor = itemView.resources.getColor(R.color.colorDefaultText)

        //disable touch actions on graph
        itemView.rbcBooksByMonth.setTouchEnabled(false)

        // set x axis' text size
        itemView.rbcBooksByMonth.xAxis.textSize = 11F

        // the x labels are not cut
        itemView.rbcBooksByMonth.extraBottomOffset = 8F

        //draw chart
        itemView.rbcBooksByMonth.invalidate()

        itemView.clBooksByMonth.setOnClickListener {
            var animDuration = 200L
            var scaleSmall = 0.95F
            var scaleBig = 1F

            itemView.rbcBooksByMonth.animateY(500)

            itemView.clBooksByMonth.animate().scaleX(scaleSmall).setDuration(animDuration).start()
            itemView.clBooksByMonth.animate().scaleY(scaleSmall).setDuration(animDuration).start()

            MainScope().launch {
                delay(animDuration)
                itemView.clBooksByMonth.animate().scaleX(scaleBig).setDuration(animDuration).start()
                itemView.clBooksByMonth.animate().scaleY(scaleBig).setDuration(animDuration).start()
            }
        }
    }

    private fun setupPagesByMonthChart(itemView: View, yearPagesByMonth: Array<Int>) {
        monthsList = arrayListOf(
            itemView.resources.getString(R.string.month_1_short),
            itemView.resources.getString(R.string.month_2_short),
            itemView.resources.getString(R.string.month_3_short),
            itemView.resources.getString(R.string.month_4_short),
            itemView.resources.getString(R.string.month_5_short),
            itemView.resources.getString(R.string.month_6_short),
            itemView.resources.getString(R.string.month_7_short),
            itemView.resources.getString(R.string.month_8_short),
            itemView.resources.getString(R.string.month_9_short),
            itemView.resources.getString(R.string.month_10_short),
            itemView.resources.getString(R.string.month_11_short),
            itemView.resources.getString(R.string.month_12_short)
        )

        val entries: ArrayList<BarEntry> = ArrayList()

        entries.add(BarEntry(0f, yearPagesByMonth[0].toFloat()))
        entries.add(BarEntry(1f, yearPagesByMonth[1].toFloat()))
        entries.add(BarEntry(2f, yearPagesByMonth[2].toFloat()))
        entries.add(BarEntry(3f, yearPagesByMonth[3].toFloat()))
        entries.add(BarEntry(4f, yearPagesByMonth[4].toFloat()))
        entries.add(BarEntry(5f, yearPagesByMonth[5].toFloat()))
        entries.add(BarEntry(6f, yearPagesByMonth[6].toFloat()))
        entries.add(BarEntry(7f, yearPagesByMonth[7].toFloat()))
        entries.add(BarEntry(8f, yearPagesByMonth[8].toFloat()))
        entries.add(BarEntry(9f, yearPagesByMonth[9].toFloat()))
        entries.add(BarEntry(10f, yearPagesByMonth[10].toFloat()))
        entries.add(BarEntry(11f, yearPagesByMonth[11].toFloat()))

        val barDataSet = BarDataSet(entries, "")
        barDataSet.setColors(*ColorTemplate.PASTEL_COLORS)

        var data = BarData(barDataSet)
        data.setValueFormatter(DefaultValueFormatter(0))

        // color of values
        data.setValueTextColor(itemView.resources.getColor(R.color.colorDefaultText))

        // size of values
        data.setValueTextSize(11F)

        itemView.rbcPagesByMonth.data = data

        //hide grid lines
        itemView.rbcPagesByMonth.axisLeft.setDrawGridLines(false)
        itemView.rbcPagesByMonth.xAxis.setDrawGridLines(false)
        itemView.rbcPagesByMonth.xAxis.setDrawAxisLine(false)

        //remove right y-axis
        itemView.rbcPagesByMonth.axisRight.isEnabled = false
        //remove left y-axis
        itemView.rbcPagesByMonth.axisLeft.isEnabled = false

        //remove legend
        itemView.rbcPagesByMonth.legend.isEnabled = false

        //remove description label
        itemView.rbcPagesByMonth.description.isEnabled = false

        //add animation
        itemView.rbcPagesByMonth.animateY(900)

        itemView.rbcPagesByMonth.xAxis.position = XAxis.XAxisPosition.BOTTOM

        itemView.rbcPagesByMonth.xAxis.valueFormatter = IndexAxisValueFormatter(monthsList)

        //change x axis label's color
        itemView.rbcPagesByMonth.xAxis.textColor = itemView.resources.getColor(R.color.colorDefaultText)

        //disable touch actions on graph
        itemView.rbcPagesByMonth.setTouchEnabled(false)

        // set x axis' text size
        itemView.rbcPagesByMonth.xAxis.textSize = 11F

        // the x labels are not cut
        itemView.rbcPagesByMonth.extraBottomOffset = 8F

        //draw chart
        itemView.rbcPagesByMonth.invalidate()

        itemView.clPagesByMonth.setOnClickListener {
            var animDuration = 200L
            var scaleSmall = 0.95F
            var scaleBig = 1F

            itemView.rbcPagesByMonth.animateY(500)

            itemView.clPagesByMonth.animate().scaleX(scaleSmall).setDuration(animDuration).start()
            itemView.clPagesByMonth.animate().scaleY(scaleSmall).setDuration(animDuration).start()

            MainScope().launch {
                delay(animDuration)
                itemView.clPagesByMonth.animate().scaleX(scaleBig).setDuration(animDuration).start()
                itemView.clPagesByMonth.animate().scaleY(scaleBig).setDuration(animDuration).start()
            }
        }
    }

    private fun callChallengeDialog(foundYear: Year?, it: View, challengeBooksRead: String) {
        if (foundYear != null) {
            val challengeDialog = ChallengeDialog(it.context,
                foundYear,
                object : ChallengeDialogListener {
                    override fun onSaveButtonClicked(year: Year) {
                        viewModel.upsertYear(year)
                    }
                }
            )
            challengeDialog.show()

            val width = (it.getResources().getDisplayMetrics().widthPixels * 0.80).toInt()

            challengeDialog.getWindow()?.setLayout(width, WindowManager.LayoutParams.WRAP_CONTENT)

        } else {
            ChallengeDialog(it.context,
                Year(
                    Calendar.getInstance().get(Calendar.YEAR).toString(),
                    challengeBooksRead.toInt()
                ),
                object : ChallengeDialogListener {
                    override fun onSaveButtonClicked(year: Year) {
                        viewModel.upsertYear(year)
                    }
                }
            ).show()
        }
    }

    private fun convertLongToDays(time: Long): String {
        return TimeUnit.MILLISECONDS.toDays(time).toString()
    }
}