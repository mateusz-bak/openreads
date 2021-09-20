package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_backup.view.*
import software.mdev.bookstracker.R
import java.io.File


class BackupAdapter(
    private val files: Array<File>?
) : RecyclerView.Adapter<BackupAdapter.ViewPagerViewHolder>() {
    inner class ViewPagerViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewPagerViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_backup, parent, false)

        return ViewPagerViewHolder(view)
    }

    private var onBackupClickListener: ((String) -> Unit)? = null

    override fun onBindViewHolder(holder: ViewPagerViewHolder, position: Int) {
        holder.itemView.apply {
            tvBackup.text = files?.get(position)?.name

            setOnClickListener {
                val backup = files?.get(position)?.name

                if (backup != null) {
                    onBackupClickListener?.let { it1 -> it1(backup) }
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return files?.size ?: 0
    }

    fun setOnBackupClickListener(listener: (String) -> Unit) {
        onBackupClickListener = listener
    }
}