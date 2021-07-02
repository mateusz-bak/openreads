package software.mdev.bookstracker.ui.bookslist.dialogs

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import software.mdev.bookstracker.R
import androidx.appcompat.app.AppCompatDialog
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.dialog_filter_books.*
import software.mdev.bookstracker.adapters.YearsAdapter
import software.mdev.bookstracker.ui.bookslist.ListActivity


class FilterBooksDialog(
    var view: View,
    var filterBooksDialogListener: FilterBooksDialogListener,
    var years: Array<String>,
    var listActivity: ListActivity
) : AppCompatDialog(view.context) {

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_filter_books)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        val yearsAdapter = YearsAdapter(view.context, listActivity)
        rvYears.adapter = yearsAdapter
        rvYears.layoutManager = LinearLayoutManager(view.context)

        yearsAdapter.differ.submitList(years.toList())

        btnFilterExecute.setOnClickListener {
            filterBooksDialogListener.onSaveFilterButtonClicked()
            dismiss()
        }
    }
}
