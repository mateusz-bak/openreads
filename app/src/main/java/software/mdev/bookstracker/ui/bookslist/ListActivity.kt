package software.mdev.bookstracker.ui.bookslist

import android.annotation.SuppressLint
import android.app.Activity
import android.app.SearchManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.ColorStateList
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Bundle
import android.provider.BaseColumns
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.appcompat.widget.SearchView
import androidx.core.content.ContextCompat
import androidx.core.view.MenuItemCompat
import androidx.cursoradapter.widget.CursorAdapter
import androidx.cursoradapter.widget.SimpleCursorAdapter
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_list.*
import kotlinx.android.synthetic.main.fragment_books.*
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Backup
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Updater
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.io.IOException


class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel
    lateinit var notDeletedBooks: List<Book>

    override fun onCreate(savedInstanceState: Bundle?) {
        val booksRepository = BooksRepository(BooksDatabase(this))
        val yearRepository = YearRepository(YearDatabase(this))
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(LanguageDatabase(this))

        val updater = Updater()

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            booksRepository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        setAppThemeMode()
        setAppAccent()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        updater.checkForAppUpdate(this, false)

        // ask for rating only in gplay release
        if (BuildConfig.FLAVOR == "gplay" && BuildConfig.BUILD_TYPE == "release")
            askForRating()

        booksViewModel.getNotDeletedBooks().observe(this, Observer {
            notDeletedBooks = it
        })
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)

        val searchItem = menu?.findItem(R.id.miSearch)
        val searchView = searchItem?.actionView as SearchView

        searchView.queryHint = getString(R.string.search_hint)
        searchView.findViewById<AutoCompleteTextView>(R.id.search_src_text).threshold = 1

        val from = arrayOf(SearchManager.SUGGEST_COLUMN_TEXT_1)
        val to = intArrayOf(R.id.tvSearch)
        val cursorAdapter = SimpleCursorAdapter(baseContext, R.layout.item_search, null, from, to, CursorAdapter.FLAG_REGISTER_CONTENT_OBSERVER)
        var suggestions = mutableListOf<Book>()

        booksViewModel.getNotDeletedBooks().observe(this, Observer {
            suggestions = it as MutableList<Book>
        })

        booksNavHostFragment.findNavController()
            .addOnDestinationChangedListener { _, destination, _ ->
                when(destination.id) {
                    R.id.booksFragment -> {
                        supportActionBar?.setDisplayHomeAsUpEnabled(false)

                        menu.findItem(R.id.miSearch).isVisible = true
                        menu.findItem(R.id.miSort).isVisible = true
                        menu.findItem(R.id.miStatistics).isVisible = true
                        menu.findItem(R.id.miSettings).isVisible = true
                    }
                    R.id.setupFragment -> {
                        supportActionBar?.setDisplayHomeAsUpEnabled(false)

                        MenuItemCompat.collapseActionView(searchItem)

                        menu.findItem(R.id.miSearch).isVisible = false
                        menu.findItem(R.id.miSort).isVisible = false
                        menu.findItem(R.id.miStatistics).isVisible = false
                        menu.findItem(R.id.miSettings).isVisible = false
                    }
                    else -> {
                        supportActionBar?.setDisplayHomeAsUpEnabled(true)
                        searchView.isIconified = true
                        MenuItemCompat.collapseActionView(searchItem)

                        menu.findItem(R.id.miSearch).isVisible = false
                        menu.findItem(R.id.miSort).isVisible = false
                        menu.findItem(R.id.miStatistics).isVisible = false
                        menu.findItem(R.id.miSettings).isVisible = false

                    }
                }
            }

        booksNavHostFragment.findNavController()
            .addOnDestinationChangedListener { _, destination, _ ->
                when(destination.id) {
                    R.id.booksFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(false)
                        supportActionBar?.title = Constants.EMPTY_STRING
                    }
                    R.id.addEditBookFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(false)
                        supportActionBar?.title = Constants.EMPTY_STRING
                    }
                    R.id.addBookSearchFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(true)
                        supportActionBar?.title = this.getString(R.string.btnAddSearch)
                    }
                    R.id.statisticsFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(true)
                        supportActionBar?.title = this.getString(R.string.statisticsFragment)
                    }
                    R.id.settingsFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(true)
                        supportActionBar?.title = this.getString(R.string.settings)
                    }
                    R.id.settingsBackupFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(true)
                        supportActionBar?.title = this.getString(R.string.backup_title)
                    }
                    R.id.trashFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(true)
                        supportActionBar?.title = this.getString(R.string.trash_title)
                    }
                    R.id.displayBookFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(false)
                        supportActionBar?.title = Constants.EMPTY_STRING
                    }
                    R.id.setupFragment -> {
                        supportActionBar?.setDisplayShowTitleEnabled(false)
                        supportActionBar?.title = Constants.EMPTY_STRING
                    }
                }
            }

        searchView.suggestionsAdapter = cursorAdapter

        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {

            override fun onQueryTextSubmit(query: String?): Boolean {
                if (!searchView.suggestionsAdapter.isEmpty) {
                    val cursor = searchView.suggestionsAdapter.getItem(0) as Cursor
                    val selection = cursor.getString(cursor.getColumnIndex(SearchManager.SUGGEST_COLUMN_TEXT_1))
                    val selectionID = cursor.getString(cursor.getColumnIndex(SearchManager.SUGGEST_COLUMN_TEXT_2))
                    searchView.setQuery(selection, false)
                    booksViewModel.getBook(selectionID.toInt()).observe(this@ListActivity) { book ->
                        displayBookFromSearch(book)
                    }

                    searchView.isIconified = true
                    MenuItemCompat.collapseActionView(searchItem)
                    }
                return true
            }

            override fun onQueryTextChange(query: String?): Boolean {
                val cursor = MatrixCursor(arrayOf(BaseColumns._ID, SearchManager.SUGGEST_COLUMN_TEXT_1, SearchManager.SUGGEST_COLUMN_TEXT_2))
                query?.let {
                    suggestions.forEachIndexed { index, suggestion ->
                        if (runSearchQuery(query, suggestion)){
                            val suggestionString = suggestion.bookTitle + " - " + suggestion.bookAuthor
                            cursor.addRow(arrayOf(index, suggestionString, suggestion.id))
                        }
                    }
                }

                cursorAdapter.changeCursor(cursor)
                return true
            }
        })

        searchView.setOnSuggestionListener(object: SearchView.OnSuggestionListener {

            override fun onSuggestionSelect(position: Int): Boolean {
                return false
            }

            override fun onSuggestionClick(position: Int): Boolean {
                hideKeyboard()

                val cursor = searchView.suggestionsAdapter.getItem(position) as Cursor
                val selection = cursor.getString(cursor.getColumnIndex(SearchManager.SUGGEST_COLUMN_TEXT_1))
                val selectionID = cursor.getString(cursor.getColumnIndex(SearchManager.SUGGEST_COLUMN_TEXT_2))
                searchView.setQuery(selection, false)

                booksViewModel.getBook(selectionID.toInt()).observe(this@ListActivity) { book ->
                    displayBookFromSearch(book)
                }

                searchView.isIconified = true
                MenuItemCompat.collapseActionView(searchItem)
                return true
            }

        })

        return true
    }

    private fun runSearchQuery(query: String, suggestion: Book): Boolean {
        var queryResult = false
        var stringResult = true

        val strings = query.split(" ").toTypedArray()

        for (string in strings) {
            if (suggestion.bookTitle.contains(string, true)
                || suggestion.bookTitle_ASCII.contains(string, true)
                || suggestion.bookAuthor.contains(string, true)
                || suggestion.bookAuthor_ASCII.contains(string, true)) {
                queryResult = true
            }
            else
                stringResult = false
        }

       return queryResult && stringResult
    }

    private fun displayBookFromSearch(book: Book) {
        val bundle = Bundle().apply {
            putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, book)
            putSerializable(
                Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE,
                Constants.FROM_DISPLAY
            )
        }

        booksNavHostFragment.findNavController().navigate(
            R.id.displayBookFragment,
            bundle
        )
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.miSettings -> booksNavHostFragment.findNavController().navigate(R.id.settingsFragment)
            R.id.miStatistics -> booksNavHostFragment.findNavController().navigate(R.id.statisticsFragment)
            R.id.miSearch -> onSearchRequested()
            R.id.miSort -> showSortBottomSheetDialog()
            android.R.id.home -> onBackPressed()
        }
        return true
    }

    private fun showSortBottomSheetDialog() {
        val bottomSheetDialog =
            BottomSheetDialog(this, R.style.AppBottomSheetDialogTheme)

        bottomSheetDialog.setContentView(R.layout.bottom_sheet_sort_books)

        setCurrentSortType(bottomSheetDialog)
        setCurrentOnlyFav(bottomSheetDialog)

        setSortBottomSheetDialogColors(bottomSheetDialog)
        setOnRadioButtonClickListeners(bottomSheetDialog)
        setAscDescButtonsListeners(bottomSheetDialog)

        bottomSheetDialog.findViewById<Button>(R.id.btnSortSave)
            ?.setOnClickListener {
                val sortType = getSortType(bottomSheetDialog)
                val isOrderAsc = isOrderAsc(bottomSheetDialog)
                val isOnlyFav = isOnlyFav(bottomSheetDialog)
                saveSortType(sortType, isOrderAsc, isOnlyFav)
                bottomSheetDialog.dismiss()
            }

        bottomSheetDialog.show()
    }

    private fun setCurrentSortType(bottomSheetDialog: BottomSheetDialog) {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)

        val currentSortType = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_SORT_ORDER,
            Constants.SORT_ORDER_TITLE_ASC
        )

        when (currentSortType) {
            Constants.SORT_ORDER_TITLE_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 0, true)

            Constants.SORT_ORDER_TITLE_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 0, false)

            Constants.SORT_ORDER_AUTHOR_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 1, true)

            Constants.SORT_ORDER_AUTHOR_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 1, false)

            Constants.SORT_ORDER_RATING_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 2, true)

            Constants.SORT_ORDER_RATING_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 2, false)

            Constants.SORT_ORDER_PAGES_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 3, true)

            Constants.SORT_ORDER_PAGES_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 3, false)

            Constants.SORT_ORDER_START_DATE_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 4, true)

            Constants.SORT_ORDER_START_DATE_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 4, false)

            Constants.SORT_ORDER_FINISH_DATE_ASC ->
                setCurrentSortTypeViews(bottomSheetDialog, 5, true)

            Constants.SORT_ORDER_FINISH_DATE_DESC ->
                setCurrentSortTypeViews(bottomSheetDialog, 5, false)
        }
    }

    private fun setCurrentOnlyFav(bottomSheetDialog: BottomSheetDialog) {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)

        val currentOnlyFav = sharedPref.getBoolean(
            Constants.SHARED_PREFERENCES_KEY_ONLY_FAV,
            false
        )

        setCurrentOnlyFavViews(bottomSheetDialog, currentOnlyFav)
    }

    private fun setCurrentSortTypeViews(bottomSheetDialog: BottomSheetDialog, sortType: Int, isAsc: Boolean) {
        val radioButtons = listOf<RadioButton?>(
            bottomSheetDialog.findViewById(R.id.rbSortByTitle), //sortType 0
            bottomSheetDialog.findViewById(R.id.rbSortByAuthor), //sortType 1
            bottomSheetDialog.findViewById(R.id.rbSortByRating), //sortType 2
            bottomSheetDialog.findViewById(R.id.rbSortByPages), //sortType 3
            bottomSheetDialog.findViewById(R.id.rbSortByStartDate), //sortType 4
            bottomSheetDialog.findViewById(R.id.rbSortByFinishDate) //sortType 5
        )

        val textViews = listOf<TextView?>(
            bottomSheetDialog.findViewById(R.id.tvOrderAsc),
            bottomSheetDialog.findViewById(R.id.tvOrderDesc)
        )

        for (radioButton in radioButtons) {
            radioButton?.isChecked = radioButton == radioButtons[sortType]
        }

        if (isAsc) {
            textViews[0]?.hint = "true"
            textViews[1]?.hint = "false"

            textViews[0]?.setTextColor(getAccentColor(this))
            textViews[1]?.setTextColor(this.getColor(R.color.colorDefaultText))
        } else {
            textViews[0]?.hint = "false"
            textViews[1]?.hint = "true"

            textViews[0]?.setTextColor(this.getColor(R.color.colorDefaultText))
            textViews[1]?.setTextColor(getAccentColor(this))
        }
    }

    private fun setCurrentOnlyFavViews(bottomSheetDialog: BottomSheetDialog, currentOnlyFav: Boolean) {
        val checkbox = bottomSheetDialog.findViewById<CheckBox>(R.id.cbFilterFavourite)
        checkbox?.isChecked = currentOnlyFav
    }

    private fun saveSortType(sortType: Int?, isOrderAsc: Boolean?, isOnlyFav: Boolean?) {
        if (sortType != null && isOrderAsc != null && isOnlyFav != null) {

            val sortOrder = when (sortType) {
                1 -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_AUTHOR_ASC
                    else
                        Constants.SORT_ORDER_AUTHOR_DESC
                }
                2 -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_RATING_ASC
                    else
                        Constants.SORT_ORDER_RATING_DESC
                }
                3 -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_PAGES_ASC
                    else
                        Constants.SORT_ORDER_PAGES_DESC
                }
                4 -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_START_DATE_ASC
                    else
                        Constants.SORT_ORDER_START_DATE_DESC
                }
                5 -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_FINISH_DATE_ASC
                    else
                        Constants.SORT_ORDER_FINISH_DATE_DESC
                }
                else -> {
                    if (isOrderAsc)
                        Constants.SORT_ORDER_TITLE_ASC
                    else
                        Constants.SORT_ORDER_TITLE_DESC
                }
            }

            var sharedPrefName = getString(R.string.shared_preferences_name)
            val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)
            val sharedPrefEditor = sharedPref?.edit()

            sharedPrefEditor?.apply {
                putString(Constants.SHARED_PREFERENCES_KEY_SORT_ORDER, sortOrder)
                putBoolean(Constants.SHARED_PREFERENCES_KEY_ONLY_FAV, isOnlyFav)
                apply()
            }
            booksViewModel.getBooksTrigger.postValue(System.currentTimeMillis())
        }
    }

    private fun getSortType(bottomSheetDialog: BottomSheetDialog): Int? {
        val radioButtons = listOf<RadioButton?>(
            bottomSheetDialog.findViewById(R.id.rbSortByTitle),
            bottomSheetDialog.findViewById(R.id.rbSortByAuthor),
            bottomSheetDialog.findViewById(R.id.rbSortByRating),
            bottomSheetDialog.findViewById(R.id.rbSortByPages),
            bottomSheetDialog.findViewById(R.id.rbSortByStartDate),
            bottomSheetDialog.findViewById(R.id.rbSortByFinishDate)
        )
        for ((i, radioButton) in radioButtons.withIndex()) {
            if (radioButton?.isChecked == true)
                return i
        }
        return null
    }
    private fun isOrderAsc(bottomSheetDialog: BottomSheetDialog): Boolean? {
        return if (bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)
                ?.hint == "true")
            true
        else if (bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)
                ?.hint == "true")
            false
        else
            null
    }

    private fun isOnlyFav(bottomSheetDialog: BottomSheetDialog): Boolean? {
        return bottomSheetDialog.findViewById<CheckBox>(R.id.cbFilterFavourite)?.isChecked == true
    }

    private fun setAscDescButtonsListeners(bottomSheetDialog: BottomSheetDialog) {
        bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)?.setOnClickListener {
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)
                ?.setTextColor(getAccentColor(this))
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)
                ?.hint = "true"

            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)
                ?.setTextColor(this.getColor(R.color.colorDefaultText))
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)
                ?.hint = "false"
        }

        bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)?.setOnClickListener {
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)
                ?.setTextColor(getAccentColor(this))
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderDesc)
                ?.hint = "true"

            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)
                ?.setTextColor(this.getColor(R.color.colorDefaultText))
            bottomSheetDialog.findViewById<TextView>(R.id.tvOrderAsc)
                ?.hint = "false"
        }
    }

    private fun setSortBottomSheetDialogColors(bottomSheetDialog: BottomSheetDialog) {
        bottomSheetDialog.findViewById<Button>(R.id.btnSortSave)?.backgroundTintList =
            ColorStateList.valueOf(getAccentColor(this))

        bottomSheetDialog.findViewById<CheckBox>(R.id.cbFilterFavourite)?.buttonTintList =
            ColorStateList.valueOf(getAccentColor(this))

        val radioButtons = listOf<RadioButton?>(
            bottomSheetDialog.findViewById(R.id.rbSortByTitle),
            bottomSheetDialog.findViewById(R.id.rbSortByAuthor),
            bottomSheetDialog.findViewById(R.id.rbSortByRating),
            bottomSheetDialog.findViewById(R.id.rbSortByPages),
            bottomSheetDialog.findViewById(R.id.rbSortByStartDate),
            bottomSheetDialog.findViewById(R.id.rbSortByFinishDate)
        )

        for (radioButton in radioButtons) {
            radioButton?.buttonTintList =
                ColorStateList.valueOf(getAccentColor(this))
        }
    }

        private fun setOnRadioButtonClickListeners(bottomSheetDialog: BottomSheetDialog) {
        val radioButtons = listOf<RadioButton?>(
            bottomSheetDialog.findViewById(R.id.rbSortByTitle),
            bottomSheetDialog.findViewById(R.id.rbSortByAuthor),
            bottomSheetDialog.findViewById(R.id.rbSortByRating),
            bottomSheetDialog.findViewById(R.id.rbSortByPages),
            bottomSheetDialog.findViewById(R.id.rbSortByStartDate),
            bottomSheetDialog.findViewById(R.id.rbSortByFinishDate)
        )

        for (radioButton in radioButtons) {
            radioButton?.setOnClickListener {
                for (radioButton2 in radioButtons) {
                    if (radioButton2 == radioButton)
                        radioButton2.isChecked = true
                    else
                        radioButton2?.isChecked = false
                }
            }
        }
    }

    private fun setAppAccent(){
        var sharedPreferencesName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_LightGreen)
            Constants.THEME_ACCENT_ORANGE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Orange)
            Constants.THEME_ACCENT_CYAN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Cyan)
            Constants.THEME_ACCENT_GREEN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Green)
            Constants.THEME_ACCENT_BROWN_400 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Brown)
            Constants.THEME_ACCENT_LIME_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Lime)
            Constants.THEME_ACCENT_PINK_300 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Pink)
            Constants.THEME_ACCENT_PURPLE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Purple)
            Constants.THEME_ACCENT_TEAL_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Teal)
            Constants.THEME_ACCENT_YELLOW_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Yellow)
        }
    }

    fun getAccentColor(context: Context, asOrderedInt: Boolean = false): Int {
        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when (accent) {
            Constants.THEME_ACCENT_LIGHT_GREEN -> {
                accentColor = if (asOrderedInt)
                    0
                else
                    ContextCompat.getColor(context, R.color.light_green)
            }
            Constants.THEME_ACCENT_ORANGE_500 -> {
                accentColor = if (asOrderedInt)
                    1
                else
                    ContextCompat.getColor(context, R.color.orange_500)
            }
            Constants.THEME_ACCENT_CYAN_500 -> {
                accentColor = if (asOrderedInt)
                    2
                else
                    ContextCompat.getColor(context, R.color.cyan_500)
            }
            Constants.THEME_ACCENT_GREEN_500 -> {
                accentColor = if (asOrderedInt)
                    3
                else
                    ContextCompat.getColor(context, R.color.green_500)
            }
            Constants.THEME_ACCENT_BROWN_400 -> {
                accentColor = if (asOrderedInt)
                    4
                else
                    ContextCompat.getColor(context, R.color.brown_400)
            }
            Constants.THEME_ACCENT_LIME_500 -> {
                accentColor = if (asOrderedInt)
                    5
                else
                    ContextCompat.getColor(context, R.color.lime_500)
            }
            Constants.THEME_ACCENT_PINK_300 -> {
                accentColor = if (asOrderedInt)
                    6
                else
                    ContextCompat.getColor(context, R.color.pink_300)
            }
            Constants.THEME_ACCENT_PURPLE_500 -> {
                accentColor = if (asOrderedInt)
                    7
                else
                    ContextCompat.getColor(context, R.color.purple_500)
            }
            Constants.THEME_ACCENT_TEAL_500 -> {
                accentColor = if (asOrderedInt)
                    8
                else
                    ContextCompat.getColor(context, R.color.teal_500)
            }
            Constants.THEME_ACCENT_YELLOW_500 -> {
                accentColor = if (asOrderedInt)
                    9
                else
                    ContextCompat.getColor(context, R.color.yellow_500)
            }
        }
        return accentColor
    }

    private fun setAppThemeMode(){
        var sharedPreferencesName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_THEME_MODE,
            Constants.THEME_MODE_AUTO
        ).toString()

        when(accent){
            Constants.THEME_MODE_AUTO -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
            Constants.THEME_MODE_DAY -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            Constants.THEME_MODE_NIGHT -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
        }
    }

    // Show a snackbar containing a given text and an optional action, with a 5 seconds duration
    @SuppressLint("ResourceType")
    fun showSnackbar(
        content: String,
        attachView: View? = null,
        action: (() -> Unit)? = null,
        actionText: String? = null,
    ) {
        val snackbar = Snackbar.make(findViewById(android.R.id.content), content, 5000)
        snackbar.isGestureInsetBottomIgnored = true
        if (attachView != null)
            snackbar.anchorView = attachView
        else
            snackbar.anchorView = this.fabAddBook
        if (action != null) {
            snackbar.setAction(actionText) {
                action()
            }
        }
        snackbar.show()
    }

    // Choose a backup registering a callback and following the latest guidelines
    val selectBackup =
        registerForActivityResult(ActivityResultContracts.GetContent()) { fileUri: Uri? ->

            try {
                val backupImporter = Backup()
                if (fileUri != null) backupImporter.importBackup(this, fileUri)
            } catch (e: IOException) {
                showSnackbar(e.toString())
                e.printStackTrace()
            }
        }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (grantResults.isNotEmpty()
            && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            when (requestCode) {
                Constants.PERMISSION_CAMERA_FROM_BOOK_LIST -> booksNavHostFragment.findNavController()
                    .navigate(R.id.action_booksFragment_to_addBookScanFragment)
                Constants.PERMISSION_CAMERA_FROM_UPLOAD_COVER ->
                    Toast.makeText(this.baseContext, R.string.permission_granted_click_cover_again, Toast.LENGTH_SHORT).show()
                Constants.PERMISSION_READ_EXTERNAL_STORAGE_FROM_UPLOAD_COVER ->
                    Toast.makeText(this.baseContext, R.string.permission_granted_click_cover_again, Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun askForRating() {
        var askForRatingTime = checkNextAskingTime()

        if (askForRatingTime == 0L)
            setNextAskingTime(System.currentTimeMillis() + Constants.MS_ONE_WEEK)
        else if (askForRatingTime == Long.MAX_VALUE) {

        } else {
            if (askForRatingTime < System.currentTimeMillis())
                displayAskForRatingDialog()
        }
    }

    private fun displayAskForRatingDialog() {
        val askForRatingDialog = AlertDialog.Builder(this)
                .setTitle(R.string.ask_for_rating_dialog_title)
                .setMessage(R.string.ask_for_rating_dialog_message)
                .setIcon(R.drawable.ic_iconscout_star_24)
                .setPositiveButton(R.string.ask_for_rating_dialog_pos) { _, _ ->
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$packageName")))
                    } catch (e: ActivityNotFoundException) {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$packageName")))
                    }
                    setNextAskingTime(Long.MAX_VALUE)
                }
                .setNeutralButton(R.string.ask_for_rating_dialog_neu) { _, _ ->
                    setNextAskingTime(System.currentTimeMillis() + Constants.MS_THREE_DAYS)
                }
                .setNegativeButton(R.string.ask_for_rating_dialog_neg) { _, _ ->
                    setNextAskingTime(Long.MAX_VALUE)
                }
                .create()

        askForRatingDialog?.show()
        askForRatingDialog?.getButton(AlertDialog.BUTTON_NEGATIVE)?.setTextColor(ContextCompat.getColor(this.baseContext, R.color.grey_500))
        askForRatingDialog?.getButton(AlertDialog.BUTTON_NEUTRAL)?.setTextColor(ContextCompat.getColor(this.baseContext, R.color.grey_500))
    }

    private fun setNextAskingTime(time: Long) {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)
        val sharedPrefEditor = sharedPref?.edit()

        sharedPrefEditor?.apply {
            putLong(Constants.SHARED_PREFERENCES_KEY_TIME_TO_ASK_FOR_RATING, time)
            apply()
        }
    }

    private fun checkNextAskingTime(): Long {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)

        return sharedPref.getLong(
            Constants.SHARED_PREFERENCES_KEY_TIME_TO_ASK_FOR_RATING,
            0L
        )
    }

    private fun Activity.hideKeyboard() {
        hideKeyboard(currentFocus ?: View(this))
    }

    private fun Context.hideKeyboard(view: View) {
        val inputMethodManager = getSystemService(Activity.INPUT_METHOD_SERVICE) as InputMethodManager
        inputMethodManager.hideSoftInputFromWindow(view.windowToken, 0)
    }
}