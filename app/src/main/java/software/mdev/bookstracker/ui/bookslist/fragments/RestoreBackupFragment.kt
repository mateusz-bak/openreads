package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.fragment_restore_backup.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.ListActivity
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.adapters.BackupAdapter
import java.io.File


class RestoreBackupFragment : Fragment(R.layout.fragment_restore_backup) {
    lateinit var backupAdapter: BackupAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val dbFile: File = (activity as ListActivity).baseContext.getDatabasePath("BooksDB.db")
        val files = File("/sdcard/Backup/BooksTracker").listFiles()

        setupRv(files)

        backupAdapter.setOnBackupClickListener {
            importDbBackupFromFile((activity as ListActivity), it)
        }
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

    private fun setupRv(files: Array<File>?) {
        backupAdapter = BackupAdapter(files)

        rvBackups.apply {
            adapter = backupAdapter
            layoutManager = LinearLayoutManager(context)
        }

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(
            rvBackups,
            OverScrollDecoratorHelper.ORIENTATION_VERTICAL
        )
    }

    private fun importDbBackupFromFile(activity: ListActivity, file: String) {
        when (Build.VERSION.SDK_INT) {
            in 1..28 -> importDbFromFileApi28AndLower(activity)
            29 -> importDbFromFileApi29(activity)
            30 -> importDbFromFileApi30(activity)
        }
    }

    private fun importDbFromFileApi28AndLower(activity: ListActivity) {
        Toast.makeText(activity.baseContext, R.string.notYetImplemented, Toast.LENGTH_SHORT).show()
    }

    private fun importDbFromFileApi29(activity: ListActivity) {
        Toast.makeText(activity.baseContext, R.string.api_29_not_yet_supported, Toast.LENGTH_SHORT).show()
    }

    private fun importDbFromFileApi30(activity: ListActivity) {
        Toast.makeText(activity.baseContext, R.string.api_30_not_yet_supported, Toast.LENGTH_SHORT).show()
    }
}