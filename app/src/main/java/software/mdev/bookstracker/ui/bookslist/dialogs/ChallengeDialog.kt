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

            if (chosenBooksInt != null || chosenPagesInt != null) {
                year.yearChallengeBooks = chosenBooksInt
                year.yearChallengePagesCorrected = chosenPagesInt
                challengeDialogListener.onSaveButtonClicked(year)
                dismiss()
            } else {
                Snackbar.make(
                    it,
                    R.string.warning_challenge_difficulty_not_set,
                    Snackbar.LENGTH_SHORT
                ).show()
            }
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
        } else {
            etChallengeEditorBooksNumber.setText("0")
        }

        if (year.yearChallengePagesCorrected != null) {
            etChallengeEditorPagesNumber.setText(year.yearChallengePagesCorrected.toString())
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