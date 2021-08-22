package software.mdev.bookstracker.ui.bookslist.dialogs

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import software.mdev.bookstracker.R
import androidx.appcompat.app.AppCompatDialog
import kotlinx.android.synthetic.main.dialog_alert.*
import software.mdev.bookstracker.ui.bookslist.ListActivity


class AlertDialog(
    var view: View,
    var alertDialogListener: AlertDialogListener,
    var listActivity: ListActivity
) : AppCompatDialog(view.context) {

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_alert)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        btnOk.setOnClickListener {
            alertDialogListener.onOkButtonClicked(cbDontShowAgain.isChecked)
            dismiss()
        }
    }
}
