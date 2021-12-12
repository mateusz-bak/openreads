package software.mdev.bookstracker.ui.bookslist.dialogs

import android.app.Dialog
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.AnimationUtils
import android.view.inputmethod.InputMethodManager
import android.widget.*
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.graphics.scale
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.snackbar.Snackbar
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.dialog_add_edit_book.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.other.RoundCornersTransform
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.dialogs.AddEditBookDialogArgs
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.io.ByteArrayOutputStream
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*


class AddEditBookDialog : DialogFragment() {

    lateinit var viewModel: BooksViewModel
    private val args: AddEditBookDialogArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity
    private var bookFinishDateMs: Long? = null
    private var bookStartDateMs: Long? = null
    private var animateRating = false
    private var whatIsClicked = Constants.BOOK_STATUS_NOTHING
    private lateinit var takePhoto: ActivityResultLauncher<Void>
    private lateinit var choosePhoto: ActivityResultLauncher<Array<String>>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        when (args.accent) {
            0 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_LightGreen)
            1 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Orange)
            2 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Cyan)
            3 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Green)
            4 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Brown)
            5 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Lime)
            6 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Pink)
            7 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Purple)
            8 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Teal)
            9 -> setStyle(STYLE_NORMAL, R.style.Theme_Mdev_Bookstracker_FullScreenDialog_Yellow)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        super.onCreateView(inflater, container, savedInstanceState)
        return inflater.inflate(R.layout.dialog_add_edit_book, container, false)
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        return object : Dialog(requireActivity(), theme) {
            override fun onBackPressed() {
                if (dpBookStartDate.visibility == View.VISIBLE ||
                    dpBookFinishDate.visibility == View.VISIBLE
                ) {
                    startDatePickerVis(false)
                    finishDatePickerVis(false)
                    svEditor.visibility = View.VISIBLE
                } else
                    dismiss()
            }
        }
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        // callback for cover from camera
        takePhoto = registerForActivityResult(ActivityResultContracts.TakePicturePreview()) {
            ivBookCover.setImageBitmap(it)
        }

        // callback for cover from files
        choosePhoto = registerForActivityResult(ActivityResultContracts.OpenDocument()) {
            ivBookCover.setImageURI(it)
        }

        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val database = BooksDatabase(view.context)
        val yearDatabase = YearDatabase(view.context)
        val languageDatabase = LanguageDatabase(view.context)

        val repository = BooksRepository(database)
        val yearRepository = YearRepository(yearDatabase)
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(languageDatabase)

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            repository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        book = args.book
        val bookSource = args.bookSource
        var accentColor = getAccentColor(view.context)

        val viewModel = ViewModelProviders.of(this, booksViewModelProviderFactory)
            .get(BooksViewModel::class.java)


        startDatePickerVis(false)
        finishDatePickerVis(false)
        setSpinner()
        initConfig()

        if (bookSource == Constants.FROM_DISPLAY
            || bookSource == Constants.FROM_SCAN
            || bookSource == Constants.FROM_SEARCH
        )
            populateBooksDetails()

        if (bookSource == Constants.NO_SOURCE
            || bookSource == Constants.FROM_SCAN
            || bookSource == Constants.FROM_SEARCH
        )
            setFinishDateToToday()

        setInitialViews()

        // set cover image
        when (bookSource) {
            Constants.FROM_DISPLAY -> {
                if (book.bookCoverImg == null)
                    setCoverFromURL(view, book.bookCoverUrl)
                else
                    setCoverFromDB(book.bookCoverImg)
            }
            Constants.FROM_SEARCH -> setCoverFromURL(view, book.bookCoverUrl)
            Constants.FROM_SCAN -> setCoverFromURL(view, book.bookCoverUrl)
        }

        tietBookTitle.requestFocus()
        showKeyboard(tietBookTitle, 600)

        btnBookCancel.setOnClickListener {
            view?.hideKeyboard()
            recalculateChallenges()

            when (bookSource) {
                Constants.NO_SOURCE -> dismiss()
                Constants.FROM_SEARCH -> popBackStack(1)
                Constants.FROM_SCAN -> popBackStack(3) // TODO book cancel from scan
                Constants.FROM_DISPLAY -> dismiss()
            }
        }

        clBookStartDate.setOnClickListener {
            view?.hideKeyboard()
            svEditor.visibility = View.GONE
            startDatePickerVis(true)
        }

        clBookFinishDate.setOnClickListener {
            view?.hideKeyboard()
            svEditor.visibility = View.GONE
            finishDatePickerVis(true)
        }

        btnStartDateCancel.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            startDatePickerVis(false)
        }

        btnStartDateClear.setOnClickListener {
            bookStartDateMs = null
            tvBookStartDateValue.text = context?.getString(R.string.set)

            svEditor.visibility = View.VISIBLE
            startDatePickerVis(false)
        }

        btnStartDateSave.setOnClickListener {
            bookStartDateMs = getDateFromDatePickerInMillis(dpBookStartDate)
            bookStartDateMs = clearDateOfTime(bookStartDateMs!!)

            svEditor.visibility = View.VISIBLE
            startDatePickerVis(false)
            tvBookStartDateValue.text = bookStartDateMs?.let { it1 -> convertLongToTime(it1) }
        }

        btnFinishDateCancel.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            finishDatePickerVis(false)
        }

        btnFinishDateClear.setOnClickListener {
            bookFinishDateMs = null
            tvBookFinishDateValue.text = context?.getString(R.string.set)

            svEditor.visibility = View.VISIBLE
            finishDatePickerVis(false)
        }

        btnFinishDateSave.setOnClickListener {
            bookFinishDateMs = getDateFromDatePickerInMillis(dpBookFinishDate)
            bookFinishDateMs = clearDateOfTime(bookFinishDateMs!!)

            svEditor.visibility = View.VISIBLE
            finishDatePickerVis(false)
            tvBookFinishDateValue.text = bookFinishDateMs?.let { it1 -> convertLongToTime(it1) }
        }

        btnBookSave.setOnClickListener {
            view?.hideKeyboard()

            if (validateDetails()) {
                val newBook = getDetailsFromInputs()

                when (bookSource) {
                    Constants.NO_SOURCE -> {
                        newBook.bookCoverUrl = Constants.DATABASE_EMPTY_VALUE

                        viewModel.upsert(newBook)
                        recalculateChallenges()
                        dismiss()
                    }
                    Constants.FROM_SEARCH -> { // TODO book save from search
                        viewModel.upsert(newBook)
                        recalculateChallenges()
                        popBackStack(1)
                    }
                    Constants.FROM_SCAN -> { // TODO book save from scan
                        viewModel.upsert(newBook)
                        recalculateChallenges()
                        popBackStack(3)
                    }
                    Constants.FROM_DISPLAY -> {

                        viewModel.updateBook(
                            book.id,
                            newBook.bookTitle,
                            newBook.bookAuthor,
                            newBook.bookRating,
                            newBook.bookStatus,
                            newBook.bookPriority,
                            newBook.bookStartDate,
                            newBook.bookFinishDate,
                            newBook.bookNumberOfPages,
                            newBook.bookTitle_ASCII,
                            newBook.bookAuthor_ASCII,
                            newBook.bookIsDeleted,
                            newBook.bookCoverUrl,
                            newBook.bookOLID,
                            newBook.bookISBN10,
                            newBook.bookISBN13,
                            newBook.bookPublishYear,
                            newBook.bookIsFav,
                            newBook.bookCoverImg
                        )

                        recalculateChallenges()
                        dismiss()
                    }
                }
            }
        }

        tietBookTitle.addTextChangedListener { editable ->
            editable?.let {
                if (it.isNotEmpty())
                    ivClearBookTitle.visibility = View.VISIBLE
                else
                    ivClearBookTitle.visibility = View.GONE
            }
        }

        tietBookAuthor.addTextChangedListener { editable ->
            editable?.let {
                if (it.isNotEmpty())
                    ivClearBookAuthor.visibility = View.VISIBLE
                else
                    ivClearBookAuthor.visibility = View.GONE
            }
        }

        ivClearBookTitle.setOnClickListener {
            tietBookTitle.setText("")
        }

        ivClearBookAuthor.setOnClickListener {
            tietBookAuthor.setText("")
        }

        btnCoverRemove.setOnClickListener {
            ivBookCover.setImageDrawable(null)
        }

        rlBookCover.setOnClickListener {
            view?.hideKeyboard()
            showBottomSheetDialog()
        }

        tvClickToAddCover.setOnClickListener {
            view?.hideKeyboard()
            showBottomSheetDialog()
        }

        ivBookCover.setOnClickListener {
            view?.hideKeyboard()
            showBottomSheetDialog()
        }

    }

    override fun onStart() {
        super.onStart()
        val dialog: Dialog? = dialog
        if (dialog != null) {
            val width = ViewGroup.LayoutParams.MATCH_PARENT
            val height = ViewGroup.LayoutParams.MATCH_PARENT
            if (dialog.window != null) {
                dialog.window?.setLayout(width, height)
                dialog.window?.setWindowAnimations(R.style.Theme_Mdev_Bookstracker_Slide)
            }
        }
    }

    companion object {
        const val TAG = "dialog_add_edit_book"
        fun display(fragmentManager: FragmentManager?): AddEditBookDialog {
            val exampleDialog = AddEditBookDialog()
            exampleDialog.show(fragmentManager!!, TAG)
            return exampleDialog
        }
    }

    private fun getDetailsFromInputs(): Book {
        val REGEX_UNACCENT =
            "\\p{InCombiningDiacriticalMarks}+".toRegex()

        fun CharSequence.unaccent(): String {
            val temp =
                Normalizer.normalize(this, Normalizer.Form.NFD)
            return REGEX_UNACCENT.replace(temp, "")
        }

        var bookRating = 0.0F
        if (whatIsClicked == Constants.BOOK_STATUS_READ)
            bookRating = rbBookRating.rating

        var booksPages = 0
        if (tietBookPages.text != null) {
            if (tietBookPages.text!!.isNotEmpty())
                booksPages = tietBookPages.text.toString().toInt()
        }

        var booksPubYear = 0
        if (tietBookPublishYear.text != null) {
            if (tietBookPublishYear.text!!.isNotEmpty())
                booksPubYear = tietBookPublishYear.text.toString().toInt()
        }

        var bookStartDate = Constants.DATABASE_EMPTY_VALUE
        if (whatIsClicked == Constants.BOOK_STATUS_READ || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS)
            bookStartDate = bookStartDateMs.toString()

        var bookFinishDate = Constants.DATABASE_EMPTY_VALUE
        if (whatIsClicked == Constants.BOOK_STATUS_READ)
            bookFinishDate = bookFinishDateMs.toString()

        var bookOLID = Constants.DATABASE_EMPTY_VALUE
        if (tietBookOLID.text != null) {
            if (tietBookOLID.text!!.isNotEmpty()) {
                bookOLID = tietBookOLID.text.toString()!!
            }
        }

        var bookISBN = Constants.DATABASE_EMPTY_VALUE
        if (tietBookISBN.text != null) {
            if (tietBookISBN.text!!.isNotEmpty()) {
                bookISBN = tietBookISBN.text.toString()!!
            }
        }

        var bookCoverImg: ByteArray? = getCoverFromImageView()

        return Book(
            tietBookTitle.text.toString(),
            tietBookAuthor.text.toString(),
            bookRating,
            whatIsClicked,
            Constants.DATABASE_EMPTY_VALUE,
            bookStartDate,
            bookFinishDate,
            booksPages,
            tietBookTitle.text.toString().unaccent().replace("ł", "l", false),
            tietBookAuthor.text.toString().unaccent().replace("ł", "l", false),
            false,
            book.bookCoverUrl,
            bookOLID,
            Constants.DATABASE_EMPTY_VALUE,
            bookISBN,
            booksPubYear,
            book.bookIsFav,
            bookCoverImg
        )
    }

    private fun validateDetails(): Boolean {
        if (tietBookTitle.text != null) {
            if (tietBookTitle.text!!.isEmpty()) {
                view?.let {
                    Snackbar.make(
                        it,
                        getString(R.string.sbWarningTitle),
                        Snackbar.LENGTH_SHORT
                    ).show()
                }
                return false
            }
        }

        if (tietBookAuthor.text != null) {
            if (tietBookAuthor.text!!.isEmpty()) {
                view?.let {
                    Snackbar.make(
                        it,
                        getString(R.string.sbWarningAuthor),
                        Snackbar.LENGTH_SHORT
                    ).show()
                }
                return false
            }
        }

        when (whatIsClicked) {
            Constants.BOOK_STATUS_READ -> {
                if (bookStartDateMs != null && bookFinishDateMs != null) {
                    if (bookStartDateMs!! > bookFinishDateMs!!) {
                        view?.let {
                            Snackbar.make(
                                it,
                                getString(R.string.sbWarningStartDateMustBeBeforeFinishDate),
                                Snackbar.LENGTH_SHORT
                            ).show()
                        }
                        return false
                    }
                }
            }
        }
        return true
    }

    private fun setInitialViews() {
        // add minimal delay to get proper height of views
        MainScope().launch {
            delay(50)
            clBookStatus.layoutParams.height = tietBookTitle.height
            clBookRating.layoutParams.height = (tietBookTitle.height * 1.4).toInt()
            clBookStartDate.layoutParams.height = tietBookTitle.height
            clBookFinishDate.layoutParams.height = tietBookTitle.height

            clBookStatus.requestLayout()
            clBookRating.requestLayout()
            clBookStartDate.requestLayout()
            clBookFinishDate.requestLayout()
            ivBookFinishDate.requestLayout()
        }

        setRatingAndDatesVis()
    }

    private fun setSpinner() {
        val spinner = spBookStatus
        val bookStatuses = arrayListOf<String>()

        activity?.let {
            bookStatuses.add(it.getString(R.string.finished))
            bookStatuses.add(it.getString(R.string.inProgress))
            bookStatuses.add(it.getString(R.string.toRead))

            val spinnerAdapter = ArrayAdapter(
                requireActivity().baseContext,
                android.R.layout.simple_spinner_item,
                bookStatuses
            )
            spinnerAdapter.setDropDownViewResource(R.layout.simple_spinner_dropdown)
            spinner.adapter = spinnerAdapter
        }

        val listener: AdapterView.OnItemSelectedListener =
            object : AdapterView.OnItemSelectedListener {
                override fun onItemSelected(
                    parent: AdapterView<*>,
                    view: View,
                    position: Int,
                    id: Long
                ) {
                    view.hideKeyboard()
                    activity?.resources?.getColor(R.color.colorDefaultText)?.let {
                        (parent.getChildAt(0) as TextView).setTextColor(
                            it
                        )
                    }

                    when (position) {
                        0 -> {
                            ivBookStatus.setImageDrawable(
                                activity?.baseContext?.resources?.getDrawable(
                                    R.drawable.ic_iconscout_check_circle_24
                                )
                            )
                            whatIsClicked = Constants.BOOK_STATUS_READ
                        }
                        1 -> {
                            ivBookStatus.setImageDrawable(
                                activity?.baseContext?.resources?.getDrawable(
                                    R.drawable.ic_iconscout_book_open_24
                                )
                            )
                            whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
                        }
                        2 -> {
                            ivBookStatus.setImageDrawable(
                                activity?.baseContext?.resources?.getDrawable(
                                    R.drawable.ic_iconscout_clock_nine_24
                                )
                            )
                            whatIsClicked = Constants.BOOK_STATUS_TO_READ
                        }
                    }

                    setRatingAndDatesVis()
                    animateRating = true
                }

                override fun onNothingSelected(parent: AdapterView<*>?) {}
            }

        spinner.onItemSelectedListener = listener
    }

    private fun populateBooksDetails() {
        tietBookTitle.setText(book.bookTitle)
        if (tietBookTitle.text?.isNotEmpty() == true)
            ivClearBookTitle.visibility = View.VISIBLE
        else
            ivClearBookTitle.visibility = View.GONE

        tietBookAuthor.setText(book.bookAuthor)
        if (tietBookAuthor.text?.isNotEmpty() == true)
            ivClearBookAuthor.visibility = View.VISIBLE
        else
            ivClearBookAuthor.visibility = View.GONE

        when (book.bookStatus) {
            Constants.BOOK_STATUS_READ -> {
                whatIsClicked = Constants.BOOK_STATUS_READ
                rbBookRating.rating = book.bookRating
                spBookStatus.setSelection(0)
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
                tvBookRating.visibility = View.GONE
                clBookRating.visibility = View.GONE
                spBookStatus.setSelection(1)
            }
            Constants.BOOK_STATUS_TO_READ -> {
                whatIsClicked = Constants.BOOK_STATUS_TO_READ
                tvBookRating.visibility = View.GONE
                clBookRating.visibility = View.GONE
                spBookStatus.setSelection(2)
            }
        }

        tietBookPages.setText(book.bookNumberOfPages.toString())
        tietBookPublishYear.setText(book.bookPublishYear.toString())
        tietBookISBN.setText(book.bookISBN13)

        if (book.bookISBN13 == "none" || book.bookISBN13 == "null") {
            if (book.bookISBN10 == "none" || book.bookISBN10 == "null") {
                tietBookISBN.setText(Constants.EMPTY_STRING)
            } else {
                tietBookISBN.setText(book.bookISBN10)
            }
        } else {
            tietBookISBN.setText(book.bookISBN13)
        }

        if (book.bookOLID == "none" || book.bookOLID == "null") {
            tietBookOLID.setText(Constants.EMPTY_STRING)
        } else {
            tietBookOLID.setText(book.bookOLID)
        }

        if (book.bookStartDate == "none" || book.bookStartDate == "null") {
            tvBookStartDateValue.text = getString(R.string.set)
        } else {
            bookStartDateMs = book.bookStartDate.toLong()
            tvBookStartDateValue.text = convertLongToTime(bookStartDateMs!!)
        }

        if (book.bookFinishDate == "none" || book.bookFinishDate == "null") {
            tvBookFinishDateValue.text = getString(R.string.set)
        } else {
            bookFinishDateMs = book.bookFinishDate.toLong()
            tvBookFinishDateValue.text = convertLongToTime(bookFinishDateMs!!)
        }
    }

    private fun setFinishDateToToday() {
        bookFinishDateMs = System.currentTimeMillis()
        bookFinishDateMs = clearDateOfTime(bookFinishDateMs!!)
        tvBookFinishDateValue.text = convertLongToTime(bookFinishDateMs!!)
    }

    private fun setRatingAndDatesVis() {
        when (whatIsClicked) {
            Constants.BOOK_STATUS_READ -> {
                tvBookRating.visibility = View.VISIBLE
                clBookRating.visibility = View.VISIBLE

                tvBookStartDate.visibility = View.VISIBLE
                clBookStartDate.visibility = View.VISIBLE

                tvBookFinishDate.visibility = View.VISIBLE
                clBookFinishDate.visibility = View.VISIBLE

                val layoutParams: ConstraintLayout.LayoutParams =
                    clBookStartDate.layoutParams as ConstraintLayout.LayoutParams
                layoutParams.endToEnd = tilBookPages.id
                clBookStartDate.layoutParams = layoutParams

                // disable scale anim on loading view when book status is finished
                if (animateRating)
                    hintRatingDatesAnim(arrayOf(clBookRating, clBookStartDate, clBookFinishDate))
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                tvBookRating.visibility = View.GONE
                clBookRating.visibility = View.GONE

                tvBookStartDate.visibility = View.VISIBLE
                clBookStartDate.visibility = View.VISIBLE

                tvBookFinishDate.visibility = View.GONE
                clBookFinishDate.visibility = View.GONE

                val layoutParams: ConstraintLayout.LayoutParams =
                    clBookStartDate.layoutParams as ConstraintLayout.LayoutParams
                layoutParams.endToEnd = tilBookPublishYear.id
                clBookStartDate.layoutParams = layoutParams

                if (animateRating)
                    hintRatingDatesAnim(arrayOf(clBookStartDate))
            }
            Constants.BOOK_STATUS_TO_READ -> {
                tvBookRating.visibility = View.GONE
                clBookRating.visibility = View.GONE

                tvBookStartDate.visibility = View.GONE
                clBookStartDate.visibility = View.GONE

                tvBookFinishDate.visibility = View.GONE
                clBookFinishDate.visibility = View.GONE
            }
        }
    }

    private fun startDatePickerVis(visibility: Boolean) {
        var viewVisibility = if (visibility)
            View.VISIBLE
        else
            View.GONE

        dpBookStartDate.visibility = viewVisibility
        btnStartDateCancel.visibility = viewVisibility
        btnStartDateSave.visibility = viewVisibility
        btnStartDateClear.visibility = viewVisibility
    }

    private fun finishDatePickerVis(visibility: Boolean) {
        var viewVisibility = if (visibility)
            View.VISIBLE
        else
            View.GONE

        dpBookFinishDate.visibility = viewVisibility
        btnFinishDateCancel.visibility = viewVisibility
        btnFinishDateSave.visibility = viewVisibility
        btnFinishDateClear.visibility = viewVisibility
    }

    private fun clearDateOfTime(orgDate: Long): Long {
        var date = Calendar.getInstance()
        date.timeInMillis = orgDate!!

        var year = date.get(Calendar.YEAR)
        var month = date.get(Calendar.MONTH)
        var day = date.get(Calendar.DAY_OF_MONTH)

        var dateWithoutTime = Calendar.getInstance()
        dateWithoutTime.timeInMillis = 0L
        dateWithoutTime.set(Calendar.YEAR, year)
        dateWithoutTime.set(Calendar.MONTH, month)
        dateWithoutTime.set(Calendar.DAY_OF_MONTH, day)
        dateWithoutTime.set(Calendar.HOUR, 0)
        dateWithoutTime.set(Calendar.MINUTE, 0)
        dateWithoutTime.set(Calendar.SECOND, 0)
        dateWithoutTime.set(Calendar.MILLISECOND, 0)

        return dateWithoutTime.timeInMillis
    }

    private fun initConfig() {
        dpBookStartDate.maxDate = System.currentTimeMillis()
        dpBookFinishDate.maxDate = System.currentTimeMillis()
    }

    private fun hintRatingDatesAnim(views: Array<View>) {
        for (view in views)
            view.startAnimation(AnimationUtils.loadAnimation(context, R.anim.shake_1_minimal))
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun View.showKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.toggleSoftInputFromWindow(windowToken, 0, 0)
    }

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                if (context != null) {
                    val inputManager =
                        context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    inputManager.showSoftInput(et, 0)
                }
            }
        }, delay)
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }

    fun getDateFromDatePickerInMillis(datePicker: DatePicker): Long? {
        val day = datePicker.dayOfMonth
        val month = datePicker.month
        val year = datePicker.year
        val calendar = Calendar.getInstance()
        calendar[year, month] = day
        return calendar.timeInMillis
    }

    fun getAccentColor(context: Context): Int {
        var accentColor = ContextCompat.getColor(context, R.color.green_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when (accent) {
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor =
                ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor =
                ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor =
                ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor =
                ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor =
                ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor =
                ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }

    private fun recalculateChallenges() {
        viewModel.getSortedBooksByFinishDateDesc(Constants.BOOK_STATUS_READ)
            .observe(viewLifecycleOwner, Observer { books ->
                var year: Int
                var years = listOf<Int>()

                for (item in books) {
                    if (item.bookFinishDate != "null" && item.bookFinishDate != "none") {
                        year = convertLongToYear(item.bookFinishDate.toLong()).toInt()
                        if (year !in years) {
                            years = years + year
                        }
                    }
                }

                for (item_year in years) {
                    var booksInYear = 0

                    for (item_book in books) {
                        if (item_book.bookFinishDate != "none" && item_book.bookFinishDate != "null") {
                            year = convertLongToYear(item_book.bookFinishDate.toLong()).toInt()
                            if (year == item_year) {
                                booksInYear++
                            }
                        }
                    }
                    viewModel.updateYearsNumberOfBooks(item_year.toString(), booksInYear)
                }
            }
            )
    }

    private fun popBackStack(times: Int = 1) {
        lifecycleScope.launch {
            delay(100L)
            view?.hideKeyboard()

            for (i in 1..times) {
                findNavController().popBackStack()
            }
        }
    }

    private fun getCoverFromImageView(): ByteArray? {
        try {
            val imageView = view?.findViewById(R.id.ivBookCover) as ImageView
            if (imageView.drawable != null) {
                val bitmap = (imageView.drawable as BitmapDrawable).bitmap
                val baos = ByteArrayOutputStream()
                val resizedBitmap = resizeCover(bitmap)

                resizedBitmap.compress(Bitmap.CompressFormat.JPEG, 95, baos)

                return baos.toByteArray()
            } else
                return null
        } catch (e: Exception) {
            return null
        }
    }

    private fun resizeCover(bitmap: Bitmap): Bitmap {
        var width = bitmap.width.toFloat()
        var height = bitmap.height.toFloat()
        var ratio: Float = width / height


        var newWidth = 512
        var newHeight = (newWidth / ratio).toInt()

        return bitmap.scale(newWidth, newHeight)
    }

    private fun setCoverFromDB(bookCoverImg: ByteArray?) {
        if (bookCoverImg != null) {
            val bmp = BitmapFactory.decodeByteArray(bookCoverImg, 0, bookCoverImg.size)
            ivBookCover.setImageBitmap(bmp)
        }
    }

    private fun setCoverFromURL(view: View, bookCoverUrl: String) {
        if (bookCoverUrl != "none" && bookCoverUrl != "null") {
            val circularProgressDrawable = CircularProgressDrawable(view.context)
            circularProgressDrawable.strokeWidth = 5f
            circularProgressDrawable.centerRadius = 30f
            circularProgressDrawable.setColorSchemeColors(
                ContextCompat.getColor(
                    view.context,
                    R.color.grey
                )
            )
            circularProgressDrawable.start()

            var coverUrl = "https://covers.openlibrary.org/b/id/$bookCoverUrl-L.jpg"

            Picasso
                .get()
                .load(coverUrl)
                .placeholder(circularProgressDrawable)
                .error(R.drawable.ic_iconscout_exclamation_octagon_24)
                .transform(RoundCornersTransform(16.0f))
                .into(ivBookCover)
        }
    }

    private fun showBottomSheetDialog() {
        if (context != null) {
            val bottomSheetDialog =
                BottomSheetDialog(requireContext(), R.style.AppBottomSheetDialogTheme)
            bottomSheetDialog.setContentView(R.layout.bottom_sheet_upload_cover)

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llUploadFromStorage)
                ?.setOnClickListener {
                    uploadCoverFromStorage()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llUploadFromCamera)
                ?.setOnClickListener {
                    uploadCoverFromCamera()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.show()
        }
    }

    private fun uploadCoverFromStorage() {
        if (Functions().checkPermission(
                activity as ListActivity,
                android.Manifest.permission.READ_EXTERNAL_STORAGE
            )
        ) {
            choosePhoto.launch(null)
        } else {
            Functions().requestPermission(
                activity as ListActivity,
                android.Manifest.permission.READ_EXTERNAL_STORAGE,
                Constants.PERMISSION_READ_EXTERNAL_STORAGE_FROM_UPLOAD_COVER
            )
        }
    }

    private fun uploadCoverFromCamera() {
        if (Functions().checkPermission(
                activity as ListActivity,
                android.Manifest.permission.CAMERA
            )
        ) {
            takePhoto.launch(null)
        } else {
            Functions().requestPermission(
                activity as ListActivity,
                android.Manifest.permission.CAMERA,
                Constants.PERMISSION_CAMERA_FROM_UPLOAD_COVER
            )
        }
    }
}