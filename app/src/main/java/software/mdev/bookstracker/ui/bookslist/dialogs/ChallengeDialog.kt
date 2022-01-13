package software.mdev.bookstracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import software.mdev.bookstracker.R
import androidx.appcompat.app.AppCompatDialog
import com.google.android.material.slider.Slider
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.dialog_edit_challenge.*
import software.mdev.bookstracker.data.db.entities.Year
import kotlin.math.roundToInt


class ChallengeDialog(
    context: Context,
    var year: Year,
    var challengeDialogListener: ChallengeDialogListener
) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_edit_challenge)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        initViews()
        setOnCheckBoxListener()

        etChallengeEditorBooksNumber.requestFocus()
        etChallengeEditorBooksNumber.setSelection(etChallengeEditorBooksNumber.text.toString().length)

        btnChallengeEditorSet.setOnClickListener {
            val chosenBooks: String = etChallengeEditorBooksNumber.text.toString()
            val chosenPages: String = etChallengeEditorPagesNumber.text.toString()

            var chosenBooksInt: Int? = null
            var chosenPagesInt: Int? = null

            if (chosenBooks.isNotEmpty() && chosenBooks.toInt() > 0)
                chosenBooksInt = chosenBooks.toInt()

            if (chosenPages.isNotEmpty() && chosenPages.toInt() > 0 && cbPagesChallenge.isChecked)
                chosenPagesInt = chosenPages.toInt()

            year.yearChallengeBooks = chosenBooksInt
            year.yearChallengePagesCorrected = chosenPagesInt
            challengeDialogListener.onSaveButtonClicked(year)
            dismiss()
        }

        btnChallengeEditorCancel.setOnClickListener {
            dismiss()
        }

        slChallengeBooks.addOnChangeListener(Slider.OnChangeListener { _, value, _ ->
            etChallengeEditorBooksNumber.setText(value.toInt().toString())
            etChallengeEditorBooksNumber.requestFocus()
            etChallengeEditorBooksNumber.setSelection(etChallengeEditorBooksNumber.text.toString().length)
        })

        slChallengePages.addOnChangeListener(Slider.OnChangeListener { _, value, _ ->
            etChallengeEditorPagesNumber.setText(value.toInt().toString())
            etChallengeEditorPagesNumber.requestFocus()
            etChallengeEditorPagesNumber.setSelection(etChallengeEditorPagesNumber.text.toString().length)
        })
    }

    private fun initViews() {
        var string = context.applicationContext.getString(R.string.tvChallengeEditorTitle) + " " + year.year
        tvChallengeEditorTitle.text = string

        if (year.yearChallengeBooks != null) {
            etChallengeEditorBooksNumber.setText(year.yearChallengeBooks.toString())

            when {
                year.yearChallengeBooks!!.toFloat() > slChallengeBooks.valueTo ->
                    slChallengeBooks.value = slChallengeBooks.valueTo
                year.yearChallengeBooks!!.toFloat() < slChallengeBooks.valueFrom ->
                    slChallengeBooks.value = slChallengeBooks.valueFrom
                // Find a numbers closest to actual value
                (year.yearChallengeBooks!!.toFloat().mod(slChallengeBooks.stepSize) != 0F) -> {
                    val number = (year.yearChallengeBooks!!.toFloat() -
                            year.yearChallengeBooks!!.toFloat()
                                .mod(slChallengeBooks.stepSize))
                        .roundToInt()

                    slChallengeBooks.value = number.toFloat()
                }
                else ->
                    slChallengeBooks.value = year.yearChallengeBooks!!.toFloat()
            }
        } else {
            etChallengeEditorBooksNumber.setText("0")
        }

        if (year.yearChallengePagesCorrected != null) {
            etChallengeEditorPagesNumber.setText(year.yearChallengePagesCorrected.toString())

            when {
                year.yearChallengePagesCorrected!!.toFloat() > slChallengePages.valueTo ->
                    slChallengePages.value = slChallengePages.valueTo
                year.yearChallengePagesCorrected!!.toFloat() < slChallengePages.valueFrom ->
                    slChallengePages.value = slChallengePages.valueFrom
                // Find a numbers closest to actual value
                (year.yearChallengePagesCorrected!!.toFloat().mod(slChallengePages.stepSize) != 0F) -> {
                    val number = (year.yearChallengePagesCorrected!!.toFloat() -
                            year.yearChallengePagesCorrected!!.toFloat()
                                .mod(slChallengePages.stepSize))
                        .roundToInt()
                    slChallengePages.value = number.toFloat()
                }
                else ->
                    slChallengePages.value = year.yearChallengePagesCorrected!!.toFloat()
            }
        } else {
            etChallengeEditorPagesNumber.setText("0")
        }

        if (year.yearChallengePagesCorrected != null) {
            clPagesChallenge.visibility = View.VISIBLE
            cbPagesChallenge.isChecked = true
        }
        else {
            clPagesChallenge.visibility = View.GONE
            cbPagesChallenge.isChecked = false
        }
    }

    private fun setOnCheckBoxListener() {
        cbPagesChallenge.setOnClickListener {
            if (cbPagesChallenge.isChecked)
                clPagesChallenge.visibility = View.VISIBLE
            else
                clPagesChallenge.visibility = View.GONE
        }
    }
}